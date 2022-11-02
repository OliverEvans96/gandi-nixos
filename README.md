# Gandi NixOS Deployment with Terraform

This repository demonstrates :
- provisioning of a NixOS compute instance on GandiCloud VPS via Terraform
- reading encrypted cloud credentials from terraform with sops
- deploying to the new server via nixos-rebuild
- dynamic creation of github action secrets from terraform deployment outputs
- a github action to deploy NixOS configurations to the server

## Usage
``` sh
# 1. Insert secrets (Gandi username/password + GitHub token)
sops secrets.yaml

# 2. Plan terraform deployment
nix run .#plan

# 3. Terraform apply (spin up server)
nix run .#apply

# 4. Deploy NixOS config (via nixos-rebuild / SSH)
nix run .#deploy

# 5. Login via SSH (via mosh)
nix run .#login

# 6. Destroy (spin down server)
nix run .#destroy
```

# Useful links

- [Gandi + Terraform](https://docs.gandi.net/en/cloud/vps/api/index.html)
- [OpenStack Terraform Provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- [sops w/ age](https://github.com/mozilla/sops#encrypting-using-age)
- [.sops.yaml config file](https://github.com/mozilla/sops#using-sops-yaml-conf-to-select-kms-pgp-for-new-files)
- [GitHub Terraform Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
