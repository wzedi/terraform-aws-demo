module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "${var.project_name}-${var.environment}-asg"

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  security_groups           = [aws_security_group.client_security_group.id]

  # Launch template
  launch_template_name            = "launchtemplate"
  launch_template_description     = "Launch template"
  update_default_version          = true
  launch_template_use_name_prefix = false

  image_id          = var.asg_image_id
  instance_type     = var.asg_instance_type
  enable_monitoring = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}