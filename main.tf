# Terraform configuration for Minimum Viable Deployment (MVD)

provider "aws" {
 # AWS provider configured via environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  region = "${var.aws_region}"
}

# Internet VPC
resource "aws_vpc" "mvd_vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name = "mvd_vpc"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

# Subnets
resource "aws_subnet" "mvd-public-1" {
  vpc_id                  = "${aws_vpc.mvd_vpc.id}"
  cidr_block              = "${var.public_subnet_1_block}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${format("%sa",var.aws_region)}"

  tags {
    Name = "mvd-public-1"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

resource "aws_subnet" "mvd-public-2" {
  vpc_id                  = "${aws_vpc.mvd_vpc.id}"
  cidr_block              = "${var.public_subnet_2_block}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${format("%sb",var.aws_region)}"

  tags {
    Name = "mvd-public-2"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

resource "aws_subnet" "mvd-private-1" {
  vpc_id                  = "${aws_vpc.mvd_vpc.id}"
  cidr_block              = "${var.private_subnet_1_block}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${format("%sa",var.aws_region)}"

  tags {
    Name = "mvd-private-1"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

resource "aws_subnet" "mvd-private-2" {
  vpc_id                  = "${aws_vpc.mvd_vpc.id}"
  cidr_block              = "${var.private_subnet_2_block}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${format("%sb",var.aws_region)}"

  tags {
    Name = "mvd-private-2"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

# Internet GW
resource "aws_internet_gateway" "mvd-gw" {
  vpc_id = "${aws_vpc.mvd_vpc.id}"

  tags {
    Name = "mvd-gw"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

#Public route table with IGW
resource "aws_route_table" "mvd-public" {
  vpc_id = "${aws_vpc.mvd_vpc.id}"

tags {
    Name = "mvd-public-1"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

#Public route
resource "aws_route" "mvd-public-route" {
  route_table_id = "${aws_route_table.mvd-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.mvd-gw.id}"
}

# route associations public
resource "aws_route_table_association" "mvd-public-1-a" {
  subnet_id      = "${aws_subnet.mvd-public-1.id}"
  route_table_id = "${aws_route_table.mvd-public.id}"
}

resource "aws_route_table_association" "mvd-public-2-a" {
  subnet_id      = "${aws_subnet.mvd-public-2.id}"
  route_table_id = "${aws_route_table.mvd-public.id}"
}

resource "aws_security_group" "mvd-sg" {
  vpc_id      = "${aws_vpc.mvd_vpc.id}"
  description = "security group that allows ssh and all egress traffic"

  tags {
    Name = "mvd-sg"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

resource "aws_security_group_rule" "egress_allow_all" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.mvd-sg.id}"
}

resource "aws_security_group_rule" "ingress_allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.mvd-sg.id}"
}


# nat gw
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.mvd-public-1.id}"
  depends_on    = ["aws_internet_gateway.mvd-gw"]
}

#Private route table with NAT
resource "aws_route_table" "mvd-private" {
  vpc_id = "${aws_vpc.mvd_vpc.id}"

  tags {
    Name = "mvd-private-1"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

#Private route
resource "aws_route" "mvd-private-route" {
  route_table_id = "${aws_route_table.mvd-private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
}


# route associations private
resource "aws_route_table_association" "mvd-private-1-a" {
  subnet_id      = "${aws_subnet.mvd-private-1.id}"
  route_table_id = "${aws_route_table.mvd-private.id}"
}

resource "aws_route_table_association" "mvd-private-1-b" {
  subnet_id      = "${aws_subnet.mvd-private-2.id}"
  route_table_id = "${aws_route_table.mvd-private.id}"
}


#User data
data "template_file" "user_data" {
  template = "${file(var.user_data_file_path)}"
}

#Launch configuration
resource "aws_launch_configuration" "mvdserver_lc" {
  name_prefix   = "mvdserver-"
  image_id      = "${lookup(var.ami_id, var.aws_region)}"
  instance_type = "${var.instance_size}"

  key_name = "${aws_key_pair.mvdkeypair.key_name}"

  security_groups = ["${aws_security_group.mvd-sg.id}"]

  lifecycle {
      create_before_destroy = true
  }

  #user_data = "${file(var.user_data_file_path)}"
  user_data = "${data.template_file.user_data.rendered}"

}

#Auto Scaling group
resource "aws_autoscaling_group" "mvdserver_asg" {
  launch_configuration = "${aws_launch_configuration.mvdserver_lc.name}"
  min_size	       = "${var.asg_size_map["min"]}"
  max_size	       = "${var.asg_size_map["max"]}"
  desired_capacity     = "${var.asg_size_map["desired"]}"
  health_check_type    = "EC2"

  vpc_zone_identifier       = ["${aws_subnet.mvd-public-1.id}", "${aws_subnet.mvd-public-2.id}"]

 tags = [
    {
      key                 = "App"
      value               = "${var.App}"
      propagate_at_launch = true
    },
    {
      key                 = "Env"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.name}"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = "${var.owner}"
      propagate_at_launch = true
    },
    {
      key                 = "TTL"
      value               = "${var.ttl}"
      propagate_at_launch = true
    }
  ]

  lifecycle {
      create_before_destroy = true
  }

}

resource "aws_key_pair" "mvdkeypair" {
  key_name   = "mvdkeypair"
  public_key = "${var.id_rsa_pub}"
}
