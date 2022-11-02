# Gandi NixOS Deployment with Terraform

1. Insert secrets (Gandi username/password)

``` sh
sops secrets.yaml
```

2. Plan

``` sh
nix run .#plan
```

3. Apply (spin up server)

``` sh
nix run .#apply
```

4. Deploy NixOS config (via nixos-rebuild / SSH)

``` sh
nix run .#deploy
```


5. Login via SSH (via mosh)

``` sh
nix run .#login
```

6. Destroy (spin down server)

``` sh
nix run .#destroy
```

# Useful links

- [Gandi + Terraform](https://docs.gandi.net/en/cloud/vps/api/index.html)
- [Terraform OpenStack Provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- [sops w/ age](https://github.com/mozilla/sops#encrypting-using-age)
- [.sops.yaml config file](https://github.com/mozilla/sops#using-sops-yaml-conf-to-select-kms-pgp-for-new-files)
