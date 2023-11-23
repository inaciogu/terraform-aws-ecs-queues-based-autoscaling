module "ecs-service" {
  source = "github.com/inaciogu/terraform-aws-ecs-fargate-deployment"

  aws_region = var.aws_region
  account_id = var.account_id

  vpc_cidr_block             = var.service.network.vpc_cidr_block
  public_subnet_cidr_blocks  = var.service.network.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.service.network.private_subnet_cidr_blocks
  security_group_name        = var.service.network.security_group_name

  clusters = [
    {
      name = var.cluster_name
      services = [{
        desired_count   = var.service.desired_count
        name            = var.service.name
        task_definition = var.service.task_definition
        network         = var.service.network
        autoscaling     = var.service.autoscaling
      }]
    },
  ]
}
