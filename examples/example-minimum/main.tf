variable "id_rsa_pub" {
  description = "The public key for SSH login."
}

variable "owner" {
  description = "An Owner tag"
}

module "aws_minimum_viable_deployment" {
  source = "../../"
  #source = "github.com/kawsark/terraform-aws-mvd"

  owner               = "${var.owner}"
  id_rsa_pub          = "${var.id_rsa_pub}"
  user_data_file_path = "${path.module}/user-data.sh"
}
