variable "id_rsa_pub" {
	description = "The public key file contents for SSH login."
}

variable "owner" {
  description = "An Owner tag"
}

module "aws_minimum_viable_deployment" {
  source = "app.terraform.io/kawsark/terraform-aws-mvd"

  owner = "${var.owner}"
  id_rsa_pub = "${var.id_rsa_pub}"
  user_data_file_path = "user-data.sh"

}
