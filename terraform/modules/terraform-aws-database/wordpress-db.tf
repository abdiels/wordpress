

resource "aws_security_group" "DBSecurityGroup" {
  name        = "Wordpress-Demo-RDS-SG"
  description = "RDS Security Group"
  vpc_id      = var.VpcId

  ingress {
    description = "Allow database access to the whole VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "DBSubnetGroup" {
  name        = "wp-db-subnet-group"
  description = "wp-db-subnet-group"
  subnet_ids  = [var.db_subnet_0, var.db_subnet_1]
}

resource "aws_rds_cluster" "WordpressDB" {
  engine                  = "aurora-mysql"
  engine_mode             = "serverless"
  db_subnet_group_name    = aws_db_subnet_group.DBSubnetGroup.id
  database_name           = "wordpress"
  master_username         = "admin"
  master_password         = "supersecretpassword"
  vpc_security_group_ids  = [aws_security_group.DBSecurityGroup.id]
  skip_final_snapshot     = true
}


