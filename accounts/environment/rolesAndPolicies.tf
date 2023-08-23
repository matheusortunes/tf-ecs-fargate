#--------------------------------------------
# Deploy IAM Role
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/5.20.0
#--------------------------------------------

module "iam-role-cicd-ecs" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.20.0"

  role_name         = "CICD-Ecs-Role-${var.env}"
  role_description  = "Role CICD - Cross Account"
  create_role       = true
  role_requires_mfa = false

  trusted_role_arns = ["arn:aws:iam::${var.devops_account_id}:root"]

  custom_role_policy_arns = [
    module.iam-policy-ecs-access.arn
  ]

  tags = var.tags
}

#--------------------------------------------
# Deploy IAM Policy
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/5.20.0
#--------------------------------------------

module "iam-policy-ecs-access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.20.0"

  name = "ECSAccess"
  path = "/"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecs:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:Get*"
            ],
            "Resource": [
              "arn:aws:s3:::my-project-devops-codepipeline/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:ListBucket"
            ],
            "Resource": [
              "arn:aws:s3:::my-project-devops-codepipeline"
            ]
        },
        {
        "Effect": "Allow",
        "Action": [
           "kms:DescribeKey",
           "kms:GenerateDataKey*",
           "kms:Encrypt",
           "kms:ReEncrypt*",
           "kms:Decrypt"
          ],
        "Resource": [
           "arn:aws:kms:us-east-1:${var.devops_account_id}:key/*"
          ]
      }
    ]
}
EOT
}