terraform {
  backend "s3" {
    bucket         = "myproject-environment-account-tf-state"
    key            = "tf.tfstate"
    dynamodb_table = "myproject-environment-account-tf-state-dynamo-lock"
    region         = "us-east-1"
    profile        = "role-ENVIRONMENT"
  }
}