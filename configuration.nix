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
    ./modules/nixos/gdm.nix
  ];

  # ── Locale ───────────────────────────────────────────────────────────────────
  time.timeZone      = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME        = "en_GB.UTF-8";
    LC_PAPER       = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
  };
  console.keyMap = "uk";

  # ── User ─────────────────────────────────────────────────────────────────────
  users.users.ochinix = {
    isNormalUser = true;
    description  = "ochinix";
    extraGroups  = [ "wheel" "networkmanager" "video" "render" "audio" ];
    initialPassword = "changeme"; # replace with hashedPasswordFile + sops post first deploy
  };

  # ── Nix ──────────────────────────────────────────────────────────────────────
  nix.settings.trusted-users = [ "root" "ochinix" ];

  # ── Environment ──────────────────────────────────────────────────────────────
  # environment.defaultPackages = []; # remove implicit nano, perl, strace etc.
  environment.defaultPackages = lib.mkForce [ pkgs.nano ];
  system.stateVersion = "26.05";
}
