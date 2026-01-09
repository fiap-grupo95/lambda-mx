output "lambda_function_name" {
  value = aws_lambda_function.authorizer.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.authorizer.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.authorizer.invoke_arn
}
