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
