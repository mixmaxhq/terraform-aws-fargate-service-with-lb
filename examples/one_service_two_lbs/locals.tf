module "global_constants" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-global-constants.git?ref=v1.4.0"
}

locals {
  aws_account_id  = module.global_constants.aws_account_id[var.environment]
  vpc_id          = module.global_constants.vpc_id[var.environment]
  private_subnets = module.global_constants.private_subnets[var.environment]
  cert_arn        = module.global_constants.wildcard_cert_arn[var.environment]
}
