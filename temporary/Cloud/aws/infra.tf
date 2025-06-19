terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.23.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DynamoDB Tables
resource "aws_dynamodb_table" "users" {
  name         = "user_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Name = "users"
  }
}

resource "aws_dynamodb_table" "notes" {
  name         = "notes_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "note_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "note_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  global_secondary_index {
    name            = "timestamp-index"
    hash_key        = "user_id"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  tags = {
    Name = "Notes"
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "notes_app_user_pool" {
  name = "notes_app_pool"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  auto_verified_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "note_app_client" {
  name         = "note_app_client"
  user_pool_id = aws_cognito_user_pool.notes_app_user_pool.id

  generate_secret             = false
  explicit_auth_flows         = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  supported_identity_providers = ["COGNITO"]
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "notes-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "notes-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.users.arn,
          aws_dynamodb_table.notes.arn,
          "${aws_dynamodb_table.notes.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda Functions
resource "aws_lambda_function" "auth_lambda" {
  filename      = "auth_lambda.zip"
  function_name = "notes-auth"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"
  runtime       = "provided.al2023"                  # Change from provided.al2023

  environment {
    variables = {
      USER_POOL_ID  = aws_cognito_user_pool.notes_app_user_pool.id
      CLIENT_ID     = aws_cognito_user_pool_client.note_app_client.id
      CLIENT_SECRET = aws_cognito_user_pool_client.note_app_client.client_secret
    }
  }
}

resource "aws_lambda_function" "note_lambda" {
  filename      = "notes_lambda.zip"
  function_name = "notes-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"
  runtime       = "provided.al2023"

  environment {
    variables = {
      USER_TABLE  = aws_dynamodb_table.users.name
      NOTES_TABLE = aws_dynamodb_table.notes.name
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "notes_api_gateway" {
  name        = "notes_api_gateway"
  description = "API for Notes AI Assistant"
}

# API Gateway Cognito Authorizer for /notes
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "cognito_authorizer"
  rest_api_id     = aws_api_gateway_rest_api.notes_api_gateway.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.notes_app_user_pool.arn]
  identity_source = "method.request.header.Authorization"
}

# API Resources: /login, /register, /notes
resource "aws_api_gateway_resource" "login_resource" {
  rest_api_id = aws_api_gateway_rest_api.notes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.notes_api_gateway.root_resource_id
  path_part   = "login"
}

resource "aws_api_gateway_resource" "register_resource" {
  rest_api_id = aws_api_gateway_rest_api.notes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.notes_api_gateway.root_resource_id
  path_part   = "register"
}

resource "aws_api_gateway_resource" "notes_resource" {
  rest_api_id = aws_api_gateway_rest_api.notes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.notes_api_gateway.root_resource_id
  path_part   = "notes"
}

# API Methods and Integration for /login
resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api_gateway.id
  resource_id   = aws_api_gateway_resource.login_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "login_integration" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api_gateway.id
  resource_id             = aws_api_gateway_resource.login_resource.id
  http_method             = aws_api_gateway_method.login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth_lambda.invoke_arn
}

# API Methods and Integration for /register
resource "aws_api_gateway_method" "register_post" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api_gateway.id
  resource_id   = aws_api_gateway_resource.register_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "register_integration" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api_gateway.id
  resource_id             = aws_api_gateway_resource.register_resource.id
  http_method             = aws_api_gateway_method.register_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth_lambda.invoke_arn
}

# API Methods and Integration for /notes (Protected by Cognito Authorizer)
resource "aws_api_gateway_method" "notes_post" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api_gateway.id
  resource_id   = aws_api_gateway_resource.notes_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_integration" "notes_integration" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api_gateway.id
  resource_id             = aws_api_gateway_resource.notes_resource.id
  http_method             = aws_api_gateway_method.notes_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.note_lambda.invoke_arn
}

# Lambda permissions to allow API Gateway invocation
resource "aws_lambda_permission" "auth_lambda_permission" {
  statement_id  = "AllowAuthLambdaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.notes_api_gateway.execution_arn}/*/*"
}

resource "aws_lambda_permission" "note_lambda_permission" {
  statement_id  = "AllowNoteLambdaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.note_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.notes_api_gateway.execution_arn}/*/*"
}

# API Gateway Deployment and Stage
resource "aws_api_gateway_deployment" "notes_deployment" {
  depends_on = [
    aws_api_gateway_integration.login_integration,
    aws_api_gateway_integration.register_integration,
    aws_api_gateway_integration.notes_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.notes_api_gateway.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.notes_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.notes_api_gateway.id
  stage_name    = var.stage_name
}

variable "aws_region" {
  default = "us-east-1"
}

variable "stage_name" {
  default = "prod"
}

output "api_invoke_url" {
  description = "Invoke URL for the API Gateway stage"
  value       = "https://${aws_api_gateway_rest_api.notes_api_gateway.id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}"
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.notes_app_user_pool.id
}

output "lambda_auth_arn" {
  description = "ARN of Auth Lambda"
  value       = aws_lambda_function.auth_lambda.arn
}
