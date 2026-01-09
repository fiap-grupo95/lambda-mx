variable "aws_region" {
  description = "AWS region for Lambda deployment"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "mecanica-xpto-authorizer"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 5
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "jwt_secret" {
  description = "JWT secret used for HS256 validation"
  type        = string
  default     = ""
  sensitive   = true
}

variable "jwt_algo" {
  description = "JWT algorithm"
  type        = string
  default     = "HS256"
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 7
}

variable "authorizer_invoke_arn" {
  description = "Optional API Gateway invoke ARN that can call the Lambda"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to AWS resources"
  type        = map(string)
  default = {
    Project = "lambda-mx"
  }
}
