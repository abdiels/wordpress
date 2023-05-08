
resource "aws_vpc" "wordpress_vpc" {
  enable_dns_support = true
  enable_dns_hostnames = true
  cidr_block = var.SubnetConfig["VPC_CIDR"]
  tags = {
    Name = var.VPCName
    Network = "Public"
  }
}

resource "aws_subnet" "PublicSubnet0" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.SubnetConfig["Public0_CIDR"]
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name        = "VPCNameParameter-public-+ aws_wordpress_public_subnet.PublicSubnet0.availability_zone"
    Network     = "Public"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.SubnetConfig["Public1_CIDR"]
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name        = "VPCNameParameter-public-+ aws_wordpress_public_subnet.PublicSubnet1.availability_zone"
    Network     = "Public"
  }
}

resource "aws_subnet" "PrivateSubnet0" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.SubnetConfig["Private0_CIDR"]
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name        = "VPCNameParameter-private-+ aws_wordpress_private_subnet.PrivateSubnet0.availability_zone"
    Network     = "Private"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.SubnetConfig["Private1_CIDR"]
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name        = "VPCNameParameter-private-+ aws_wordpress_private_subnet.PrivateSubnet1.availability_zone"
    Network     = "Private"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name        = "VPCNameParameter-public-+ aws_vpc.wordpress_vpc.name-IGW"
    Network     = "Public"
  }
}

resource "aws_internet_gateway_attachment" "GatewayToInternet" {
  internet_gateway_id = aws_internet_gateway.InternetGateway.id
  vpc_id              = aws_vpc.wordpress_vpc.id
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }

  tags = {
    Name        = "VPC Name-public-route-table"
    Network     = "Public"
    Application = "Stack Name..."
  }
}

resource "aws_route_table_association" "PublicSubnetRouteTableAssociation0" {
  subnet_id      = aws_subnet.PublicSubnet0.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "PublicSubnetRouteTableAssociation1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_network_acl" "PublicNetworkAcl" {
  vpc_id = aws_vpc.wordpress_vpc.id
  tags = {
    Name = "${aws_vpc.wordpress_vpc.tags["Name"]}-public-nacl"
  }
}

resource "aws_network_acl_rule" "PublicNetworkAcl_ingress" {
    network_acl_id = aws_network_acl.PublicNetworkAcl.id
    rule_number    = 100
    protocol       = "-1"
    rule_action    = "allow"
    egress         = false
    cidr_block     = "0.0.0.0/0"
    from_port      = 0
    to_port        = 0
}

resource "aws_network_acl_rule" "PublicNetworkAcl_egress" {
    network_acl_id = aws_network_acl.PublicNetworkAcl.id
    rule_number    = 100
    protocol       = "-1"
    rule_action    = "allow"
    egress         = true
    cidr_block     = "0.0.0.0/0"
    from_port      = 0
    to_port        = 0
}

resource "aws_network_acl_association" "PublicSubnetNetworkAclAssociation0" {
  network_acl_id = aws_network_acl.PublicNetworkAcl.id
  subnet_id      = aws_subnet.PublicSubnet0.id
}

resource "aws_network_acl_association" "PublicSubnetNetworkAclAssociation1" {
  network_acl_id = aws_network_acl.PublicNetworkAcl.id
  subnet_id      = aws_subnet.PublicSubnet1.id
}

resource "aws_eip" "ElasticIP0" {
  vpc = true
}

resource "aws_eip" "ElasticIP1" {
  vpc = true
}

resource "aws_nat_gateway" "NATGateway0" {
  allocation_id = aws_eip.ElasticIP0.id
  subnet_id     = aws_subnet.PublicSubnet0.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.InternetGateway]
}

resource "aws_nat_gateway" "NATGateway1" {
  allocation_id = aws_eip.ElasticIP1.id
  subnet_id     = aws_subnet.PublicSubnet1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.InternetGateway]
}

resource "aws_route_table" "PrivateRouteTable0" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGateway0.id
  }

  tags = {
    Name        = "VPC Name-private-route-table-0"
    Network     = "Private"
    Application = "Stack Name..."
  }
}

resource "aws_route_table" "PrivateRouteTable1" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGateway1.id
  }

  tags = {
    Name        = "VPC Name-private-route-table-1"
    Network     = "Private"
    Application = "Stack Name..."
  }
}

resource "aws_route_table_association" "PrivateSubnetRouteTableAssociation0" {
  subnet_id      = aws_subnet.PrivateSubnet0.id
  route_table_id = aws_route_table.PrivateRouteTable0.id
}

resource "aws_route_table_association" "PrivateSubnetRouteTableAssociation1" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.PrivateRouteTable1.id
}

resource "aws_efs_file_system" "FileSystem" {
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    Name = "Wordpress-demo"
  }
}

resource "aws_security_group" "MountTargetSecurityGroup" {
  name        = "Wordpress-Demo-EFS-SG"
  description = "FileSystem Security Group"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    description = "File System"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.wordpress_vpc.cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_efs_mount_target" "MountTarget1" {
  file_system_id  = aws_efs_file_system.FileSystem.id
  subnet_id       = aws_subnet.PrivateSubnet0.id
  security_groups = [aws_security_group.MountTargetSecurityGroup.id]
}

resource "aws_efs_mount_target" "MountTarget2" {
  file_system_id  = aws_efs_file_system.FileSystem.id
  subnet_id       = aws_subnet.PrivateSubnet1.id
  security_groups = [aws_security_group.MountTargetSecurityGroup.id]
}

resource "aws_efs_access_point" "AccessPoint" {
  file_system_id = aws_efs_file_system.FileSystem.id
  posix_user {
    gid = "1000"
    uid = "1000"
  }
  root_directory {
    creation_info {
      owner_gid   = "1000"
      owner_uid   = "1000"
      permissions = "0777"
    }
    path = "/bitnami"
  }
}
