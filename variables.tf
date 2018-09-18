variable "id_rsa_pub" {
	description = "The public key for SSH login."
}

variable "owner" {
  description = "An Owner tag"
}

variable "user_data_file_path" {
	description = "Path for user_data script."
	default = "user-data.sh"
}

variable "aws_region" {
	description = "The AWS region this infrastructure should be provisioned in"
	default = "us-east-2"
}

variable "environment" {
	 default = "Production"
}

variable "asg_size_map"{
  type = "map"
  default = {
    min = 1,
    desired = 1,
    max = 1
  }
}

variable "instance_size"{
  default = "t2.micro"
}

variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 14.04 Base Image"
  type = "map"
  default = {
    us-east-1 = "ami-759bc50a",
    us-east-2 = "ami-5e8bb23b"
  }
}

variable "App" {
  default = "mvd-app"
}


variable "name" {
  description = "name to pass to Name tag"
  default = "mvd-server"
}

variable "ttl" {
  description = "A desired time to live (not enforced via terraform)"
  default = "24"
}

variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "public_subnet_1_block" {
  default = "192.168.0.0/21"
}

variable "public_subnet_2_block" {
  default = "192.168.8.0/21"
}

variable "private_subnet_1_block" {
  default = "192.168.16.0/21"
}

variable "private_subnet_2_block" {
  default = "192.168.24.0/21"
}
