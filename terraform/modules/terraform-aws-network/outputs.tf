output "VPCId" {
  value       = aws_vpc.wordpress_vpc.id
  description = "VPCId of VPC"
}

output "VPC_CIDR" {
  value       = aws_vpc.wordpress_vpc.cidr_block
  description = "VPCId of VPC"
}

output "PublicSubnet0" {
  value       = aws_subnet.PublicSubnet0.id
  description = "SubnetId of public subnet 0"
}

output "PublicSubnet1" {
  value       = aws_subnet.PublicSubnet1.id
  description = "SubnetId of public subnet 1"
}

output "PrivateSubnet0" {
  value       = aws_subnet.PrivateSubnet0.id
  description = "SubnetId of private subnet 0"
}

output "PrivateSubnet1" {
  value       = aws_subnet.PrivateSubnet1.id
  description = "SubnetId of private subnet 1"
}

output "DefaultSecurityGroup" {
  value       = aws_vpc.wordpress_vpc.default_security_group_id
  description = "DefaultSecurityGroup Id"
}

output "EFSFSId" {
  value       = aws_efs_file_system.FileSystem.id
  description = "ID of EFS FS"
}

output "EFSAccessPoint" {
  value       = aws_efs_access_point.AccessPoint.id
  description = "EFS Access Point ID"
}