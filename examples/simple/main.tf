locals {
  environment = "staging"
  app_name    = "module-test"
  service     = "testing"
}

module "web" {
  ## In a real service, use the following line instead of the relative source path:
  #source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service-with-lb.git?ref=vX.X.X"
  source      = "../.."
  environment = local.environment
  name        = local.app_name
  service     = local.service

  # See `gotchas` for more about the following parameter
  # You almost certainly want to omit or change this value
  container_name_override = "fargate-bootstrap-${local.environment}"
}
