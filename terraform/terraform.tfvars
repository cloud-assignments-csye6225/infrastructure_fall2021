// provider "aws" {
//     region = "us-east-1"
//     profile = 
// }

aws_profile = "prod"

vpc_cidr_block = "10.0.0.0/16"


subnet_a_cidr_block = "10.0.2.0/24"
subnet_b_cidr_block = "10.0.3.0/24"
subnet_c_cidr_block = "10.0.4.0/24"

igw_cidr_block = "0.0.0.0/0"

availability_zone_a = "us-east-1a"
availability_zone_b = "us-east-1b"
availability_zone_c = "us-east-1c"
// subnet_cidr_block = "10.0.1.0/24"

ami                    = "ami-09e67e426f25ce0d7"
instance_type          = "t2.micro"
root_block_volume_size = 20
root_block_volume_type = "gp2"

rds_allocated_storage   = 20
rds_storage_type        = "gp2"
rds_engine              = "postgres"
rds_engine_version      = "9.6.11"
rds_multi_az            = "false"
rds_identifier          = "csye6225"
rds_instance_class      = "db.t3.micro"
rds_name                = "csye6225"
rds_username            = "csye6225"
rds_password            = "multi-bun#6969"
rds_publicly_accessible = "false"
rds_skip_final_snapshot = "true"

db_parameter_group_name   = "postgres-parameters"
db_parameter_group_family = "postgres9.6"

s3_bucket = "kdab.dev.domain.tld"