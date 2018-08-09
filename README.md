# terraform-aws-mvd: Terraform repo for Minimal Viable Deployment (MVD) on AWS

This terraform configuration provisions the following elements. It can be used as a module, please see [examples/](examples/) directory.
- A VPC.
- 2 Public Subnets
- 2 Private Subnets
- A set of servers in an Auto Scaling Group (ASG) in the public subnet

### Input Variables
- Required:
  - Set `AWS_ACCESS_KEY_ID` and `AWS_ACCESS_KEY_ID` Environment variables to configure AWS provider
  - `id_rsa_pub` - To generate a new one: `ssh-keygen -t rsa -N "" -C "<email>" -f ~/.ssh/mvd_id_rsa"`
  - `owner` -  sets a Owner tag

- Optional:
  - Please see [variables.tf](variables.tf) file for all optional inputs.
  - `aws_region` -  set the AWS region where this should be provisioned. Default is `us-east-2`

### Outputs
- Currently none
