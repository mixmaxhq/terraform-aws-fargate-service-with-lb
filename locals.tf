module "global_constants" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-global-constants.git?ref=v2.1.1"
}

locals {
  aws_account_id  = module.global_constants.aws_account_id[var.environment]
  aws_region      = module.global_constants.aws_region[var.environment]
  vpc_id          = module.global_constants.vpc_id[var.environment]
  env_name        = var.fargate_service_name_override == "" ? "${var.name}-${var.environment}" : var.fargate_service_name_override
  container_name  = var.container_name_override == "" ? local.env_name : var.container_name_override
  private_subnets = module.global_constants.private_subnets[var.environment]
  public_subnets  = module.global_constants.public_subnets[var.environment]
  lb_subnets      = var.is_public ? local.public_subnets : local.private_subnets
  bastion_sg_id   = module.global_constants.bastion_sg_id[var.environment]
  vpn_sg_id       = module.global_constants.vpn_sg_id[var.environment]
  lb_allowed_sgs  = concat([local.bastion_sg_id, local.vpn_sg_id], var.lb_allowed_sgs)
  cert_arn        = var.custom_tls_cert_arn != "" ? var.custom_tls_cert_arn : module.global_constants.wildcard_cert_arn[var.environment]
  default_tags = {
    "Environment" : var.environment
    "Name" : var.name
    "Service" : var.service
    "Public" : var.is_public
  }
  tags = merge(var.custom_tags, local.default_tags)
}
