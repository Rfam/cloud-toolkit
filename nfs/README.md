# NFS provisioning with terraform/ansible
Terraform configuration to deploy nfs server on cloud infrastructures. This assumes that you have an existing cluster or client instance up and running. 

## Requirements
1. terraform
2. terraform-inventory
3. ansible

## Steps:
__1. Initialize terraform:__

`terraform init`

__2. Deploy nfs instance using the terraform configuration nfs:__

`terraform apply -var-file nfs-server.tfvars`

__3. Create an inventory using the terraform state file:__

`terraform-inventory -inventory terraform.tfstate > inventory`

__4. Call ansible nfs-server playbook to install and setup nfs server on the new instance:__

`ansible-playbook -i inventory nfs-server-playbook.yaml --key-file ssh_key --extra-vars "network_ip=subnet_ip"`

__5. Use your client machine inventory to install and setup nfs client using ansible playbook__

`ansible-playbook -i /path/to/client-inventory nfs-client-playbook.yaml --key-file ssh_key`



