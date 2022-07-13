resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_name
  description      = var.description
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  memory_size      = var.memory
  timeout          = var.timeout
  filename         = data.archive_file.source_zip.output_path
  source_code_hash = data.archive_file.source_zip.output_base64sha256
  layers           = ["${aws_lambda_layer_version.dependencies_layer.arn}"]
}


resource "aws_lambda_layer_version" "dependencies_layer" {
  filename         = data.archive_file.dependencies_zip.output_path
  layer_name       = "${var.lambda_name}-dependencies"
  source_code_hash = data.archive_file.dependencies_zip.output_base64sha256

  compatible_runtimes = [var.python_version]
}

output "lambda" {
  value = aws_lambda_function.lambda_function
}