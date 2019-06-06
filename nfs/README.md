# NFS provisioning with terraform/ansible
Terraform configuration to deploy nfs server on cloud infrastructures. This assumes that you have an existing cluster or client instance up and running. 


## Steps:
__1. Deploy nfs instance using the terraform configuration nfs:__

`terraform apply -var-file nfs-server.tfvars`

__2. Create an inventory using the terraform state file:__

`terraform-inventory -inventory terraform.tfstate > inventory`

__3. Call ansible nfs-server playbook to install and setup nfs server on the new instance:__

`ansible-playbook -i inventory nfs-server.yaml --key-file ssh_key`

__4. Use your client machine inventory to install and setup nfs client using ansible playbook__

`ansible-playbook -i /path/to/client-inventory nfs-client.yaml --key-file ssh_key`



