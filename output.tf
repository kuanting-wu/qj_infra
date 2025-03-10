output "api_gateway_domain_names" {
  value = {
    prod    = aws_apigatewayv2_domain_name.api.domain_name
    dev     = aws_apigatewayv2_domain_name.api_dev.domain_name
    staging = aws_apigatewayv2_domain_name.api_staging.domain_name
  }
}

output "acm_cert_arns" {
  value = {
    prod    = aws_acm_certificate.api_cert.arn
    dev     = aws_acm_certificate.api_dev_cert.arn
    staging = aws_acm_certificate.api_staging_cert.arn
  }
}

# Output the bastion host's elastic IP
output "bastion_elastic_ip" {
  value = aws_eip.bastion_eip.public_ip
  description = "Elastic IP address of the bastion host"
}

# Output the RDS connection string to be used via the bastion host
output "rds_connection_via_bastion" {
  value = "psql -h ${aws_db_instance.postgres_db.address} -p ${aws_db_instance.postgres_db.port} -U ${aws_db_instance.postgres_db.username} -d ${aws_db_instance.postgres_db.db_name}"
  description = "PostgreSQL connection command to use after SSH tunneling to the bastion"
}

# Output the SSH tunnel command
output "ssh_tunnel_command" {
  value = "ssh -i /path/to/private_key -L 5432:${aws_db_instance.postgres_db.address}:${aws_db_instance.postgres_db.port} ec2-user@${aws_eip.bastion_eip.public_ip}"
  description = "SSH tunnel command to connect to PostgreSQL through the bastion"
}

# VPC Information
output "vpc_id" {
  value = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  description = "Private subnet IDs"
}

# Lambda Information
output "lambda_function_name" {
  value = aws_lambda_function.api_lambda.function_name
  description = "Lambda function name"
}

output "lambda_function_arn" {
  value = aws_lambda_function.api_lambda.arn
  description = "Lambda function ARN"
}

# Architecture Details
output "architecture_summary" {
  value = <<-EOT
    Infrastructure Architecture:
    
    1. VPC: ${aws_vpc.main.id} (CIDR: ${aws_vpc.main.cidr_block})
    
    2. Networking:
       - Public Subnets: ${aws_subnet.public_subnet_az1.cidr_block}, ${aws_subnet.public_subnet_az2.cidr_block}
       - Private Subnets: ${aws_subnet.private_subnet_az1.cidr_block}, ${aws_subnet.private_subnet_az2.cidr_block}
       - Bastion acting as NAT: ${aws_eip.bastion_eip.public_ip}
    
    3. Database:
       - PostgreSQL RDS: ${aws_db_instance.postgres_db.address}:${aws_db_instance.postgres_db.port}
       - Located in private subnets
       - Access via bastion host only
    
    4. Bastion Host:
       - Elastic IP: ${aws_eip.bastion_eip.public_ip}
       - Functions as NAT and SSH jump host
       - Located in public subnet
    
    5. Lambda:
       - Function: ${aws_lambda_function.api_lambda.function_name}
       - Located in private subnets
       - Internet access via bastion NAT
       - Direct access to RDS in private subnet
  EOT
  description = "Summary of the architecture"
}

# Output S3 website endpoints for both root and www domain
output "website_endpoints" {
  value = {
    root = "http://${aws_s3_bucket.vue_website.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
    www  = "http://${aws_s3_bucket.www_redirect.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
  }
  description = "S3 static website hosting endpoints"
}

# DNS configuration instructions
output "dns_configuration_info" {
  value = "Configure your DNS provider (e.g., Cloudflare) with the following:\n1. CNAME record for 'www' pointing to ${aws_s3_bucket.www_redirect.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com\n2. CNAME record for root domain pointing to ${aws_s3_bucket.vue_website.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
  description = "Instructions for configuring DNS records"
}
