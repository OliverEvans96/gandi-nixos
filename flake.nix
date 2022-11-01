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

      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ ssh sops terraform openstackclient ];
        };

        apps = {
          plan = mkShellApp ''
            ${terraform-bin} plan -out tfplan
          '';

          apply = mkShellApp ''
            ${terraform-bin} apply tfplan
          '';

          login = mkShellApp ''
            SERVER_IP=$(${terraform-bin} output --raw server-ip)
            echo "ssh root@$SERVER_IP"
            ssh root@$SERVER_IP
          '';

          destroy = mkShellApp ''
            ${terraform-bin} destroy
          '';
        };
      });
}
