terraform {
  required_version = ">= 1.7.4"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.26"
      configuration_aliases = [aws.source, aws.dr, aws.central]
    }
  }
}
