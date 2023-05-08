terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.19.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["/Users/asanchez/.aws/config"]
  shared_credentials_files = ["/Users/asanchez/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-1"
}
