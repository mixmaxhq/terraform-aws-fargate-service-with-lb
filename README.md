# `terraform-aws-fargate-service-with-lb`

This module is an opinionated implementation of a Fargate service with an application load balancer, serving HTTP requests. This is useful for creating an API or web service.

It fronts all traffic with HTTPS on port 443, forwarding to the configured `container_ports` (default is 80.) This module outputs the ALB DNS name, which can be used to create a CNAME record in Route 53.

For creating a Fargate service without a built-in application load balancer, see the [terraform-aws-fargate-service module](https://github.com/mixmaxhq/terraform-aws-fargate-service). This is also useful when deploying an application behind a Network Load Balancer.

## Usage

An example deployable application can be found in the [examples/simple](examples/simple) directory.

## Notes

This module creates security groups (ie firewalls) for communicating with both the load balancer, and the service over the network. By default, it allows all traffic originating from the container (in other words, all `egress` traffic is allowed), and inbound traffic from the load balancer to the container on port 80 (or whatever `container_ports` is set to.) However, if you would like to communicate inbound to the load balancer from another service, you must create an [`aws_security_group_rule`](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html) resource referencing the load balancer's security group. The module-created security group is available as the output `lb_sg_id`.

Additionally, this module creates an IAM role for the Fargate service to authorize access to AWS resources. By default, these services get no permissions. To add permissions to an AWS resource, create an [`aws_iam_policy` resource](https://www.terraform.io/docs/providers/aws/r/iam_policy.html) and [attach the policy to the role using an `aws_iam_role_policy_attachment` resource](https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html). The module-created IAM role name is available as the output `task_role_name` from the module.

## Gotchas

### Container does not exist in the task definition
If you get an error like below,
```
Error: InvalidParameterException: The container module-test-staging does not exist in the task definition.
        status code: 400, request id: a1c206cc-c593-455c-8ac2-b198956e9447 "module-test-staging"
  on .terraform/modules/web.fargate_service/main.tf line 28, in resource "aws_ecs_service" "service":
  28: resource "aws_ecs_service" "service" {
```

This is due to this module making some assumptions about the name of the container to [connect networking for the load balancer](https://github.com/mixmaxhq/terraform-aws-fargate-service-with-lb/blob/master/main.tf#L14). The default is set to `${var.name}-${var.environment}` when deploying a task definition using the `mixmax` CLI. However, you can override this behavior. Find the `name` value in your task definition's [container definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_name), and set the `container_name_override` parameter to this module for overriding the name used.

## How are the docs generated?

Manually with [`terraform-docs`](https://github.com/segmentio/terraform-docs), something like this:
```
terraform-docs md document . >> README.md
# and then edit out the old stuff
```

## Variables

### Required Variables

The following variables are required:

#### environment

Description: The environment to deploy into. Some valid values are production, staging, engineering.

Type:
`string`

#### lb\_subnets

Description: A list of subnet IDs to use for instantiating the load balancer.

Type:
`list(string)`

#### name

Description: The name of the application to launch

Type:
`string`

#### service

Description: The name of the service this application is associated with, ie 'send' if the application is 'send-worker'

Type:
`string`

#### service\_subnets

Description: A list of subnet IDs to use for instantiating the Fargate service. Tasks will be deployed into these subnets.

Type:
`list(string)`

#### tls\_cert\_arns

Description: The ARNs of Amazon Certificate Manager certificates to use with the HTTPS listener on the load balancer. You *must* provide at least one.

Type:
`list(string)`

### Optional Variables

The following variables are optional (have default values):

#### alarm\_sns\_topic\_arns

Description: This parameter is a list of the SNS topic ARNs. This is used to send alarm notifications. This is REQUIRED for production deployments!

Type:
`list(string)`

Default:
`[]`

#### anomaly\_detection\_band\_threshold

Description: This determines how wide the anomaly threshold band is for detecting 5xx errors

Type:
`number`

Default:
`10`

#### capacity\_provider\_strategies

Description: The capacity provider (supported by the configured cluster) to use to provision tasks for the service

Type:
```hcl
list(object({
    capacity_provider = string
    base              = number
    weight            = number
  }))
```

Default:
`[]`

#### container\_name\_override

Description: The container name is used for networking the target group to the container instances; set this field to override the container name

Type:
`string`

Default:
`""`

#### container\_ports

Description: A list of ports the container listens on. Most Mixmax Docker images 'EXPOSE' port 8080.

Type:
`list(number)`

Default:
```json
[
  8080
]
```

#### cpu\_high\_threshold

Description: The CPU percentage to be considered 'high' for autoscaling purposes.

Type:
`number`

Default:
`70`

#### cpu\_low\_threshold

Description: The CPU percentage to be considered 'low' for autoscaling purposes. This was set to a 'safe' value to prevent scaling down when it's not a good idea, but please adjust this higher for your app if possible.

Type:
`number`

Default:
`30`

#### cpu\_scaling\_enabled

Description: Whether CPU-based autoscaling should be turned on or off

Type:
`bool`

Default:
`true`

#### custom\_tags

Description: A mapping of custom tags to add to the generated resources.

Type:
`map(string)`

Default:
`{}`

#### extra\_load\_balancer\_configs

Description: Extra load balancer configurations; used when you want one ECS service fronted by multiple load balancers.

Type:
`list(object({ target_group_arn = string, container_name = string, container_port = number }))`

Default:
`[]`

#### fargate\_service\_name\_override

Description: This parameter allows you to set to the Fargate service name explicitly. This is useful in cases where you need something other than the default {var.name}-{var.environment} naming convention

Type:
`string`

Default:
`""`

#### health\_check\_grace\_period

Description: The load balancer health check grace period in seconds. This defines how long ECS will ignore failing load balancer chcecks on newly instantiated tasks.

Type:
`number`

Default:
`90`

#### health\_check\_path

Description: The path the LB will GET to determine if a host is healthy. For example, /health-check  or /status. This health check should only validate that the app itself is online, not necessarily that any downstream dependent services are also online.

Type:
`string`

Default:
`"/health/elb"`

#### idle\_timeout

Description: The connection idle timeout value for the created load balancer

Type:
`number`

Default:
`60`

#### is\_public

Description: Whether the service is public or internal only.

Type:
`bool`

Default:
`false`

#### lb\_allowed\_cidrs

Description: A list of strings of CIDRs to allow inbound to the load balancer

Type:
`list(string)`

Default:
`[]`

#### lb\_allowed\_sgs

Description: A list of strings of Security Group IDs to allow inbound to the load balancer.

Type:
`list(string)`

Default:
`[]`

#### max\_capacity

Description: The maximum capacity for a scaling Fargate service.

Type:
`number`

Default:
`8`

#### min\_capacity

Description: The minimum capacity for a scaling Fargate service.

Type:
`number`

Default:
`2`

#### set\_public\_sg\_rule

Description: Whether to set the public security group rule allowing all access. This is only used on public load balancers and is useful to set to 'false' if you want to create an internet-facing load balancer that only accepts traffic from certain sources, ie Github -> Jenkins but nothing else over the public internet.

Type:
`bool`

Default:
`true`

#### task\_definition

Description: The task definition family:revision or full ARN to deploy on first run to the Fargate service. If you are deploying software with Jenkins, you can ignore this; this is used with task definitions that are managed in Terraform. If unset, the first run will use an Nginx 'hello-world' task def. Terraform will not update the task definition in the service if this value has changed.

Type:
`string`

Default:
`""`

#### task\_traffic\_slow\_start

Description: This parameter defines the number of seconds during which a newly registered Fargate task receives an increasing share of the traffic to the target group, giving it time to 'warm up'.

Type:
`number`

Default:
`30`

## Outputs

The following outputs are exported:

#### alb\_arn

Description: The ARN of the created ALB

#### alb\_dns\_name

Description: The DNS name of the created ALB. Useful for creating a CNAME from mixmax.com DNS names.

#### alb\_listener\_arn

Description: The ARN of the HTTPS ALB listener

#### cloudwatch\_log\_group\_name

Description: The name of the CloudWatch log group

#### lb\_arn\_suffix

Description: The ARN suffix of the application load balancer. Useful for Cloudwatch alarms

#### lb\_sg\_id

Description: The ID of the Security Group attached to the LB

#### task\_role\_arn

Description: The ARN of the IAM Role created for the Fargate service

#### task\_role\_name

Description: The name of the IAM Role created for the Fargate service

#### task\_sg\_id

Description: The ID of the Security Group attached to the ECS tasks

#### tg\_arn

Description: The ARN of the target group in the application load balancer.

#### tg\_arn\_suffix

Description: The ARN suffixes of the target group in the application load balancer. Useful for Cloudwatch alarms

