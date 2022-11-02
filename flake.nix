{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        terraform-bin = "${pkgs.terraform}/bin/terraform";
        mkShellApp = body:
          let script = pkgs.writeShellScript "script.sh" body;
          in {
            type = "app";
            program = "${script}";
          };

      in rec {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            openssh
            sops
            terraform
            openstackclient
            gh
            mosh
          ];
        };

        devShell = devShells.default;

        apps = {
          plan = mkShellApp ''
            ${terraform-bin} plan -out tfplan
          '';

          apply = mkShellApp ''
            ${terraform-bin} apply tfplan
          '';

          login = mkShellApp ''
            SERVER_IP=$(${terraform-bin} output --raw server-ip)
            set -x
            mosh --ssh="ssh -i ssh_private_key" root@$SERVER_IP
          '';

          deploy = mkShellApp ''
            if [ -z "$NIXOS_SERVER_IP" ]
            then
              NIXOS_SERVER_IP=$(${terraform-bin} output --raw server-ip)
            fi

            export NIX_SSHOPTS="-o StrictHostKeyChecking=no -i ssh_private_key"
            ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#gandi-nixos --target-host root@$NIXOS_SERVER_IP
          '';

          destroy = mkShellApp ''
            ${terraform-bin} destroy
          '';
        };
      }) // (let pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in {

        nixosConfigurations.gandi-nixos = nixpkgs.lib.nixosSystem {
          inherit pkgs;

          system = "x86_64-linux";
          modules = [
            (nixpkgs + "/nixos/modules/virtualisation/openstack-config.nix")
            ./nixos/default.nix
            # ./nixos/hardware-configuration.nix
          ];

        };
      });
}
