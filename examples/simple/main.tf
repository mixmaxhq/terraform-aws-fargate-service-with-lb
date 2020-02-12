module "web" {
  ## In a real service, use the following line instead of the relative source path:
  #source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service-with-lb.git?ref=vX.X.X"
  source      = "../.."
  environment = var.environment
  name        = var.name
  service     = var.service

  # See `gotchas` in the README for more about the following parameter
  # You almost certainly want to omit or change this value
  container_name_override = "fargate-bootstrap-${var.environment}"
}
