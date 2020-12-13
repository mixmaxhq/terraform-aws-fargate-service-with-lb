output "task_role_arn" {
  description = "The ARN of the IAM Role created for the Fargate service"
  value       = module.fargate_service.task_role_arn
}

output "task_role_name" {
  description = "The name of the IAM Role created for the Fargate service"
  value       = module.fargate_service.task_role_name
}

output "task_sg_id" {
  description = "The ID of the Security Group attached to the ECS tasks"
  value       = module.fargate_service.task_sg_id
}

output "lb_sg_id" {
  description = "The ID of the Security Group attached to the LB"
  value       = aws_security_group.lb.id
}

output "alb_dns_name" {
  description = "The DNS name of the created ALB. Useful for creating a CNAME from mixmax.com DNS names."
  value       = module.alb.this_lb_dns_name
}

output "zone_id" {
  description = "The Zone ID that the ALB resides in. Useful for creating Route53 records with failover behaviour."
  value       = module.alb.this_lb_zone_id
}

output "alb_arn" {
  description = "The ARN of the created ALB"
  value       = module.alb.this_lb_arn
}

output "alb_listener_arn" {
  description = "The ARN of the HTTPS ALB listener"
  value       = module.alb.https_listener_arns[0]
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = module.fargate_service.cloudwatch_log_group_name
}

output "lb_arn_suffix" {
  description = "The ARN suffix of the application load balancer. Useful for Cloudwatch alarms"
  value       = module.alb.this_lb_arn_suffix
}

# As of now, this module only creates one target group; thus we only emit the first item of the list.
output "tg_arn" {
  description = "The ARN of the target group in the application load balancer."
  value       = module.alb.target_group_arns[0]
}

output "tg_arn_suffix" {
  description = "The ARN suffixes of the target group in the application load balancer. Useful for Cloudwatch alarms"
  value       = module.alb.target_group_arn_suffixes[0]
}
