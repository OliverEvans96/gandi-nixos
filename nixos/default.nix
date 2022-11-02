{ config, lib, pkgs, ... }:

{
  networking.hostName = "gandi-nixos-r1";
  system.stateVersion = "22.05";

  services.openssh.enable = true;
  programs.mosh.enable = true;
  environment.systemPackages = with pkgs; [ htop tmux ];
}
