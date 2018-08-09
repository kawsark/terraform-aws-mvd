variable "id_rsa_pub_path" {
	description = "The public key file path for SSH login."
}

variable "owner" {
  description = "An Owner tag"
}

module "aws_minimum_viable_deployment" {
  source = "../../"
  #source = "github.com/kawsark/terraform-aws-mvd"

  owner = "${var.owner}"
  id_rsa_pub_path = "${var.id_rsa_pub_path}"
  user_data_file_path = "../../user-data.sh"

}
