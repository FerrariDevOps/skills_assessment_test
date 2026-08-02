# Source vault (Prod, Frankfurt)
resource "aws_backup_vault" "source" {
  provider    = aws.source
  name        = "${var.name}-vault-source"
  kms_key_arn = aws_kms_key.source.arn
  tags        = local.tags
}

# Cross-region copy vault (Prod, Ireland)
resource "aws_backup_vault" "dr" {
  provider    = aws.dr
  name        = "${var.name}-vault-dr"
  kms_key_arn = aws_kms_key.dr.arn
  tags        = local.tags
}

# Cross-account copy vault (Backup account, Frankfurt)
resource "aws_backup_vault" "central" {
  provider    = aws.central
  name        = "${var.name}-vault-central"
  kms_key_arn = aws_kms_key.central.arn
  tags        = local.tags
}

resource "aws_backup_vault_lock_configuration" "source" {
  provider            = aws.source
  backup_vault_name   = aws_backup_vault.source.name
  min_retention_days  = var.vault_lock.min_retention_days
  max_retention_days  = var.vault_lock.max_retention_days
  changeable_for_days = var.vault_lock.changeable_for_days
}

resource "aws_backup_vault_lock_configuration" "dr" {
  provider            = aws.dr
  backup_vault_name   = aws_backup_vault.dr.name
  min_retention_days  = var.vault_lock.min_retention_days
  max_retention_days  = var.vault_lock.max_retention_days
  changeable_for_days = var.vault_lock.changeable_for_days
}

resource "aws_backup_vault_lock_configuration" "central" {
  provider            = aws.central
  backup_vault_name   = aws_backup_vault.central.name
  min_retention_days  = var.vault_lock.min_retention_days
  max_retention_days  = var.vault_lock.max_retention_days
  changeable_for_days = var.vault_lock.changeable_for_days
}

resource "aws_backup_vault_policy" "central" {
  provider          = aws.central
  backup_vault_name = aws_backup_vault.central.name
  policy            = data.aws_iam_policy_document.central_vault_policy.json
}
