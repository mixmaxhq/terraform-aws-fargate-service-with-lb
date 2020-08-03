module "web" {
  ## In a real service, use the following line instead of the relative source path:
  #source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service-with-lb.git?ref=vX.X.X"
  source      = "../.."
  environment = var.environment
  name        = var.name
  service     = var.service

  # Networking inputs
  tls_cert_arns   = [local.wildcard_cert_arn]
  service_subnets = local.private_subnets
  lb_subnets      = local.private_subnets

  # The default for the below value is 8080; if your container listens on that port
  # feel free to delete the below parameter.
  container_ports = [80]

  # See `gotchas` in the README for more about the following parameters
  # You almost certainly want to omit or change these values.
  container_name_override = "fargate-bootstrap-${var.environment}"
  task_definition         = module.fargate_bootstrap_task_definition.arn
}

module "fargate_bootstrap_task_definition" {
  source                   = "git@github.com:mixmaxhq/terraform-aws-ecs-task-definition?ref=v1.2.2"
  family                   = "fargate-bootstrap-${var.environment}"
  name                     = "fargate-bootstrap-${var.environment}"
  cpu                      = 256
  memory                   = 512
  image                    = "nginxdemos/hello"
  network_mode             = "awsvpc"
  portMappings             = [{ "containerPort" : 80 }]
  requires_compatibilities = ["FARGATE"]
  tags                     = { "Name" : "fargate-bootstrap", "Environment" : var.environment }
  execution_role_arn       = "arn:aws:iam::${local.aws_account_id}:role/ecsTaskExecutionRole"
}
