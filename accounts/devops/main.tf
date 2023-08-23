#--------------------------------------------
# Deploy S3 
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/3.10.1
#--------------------------------------------
module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.1"

  for_each = var.s3

  bucket = "${var.project_name}-${var.env}-${each.key}"

  versioning = {
    enabled = false
  }
  attach_policy = true
  policy        = <<EOT
 {
  "Version": "2012-10-17",
  "Id": "SSEAndSSLPolicy",
  "Statement": [
	{
  	"Sid": "DenyUnEncryptedObjectUploads",
	  "Effect": "Deny",
	  "Principal": "*",
	  "Action": "s3:PutObject",
	  "Resource": "arn:aws:s3:::${var.project_name}-${var.env}-${each.key}/*",
	  "Condition": {
		"StringNotEquals": {
		"s3:x-amz-server-side-encryption": "aws:kms"
		}
	   }
	 },
	{
	  "Sid": "DenyInsecureConnections",
	  "Effect": "Deny",
	  "Principal": "*",
	  "Action": "s3:*",
	  "Resource": "arn:aws:s3:::${var.project_name}-${var.env}-${each.key}/*",
	  "Condition": {
		"Bool": {
	  		"aws:SecureTransport": false
			}
		}
	  },
	{
	  "Sid": "",
	  "Effect": "Allow",
	  "Principal": {
    "AWS": [
       "arn:aws:iam::${var.environment_account_id}:root"
    ]
		},
	  "Action": [
            "s3:Get*",
            "s3:Put*"
        ],
	  "Resource": "arn:aws:s3:::${var.project_name}-${var.env}-${each.key}/*"
	},
	{
	  "Sid": "",
	  "Effect": "Allow",
	  "Principal": {
	      "AWS": [
            "arn:aws:iam::${var.environment_account_id}:root"
        ]
		},
	  "Action": "s3:ListBucket",
  	"Resource": "arn:aws:s3:::${var.project_name}-${var.env}-${each.key}"
	}
   ]
}
EOT

  force_destroy = true

  tags = var.tags
}

#--------------------------------------------
# Deploy CodeCommit Repos
#--------------------------------------------

module "codecommit_repositories" {
  source = "../../modules/codecommit-repository"

  for_each        = var.repositories
  repository_name = each.key
  description     = each.value.description
}

module "codecommit_approval_templates" {
  source = "../../modules/codecommit-approval-templates"

  for_each                      = local.approval_templates
  approval_template_name        = each.key
  repository_name               = each.value.repository_name
  description                   = each.value.description
  approval_template_description = each.value.approval_template_description
  content                       = each.value.content
}

#--------------------------------------------
# Deploy Pipeline Resorces
#--------------------------------------------

module "codebuild_projects" {
  source = "../../modules/codebuild-project"

  for_each = var.build-projects

  codebuild_project_name = each.key
  description            = each.value.description
  codebuild_service_role = module.iam-role-codebuild.iam_role_arn
  buildspec_path         = "../../accounts/${var.env}/buildspec/${each.value.buildspec_file}"
  compute_type           = each.value.compute_type
  image                  = each.value.image
  type                   = each.value.type
  privileged             = each.value.privileged

  tags = var.tags
}

module "codepipeline_ecs" {
  source = "../../modules/codepipeline-ecs"

  for_each = var.pipelines-ecs

  codepipeline_name      = each.key
  role_arn               = module.iam-role-codepipeline.iam_role_arn
  bucket                 = module.s3["codepipeline"].s3_bucket_id
  repository_name        = module.codecommit_repositories["${each.value.repo_name}"].name
  branch                 = each.value.branch
  codebuild_project_name = module.codebuild_projects["${each.value.build_project}"].name
  env                    = each.value.env
  service_name           = each.value.service_name
  assume_role            = each.value.assume_role
  kms_arn                = module.kms.key_arn

  tags = var.tags
}

# --------------------------------------------
# Deploy ECR Registry
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/1.6.0
# --------------------------------------------

module "ecr_registry" {
  source = "terraform-aws-modules/ecr/aws"

  for_each = toset(var.ecr)

  repository_name                 = each.value
  repository_type                 = "private"
  repository_image_tag_mutability = "MUTABLE"

  create_repository_policy = false
  repository_policy        = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPullCrossAccount",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.environment_account_id}:root"
        ]
      },
      "Action": [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
EOT
  attach_repository_policy = true

  create_lifecycle_policy = false
  #   repository_lifecycle_policy = jsonencode({
  #     rules = [
  #       {
  #         rulePriority = 1,
  #         description  = "Keep last 60 images",
  #         selection = {
  #           tagStatus     = "tagged",
  #           tagPrefixList = ["v"],
  #           countType     = "imageCountMoreThan",
  #           countNumber   = 60
  #         },
  #         action = {
  #           type = "expire"
  #         }
  #       }
  #     ]
  #   })

  # Registry Scanning Configuration
  manage_registry_scanning_configuration = true
  registry_scan_type                     = "ENHANCED"
  registry_scan_rules = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter         = "*"
      filter_type    = "WILDCARD"
    }
  ]

  # Registry Replication Configuration
  create_registry_replication_configuration = false
  # registry_replication_rules = [
  #   {
  #     destinations = [{
  #       region      = "us-east-2"
  #       registry_id = data.aws_caller_identity.current.account_id
  #     }]
  #   }
  # ]

  tags = var.tags
}

# --------------------------------------------
# Deploy KMS Customer Key
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/kms/aws/1.5.0
# --------------------------------------------

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  description = "Codepipeline key usage"
  key_usage   = "ENCRYPT_DECRYPT"

  key_users = [
    "arn:aws:iam::${var.environment_account_id}:role/CICD-Ecs-Role-ENVIRONMENT",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CodePipeline-ServiceRole",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CodeBuild-ServiceRole"
  ]
  #key_service_users  = ["arn:aws:iam::${var.environment_account_id}:role/CICD-Ecs-Role-ENVIRONMENT"]

  # Aliases
  aliases = ["my-project/cicd"]

  tags = var.tags
}