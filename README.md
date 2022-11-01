# Gandi NixOS Deployment with Terraform

1. Insert secrets (Gandi username/password)

``` sh
sops secrets.yaml
```

## Plan

``` sh
nix run .#plan
```

which runs

``` sh
terraform plan -out tfplan
```

## Apply (spin up server)

``` sh
nix run .#apply
```

which runs

``` sh
terraform apply tfplan
```

## Login via SSH

``` sh
nix run .#login
```

which runs

``` sh
SERVER_IP=$(terraform output --raw server-ip)
ssh root@$SERVER_IP
```

## Destroy (spin down server)

``` sh
nix run .#destroy
```

which runs

``` sh
terraform plan -out tfplan
```

## Deploy

TODO: How to deploy new NixOS configs

# Useful links

- [Gandi + Terraform](https://docs.gandi.net/en/cloud/vps/api/index.html)
- [Terraform OpenStack Provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- [sops w/ age](https://github.com/mozilla/sops#encrypting-using-age)
- [.sops.yaml config file](https://github.com/mozilla/sops#using-sops-yaml-conf-to-select-kms-pgp-for-new-files)
