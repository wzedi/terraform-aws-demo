resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name = "${var.project_name}-${var.environment}-instance-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
}

resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "${var.project_name}-${var.environment}-cpu-utilisation"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = var.asg_cpu_utilisation_threshold
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}

data "template_file" "userdata" {
  template = "${file("userdata.tpl")}"
}

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
  security_groups           = [aws_security_group.client_security_group.id, aws_security_group.target_security_group.id]

  # Launch template
  launch_template_name            = "launchtemplate"
  launch_template_description     = "Launch template"
  update_default_version          = true
  launch_template_use_name_prefix = false

  image_id                 = var.asg_image_id
  instance_type            = var.asg_instance_type
  enable_monitoring        = true
  iam_instance_profile_arn = aws_iam_instance_profile.instance_profile.arn

  target_group_arns = module.alb.target_group_arns

  user_data = base64encode(data.template_file.userdata.rendered)

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}