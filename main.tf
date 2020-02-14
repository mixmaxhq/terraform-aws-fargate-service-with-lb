module "fargate_service" {
  source = "git::ssh://git@github.com/mixmaxhq/terraform-aws-fargate-service.git?ref=v1.1.0"

  name            = var.name
  environment     = var.environment
  service         = var.service
  is_public       = var.is_public
  custom_tags     = var.custom_tags
  task_definition = var.task_definition
  load_balancer_config = [
    for port in var.container_ports :
    {
      target_group_arn = module.alb.target_group_arns[0]
      container_name   = local.container_name
      container_port   = port
    }
  ]
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
  count             = var.is_public ? 1 : 0
  security_group_id = aws_security_group.lb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "public_load_balancer_443_rule" {
  count             = var.is_public ? 1 : 0
  security_group_id = aws_security_group.lb.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "load_balancer_80_rule_for_sgs" {
  count             = length(local.lb_allowed_sgs)
  security_group_id = aws_security_group.lb.id

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  source_security_group_id = local.lb_allowed_sgs[count.index]
}

resource "aws_security_group_rule" "load_balancer_443_rule_for_sgs" {
  count             = length(local.lb_allowed_sgs)
  security_group_id = aws_security_group.lb.id

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = local.lb_allowed_sgs[count.index]
}

module "alb" {
  source = "git::ssh://git@github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v5.0.0"

  name = "${local.env_name}"

  load_balancer_type = "application"

  vpc_id          = local.vpc_id
  subnets         = local.lb_subnets
  security_groups = [aws_security_group.lb.id]
  internal        = var.is_public ? false : true

  target_groups = [
    for port in var.container_ports :
    {
      name                 = "${local.env_name}-${port}"
      backend_protocol     = "HTTP"
      backend_port         = port
      target_type          = "ip"
      deregistration_delay = 60

      health_check = {
        path    = var.health_check_path
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
