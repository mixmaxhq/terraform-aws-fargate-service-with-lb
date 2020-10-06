module "fargate_service" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service.git?ref=v3.3.0"

  name            = var.name
  environment     = var.environment
  service         = var.service
  is_public       = var.is_public
  custom_tags     = var.custom_tags
  task_definition = var.task_definition
  min_capacity    = var.min_capacity
  max_capacity    = var.max_capacity
  service_subnets = var.service_subnets

  cpu_scaling_enabled = var.cpu_scaling_enabled
  cpu_high_threshold  = var.cpu_high_threshold
  cpu_low_threshold   = var.cpu_low_threshold

  cloudwatch_evaluation_periods = var.cloudwatch_evaluation_periods

  fargate_service_name_override = var.fargate_service_name_override
  health_check_grace_period     = var.health_check_grace_period
  deployment_maximum_percent    = var.deployment_maximum_percent

  load_balancer_config = concat([
    for port in var.container_ports :
    {
      target_group_arn = module.alb.target_group_arns[0]
      container_name   = local.container_name
      container_port   = port
    }
    ],
    var.extra_load_balancer_configs
  )

  capacity_provider_strategies = var.capacity_provider_strategies
}

## Allow loadbalancer inbound to task on container port(s)
resource "aws_security_group_rule" "task_inbound" {
  count             = length(var.container_ports)
  security_group_id = module.fargate_service.task_sg_id

  type      = "ingress"
  from_port = var.container_ports[count.index]
  to_port   = var.container_ports[count.index]
  protocol  = "tcp"

  source_security_group_id = aws_security_group.lb.id
}

## Load Balancer Security Group
resource "aws_security_group" "lb" {
  name        = "${local.env_name}-lb-sg"
  description = "Security group for ${local.env_name} load balancer"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "Name" : "${local.env_name}-lb-sg" })
}

resource "aws_security_group_rule" "public_load_balancer_80_rule" {
  count             = var.is_public && var.set_public_sg_rule ? 1 : 0
  security_group_id = aws_security_group.lb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_load_balancer_443_rule" {
  count             = var.is_public && var.set_public_sg_rule ? 1 : 0
  security_group_id = aws_security_group.lb.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "load_balancer_80_rule_for_sgs" {
  count             = length(var.lb_allowed_sgs)
  security_group_id = aws_security_group.lb.id

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  source_security_group_id = var.lb_allowed_sgs[count.index]
}

resource "aws_security_group_rule" "load_balancer_443_rule_for_sgs" {
  count             = length(var.lb_allowed_sgs)
  security_group_id = aws_security_group.lb.id

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = var.lb_allowed_sgs[count.index]
}

module "alb" {
  source = "git::ssh://git@github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v5.8.0"

  name = "${local.env_name}"

  load_balancer_type = "application"

  vpc_id          = local.vpc_id
  subnets         = var.lb_subnets
  security_groups = [aws_security_group.lb.id]
  internal        = var.is_public ? false : true
  idle_timeout    = var.idle_timeout

  load_balancer_create_timeout = "20m"
  load_balancer_update_timeout = "20m"
  listener_ssl_policy_default  = "ELBSecurityPolicy-TLS-1-2-2017-01"

  access_logs = {
    bucket = "mixmax-lb-logs-${var.environment}"
    prefix = local.env_name
  }

  target_groups = [
    for port in var.container_ports :
    {
      name                 = "${local.env_name}-${port}"
      backend_protocol     = "HTTP"
      backend_port         = port
      target_type          = "ip"
      deregistration_delay = 60
      slow_start           = var.task_traffic_slow_start

      load_balancing_algorithm_type = var.load_balancing_algorithm_type

      health_check = {
        path    = var.health_check_path
        matcher = "200-299" # the HTTP status codes from the health check endpoint to consider "healthy"
      }
    }
  ]

  https_listeners = [
    {
      port     = 443
      protocol = "HTTPS"
      # We validate in the variable declaration that we have at least one certificate ARN provided to us.
      certificate_arn    = var.tls_cert_arns[0]
      target_group_index = 0
    }
  ]

  extra_ssl_certs = [
    for cert_arn in slice(var.tls_cert_arns, 1, length(var.tls_cert_arns)) :
    {
      certificate_arn      = cert_arn
      https_listener_index = 0
    }
  ]

  tags = local.tags
}

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = module.alb.this_lb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
