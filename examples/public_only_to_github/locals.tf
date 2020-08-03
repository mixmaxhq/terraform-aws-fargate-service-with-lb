module "global_constants" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-global-constants.git?ref=v3.0.0"
}

locals {
  aws_account_id    = module.global_constants.aws_account_id[var.environment]
  private_subnets   = module.global_constants.private_subnets[var.environment]
  public_subnets    = module.global_constants.public_subnets[var.environment]
  wildcard_cert_arn = module.global_constants.wildcard_cert_arn[var.environment]
}
