
module "ecs_task_execution_role" {
  source = "dod-iac/ecs-task-execution-role/aws"

  allow_create_log_groups    = true
  cloudwatch_log_group_names = ["*"]
  name = "app-WordpressApp-task-execution-role"
}

module "aws_network" {
  source = "./modules/terraform-aws-network"

  VPCName = "WordpressBlogVPC"
}

module "aws_database" {
  source = "./modules/terraform-aws-database"

  VpcId             = module.aws_network.VPCId
  VPC_CIDR          = module.aws_network.VPC_CIDR
  db_subnet_0       = module.aws_network.PublicSubnet0
  db_subnet_1       = module.aws_network.PublicSubnet1
}

module "aws_worpress_app" {
  source = "./modules/terraform-aws-wordpress"

  VpcId          = module.aws_network.VPCId
  PublicSubnet0  = module.aws_network.PublicSubnet0
  PublicSubnet1  = module.aws_network.PublicSubnet1
  PrivateSubnet0 = module.aws_network.PrivateSubnet0
  PrivateSubnet1 = module.aws_network.PrivateSubnet1
  FileSystemId   = module.aws_network.EFSFSId
  AccessPoint    = module.aws_network.EFSAccessPoint
  WordpressDB    = module.aws_database.RDSEndpointAddress
  task_execution_role = module.ecs_task_execution_role.arn
}
