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
    github = {
      source  = "integrations/github"
      version = "5.7.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

# Gandi Cloud VPS (via OpenStack)

# Configure the OpenStack Provider
provider "openstack" {
  user_name        = data.sops_file.secrets.data["gandi.username"]
  user_domain_name = "public"
  auth_url         = "https://keystone.sd6.api.gandi.net:5000/v3"
  password         = data.sops_file.secrets.data["gandi.password"]
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

# Generate SSH key to login to the server
resource "openstack_compute_keypair_v2" "nixos-keypair" {
  name = "nixos-keypair"
}

# Write SSH key to local file
resource "local_sensitive_file" "ssh-private-key-file" {
  content  = resource.openstack_compute_keypair_v2.nixos-keypair.private_key
  filename = "ssh_private_key"
}

# Create a storage volume
resource "openstack_blockstorage_volume_v3" "nixos-volume" {
  name        = "nixos-volume"
  description = "20GB nixos volume"
  image_id    = data.openstack_images_image_v2.nixos.id
  size        = 20 # GiB
}

# Create a compute instance
resource "openstack_compute_instance_v2" "nixos" {
  name      = "gandi-nixos-r1"
  flavor_id = data.openstack_compute_flavor_v2.v-r1.id
  key_pair  = resource.openstack_compute_keypair_v2.nixos-keypair.name

  block_device {
    uuid             = resource.openstack_blockstorage_volume_v3.nixos-volume.id
    source_type      = "volume"
    destination_type = "volume"
  }
}

# GitHub

provider "github" {
  token = data.sops_file.secrets.data["github.token"]
}

data "external" "github-repo-name" {
  program = ["gh", "repo", "view", "--json", "nameWithOwner"]
}

data "github_repository" "github-origin" {
  full_name = data.external.github-repo-name.result["nameWithOwner"]
}

resource "github_actions_secret" "nixos-server-ip" {
  repository      = data.github_repository.github-origin.name
  secret_name     = "nixos_server_ip"
  plaintext_value = resource.openstack_compute_instance_v2.nixos.access_ip_v4
}

resource "github_actions_secret" "ssh-private-key" {
  repository      = data.github_repository.github-origin.name
  secret_name     = "ssh_private_key"
  plaintext_value = resource.openstack_compute_keypair_v2.nixos-keypair.private_key
}
