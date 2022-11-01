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
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ ssh sops terraform openstackclient ];
        };

        apps = {
          plan = let
            script = pkgs.writeShellScript "plan.sh" ''
              ${terraform-bin} plan -out tfplan
            '';
          in {
            type = "app";
            program = "${script}";
          };

          apply = let
            script = pkgs.writeShellScript "apply.sh" ''
              ${terraform-bin} apply tfplan
            '';
          in {
            type = "app";
            program = "${script}";
          };

          login = let
            script = pkgs.writeShellScript "login.sh" ''
              SERVER_IP=$(${terraform-bin} output --raw server-ip)
              ssh root@$SERVER_IP
            '';
          in {
            type = "app";
            program = "${script}";
          };
        };
      });
}
