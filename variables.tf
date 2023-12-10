// set aws region 
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default = "us-east-1"
}

// set lambda function name
variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "HelloDillanFunction"
}

// set timeout for lambda function
variable "timeout_seconds" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 10
}

// set concurrency limit for lambda function to control the number of 
// concurrent executions of the Lambda function, 
// and manage access to downstream resources
variable "concurrency_limit" {
  description = "Concurrency limit for the Lambda function"
  type        = number
  default     = 5
}