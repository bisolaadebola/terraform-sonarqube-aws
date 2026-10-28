
variable "aws_region" {
  description = "AWS region for the SonarQube infrastructure"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for SonarQube"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "Name for the EC2 SSH key pair"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public SSH key file"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IPv4 address in CIDR notation, for example 203.0.113.10/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must be a valid IPv4 CIDR block, such as 203.0.113.10/32."
  }
}

variable "root_volume_size" {
  description = "Encrypted root EBS volume size in GiB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 30
    error_message = "The root volume must be at least 30 GiB."
  }
}
