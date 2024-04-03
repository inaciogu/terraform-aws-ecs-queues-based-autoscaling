variable "aws_access_key_id" {
  description = "value of AWS_ACCESS_KEY_ID"
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "value of AWS_SECRET_ACCESS_KEY"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "value of AWS_DEFAULT_REGION"
  type        = string
}

variable "account_id" {
  description = "value of AWS account id"
  type        = string
}

variable "schedule_expression" {
  description = "Schedule expression to trigger the Lambda function"
  type        = string
}

variable "topic_name" {
  description = "Name of the SNS topic to trigger the Lambda function"
  type        = string
  default     = "process_queues"
}

variable "queues_prefix" {
  description = "Prefix of the SQS queues that will be processed by the Lambda function"
  type        = string
}

variable "messages_per_task" {
  description = "Number of messages that a single task processes"
  type        = number
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "create_cluster" {
  description = "Whether to create the cluster"
  type        = bool
  default     = false
}

variable "create_service" {
  description = "Whether to create the service"
  type        = bool
  default     = true
}

variable "service" {
  description = "ECS service to be scaled up"
  type = object({
    name          = string           # Name of the service
    desired_count = optional(number) # Desired number of tasks
    autoscaling = object({
      min_capacity            = number           # Minimum number of tasks
      max_capacity            = number           # Maximum number of tasks
      metric_target_value     = number           # Target value of the metric
      scale_up_cooldown       = optional(number) # Cooldown of the scale up policy
      scale_down_cooldown     = optional(number) # Cooldown of the scale down policy
      scale_up_alarm_period   = optional(number) # Period of the scale up alarm
      scale_down_alarm_period = optional(number) # Period of the scale down alarm
      queues_require_consumer_alarm_period = optional(number) # Period of the queues require consumer alarm
    })
    task_definition = optional(object({
      family_name = string # Name of the task definition family
      container_definitions = list(object({
        name                    = string           # Name of the container
        create_repository_setup = bool             # Whether to create the repository
        repository_name         = string           # Name of ECR repository to be used
        dockerfile_location     = optional(string) # path to the Dockerfile
        portMappings = optional(list(object({
          containerPort = number # Port of the container
          hostPort      = number # Port of the host
          protocol      = string # Protocol of the port
        })))
        environment = optional(list(object({
          name  = string              # Name of the environment variable
          value = string              # Value of the environment variable
        })))                          # Environment variables
        secret_arn = optional(string) # ARN of the secret to get the environment variables
        secrets = optional(list(object({
          name      = string # Name of the secret
          valueFrom = string # ARN of the secret
        })))
      }))
      cpu    = number # CPU units
      memory = number # Memory units
    }))
    network = optional(object({
      security_groups_tag = object({
        key    = string       # Key of the tag
        values = list(string) # Value of the tag
      })
      subnets_tag = object({
        key    = string       # Key of the tag
        values = list(string) # Value of the tag
      })
    }))
    vpc = optional(object({
      vpc_cidr_block             = string       # CIDR block of the VPC
      public_subnet_cidr_blocks  = list(string) # CIDR blocks of the public subnets
      private_subnet_cidr_blocks = list(string) # CIDR blocks of the private subnets
      security_group_name        = string       # Name of the security group
    }))
  })
}
