#--------------------------------------------
# Deploy IAM Role
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/5.20.0
#--------------------------------------------

module "iam-role-codepipeline" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.20.0"

  role_name         = "CodePipeline-ServiceRole"
  role_description  = "Role to CodePipeline"
  create_role       = true
  role_requires_mfa = false

  trusted_role_services = [
    "codepipeline.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.iam_policy_codepipeline.arn
  ]

  tags = var.tags
}
#--------------------------------------------
# Deploy IAM Policy
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/5.20.0
#--------------------------------------------

module "iam_policy_codepipeline" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.20.0"

  name        = "CodePipelinePolicy"
  path        = "/"
  description = "CodePipeline Assume Role Cross Account"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "iam:PassRole",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "AssumeRoleCodePipelineCrossAccount",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::${var.ENVIRONMENT_account_id}:role/CICD-Ecs-Role-ENVIRONMENT"
                
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${module.s3["codepipeline"].s3_bucket_arn}/*",
                "${module.s3["codepipeline"].s3_bucket_arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codecommit:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:*"
            ],
            "Resource": [
                "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.current.account_id}:project/ecs-environment-build-job"
            ]
        }
    ]
}
EOT
}