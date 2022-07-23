terraform {
  backend "s3" {
    bucket = "tfstate-23072022"
    key    = "lambdaBlueGreenPoc/state.tfstate"
    region = "us-east-1"
  }
}