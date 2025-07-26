variable "aws_region" {
  description = "AWS region to deploy resources."
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as prefix in resource names."
  default     = "dml-temperature-analysis"
}

variable "use_existing_bucket" {
  description = "Set to true to use an existing S3 bucket instead of creating one."
  type        = bool
  default     = false
}

variable "existing_bucket_name" {
  description = "The name of the existing S3 bucket to use."
  type        = string
  default     = "dml-temperature-analysis-raw-data"
}