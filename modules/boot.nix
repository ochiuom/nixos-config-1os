{ config, pkgs, lib, ... }:
{
  boot.loader.systemd-boot.enable          = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables     = true;
  boot.loader.efi.efiSysMountPoint         = "/boot";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "i915" ];

  boot.plymouth = {
    enable = true;
    theme  = "bgrt";
  };

  boot.initrd.systemd.enable = true;
  boot.consoleLogLevel       = 0;
  boot.initrd.verbose        = false;

  boot.kernelParams = [
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
    "quiet"
    "splash"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "mem_sleep_default=deep"
    "nowatchdog"
    "nmi_watchdog=0"
    "vm.dirty_writeback_centisecs=1500"
  ];

  # ── Faster LUKS decrypt via AES-NI bypass ────────────────────────────
  boot.initrd.luks.devices = lib.mapAttrs (_: _: {
    bypassWorkqueues = true;
  }) config.boot.initrd.luks.devices;

  # ── Move home-manager out of critical boot path ───────────────────────
  # Prevents 16s block between LUKS unlock and login screen.
  # Desktop may snap in 2-3s after login — acceptable tradeoff.
  systemd.services.home-manager-ochinix = {
    after    = lib.mkForce [ "network.target" ];
    wantedBy = lib.mkForce [ "multi-user.target" ];
  };

  systemd.settings.Manager.RuntimeWatchdogSec = "30s";
  systemd.settings.Manager.RebootWatchdogSec  = "10s";
}
