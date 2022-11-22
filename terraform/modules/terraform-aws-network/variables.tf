variable "VPCName" {
  type    = string
  default = "Wordpress on Fargate base infrastructure"
}

variable SubnetConfig {
  type = map
  default = {
    "VPC_CIDR"      = "10.0.0.0/16"
    "Public0_CIDR"  = "10.0.0.0/24"
    "Public1_CIDR"  = "10.0.1.0/24"
    "Private0_CIDR" = "10.0.2.0/24"
    "Private1_CIDR" = "10.0.3.0/24"
  }
}
