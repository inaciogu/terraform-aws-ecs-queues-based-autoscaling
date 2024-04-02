provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "sns_topic_subscription" {
  source = "github.com/Coaktion/terraform-aws-pubsub-module"

  queues = [
    {
      name = "test_scaling_queue_1"
      topics_to_subscribe = [
        {
          name = "test_scaling_topic"
        }
      ]
    },
    {
      name = "test_scaling_queue_2"
      topics_to_subscribe = [
        {
          name = "test_scaling_topic"
          create_topic = false
        }
      ]
    },
    {
      name = "test_scaling_queue_3"
      topics_to_subscribe = [
        {
          name = "test_scaling_topic"
          create_topic = false
        }
      ]
    }
  ]

  fifo       = true
  account_id = data.aws_caller_identity.current.account_id
}

module "test" {
  source = "../"

  account_id = data.aws_caller_identity.current.account_id
  aws_region          = "us-east-1"
  messages_per_task   = 10
  schedule_expression = "rate(2 minutes)"
  queues_prefix       = "test_scaling_queue"

  topic_name     = "process_queues"
  cluster_name   = "test-scaling"
  create_cluster = true
  service = {
    name          = "test-service"
    desired_count = 0
    autoscaling = {
      max_capacity            = 10
      min_capacity            = 0
      metric_target_value     = 10
      scale_up_cooldown       = 30
      scale_down_cooldown     = 30
      scale_up_alarm_period   = 60
      scale_down_alarm_period = 180
      queues_require_consumer_alarm_period = 60
    }
    task_definition = {
      cpu         = 512
      memory      = 1024
      family_name = "test-task"
      container_definitions = [
        {
          name                    = "test-container"
          repository_name         = "example-scaling-repository"
          create_repository_setup = true
          dockerfile_location = "./"
          portMappings = [
            {
              containerPort = 80
              hostPort      = 80
              protocol      = "tcp"
            }
          ]
          secret_manager = "example-scaling-test"
        }
        
      ]
    }
    vpc = {
      vpc_cidr_block             = "10.0.0.0/16"
      public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
      private_subnet_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
      security_group_name        = "example-security-group"
    }
  }
}
