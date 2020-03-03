variable "name" {
  description = "The name of the application to launch"
  type        = string
}

variable "environment" {
  description = "The environment to deploy into. Some valid values are production, staging, engineering."
  type        = string
}

variable "service" {
  description = "The name of the service this application is associated with, ie 'send' if the application is 'send-worker'"
  type        = string
}

variable "is_public" {
  description = "A boolean describing if the service is public or internal only."
  type        = bool
  default     = false
}

variable "lb_allowed_cidrs" {
  description = "A list of strings of CIDRs to allow inbound to the load balancer"
  type        = list(string)
  default     = []
}

variable "lb_allowed_sgs" {
  description = "A list of strings of Security Group IDs to allow inbound to the load balancer. The bastion is allowed by default."
  type        = list(string)
  default     = []
}

variable "container_ports" {
  description = "A list of ports the container listens on. Most Mixmax Docker images 'EXPOSE' port 8080."
  type        = list(number)
  default     = [8080]
}

variable "container_name_override" {
  description = "The container name is used for networking the target group to the container instances; set this field to override the container name"
  type        = string
  default     = ""
}

variable "custom_tags" {
  description = "A mapping of custom tags to add to the generated resources."
  type        = map(string)
  default     = {}
}

variable "health_check_path" {
  description = "The path the LB will GET to determine if a host is healthy. For example, /health-check  or /status. This health check should only validate that the app itself is online, not necessarily that any downstream dependent services are also online."
  type        = string
  default     = "/health/elb"
}

variable "task_definition" {
  description = "The task definition family:revision or full ARN to deploy on first run to the Fargate service. If you are deploying software with Jenkins, you can ignore this; this is used with task definitions that are managed in Terraform. If unset, the first run will use an Nginx 'hello-world' task def. Terraform will not update the task definition in the service if this value has changed."
  type        = string
  default     = ""
}

variable "min_capacity" {
  description = "The minimum capacity for a scaling Fargate service."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The maximum capacity for a scaling Fargate service."
  type        = number
  default     = 8
}

variable "fargate_service_name_override" {
  description = "This parameter allows you to set to the Fargate service name explicitly. This is useful in cases where you need something other than the default {var.name}-{var.environment} naming convention"
  type        = string
  default     = ""
}
