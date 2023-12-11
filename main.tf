// create Lambda function
resource "aws_lambda_function" "hello_dillan" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  filename         = "deployment-file.zip"
  timeout          = var.timeout_seconds
  reserved_concurrent_executions = var.concurrency_limit

  source_code_hash = filebase64("${path.module}/lambda/index.js")
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