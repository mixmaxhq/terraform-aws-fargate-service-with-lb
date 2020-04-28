module "global_constants" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-global-constants.git?ref=v1.4.0"
}

locals {
  aws_account_id = module.global_constants.aws_account_id[var.environment]
}
