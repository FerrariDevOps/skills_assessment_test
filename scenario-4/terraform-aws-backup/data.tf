data "aws_caller_identity" "source" {
  provider = aws.source
}

# Backup service IAM permissions
data "aws_iam_policy_document" "backup_assume_role_policy" {
  provider = aws.source

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "backup" {
  provider = aws.source
  name     = "AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "restores" {
  provider = aws.source
  name     = "AWSBackupServiceRolePolicyForRestores"
}

data "aws_iam_policy" "s3_backup" {
  provider = aws.source
  name     = "AWSBackupServiceRolePolicyForS3Backup"
}

data "aws_iam_policy" "s3_restore" {
  provider = aws.source
  name     = "AWSBackupServiceRolePolicyForS3Restore"
}

# Cross-account copy permissions on the central vault
data "aws_iam_policy_document" "central_vault_policy" {
  provider = aws.central

  statement {
    sid       = "AllowCopyFromSourceAccount"
    effect    = "Allow"
    actions   = ["backup:CopyIntoBackupVault"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.source.account_id}:root"]
    }
  }
}
