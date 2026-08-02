variable "name" {
  description = "Prefix for every resource created by the module."
  type        = string
  default     = "cloudfoundation"
}

variable "backup_schedule" {
  description = "Cron expression for the backup rule."
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "backup_retention_days" {
  description = "Retention in days of recovery points in the source vault."
  type        = number
  default     = 35
}

variable "start_window_minutes" {
  description = "Minutes a backup job can wait before starting."
  type        = number
  default     = 60
}

variable "completion_window_minutes" {
  description = "Minutes a backup job has to complete after starting."
  type        = number
  default     = 480
}

variable "cross_region_copy_retention_days" {
  description = "Retention in days of the cross-region copy in the DR vault."
  type        = number
  default     = 35
}

variable "cross_account_copy_retention_days" {
  description = "Retention in days of the cross-account copy in the central vault."
  type        = number
  default     = 90
}

variable "selection_tags" {
  description = "Tags AWS Backup uses to dynamically discover which resources join the backup plan. Matching is exact and case-sensitive, and every tag must be present on a resource (AND logic, not OR), so a partial match never selects a resource."
  type        = map(string)
  default = {
    ToBackup = "true"
  }
}

variable "vault_lock" {
  description = "Vault Lock settings applied to the three vaults. changeable_for_days switches the lock to compliance mode (immutable) once the grace period ends; set it to null to stay in governance mode."
  type = object({
    min_retention_days  = number
    max_retention_days  = number
    changeable_for_days = optional(number)
  })
  default = {
    min_retention_days  = 7
    max_retention_days  = 365
    changeable_for_days = 3
  }
}

variable "tags" {
  description = "Additional tags merged into the standard tag set applied to every resource."
  type        = map(string)
  default     = {}
}
