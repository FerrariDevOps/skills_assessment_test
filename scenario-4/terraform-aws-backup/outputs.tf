# Backup plan outputs
output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = aws_backup_plan.this.id
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = aws_backup_plan.this.arn
}

# Vault outputs
output "source_vault_arn" {
  description = "ARN of the source vault (Prod, Frankfurt)"
  value       = aws_backup_vault.source.arn
}

output "dr_vault_arn" {
  description = "ARN of the cross-region vault (Prod, Ireland)"
  value       = aws_backup_vault.dr.arn
}

output "central_vault_arn" {
  description = "ARN of the cross-account vault (Backup account, Frankfurt)"
  value       = aws_backup_vault.central.arn
}

# Backup service IAM outputs
output "backup_role_name" {
  description = "Name of the IAM role used by AWS Backup"
  value       = aws_iam_role.backup_role.name
}

output "backup_role_arn" {
  description = "ARN of the IAM role used by AWS Backup"
  value       = aws_iam_role.backup_role.arn
}
