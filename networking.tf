# VPC with DNS support
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "qj-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "qj-igw"
  }
}

# Public Subnet for Bastion in AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public Subnet AZ1"
  }
}

# Public Subnet for redundancy in AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public Subnet AZ2"
  }
}

# Private Subnet for Lambda and RDS in AZ1
resource "aws_subnet" "private_subnet_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "Private Subnet AZ1"
  }
}

# Private Subnet for Lambda and RDS in AZ2
resource "aws_subnet" "private_subnet_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "Private Subnet AZ2"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "Public Route Table"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public_rta_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT-Gateway-EIP"
  }
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_az1.id
  
  tags = {
    Name = "Main-NAT-Gateway"
  }
  
  # To ensure proper ordering, add dependencies
  depends_on = [aws_internet_gateway.igw]
}

# Route Table for Private Subnets - with route through NAT Gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  
  # Add route to internet through NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  
  tags = {
    Name = "Private Route Table"
  }
}

# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "private_rta_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_rt.id
}

# DB Subnet Group for PostgreSQL in private subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "Private subnet group for PostgreSQL RDS"
  subnet_ids  = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  
  tags = {
    Name = "RDS Private Subnet Group"
  }
}

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id
  
  # Allow ALL outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name = "Lambda Security Group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.main.id
  
  # No ingress rules here - will be added specifically for Lambda and Bastion
  
  tags = {
    Name = "RDS Security Group"
  }
}

# Allow inbound from Lambda to PostgreSQL RDS - security group approach
resource "aws_security_group_rule" "allow_lambda_to_postgres" {
  type                     = "ingress"
  from_port                = 5432  # PostgreSQL port
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow PostgreSQL access from Lambda security group"
}

# Allow inbound from all private subnets to PostgreSQL RDS - CIDR approach
resource "aws_security_group_rule" "allow_private_subnet_to_postgres" {
  type              = "ingress"
  from_port         = 5432  # PostgreSQL port
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = ["10.0.3.0/24", "10.0.4.0/24"]  # All private subnet CIDRs
  description       = "Allow PostgreSQL access from all private subnets"
}

