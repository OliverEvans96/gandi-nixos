{ config, lib, pkgs, ... }:

{
  networking.hostName = "test-hostname";
  system.stateVersion = "22.05";
  services.openssh.enable = true;
  programs.mosh.enable = true;
}
