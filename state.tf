terraform {
  backend "s3" {
    bucket = "tfstate-23072022"
    key    = "lambdaBlueGreen/state.tfstate"
    region = "us-east-1"
  }
}