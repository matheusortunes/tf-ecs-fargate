#-------------------------------------------------------------
# Deploy S3 bucket to keep terraform state. Run only-once
#-------------------------------------------------------------

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.name

  tags = merge(
    { Name = "${var.name}" },
    var.tags
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = (var.s3_versioning ? "Enabled" : "Disabled")
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  count          = var.state_lock ? 1 : 0
  name           = "${var.name}-dynamo-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}