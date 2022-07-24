env = "dev"
aws_region = "us-east-1"
cloudwatch_logs_retention_in_days = 1  # For prod, it should be different
lambda_deployment_type = "CodeDeployDefault.LambdaAllAtOnce"  # "CodeDeployDefault.LambdaAllAtOnce  CodeDeployDefault.LambdaLinear10PercentEvery1Minute"