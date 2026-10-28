
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 1. VPC
resource "aws_vpc" "sonarqube_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "sonarqube-vpc"
    Project = "Terraform-SonarQube"
  }
}

# 2. Public subnet
resource "aws_subnet" "sonarqube_public" {
  vpc_id                  = aws_vpc.sonarqube_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "sonarqube-public-subnet"
  }
}

# 3. Internet gateway
resource "aws_internet_gateway" "sonarqube_igw" {
  vpc_id = aws_vpc.sonarqube_vpc.id

  tags = {
    Name = "sonarqube-igw"
  }
}

# 4. Public route table
resource "aws_route_table" "sonarqube_public_rt" {
  vpc_id = aws_vpc.sonarqube_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sonarqube_igw.id
  }

  tags = {
    Name = "sonarqube-public-route-table"
  }
}

# 5. Associate subnet and route table
resource "aws_route_table_association" "sonarqube_public_assoc" {
  subnet_id      = aws_subnet.sonarqube_public.id
  route_table_id = aws_route_table.sonarqube_public_rt.id
}

# 6. Security group
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Restricted SSH and SonarQube web access"
  vpc_id      = aws_vpc.sonarqube_vpc.id

  ingress {
    description = "SSH from your IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "SonarQube web interface from your IP only"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "HTTP for redirects and certificate validation"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for secure SonarQube access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sonarqube-sg"
  }
}

# 7. Register your public SSH key with AWS
resource "aws_key_pair" "sonarqube_key" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name = "sonarqube-key"
  }
}

# 8. EC2 instance — infrastructure only
resource "aws_instance" "sonarqube_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.sonarqube_public.id
  vpc_security_group_ids      = [aws_security_group.sonarqube_sg.id]
  key_name                    = aws_key_pair.sonarqube_key.key_name
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker
    usermod -aG docker ubuntu
  EOF

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "sonarqube-server"
    Project     = "Terraform-SonarQube"
    Environment = "Learning"
  }

  depends_on = [
    aws_route_table_association.sonarqube_public_assoc
  ]
}

# 9. Stable public IPv4 for Namecheap DNS
resource "aws_eip" "sonarqube_eip" {
  domain   = "vpc"
  instance = aws_instance.sonarqube_server.id

  tags = {
    Name = "sonarqube-eip"
  }
}
