resource "aws_kms_key" "source" {
  provider            = aws.source
  description         = "${var.name} backup vault key (source)"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "source" {
  provider      = aws.source
  name          = "alias/${var.name}-backup-source"
  target_key_id = aws_kms_key.source.key_id
}

resource "aws_kms_key" "dr" {
  provider            = aws.dr
  description         = "${var.name} backup vault key (cross-region DR)"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "dr" {
  provider      = aws.dr
  name          = "alias/${var.name}-backup-dr"
  target_key_id = aws_kms_key.dr.key_id
}

resource "aws_kms_key" "central" {
  provider            = aws.central
  description         = "${var.name} backup vault key (cross-account)"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "central" {
  provider      = aws.central
  name          = "alias/${var.name}-backup-central"
  target_key_id = aws_kms_key.central.key_id
}
