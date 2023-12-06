locals {
  has_vpc = var.service.vpc != null
}

module "ecs-service" {
  source = "github.com/inaciogu/terraform-aws-ecs-fargate-deployment"
  count  = var.create_service ? 1 : 0

  aws_region = var.aws_region
  account_id = var.account_id

  vpc_cidr_block             = local.has_vpc ? var.service.vpc.cidr_block : null
  public_subnet_cidr_blocks  = local.has_vpc ? var.service.vpc.public_subnet_cidr_blocks : []
  private_subnet_cidr_blocks = local.has_vpc ? var.service.vpc.private_subnet_cidr_blocks : []
  security_group_name        = local.has_vpc ? var.service.vpc.security_group_name : null

  clusters = [
    {
      name           = var.cluster_name
      create_cluster = var.create_cluster
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
