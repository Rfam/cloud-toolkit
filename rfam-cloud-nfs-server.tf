# Terraform configuration to launch an NFS server in an openstack tenancy

# terraform variable declaration

variable "os_image" {
	default = ""
}

variable "flavor_name" {
	default = ""
}

variable "flavor_id" {
	default = ""
}

variable "keypair" {
	default = ""
}

variable "security_group" {
	default = ""
}

variable "network_name" {
	default = ""
}

variable "floating_ip_pool" {
	default = ""
}

variable "ssh_user"{
	default = "ubuntu"
}

## create a new volume
resource "openstack_blockstorage_volume_v2" "nfs_vol" {
  name = "nfs_vol"
  size = 10
}

###############------------INSTANCES-----------###############


# create a new openstack instance
resource "openstack_compute_instance_v2" "nfs_server" {
  name              = "nfs_server"
  image_name        = "${var.os_image}"
  flavor_name       = "${var.flavor_name}" 
  key_pair          = "${var.keypair}"
  security_groups   = ["${var.security_group}"]

  # asign instance to a network
  #connection {
  #private_key = "./ssh_key"
  #}

  # the network to be attached to the instance
  network {
    name = "${var.network_name}"
  }
}

# attach volume to instance
resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = "${openstack_compute_instance_v2.nfs_server.id}"
  volume_id = "${openstack_blockstorage_volume_v2.nfs_vol.id}"
}

# fetch floating ip from floating ip pool
resource "openstack_networking_floatingip_v2" "nfs_server_floating_ip" {
  pool = "${var.floating_ip_pool}"
}

# associate floating IP to instance
resource "openstack_compute_floatingip_associate_v2" "nfs_server_floating_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.nfs_server_floating_ip.address}"
  instance_id = "${openstack_compute_instance_v2.nfs_server.id}"
}

# call ansible to install the nfs server - Currently not working

 # provisioner "remote-exec" {
 #    inline = ["sudo dnf -y install python"]

 #    connection {
 #      type        = "ssh"
 #      user        = "ubuntu"
 #      private_key = "./ssh_key" #"${file(var.ssh_key_private)}"
 #    }
 #  }

 #    provisioner "local-exec" {
 #    command = "ansible-playbook -i '${self.public_ip}' --private-key ssh_key nfs-playbook.yaml --extra-vars host_ip='${self.public_ip}' hostname='${self.nfs_server.name}' network_ip='${self.nfs_server.network.ip}'" 
 #  }




