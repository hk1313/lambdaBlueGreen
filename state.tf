terraform {
  backend "s3" {
    bucket = "tfstate-23072022"
    key    = "test/state.tfstate"
    region = "us-east-1"
  }
}