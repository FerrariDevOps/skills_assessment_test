# Backup service IAM
resource "aws_iam_role" "backup_role" {
  provider           = aws.source
  name               = "${var.name}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  provider   = aws.source
  role       = aws_iam_role.backup_role.name
  policy_arn = data.aws_iam_policy.backup.arn
}

resource "aws_iam_role_policy_attachment" "restores" {
  provider   = aws.source
  role       = aws_iam_role.backup_role.name
  policy_arn = data.aws_iam_policy.restores.arn
}

resource "aws_iam_role_policy_attachment" "s3_backup" {
  provider   = aws.source
  role       = aws_iam_role.backup_role.name
  policy_arn = data.aws_iam_policy.s3_backup.arn
}

resource "aws_iam_role_policy_attachment" "s3_restore" {
  provider   = aws.source
  role       = aws_iam_role.backup_role.name
  policy_arn = data.aws_iam_policy.s3_restore.arn
}
