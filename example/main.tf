provider "aws" {
  region = "us-east-1"
}

module "test" {
  source = "../"

  account_id          = ""
  aws_region          = "us-east-1"
  messages_per_task   = 4
  schedule_expression = "rate(2 minutes)"
  queues_prefix       = "teste__"

  topic_name     = "process_queues"
  cluster_name   = "test-scaling"
  create_cluster = true
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
      subnets         = ["subnet-00000000000"]
      security_groups = ["sg-00000000000"]
    }
  }
}
