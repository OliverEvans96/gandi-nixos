terraform {
  required_version = ">= 0.14.0"
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name        = data.sops_file.secrets.data["username"]
  user_domain_name = "public"
  auth_url         = "https://keystone.sd6.api.gandi.net:5000/v3"
  password         = data.sops_file.secrets.data["password"]
}

# Query the Gandi NixOS image
data "openstack_images_image_v2" "nixos" {
  name        = "NixOS"
  most_recent = true
}

# The compute instance type (V-R1)
data "openstack_compute_flavor_v2" "v-r1" {
  vcpus = 1
  ram   = 1024
}

# SSH key to login to the server
data "openstack_compute_keypair_v2" "oliver-laptop" {
  name = "oliver-laptop"
}

# Create a compute instance
resource "openstack_compute_instance_v2" "nixos" {
  name      = "gandi-nixos-r1"
  flavor_id = data.openstack_compute_flavor_v2.v-r1.id
  key_pair  = data.openstack_compute_keypair_v2.oliver-laptop.name

  block_device {
    source_type      = "image"
    destination_type = "volume"
    uuid             = data.openstack_images_image_v2.nixos.id
    volume_size      = 20 # GiB
  }
}
