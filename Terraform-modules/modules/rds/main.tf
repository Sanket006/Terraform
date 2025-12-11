# RDS Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg_name
  description = var.description
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr_blocks] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rds-sg"
  }
}

# RDS Instance
resource "aws_db_instance" "my_rds" {
  db_name              = var.db_name
  engine               = var.engine_name
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  storage_type         = var.storage_type
  allocated_storage    = var.allocated_storage
  username             = var.username
  password             = var.password
  port                 = var.db_port  
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = true
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name = "${var.project}-rds-instance"
  }
}
