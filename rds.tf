# Custom PostgreSQL parameter group to allow VPC connections without SSL
resource "aws_db_parameter_group" "postgres_params" {
  name        = "postgres17-vpc-access"
  family      = "postgres17"
  description = "PostgreSQL parameter group allowing VPC connections without SSL"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
    apply_method = "pending-reboot"
  }

  # Log settings for debugging connection issues
  parameter {
    name  = "log_connections"
    value = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "PostgreSQL VPC Access Parameters"
  }
}

# PostgreSQL RDS instance in private subnet
resource "aws_db_instance" "postgres_db" {
  identifier                = "qj-postgres-db" # This is what appears in the AWS console
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "17.4"
  instance_class            = "db.t4g.micro"  # ARM-based for cost savings
  db_name                   = "qj_database"   # This is the actual database name inside PostgreSQL
  username                  = "postgres"
  password                  = "YourStrongPasswordHere123!"  # This won't be used for updates
  
  lifecycle {
    ignore_changes = [
      password # Ignore password changes to preserve the one set in AWS console
    ]
  }
  parameter_group_name      = aws_db_parameter_group.postgres_params.name
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "mon:04:00-mon:05:00"
  multi_az                  = false
  skip_final_snapshot       = true
  deletion_protection       = false
  storage_encrypted         = true
  port                      = 5432
  publicly_accessible       = false  # Very important - not publicly accessible
  
  tags = {
    Name = "QJ PostgreSQL Database"
  }
}

output "db_instance_endpoint" {
  value = aws_db_instance.postgres_db.endpoint
  description = "PostgreSQL endpoint address"
}

output "db_instance_port" {
  value = aws_db_instance.postgres_db.port
  description = "PostgreSQL port"
}
