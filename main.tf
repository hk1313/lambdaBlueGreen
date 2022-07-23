module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

  function_name          = "deploy-lambda-bluegreen-poc-${var.env}"
  description            = "Lambda function"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.9"
  source_path            = "./src"

  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days 
  
}

module "lambda_alias" {
  source = "terraform-aws-modules/lambda/aws//modules/alias"

  depends_on = [module.lambda]
  refresh_alias = true

  name          = "current"
  function_name = module.lambda.lambda_function_name

  # Set function_version when creating alias to be able to deploy using it,
  # because AWS CodeDeploy doesn't understand $LATEST as CurrentVersion.
  function_version = module.lambda.lambda_function_version
}

module "deploy" {
  depends_on = [module.lambda, module.lambda_alias]
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name    = module.lambda_alias.lambda_alias_name
  function_name = module.lambda.lambda_function_name

  target_version = module.lambda.lambda_function_version

  create_app = true
  app_name   = "codedeploy-app-bluegreen-lambda-${var.env}"

  create_deployment_group = true
  deployment_group_name   = "codedeploy-deployment-group-bluegreen-lambda-${var.env}"
  deployment_config_name = var.lambda_deployment_type

  create_deployment          = true
  run_deployment             = true
  wait_deployment_completion = true

}