variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "The project name"
  type        = string
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "asg_min_size" {
  description = "The minimum size of the autoscaling group"
  type         = number
  default      = 1
}

variable "asg_max_size" {
  description = "The maximum size of the autoscaling group"
  type         = number
  default      = 1
}

variable "asg_image_id" {
  description = "The AMI ID for the ASG launch template"
  type        = string
  default     = "ami-0d6fb2916ee0ab9fe"
}

variable "asg_instance_type" {
  description = "The instance type for the ASG"
  type        = string
  default     = "t3.micro"
}