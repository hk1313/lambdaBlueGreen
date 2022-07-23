terraform {
  backend "s3" {
    bucket = "tfstate-23072022"
    key    = "lambdaBlueGreenDeploy/state.tfstate"
    region = "us-east-1"
  }
}