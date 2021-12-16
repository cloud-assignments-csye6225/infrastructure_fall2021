locals {
  enable_dns_hostnames = true
}

//VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = local.enable_dns_hostnames
  enable_dns_support               = true
  enable_classiclink_dns_support   = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "vpc-csye26225"
  }
}

//Subnets
resource "aws_subnet" "subnet-a" {

  depends_on = [aws_vpc.vpc]

  cidr_block              = var.subnet_a_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-a-csye6225"
  }
}

resource "aws_subnet" "subnet-b" {

  depends_on = [aws_vpc.vpc]

  cidr_block              = var.subnet_b_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-b-csye6225"
  }
}

resource "aws_subnet" "subnet-c" {

  depends_on = [aws_vpc.vpc]

  cidr_block              = var.subnet_c_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone_c
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-c-csye6225"
  }
}

//Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gw-csye6225"
  }
}

//Route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.igw_cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt-csye6225"
  }
}

//Route Table associations
resource "aws_route_table_association" "a" {

  subnet_id      = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {

  subnet_id      = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "c" {

  subnet_id      = aws_subnet.subnet-c.id
  route_table_id = aws_route_table.rt.id
}

//Application Security group
resource "aws_security_group" "application" {
  name        = "application"
  description = "Application Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_securitygroup.id}"]
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "webapp"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_securitygroup.id}"]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "application"
  }
}

//Database Security group
resource "aws_security_group" "database" {
  name        = "database"
  description = "Database Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Postgres"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.application.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.application.id}"]
  }

  tags = {
    Name = "database"
  }
}

//Loadbalancer Security group
resource "aws_security_group" "lb_securitygroup" {
  name        = "load_balancer_securitygroup"
  description = "Load Balancer Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


//S3 bucket
resource "aws_s3_bucket" "S3_webapp" {

  bucket        = var.s3_bucket
  force_destroy = true
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }
    expiration {
      days = 90
    }
  }
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE"]
    allowed_origins = ["*"]
  }
  tags = {
    Name        = "S3_webapp"
    Environment = "Prod"
  }
}


// S3 bucket policy
resource "aws_iam_policy" "WebAppS3" {
  name        = "WebAppS3"
  path        = "/"
  description = "S3 Policy for web application"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PostObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.S3_webapp.arn}",
        "${aws_s3_bucket.S3_webapp.arn}/*",
        "arn:aws:s3:::${var.code_deploy_bucket}",
        "arn:aws:s3:::${var.code_deploy_bucket}/*"
      ]
    }
  ]
}
EOF
}

//IAM role for EC2
resource "aws_iam_role" "EC2-CSYE6225" {
  name = "EC2-CSYE6225"

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
}

//EC2 role-policy attachment
resource "aws_iam_role_policy_attachment" "EC2-S3-attach" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = aws_iam_policy.WebAppS3.arn
}

//Subnet group for RDS instance
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = ["${aws_subnet.subnet-c.id}", "${aws_subnet.subnet-b.id}", "${aws_subnet.subnet-a.id}"]
}

//db parameter group for postgres
resource "aws_db_parameter_group" "postgres-parameters" {
  name        = var.db_parameter_group_name
  family      = var.db_parameter_group_family
  description = "Postgres parameter group"

  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

//RDS instance
resource "aws_db_instance" "psql_rds" {
  allocated_storage      = var.rds_allocated_storage
  storage_type           = var.rds_storage_type
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  multi_az               = var.rds_multi_az
  identifier             = var.rds_identifier
  instance_class         = var.rds_instance_class
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  name                   = var.rds_name
  username               = var.rds_username
  password               = var.rds_password
  publicly_accessible    = var.rds_publicly_accessible
  skip_final_snapshot    = var.rds_skip_final_snapshot
  parameter_group_name   = aws_db_parameter_group.postgres-parameters.name
  vpc_security_group_ids = [aws_security_group.database.id]
}

//EC2 instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "webapp_ec2_profile"
  role = aws_iam_role.EC2-CSYE6225.name
}

