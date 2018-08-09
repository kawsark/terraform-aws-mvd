### Steps:
- Setup workspace:
```
git clone git@github.com:kawsark/terraform-aws-mvd.git
cd terraform-aws-mvd.git/examples/example-minimum
export AWS_ACCESS_KEY_ID=<access-key-id>
export AWS_SECRET_ACCESS_KEY=<secret-access-key>
export TF_VAR_owner=$(whoami)
export TF_VAR_id_rsa_pub_path="<path_to_id_rsa.pub>"
```

- Terraform:
```
terraform plan
terraform apply
```
