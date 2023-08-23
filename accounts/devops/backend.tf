terraform {
  backend "s3" {
    bucket         = "myproject-devops-account-tf-state"
    key            = "tf.tfstate"
    dynamodb_table = "myproject-devops-account-tf-state-dynamo-lock"
    region         = "us-east-1"
    profile        = "role-devops"
  }
}