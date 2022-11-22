variable "VpcId" {
  type        = string
  description = "The VPC ID"
}

variable "VPC_CIDR" {
  type = string
  description = "CIDR for the full VPC"
}

variable "db_subnet_0" {
  type        = string
  description = "Database subnet 0"
}

variable "db_subnet_1" {
  type        = string
  description = "Database subnet 1"
}
