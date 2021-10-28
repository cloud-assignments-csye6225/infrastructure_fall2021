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

  //   for_each = local.subnet_az_cidr

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

  //   for_each = local.subnet_az_cidr

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
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  ingress {
    description = "webapp"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
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

  tags = {
    Name = "database"
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
        "${aws_s3_bucket.S3_webapp.arn}/*"
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
    name         = "rds.force_ssl"
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
  subnet_id               = aws_subnet.subnet-b.id
  vpc_security_group_ids  = ["${aws_security_group.application.id}"]
  iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name

  user_data = <<EOF
#!/bin/bash
#sudo touch /home/ubuntu/.env
#sudo echo "RDS_USERNAME = "${aws_db_instance.psql_rds.username}"" >> /home/ubuntu/.env
#sudo echo "RDS_PASSWORD = "${aws_db_instance.psql_rds.password}"" >> /home/ubuntu/.env
#sudo echo "RDS_HOSTNAME = "${aws_db_instance.psql_rds.address}"" >> /home/ubuntu/.env
#sudo echo "BUCKET = "${aws_s3_bucket.S3_webapp.bucket}"" >> /home/ubuntu/.env
#sudo echo "RDS_ENDPOINT = "${aws_db_instance.psql_rds.endpoint}"" >> /home/ubuntu/.env
#sudo echo "RDS_DB_NAME = "${aws_db_instance.psql_rds.name}"" >> /home/ubuntu/.env
  EOF

  root_block_device {
    volume_size = var.root_block_volume_size
    volume_type = var.root_block_volume_type
  }
  tags = {
    Name = "webapp_ec2"
  }
}