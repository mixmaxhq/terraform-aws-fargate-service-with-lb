locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.region.name
  vpc_id         = data.aws_subnet.subnet.vpc_id
  env_name       = var.fargate_service_name_override == "" ? "${var.name}-${var.environment}" : var.fargate_service_name_override
  container_name = var.container_name_override == "" ? local.env_name : var.container_name_override
  default_tags = {
    "Environment" : var.environment
    "Name" : var.name
    "Service" : var.service
    "Public" : var.is_public
  }
  tags = merge(var.custom_tags, local.default_tags)
}

# We use this to find the VPC ID. We use the first entry
# as a representative sample of the rest.
data "aws_subnet" "subnet" {
  id = var.service_subnets[0]
}

# Expose the account ID
data "aws_caller_identity" "current" {}

# Expose the region
data "aws_region" "region" {}
