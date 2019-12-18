variable "name" {
  description = "The name of the service to launch"
  type        = string
}

variable "environment" {
  description = "The environment to deploy into. Some valid values are production, staging, engineering."
  type        = string
}

variable "image" {
  description = "The image to launch. This is passed directly to the Docker engine. An example is 012345678910.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest"
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

variable "load_balancer_type" {
  description = "A string of the load balancer type. Valid values are `application` and `network`."
  type        = string
  default     = "application"
}

variable "cpu" {
  description = "The CPU credits to provide container. 256 is .25 vCPUs, 1024 is 1 vCPU, max is 4096 (4 vCPUs). Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = number
  default     = 512
}

variable "memory" {
  description = "The memory to provide the container in MiB. 512 is min, 30720 is max. Find valid values here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = number
  default     = 1024
}

variable "environment_vars" {
  description = "A list of maps of environment variables to provide to the container. Do not put secrets here; instead use the `secrets` input to specify the ARN of a Parameter Store or Secrets Manager value."
  type        = list(map(string))
  default     = []
}

variable "secrets" {
  description = "A list of maps of ARNs of secrets stored in Parameter Store or Secrets Manager and exposed as environment variables. Do not put actual secrets here! See examples/simple for usage."
  type        = list(string)
  default     = []
}

variable "container_ports" {
  description = "A list of ports the container listens on. Default is port 80"
  type = list(number)
  default     = [80]
}

variable "custom_tags" {
  description = "A mapping of custom tags to add to the generated resources."
  type        = map(string)
  default     = {}
}
