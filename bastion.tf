# Elastic IP for Bastion
resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  tags = {
    Name = "Bastion-EIP"
  }
}

# We've already manually disabled source/destination checking on the ENI
# No need for the null_resource anymore

# Bastion host for RDS access and Lambda egress
resource "aws_spot_instance_request" "bastion" {
  ami                    = "ami-0a0c8eebcdd6dcbd0" # Amazon Linux 2023 ARM (cheaper than x86)
  instance_type          = "t4g.nano"              # Cheapest instance type (ARM-based)
  subnet_id              = aws_subnet.public_subnet_az1.id  # Placed in public subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name
  
  spot_price             = "0.0017" # Set a max price slightly above the spot price
  wait_for_fulfillment   = true
  spot_type              = "persistent"
  
  # Enable hibernation to persist through spot interruptions
  hibernation            = true
  
  # Persist tags to the spot instance
  instance_interruption_behavior = "stop"
  
  # User data script to enable IP forwarding and NAT for Lambda access
  user_data = <<-EOF
    #!/bin/bash
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
    
    # Set up iptables for NAT
    iptables -t nat -A POSTROUTING -o eth0 -s 10.0.3.0/24 -j MASQUERADE
    iptables -t nat -A POSTROUTING -o eth0 -s 10.0.4.0/24 -j MASQUERADE
    
    # Save iptables
    iptables-save > /etc/iptables.rules
    
    # Create service to restore iptables on boot
    cat > /etc/systemd/system/iptables-restore.service << 'END'
    [Unit]
    Description=Restore iptables rules
    After=network.target

    [Service]
    Type=oneshot
    ExecStart=/sbin/iptables-restore /etc/iptables.rules
    
    [Install]
    WantedBy=multi-user.target
    END
    
    # Enable the service
    systemctl enable iptables-restore.service
  EOF
  
  tags = {
    Name = "RDS-Bastion-NAT"
  }
}

# Add tags to the actual instance
resource "aws_ec2_tag" "bastion_name_tag" {
  resource_id = aws_spot_instance_request.bastion.spot_instance_id
  key         = "Name"
  value       = "RDS-Bastion-NAT"
  
  # Make sure this only runs after the spot request is fulfilled
  depends_on = [aws_spot_instance_request.bastion]
}

# Associate EIP with Bastion instance
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_spot_instance_request.bastion.spot_instance_id
  allocation_id = aws_eip.bastion_eip.id
  
  # Make sure this only runs after the spot request is fulfilled and the instance is running
  depends_on = [aws_spot_instance_request.bastion, aws_ec2_tag.bastion_name_tag]
  
  # Add a lifecycle block to ignore errors during creation
  lifecycle {
    ignore_changes = [instance_id]
  }
}

# Output the Instance ID as a local value for other resources to use
output "bastion_instance_id" {
  value = aws_spot_instance_request.bastion.spot_instance_id
  description = "The ID of the spot instance used as bastion/NAT"
}

# Security group for bastion
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for bastion host and NAT"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"] # Your IP address
    description = "SSH access from specified IP"
  }
  
  # Allow all traffic from private subnets (for NAT functionality)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
    description = "All traffic from private subnets"
  }

  # Allow outbound access to PostgreSQL RDS
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"] # Private subnet CIDRs where RDS is located
    description = "PostgreSQL access to private subnets"
  }

  # Allow all outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = {
    Name = "Bastion-NAT-SG"
  }
}

# Add a rule to RDS security group to allow inbound from bastion
resource "aws_security_group_rule" "allow_postgres_from_bastion" {
  type                     = "ingress"
  from_port                = 5432 # PostgreSQL port
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow PostgreSQL access from bastion"
}

# SSH Key for bastion
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = var.ssh_public_key
}