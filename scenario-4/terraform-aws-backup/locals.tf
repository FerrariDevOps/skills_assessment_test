locals {
  tags = merge(var.tags, {
    workload          = "backup"
    ManagedBy         = "terraform"
    github_repository = "terraform-aws-backup"
  })
}
