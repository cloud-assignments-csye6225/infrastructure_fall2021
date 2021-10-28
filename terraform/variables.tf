variable "aws_profile" {
  type        = string
  description = ""
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR for VPC"
  //   default     = "10.0.0.0/16"
}


variable "subnet_a_cidr_block" {
  type        = string
  description = "CIDR for subnet a"
  //   default     = "10.0.2.0/24"
}

variable "subnet_b_cidr_block" {
  type        = string
  description = "CIDR for subnet b"
  //   default     = "10.0.3.0/24"
}

variable "subnet_c_cidr_block" {
  type        = string
  description = "CIDR for subnet c"
  //   default     = "10.0.4.0/24"
}

variable "igw_cidr_block" {
  type        = string
  description = "CIDR for Internet Gateway"
  //   default     = "10.0.0.0/16"
}

// variable "subnet_cidr_block" {
//   type        = string
//   description = "CIDR for subnet"
//   //   default     = "10.0.1.0/24"
// }

variable "availability_zone_a" {
  type        = string
  description = "Availability zone for subnet a"
  //   default     = "us-east-1a"
}

variable "availability_zone_b" {
  type        = string
  description = "Availability zone for subnet b"
  //   default     = "us-east-1b"
}

variable "availability_zone_c" {
  type        = string
  description = "Availability zone for subnet c"
  //   default     = "us-east-1c"
}

variable "ami" {
  type        = string
  description = "ami id used to create ec2 instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type of the EC2 instance"
}

variable "root_block_volume_size" {
  type        = number
  description = "Root block volume size for EC2 instance"
}

variable "root_block_volume_type" {
  type        = string
  description = "Root block volume type for EC2 instance"
}

variable "rds_allocated_storage" {
  type        = number
  description = "RDS instance storage size"
}

variable "rds_storage_type" {
  type        = string
  description = "RDS instance storage type"
}

variable "rds_engine" {
  type        = string
  description = "RDS instance engine"
}

variable "rds_engine_version" {
  type        = string
  description = "RDS instance engine version"
}

variable "rds_multi_az" {
  type        = string
  description = "RDS instance multi az enable"
}

variable "rds_identifier" {
  type        = string
  description = "RDS instance identifier"
}

variable "rds_instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "rds_name" {
  type        = string
  description = "RDS instance name"
}

variable "rds_username" {
  type        = string
  description = "RDS instance master username"
}

variable "rds_password" {
  type        = string
  description = "RDS instance master password"
}

variable "rds_publicly_accessible" {
  type        = string
  description = "RDS instance public access flag"
}

variable "rds_skip_final_snapshot" {
  type        = string
  description = "RDS instance skip final snapshot flag"
}


variable "db_parameter_group_name" {
  type        = string
  description = "DB parameter group name"
}

variable "db_parameter_group_family" {
  type        = string
  description = "DB parameter group family"
}


variable "s3_bucket" {
  type        = string
  description = "S3 bucket name"
}

