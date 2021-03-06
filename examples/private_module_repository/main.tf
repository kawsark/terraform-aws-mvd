variable "id_rsa_pub" {
  description = "The public key file contents for SSH login."
}

variable "owner" {
  description = "An Owner tag"
}

module "aws_minimum_viable_deployment" {
  source = "app.terraform.io/kawsar-org/mvd/aws"

  owner               = "${var.owner}"
  id_rsa_pub          = "${var.id_rsa_pub}"
  user_data_file_path = "${path.module}/user-data.sh"
}
