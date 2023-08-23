#-------------------------------------------------------------
# Deploy S3 bucket to keep terraform state. Run only-once
#-------------------------------------------------------------

module "terraform_backend_state" {
  source = "../../../modules/remote-state"
  name   = "devops-account-tf-state"

  s3_versioning = true

  tags = {
    "project"   = "my-project"
    "terraform" = "true"
    "env"       = "devops"
  }
}