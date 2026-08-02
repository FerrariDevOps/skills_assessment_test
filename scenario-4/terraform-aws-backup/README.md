# terraform-aws-backup Module

This module implements an AWS Backup policy across three accounts, a daily
backup plan in a source account, a cross-region copy, and a cross-account
copy, each vault locked with AWS Backup Vault Lock.

## Usage

```hcl
module "backup_policy" {
  source = "./scenario-4/terraform-aws-backup"
  version = "0.0.0"

  providers = {
    aws.source  = aws.prod_frankfurt
    aws.dr      = aws.prod_ireland
    aws.central = aws.backup_frankfurt
  }

  name = "cloudfoundation"

  selection_tags = {
    ToBackup = "true"
    Owner    = "owner@eulerhermes.com"
  }
}
```

## Requirements

- Three provider configurations, the source account (Prod, Frankfurt), the
  cross-region account (Prod, Ireland), and the cross-account destination
  (Backup account, Frankfurt)
- The source and Backup accounts must belong to the same AWS Organizations
  organisation, cross-account copy is not possible otherwise
- The AWS Backup service opt-in enabled for the resource types being backed up,
  in the source account
- IAM permissions in each account to create KMS keys, backup vaults, an IAM
  role, and a vault policy

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :---: |
| `name` | Prefix for every resource created by the module | `string` | `"cloudfoundation"` | no |
| `backup_schedule` | Cron expression for the backup rule | `string` | `"cron(0 2 * * ? *)"` | no |
| `backup_retention_days` | Retention in days of recovery points in the source vault | `number` | `35` | no |
| `start_window_minutes` | Minutes a backup job can wait before starting | `number` | `60` | no |
| `completion_window_minutes` | Minutes a backup job has to complete after starting | `number` | `480` | no |
| `cross_region_copy_retention_days` | Retention in days of the cross-region copy in the DR vault | `number` | `35` | no |
| `cross_account_copy_retention_days` | Retention in days of the cross-account copy in the central vault | `number` | `90` | no |
| `selection_tags` | Tags AWS Backup uses to dynamically discover which resources join the backup plan. Matching is exact and case-sensitive, and every tag must be present (AND logic, not OR) | `map(string)` | `{ ToBackup = "true" }` | no |
| `vault_lock` | Vault Lock settings applied to the three vaults, `changeable_for_days` switches the lock to compliance mode once the grace period ends, set it to `null` to stay in governance mode | `object({...})` | see `variables.tf` | no |
| `tags` | Additional tags merged into the standard tag set applied to every resource | `map(string)` | `{}` | no |

## Outputs

### Backup Plan

| Name | Description |
| --- | --- |
| `backup_plan_id` | The ID of the backup plan |
| `backup_plan_arn` | The ARN of the backup plan |

### Vaults

| Name | Description |
| --- | --- |
| `source_vault_arn` | The ARN of the source vault (Prod, Frankfurt) |
| `dr_vault_arn` | The ARN of the cross-region vault (Prod, Ireland) |
| `central_vault_arn` | The ARN of the cross-account vault (Backup, Frankfurt) |

### IAM

| Name | Description |
| --- | --- |
| `backup_role_name` | The name of the IAM role assumed by AWS Backup |
| `backup_role_arn` | The ARN of the IAM role assumed by AWS Backup |

## Architecture

This module deploys the following components:

### Backup plan and selection

- One rule in the source account, on a configurable cron schedule
- Two `copy_action` blocks inside that rule, one cross-region and one
  cross-account, each with its own retention
- Resource selection by tag, using `condition` blocks so every tag in
  `selection_tags` must match (AND, not OR)

### Vaults and Vault Lock

- A source vault in Prod, Frankfurt, encrypted with a dedicated, auto-rotating
  KMS key
- A DR vault in Prod, Ireland, for the cross-region copy, with its own KMS key
- A central vault in the Backup account, Frankfurt, for the cross-account copy,
  with its own KMS key and a vault policy allowing `backup:CopyIntoBackupVault`
  from the source account
- Vault Lock (WORM) on all three, in compliance mode by default

### IAM role

- A service role assumed by AWS Backup, with the AWS managed policies for
  backup, restore, and the S3 variants of both

## Points worth knowing

- **Tag selection uses AND logic.** The requirement is `ToBackup=true` AND
  `Owner=<owner>`, so the selection uses `condition` blocks (combined with AND).
  `selection_tag` blocks are combined with OR and would select far more than
  intended. See [Assigning
  resources](https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html).
- **Vault Lock runs in compliance mode.** Because `changeable_for_days` is set,
  the lock becomes immutable once the grace period (3 days by default) expires,
  nobody, including root, can delete recovery points inside the retention window
  or remove the lock. Set `changeable_for_days = null` to keep the lock in
  governance mode instead. See [AWS Backup Vault
  Lock](https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html).
- **Cross-account copy prerequisites.** Both accounts must belong to the same
  AWS Organizations organisation, and the destination vault must use a customer
  managed KMS key (AWS managed keys cannot be shared across accounts). For
  resource types without full AWS Backup management, the source KMS key must
  also be shared with the destination account. See [Creating backup copies
  across AWS
  accounts](https://docs.aws.amazon.com/aws-backup/latest/devguide/create-cross-account-backup.html).
- **Locked vaults resist `terraform destroy`.** A vault with recovery points
  inside rejects deletion, AWS Backup returns "Backup vault cannot be deleted
  because it contains recovery points", so the destroy fails and the vault stays
  in state, managed and intact, nothing is left half-deleted. With the lock in
  compliance mode, not even `force_destroy` on `aws_backup_vault` gets past that
  inside the retention window, because deleting the recovery points themselves
  is what the lock denies. That is the point of the design, but keep it in mind
  in test environments.
