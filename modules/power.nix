{ config, pkgs, lib, ... }:
{
  # SUSPECT #1 — independent MSR-level power clamp, stacks on top of everything TLP does.
  # Re-enable this FIRST and test alone before touching anything else below.
  # services.throttled.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
      # SUSPECT #2 — most aggressive efficiency setting; try "balance_power" instead if re-testing.
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_BOOST_ON_AC  = 1;
      # SUSPECT #3 — turbo fully disabled on battery, on top of governor + energy policy already low.
      CPU_BOOST_ON_BAT = 0;

      CPU_HWP_DYN_BOOST_ON_AC  = 1;
      # SUSPECT #4 — dynamic boost also disabled on battery; combined with #2 and #3 this is 3 throttles at once.
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      START_CHARGE_THRESH_BAT0 = 70;
      STOP_CHARGE_THRESH_BAT0  = 80;
      START_CHARGE_THRESH_BAT1 = 70;
      STOP_CHARGE_THRESH_BAT1  = 80;

      DISK_DEVICES = "nvme0n1";
      DISK_APM_LEVEL_ON_AC  = 254;
      DISK_APM_LEVEL_ON_BAT = 128;
      AHCI_RUNTIME_PM_ON_AC  = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";

      PCIE_ASPM_ON_AC  = "default";
      # SUSPECT #5 — most aggressive PCIe link-power state; can cause latency/stutter on some hardware.
      PCIE_ASPM_ON_BAT = "powersupersave";

      RUNTIME_PM_ON_AC  = "on";
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = 1;
      WIFI_PWR_ON_AC  = "off";
      WIFI_PWR_ON_BAT = "on";
      WOL_DISABLE = "Y";

      PLATFORM_PROFILE_ON_AC  = "performance";
      # SUSPECT #6 — depends on ThinkPad L14 actually exposing /sys/firmware/acpi/platform_profile;
      # if unsupported this silently no-ops, if supported it's a 4th/5th simultaneous throttle on battery.
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

  boot.kernel.sysctl = {
    # VM performance
    "vm.swappiness"          = 10;
    "vm.vfs_cache_pressure"  = 100;
    "vm.dirty_ratio"         = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_writeback_centisecs" = 1500;
    # Network performance
    "net.core.rmem_max" = 2500000;
  };

  services.irqbalance.enable = true;
}
