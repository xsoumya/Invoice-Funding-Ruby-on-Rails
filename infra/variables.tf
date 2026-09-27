variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "ap-southeast-2"
}

variable "name" {
  type        = string
  description = "Application name used in resource names."
  default     = "customer-enquiries"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "production"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the application VPC."
  default     = "10.20.0.0/16"
}

variable "container_image" {
  type        = string
  description = "Full ECR image URI and tag for the Rails container."
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to keep running."
  default     = 2
}

variable "database_instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t4g.micro"
}

variable "database_name" {
  type        = string
  description = "PostgreSQL database name."
  default     = "customer_enquiries"
}

variable "database_username" {
  type        = string
  description = "PostgreSQL master username."
  default     = "app_user"
}
