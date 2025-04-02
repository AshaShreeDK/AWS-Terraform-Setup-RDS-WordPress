variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "jump_subnet_cidr" {
  description = "CIDR block for the jump (public) subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet for the WordPress EC2 instance"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet1_cidr" {
  description = "CIDR block for the first private subnet (for RDS)"
  type        = string
  default     = "10.0.20.0/24"
}

variable "private_subnet2_cidr" {
  description = "CIDR block for the second private subnet (for RDS)"
  type        = string
  default     = "10.0.30.0/24"
}

variable "az" {
  description = "Primary Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Secondary Availability Zone"
  type        = string
  default     = "us-east-1b"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "admin123"
}

variable "base_ami" {
  type        = string
  default     = "ami-02f624c08a83ca16f"  
}
