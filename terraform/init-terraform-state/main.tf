provider "aws" {
  region = var.aws_region
}

terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }
}
