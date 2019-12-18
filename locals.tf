module "global_constants" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-global-constants.git?ref=v1.2.1"
}

locals {
  aws_account_id  = module.global_constants.aws_account_id[var.environment]
  aws_region      = module.global_constants.aws_region[var.environment]
  vpc_id          = module.global_constants.vpc_id[var.environment]
  env_name        = "${var.name}-${var.environment}"
  private_subnets = module.global_constants.private_subnets[var.environment]
  public_subnets  = module.global_constants.public_subnets[var.environment]
  lb_subnets      = var.is_public ? local.public_subnets : local.private_subnets
  lb_allowed_sgs  = concat([module.global_constants.bastion_sg_id[var.environment]], var.lb_allowed_sgs)
  cert_arn        = module.global_constants.wildcard_cert_arn[var.environment]
  ecs_cluster     = "arn:aws:ecs:${local.aws_region}:${local.aws_account_id}:cluster/default" # change me later
  default_tags = {
    "Environment" : var.environment
    "App name" : var.name
    "Public" : var.is_public
  }
  tags = merge(local.default_tags, var.custom_tags)
}
