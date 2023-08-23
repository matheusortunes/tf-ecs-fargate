variable "name" {
  type        = string
  description = "Bucket Name - Should be Unique for a region!"
}

variable "s3_versioning" {
  type        = bool
  default     = true
  description = "Whether enable S3 versioning"
}

variable "state_lock" {
  type        = bool
  default     = true
  description = "Whether create a Dynamo db table"
}

variable "tags" {
  type = map(string)
}