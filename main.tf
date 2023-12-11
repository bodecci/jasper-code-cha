
provider "archive" {}
data "archive_file" "deploy_zip_file" {
  type        = "zip"
  source_file = "index.py"
  output_path = "deployment-file.zip"
}

// create Lambda function
resource "aws_lambda_function" "hello_dillan" {
  function_name                  = var.function_name
  filename                       = data.archive_file.deploy_zip_file.output_path
  source_code_hash               = "${data.archive_file.deploy_zip_file.output_base64sha256}"
  role                           = aws_iam_role.lambda_exec_role.arn
  handler                        = "index.lambda_handler"
  runtime                        = "python3.8"
  timeout                        = var.timeout_seconds
  reserved_concurrent_executions = null
}

# Create an S3 bucket for the Lambda deployment package
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "jasper-lambda-challenge-bucket"

  tags = {
    Name        = "jasper-lambda-challenge-bucket"
    Environment = "Test"
  }
}

// create IAM role for Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

// attach IAM policy to Lambda execution role
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy"
  description = "Policy for Lambda execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "logs:CreateLogGroup",
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = "logs:CreateLogStream",
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = "logs:PutLogEvents",
        Effect   = "Allow",
        Resource = "*",
      },
      {
        "Effect" : "Allow",
        "Action" : ["s3:GetObject", "s3:ListBucket", "s3:PutBucketPolicy"],
        "Resource" : "arn:aws:s3:::lambda-challenge-bucket/*"
      },
    ],
  })
}

// attach IAM policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_exec_role_attachment" {
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

// grant CloudWatch Logs permission to invoke the Lambda function.
resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_dillan.function_name
  principal     = "logs.amazonaws.com"
}