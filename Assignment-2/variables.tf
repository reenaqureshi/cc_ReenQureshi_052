variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block))
    error_message = "VPC CIDR block must be a valid CIDR notation (e.g., 10.0.0.0/16)."
  }
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_cidr_block))
    error_message = "Subnet CIDR block must be a valid CIDR notation (e.g., 10.0.10.0/24)."
  }
}

variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix (e.g., dev, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_key" {
  description = "Path to the public key file"
  type        = string
}

variable "private_key" {
  description = "Path to the private key file"
  type        = string
}
