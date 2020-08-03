## In this example, one load balancer is created by the module itself.
## Another is created outside the module and its details fed into the 
## module's `extra_load_balancer_configs`. Keep in mind that this load
## balancer is manually managed; it contains no monitoring, no permanent
## redirect to HTTPS from port 80, no security groups allowing traffic
## inbound, no tags - ie, this is hard mode and you are now responsible
## for all these details 😈 You are absolutely REQUIRED to add tags &
## monitoring; future tooling may do scary things to your infrastructure
## if you do not. A minimal set of tags has been added to the ALB for
## your convenience.

module "web" {
  ## In a real service, use the following line instead of the relative source path:
  #source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service-with-lb.git?ref=vX.X.X"
  source      = "../.."
  environment = var.environment
  name        = var.name
  service     = var.service

  # The default for the below value is 8080; if your container listens on that port
  # feel free to delete the below parameter.
  container_ports = [80]

  # Networking inputs
  service_subnets = local.private_subnets
  lb_subnets      = local.private_subnets
  tls_cert_arns   = [local.cert_arn]

  # Here we feed in details of the ALB that's configured below this module
  extra_load_balancer_configs = [
    {
      target_group_arn = module.alb.target_group_arns[0]
      container_name   = "fargate-bootstrap-${var.environment}"
      container_port   = 80
    }
  ]

  # See `gotchas` in the README for more about the following parameters
  # You almost certainly want to omit or change these values.
  container_name_override = "fargate-bootstrap-${var.environment}"
  task_definition         = module.fargate_bootstrap_task_definition.arn
}

module "alb" {
  source = "git::ssh://git@github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v5.0.0"

  name = "${var.name}-2-${var.environment}"

  load_balancer_type = "application"

  vpc_id          = local.vpc_id
  subnets         = local.private_subnets
  security_groups = []
  internal        = true

  load_balancer_create_timeout = "20m"
  load_balancer_update_timeout = "20m"

  access_logs = {
    bucket = "mixmax-lb-logs-${var.environment}"
    prefix = "${var.name}-${var.environment}"
  }

  target_groups = [
    {
      name                 = "${var.name}-${var.environment}-80"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
      deregistration_delay = 60
      slow_start           = 30

      health_check = {
        path    = "/"
        matcher = "200-299" # the HTTP status codes from the health check endpoint to consider "healthy"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.cert_arn
      target_group_index = 0
    }
  ]

  tags = {
    Name        = "${var.name}-2-${var.environment}"
    Environment = var.environment
    Service     = var.service
    Public      = "false"
  }
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
