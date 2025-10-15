resource "aws_iam_role" "lambda_edge_role" {
  name = "lambda-edge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_edge_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.js"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_lambda_function" "add_header" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "add-header-lambda-edge"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  publish          = true
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  lifecycle {
    prevent_destroy = false
  }
  timeouts {
    delete = "30m"
  }
}
