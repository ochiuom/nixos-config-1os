# =============================================================
# Disko — Declarative Disk Configuration
# =============================================================
#
# BEFORE RUNNING: confirm your NVMe device name
#   lsblk   →   make sure it is nvme0n1 and not nvme1n1 etc.
# =============================================================
# DISKO LAYOUT VISUAL GUIDE
# =============================================================
#
# ┌─────────────────────────────────────────────────────────┐
# │ SCENARIO A — DUAL BOOT (Windows already installed)     │
# └─────────────────────────────────────────────────────────┘
#
#   nvme0n1
#   ├─ nvme0n1p1   200M     EFI (REUSED, NOT FORMATTED)
#   ├─ nvme0n1p3   ???    Windows (UNTOUCHED)
#   └─ nvme0n1p4   rest   LUKS2 → BTRFS
#                         ├─ @            → /
#                         ├─ @home        → /home
#                         ├─ @nix         → /nix
#                         ├─ @snapshots   → /.snapshots
#                         ├─ @var-log     → /var/log
#                         └─ @tmp         → /tmp
#
#   ✔ Partition table NOT modified
#   ✔ EFI NOT formatted
#   ✔ Windows NOT touched
#   ✔ Only p4 formatted
#
# =============================================================
#
# ┌─────────────────────────────────────────────────────────┐
# │ SCENARIO B — FULL DISK (NO WINDOWS)                    │
# └─────────────────────────────────────────────────────────┘
#
#   nvme0n1  (ENTIRE DISK WIPED)
#   ├─ nvme0n1p1   1G     EFI (FORMATTED FAT32)
#   └─ nvme0n1p2   rest   LUKS2 → BTRFS
#                         ├─ @            → /
#                         ├─ @home        → /home
#                         ├─ @nix         → /nix
#                         ├─ @snapshots   → /.snapshots
#                         ├─ @var-log     → /var/log
#                         └─ @tmp         → /tmp
#
#   ✔ GPT recreated
#   ✔ EFI formatted
#   ✔ All data erased
#
# =============================================================
# #   - Scenario B is active below
#     - Scenario A:  if needed follow https://github.com/ochiuom/nixos-config
# =============================================================


## =============================================================


# =============================================================
# SCENARIO B — Full Disk NixOS only (no Windows)
#   Wipes the entire drive. Creates fresh GPT with 1G EFI
#   and the rest as LUKS2 + btrfs.
#   To use: comment out Scenario A above and uncomment below.
# =============================================================

{ lib, ... }:

let
  mountOpts = [
    "noatime"
    "compress=zstd"
    "ssd"
    "discard=async"
  ];
in
{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-KBG40ZNT256G_TOSHIBA_MEMORY_90SPCCRXQA81";
      type = "disk";

      content = {
        type = "gpt";

        partitions = {

          ESP = {
            size = "1G";
            type = "EF00";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          crypt = {
            size = "100%";

            content = {
              type = "luks";
              name = "cryptroot";
              askPassword = true;

              settings = {
                allowDiscards = true;
              };

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "@"          = { mountpoint = "/";           mountOptions = mountOpts; };
                  "@home"      = { mountpoint = "/home";       mountOptions = mountOpts; };
                  "@nix"       = { mountpoint = "/nix";        mountOptions = mountOpts; };
                  "@snapshots" = { mountpoint = "/.snapshots"; mountOptions = mountOpts; };
                  "@var-log"   = { mountpoint = "/var/log";    mountOptions = mountOpts; };
                  "@tmp"       = { mountpoint = "/tmp";        mountOptions = mountOpts; };
                };
              };
            };
          };
        };
      };
    };
  };
}
