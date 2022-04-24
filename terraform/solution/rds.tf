resource "aws_security_group" "client_security_group" {
  name        = "RDS Client Security Group"
  description = "RDS client side security group"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "client_egress" {
  type                     = "egress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.server_security_group.id
  security_group_id        = aws_security_group.client_security_group.id
}

resource "aws_security_group" "server_security_group" {
  name        = "RDS Server Security Group"
  description = "RDS server side security group"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "server_ingress" {
  type                     = "ingress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.client_security_group.id
  security_group_id        = aws_security_group.server_security_group.id
}

resource "random_password" "db_master_pass" {
  length            = 40
  special           = true
  min_special       = 5
  override_special  = "!#$%^&*()-_=+[]{}<>:?"
  keepers           = {
    pass_version  = 1
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-${var.environment}-db-pwd-secret"
}

resource "aws_secretsmanager_secret_version" "db_password_value" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_master_pass.result
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-${var.environment}-db"

  engine            = var.rds_engine
  engine_version    = var.rds_engine_version
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage

  db_name  = var.rds_db_name
  username = var.rds_user_name
  password = aws_secretsmanager_secret_version.db_password_value.secret_string
  port     = var.rds_port

  iam_database_authentication_enabled = true

  vpc_security_group_ids =[aws_security_group.server_security_group.id]

  maintenance_window = var.rds_maintenance_window
  backup_window      = var.rds_backup_window

  monitoring_interval    = "30"
  monitoring_role_name   = "db-monitor-role"
  create_monitoring_role = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             =  module.vpc.private_subnets

  # DB parameter group
  family = var.rds_parameter_group

  # DB option group
  major_engine_version = var.rds_major_engine_version

  # Database Deletion Protection
  deletion_protection = true

  storage_encrypted = true

  skip_final_snapshot = var.rds_skip_final_snapshot

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]
}