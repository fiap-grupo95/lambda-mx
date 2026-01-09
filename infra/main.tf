terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "archive_file" "authorizer_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/authorizer.py"
  output_path = "${path.module}/lambda/authorizer.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "authorizer" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "authorizer" {
  function_name    = var.lambda_function_name
  handler          = "authorizer.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.authorizer_zip.output_path
  source_code_hash = data.archive_file.authorizer_zip.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      JWT_SECRET = var.jwt_secret
      JWT_ALGO   = var.jwt_algo
    }
  }

  tags = var.tags
}

locals {
  has_invoke_arn = length(trimspace(var.authorizer_invoke_arn)) > 0
}

resource "aws_lambda_permission" "apigw_invoke" {
  count         = local.has_invoke_arn ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.authorizer_invoke_arn
}
