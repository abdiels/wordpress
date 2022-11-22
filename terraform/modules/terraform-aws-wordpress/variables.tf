
variable "VpcId" {
  type        = string
  description = "The VPC ID"
}

variable "PublicSubnet0" {
  type        = string
  description = "The First Public Subnet"
}

variable "PublicSubnet1" {
  type        = string
  description = "The Second Public Subnet"
}

variable "PrivateSubnet0" {
  type        = string
  description = "The First Private Subnet"
}

variable "PrivateSubnet1" {
  type        = string
  description = "The Second Private Subnet"
}

variable "FileSystemId" {
  type = string
}

variable "AccessPoint" {
  type = string
}

variable "WordpressDB" {
  type = string
}

variable "task_execution_role" {
  type = string
}