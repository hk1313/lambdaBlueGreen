module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

  function_name          = "bluegreen-poc-${var.env}"
  description            = "Lambda function"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.9"
  source_path            = "./src"
  publish = true
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  
}

module "lambda_alias" {
  source = "terraform-aws-modules/lambda/aws//modules/alias"
  version = "3.3.1"
  depends_on = [module.lambda]
  refresh_alias = true

  name          = "current"
  function_name = module.lambda.lambda_function_name

  # Set function_version when creating alias to be able to deploy using it,
  # because AWS CodeDeploy doesn't understand $LATEST as CurrentVersion.
  function_version = module.lambda.lambda_function_version
}

/*   This block may require for ECS log group to check Error count as Lambda by default give Error count no longer require.
resource "aws_cloudwatch_log_metric_filter" "metric_filter" {
  name           = "bluegreen-poc-log-filter-${var.env}"
  pattern        = " ?\"ERROR\" ?\"Error\" ?\"error\" ?\"TIMEOUT\" ?\"Timeout\" ?\"timeout\" "
  log_group_name = module.lambda.lambda_cloudwatch_log_group_name

  metric_transformation {
    name      = "ErrorCount"
    namespace = "lambda_bluegreen_poc"
    value     = "1"
  }
}
*/

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  depends_on = [module.lambda]

  alarm_name                = "bluegreen-poc-${var.env}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  threshold                 = "1"
  alarm_description         = "This metric monitors error or timeout keyword "
  insufficient_data_actions = []

  metric_query {
    id = "e1"
    return_data = true
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = "180"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        FunctionName = module.lambda.lambda_function_name
      }
    }
  }
}

module "deploy" {
  depends_on = [module.lambda, module.lambda_alias]
  source = "terraform-aws-modules/lambda/aws//modules/deploy"
  version = "3.3.1"

  alias_name    = module.lambda_alias.lambda_alias_name
  function_name = module.lambda.lambda_function_name

  target_version = module.lambda.lambda_function_version

  alarm_enabled = true
  alarm_ignore_poll_alarm_failure  = false
  alarms = ["aws_cloudwatch_metric_alarm.metric_alarm.alarm_name"]

  create_app = true
  app_name   = "bluegreen-lambda-${var.env}"

  create_deployment_group = true
  deployment_group_name   = "bluegreen-lambda-${var.env}"
  deployment_config_name = var.lambda_deployment_type

  create_deployment          = true
  run_deployment             = true
  wait_deployment_completion = true

}