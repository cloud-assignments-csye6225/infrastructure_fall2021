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