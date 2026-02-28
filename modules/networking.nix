{ config, pkgs, lib, ... }:
{
  networking.hostName = "ochinix-pc";
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 1716 53317 ];
    allowedUDPPorts = [ 1716 53317 ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      # To add a new client:
      # 1. Set PasswordAuthentication = true and rebuild
      # 2. Run ssh-copy-id user@192.168.31.14 from new client
      # 3. Set PasswordAuthentication = false and rebuild
      PasswordAuthentication = false;
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
    jails = {
      ssh = {
        settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          maxretry = 3;
          bantime = "2h";
        };
      };
    };
  };
}
