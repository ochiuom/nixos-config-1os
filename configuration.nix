{ config, pkgs, lib, ... }:
{
  imports = [
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/power.nix
    ./modules/security.nix
    ./modules/packages.nix
    ./modules/services.nix
  ];

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "uk";

  users.users.ochinix = {
    isNormalUser = true;
    description = "ochinix";
    extraGroups = [ "wheel" "networkmanager" "video" "render" "audio" ];
    initialPassword = "changeme";
  };

  system.stateVersion = "26.05";
}
