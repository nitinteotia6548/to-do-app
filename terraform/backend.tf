terraform {
  backend "s3" {
    bucket = "the-server-samurai-s3"
    key    = "demo/terraform.tfstate"
    region = "ap-southeast-1"
  }
}