//EC2 instance
resource "aws_instance" "webapp_ec2" {
  ami                     = var.ami
  instance_type           = var.instance_type
  disable_api_termination = "false"
  subnet_id               = aws_subnet.subnet-a.id
  vpc_security_group_ids  = ["${aws_security_group.application.id}"]
  iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name
  // key_name                = aws_key_pair.ssh_key.key_name
  key_name = var.key_name


  user_data = <<EOF
#!/bin/bash
sudo touch /home/ubuntu/.env
sudo echo "RDS_USERNAME = \"${aws_db_instance.psql_rds.username}\"" >> /home/ubuntu/.env
sudo echo "RDS_PASSWORD = \"${aws_db_instance.psql_rds.password}\"" >> /home/ubuntu/.env
sudo echo "RDS_HOSTNAME = \"${aws_db_instance.psql_rds.address}\"" >> /home/ubuntu/.env
sudo echo "RDS_AWS_BUCKET = \"${aws_s3_bucket.S3_webapp.bucket}\"" >> /home/ubuntu/.env
sudo echo "RDS_ENDPOINT = \"${aws_db_instance.psql_rds.endpoint}\"" >> /home/ubuntu/.env
sudo echo "RDS_DB_NAME = \"${aws_db_instance.psql_rds.name}\"" >> /home/ubuntu/.env
sudo echo "AWS_ACCESS_KEY = \"${var.access_key}\"" >> /home/ubuntu/.env
sudo echo "AWS_SECRET_KEY = \"${var.secret_key}\"" >> /home/ubuntu/.env
sudo echo "AWS_BUCKET_REGION = \"${var.region}\"" >> /home/ubuntu/.env
  EOF

  root_block_device {
    volume_size = var.root_block_volume_size
    volume_type = var.root_block_volume_type
  }
  tags = {
    Name = "webapp_ec2"
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name                        = "asg_launch_configuration"
  image_id                    = var.ami
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  security_groups             = ["${aws_security_group.application.id}"]
  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = "true"
  }
  user_data = <<-EOFS
#!/bin/bash
sudo mkdir /home/ubuntu/webapp
sudo chmod 755 /home/ubuntu/webapp
sudo mkdir /home/ubuntu/webapp/config_log
cat > /home/ubuntu/webapp/config_log/config.json << EOF
{
"development": {
    "RDS_USERNAME": "${aws_db_instance.psql_rds.username}",
    "RDS_PASSWORD": "${aws_db_instance.psql_rds.password}",
    "RDS_DB_NAME": "${aws_db_instance.psql_rds.name}",
    "RDS_HOSTNAME": "${aws_db_instance.psql_rds.address}",
    "dialect": "postgres",
    "operatorsAliases": false,
    "RDS_AWS_BUCKET": "${aws_s3_bucket.S3_webapp.bucket}",
    "AWS_BUCKET_REGION": "${var.region}",
    "AWS_ACCESS_KEY": "${var.access_key}",
    "AWS_SECRET_KEY": "${var.secret_key}"
  }
}
EOF
EOFS

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "webapp_auto_scaling_group"
  default_cooldown     = 60
  launch_configuration = aws_launch_configuration.launch_configuration.name
  min_size             = 3
  max_size             = 5
  desired_capacity     = 3
  vpc_zone_identifier  = ["${aws_subnet.subnet-a.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "cicd"
    value               = "codedeploy"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "Webapp-ScaleUpPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "Webapp-ScaleDownPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "CPUAlarmRateHigh" {
  alarm_name          = "CPUAlarmHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"

  alarm_description = "scale up when CPU utilization is high"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
}


resource "aws_cloudwatch_metric_alarm" "CPUAlarmRateLow" {
  alarm_name          = "CPUAlarmLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "3"

  alarm_description = "scale down when CPU utilization is low"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
}


resource "aws_cloudwatch_log_group" "csye6225-log-group" {
  name = "csye6225"
}

resource "aws_cloudwatch_log_stream" "csye6225-log-stream" {
  name           = "webapp"
  log_group_name = aws_cloudwatch_log_group.csye6225-log-group.name

}


resource "aws_iam_role_policy_attachment" "cw-ec2-attach" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "admin-cw-ec2-attach" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}


resource "aws_lb" "webapp_lb" {
  name               = "webapp-load-balancer"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb_securitygroup.id}"]
  subnets            = ["${aws_subnet.subnet-c.id}", "${aws_subnet.subnet-b.id}", "${aws_subnet.subnet-a.id}"]
}

resource "aws_lb_target_group" "webapp_target_group" {
  name     = "webapp-target-group"
  port     = 8000
  protocol = "HTTP"
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }
  health_check {
    interval = 10
    path     = "/healthCheck"
  }
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 5
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = "80"
  protocol          = "HTTP"
  // certificate_arn   = "arn:aws:acm:us-east-1:928635526926:certificate/bcd377e2-78f9-4951-82d0-5abc052ace17"
  // ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_target_group.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  alb_target_group_arn   = aws_lb_target_group.webapp_target_group.arn
}