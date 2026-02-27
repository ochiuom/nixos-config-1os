{ config, pkgs, lib, ... }:
{
  security.sudo-rs.enable = true;


  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      firefox = {
        executable = "${pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
        extraArgs = [ "--private-dev" "--noroot" ];
      };
    };
  };
}
