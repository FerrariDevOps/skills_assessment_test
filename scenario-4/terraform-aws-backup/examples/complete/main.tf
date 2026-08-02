provider "aws" {
  alias  = "prod_frankfurt"
  region = "eu-central-1"
  #   profile = "prod"
}

provider "aws" {
  alias  = "prod_ireland"
  region = "eu-west-1"
  #   profile = "prod"
}

provider "aws" {
  alias  = "backup_frankfurt"
  region = "eu-central-1"
  #   profile = "backup"
}

module "backup_policy" {
  source = "../.."

  providers = {
    aws.source  = aws.prod_frankfurt
    aws.dr      = aws.prod_ireland
    aws.central = aws.backup_frankfurt
  }

  name                              = "cloudfoundation"
  backup_schedule                   = "cron(0 2 * * ? *)"
  backup_retention_days             = 35
  cross_region_copy_retention_days  = 35
  cross_account_copy_retention_days = 90

  selection_tags = {
    ToBackup = "true"
    Owner    = "owner@eulerhermes.com"
  }

  vault_lock = {
    min_retention_days  = 7
    max_retention_days  = 365
    changeable_for_days = 3
  }

  tags = {
    Team = "cloudfoundation"
  }
}
