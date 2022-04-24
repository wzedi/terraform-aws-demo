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

variable "asg_cpu_utilisation_threshold" {
  description = "The ASG CPU utilisation threshold"
  type        = string
  default     = "80"
}

variable "rds_engine" {
  description = "The RDS engine"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "The RDS engine version"
  type        = string
  default     = "8.0.28"
}

variable "rds_instance_class" {
  description = "The RDS instance class"
  type        = string
  default     = "db.t2.small"
}

variable "rds_allocated_storage" {
  description = "The RDS allocated storage"
  type        = number
  default     = 5
}

variable "rds_db_name" {
  description = "The RDS database name"
  type        = string
  default     = "SymbioteTerraformTask"
}

variable "rds_user_name" {
  description = "The RDS database user name"
  type        = string
  default     = "admin"
}

variable "rds_port" {
  description = "The RDS port"
  type        = number
  default     = 3306
}

variable "rds_maintenance_window" {
  description = "The RDS maintenance window"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "rds_backup_window" {
  description = "The RDS backup window"
  type        = string
  default     = "03:00-06:00"
}

variable "rds_parameter_group" {
  description = "The RDS parameter group"
  type        = string
  default     = "mysql8.0"
}

variable "rds_major_engine_version" {
  description = "The RDS major engine version"
  type        = string
  default     = "8.0"
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the database"
  type        = bool
  default     = true
}