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

variable "network_name" {
	default = ""
}

variable "floating_ip_pool" {
	default = ""
}

variable "ssh_user" {
	default = "ubuntu"
}

variable "volume_size" {
  default = 10
}

# create a new security group
resource "openstack_compute_secgroup_v2" "nfs_server" {
  name = "nfs_server"
  description = "Security group for the NFS instance"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }

  rule {
    from_port = 2049
    to_port = 2049
    ip_protocol = "tcp"
    cidr = "10.0.0.0/24"
  }

  rule {
    from_port = 2049
    to_port = 2049
    ip_protocol = "udp"
    cidr = "10.0.0.0/24"
  }

  rule {
    from_port = 111
    to_port = 111
    ip_protocol = "tcp"
    cidr = "10.0.0.0/24"
  }

  rule {
    from_port = 111
    to_port = 111
    ip_protocol = "udp"
    cidr = "10.0.0.0/24"
  }

  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }
}

# create a new openstack instance
resource "openstack_compute_instance_v2" "nfs_server" {
  name              = "nfs_server"
  image_name        = "${var.os_image}"
  flavor_name       = "${var.flavor_name}"
  key_pair          = "${var.keypair}"
  security_groups   = ["${openstack_compute_secgroup_v2.nfs_server.name}"]

  # the network to be attached to the instance
  network {
    name = "${var.network_name}"
  }
}

# create a new volume
resource "openstack_blockstorage_volume_v2" "nfs_volume" {
  name = "nfs_volume"
  size = "${var.volume_size}"
}

# attach volume to instance
# for some reason, this step is not working. I'm attaching manually.
# TODO: review this step
resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = "${openstack_compute_instance_v2.nfs_server.id}"
  volume_id = "${openstack_blockstorage_volume_v2.nfs_volume.id}"
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

