provider "aws" {
  region = "eu-west-2"
}

resource "aws_iam_role" "lambda_exec" {
  name = "smart-vault-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid     = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ec2_snapshot_access" {
  name = "ec2-snapshot-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:CreateSnapshot",
          "ec2:DescribeVolumes",
          "ec2:CreateTags"
        ],
        Resource = "*"
      }
    ]
  })
}


# Lambda function resource will go here

resource "aws_lambda_function" "snapshot_lambda" {
  function_name = "smart-vault-snapshot"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/lambda/function.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")
}


# EventBridge + Snapshot logic will come next

resource "aws_cloudwatch_event_rule" "snapshot_schedule" {
  name                = "snapshot-schedule"
  schedule_expression = "cron(0 3 * * ? *)" # Runs daily at 03:00 UTC
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.snapshot_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.snapshot_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.snapshot_schedule.arn
}

