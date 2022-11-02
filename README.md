# Gandi NixOS Deployment with Terraform



## Usage
``` sh
# 1. Insert secrets (Gandi username/password)
sops secrets.yaml

# 2. Plan deployment
nix run .#plan

# 3. Apply (spin up server)
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
