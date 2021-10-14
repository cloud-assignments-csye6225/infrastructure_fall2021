# infrastructure

This code base contains terraform code to configure AWS resources

# Build pipeline
1) git clone git@github.com:kartheekdabbiru97/infrastructure.git
2) Add terraform.tfVars file to pas inputs on the path /infrastructure/terraform
3) Run terraform init to initialize the terraform package
4) Use the command ' terraform fmt ' to format the contents of the files
5) Run terraform plan and observe the AWS resource changes reported on CLI
6) Run terraform apply -> 'yes'

Login through respective AWS IAM user to verify if all the resources configured in terraform files are
reflected properly on the AWS console.

# Additional files required
terraform.tfvars