This example uses Terraform Enterprise Private Module Repository (PMR)

### Steps:
- Setup workspace:
```
git clone git@github.com:kawsark/terraform-aws-mvd.git
cd terraform-aws-mvd.git/examples/private_module_repository
export AWS_ACCESS_KEY_ID=<access-key-id>
export AWS_SECRET_ACCESS_KEY=<secret-access-key>
export TF_VAR_owner=$(whoami)
export TF_VAR_id_rsa_pub="$(cat <path_to_id_rsa.pub>)"
```

- Terraform:
```
terraform plan
terraform apply
```

### Updating a new release for Private Module Repository:
```
export TAG=v0.1
git tag ${TAG}
git tag -l
git push origin --tags
```