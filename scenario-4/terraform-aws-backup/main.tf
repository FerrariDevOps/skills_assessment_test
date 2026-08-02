resource "aws_backup_plan" "this" {
  provider = aws.source
  name     = "${var.name}-backup-plan"
  tags     = local.tags

  rule {
    rule_name         = "${var.name}-daily"
    target_vault_name = aws_backup_vault.source.name
    schedule          = var.backup_schedule
    start_window      = var.start_window_minutes
    completion_window = var.completion_window_minutes

    lifecycle {
      delete_after = var.backup_retention_days
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.dr.arn

      lifecycle {
        delete_after = var.cross_region_copy_retention_days
      }
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.central.arn

      lifecycle {
        delete_after = var.cross_account_copy_retention_days
      }
    }
  }
}

resource "aws_backup_selection" "this" {
  provider     = aws.source
  name         = "${var.name}-tagged-resources"
  plan_id      = aws_backup_plan.this.id
  iam_role_arn = aws_iam_role.backup_role.arn
  resources    = ["*"]

  # condition entries are ANDed; selection_tag would OR them and select too much
  condition {
    dynamic "string_equals" {
      for_each = var.selection_tags

      content {
        key   = "aws:ResourceTag/${string_equals.key}"
        value = string_equals.value
      }
    }
  }
}
