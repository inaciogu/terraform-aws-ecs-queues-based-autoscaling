# ECS queues based autoscaling

## Description

This module creates an ECS cluster and service with an autoscaling configuration based on a custom metric that represents the number of messages per task.
To update the metric value, the module creates a Event bridge scheduler that runs in a given cron expression and sends a message to a SNS topic. The topic triggers a lambda function that updates the metric value.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "test" {
  source = "../"

  account_id          = "12345678912"
  aws_region          = "us-east-1"
  messages_per_task   = 4
  schedule_expression = "rate(2 minutes)"
  queues_prefix       = "teste__"

  topic_name   = "process_queues"
  cluster_name = "test-scaling"
  service = {
    name          = "test-service"
    desired_count = 1
    autoscaling = {
      max_capacity            = 10
      min_capacity            = 1
      metric_target_value     = 4
      scale_up_cooldown       = 30
      scale_down_cooldown     = 60
      scale_up_alarm_period   = 60
      scale_down_alarm_period = 120
    }
    task_definition = {
      cpu         = 512
      memory      = 1024
      family_name = "test-task"
      container_definitions = [
        {
          name                    = "test-container"
          repository_name         = "example-repository"
          create_repository_setup = false
          portMappings = [
            {
              containerPort = 80
              hostPort      = 80
              protocol      = "tcp"
            }
          ]
        }
      ]
    }
    network = {
      vpc_cidr_block             = "10.0.0.0/16"
      public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
      private_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24"]
      security_group_name        = "example-security-group"
    }
  }
}
```