# Configuring the master or edge node
Ansible playbook to configure master. This assumes that you have an existing cluster up and running. 

## Requirements
1. terraform-inventory
2. ansible

## Steps:

__1. Access your configuration directory (the one that contains the SSH key pair and the Terraform config template):__

`cd my_deployment`

__2. Create an inventory using the terraform state file:__

`terraform-inventory -inventory terraform.tfstate > hosts`

__3. Call ansible playbook to install and setup master server:__

`ansible-playbook -i hosts master.yml`
