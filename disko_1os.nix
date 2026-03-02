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
# TO SWITCH SCENARIOS:
#   - Scenario A is active below
#   - Comment it out and uncomment Scenario B if needed
# =============================================================


## =============================================================
# TO RUN:
#   # 1. Clone config and run Disko
#    git clone https://github.com/ochiuom/nixos-config
#    cd nixos-config
#    git checkout disko-declarative
#    Flakes are not enabled by default there.
#    Run everything with experimental features enabled.
#    sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode format,mount ./disko.nix

#   sbctl create-keys
#   Secure boot keys created!
#   nix-shell -p e2fsprogs
#   it will give u inside nix shell
#   chattr -i /sys/firmware/efi/efivars/*
#   sbctl enroll-keys --microsoft
#   then u need to exit from nix shell
#   again exit from chroot /
#   now back in live iso git config
#   sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#nixos-install -- --flake .#ochinix-pc
#   5gb download, total 16GB disk space
#   put root password
#   reboot
#   "changeme" passowrd
#
# =============================================================
# SCENARIO A — Dual Boot (Windows already installed)
#   References existing partitions directly — does NOT touch
#   the partition table, Windows partition, or EFI layout.
#   Only formats nvme0n1p4 (LUKS2 + btrfs).
#   Active by default — comment out if using Scenario B.
# =============================================================

#{ lib, ... }:

#let
#  mountOpts = [
#    "compress=zstd:1"
#    "noatime"
#    "discard=async"
#    "autodefrag"
#  ];
#in
#{
#  disko.devices = {
#
#    # We are NOT redefining the disk or GPT.
#    # We only define the partitions we manage.
#
#    disk.main = {
#      type = "disk";
#      device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA23010K50512A";
#
#      content = {
#        type = "gpt";
#
#        partitions = {
#
#          # Existing EFI (DO NOT FORMAT)
#          ESP = {
#            device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA23010K50512A-part1";
#            type = "EF00";
#
#            content = {
#              type = "filesystem";
#              format = "vfat";
#              mountpoint = "/boot";
#            };
#          };
#
#          # Existing NixOS partition (p4)
#          nixos = {
#            device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNU512GZ_BTKA23010K50512A-part4";
#
#            content = {
#              type = "luks";
#              name = "cryptroot";
#              askPassword = true;
#
#              settings = {
#                allowDiscards = true;
#                bypassWorkqueues = true;
#               };
#
#              extraFormatArgs = [
#                "--type" "luks2"
#                "--cipher" "aes-xts-plain64"
#                "--key-size" "512"
#                "--hash" "sha512"
#                "--pbkdf" "argon2id"
#              ];
#
#              content = {
#                type = "btrfs";
#                extraArgs = [ "-f" "-L" "nixos" ];
#
#                subvolumes = {
#                  "@"          = { mountpoint = "/";           mountOptions = mountOpts; };
#                  "@home"      = { mountpoint = "/home";       mountOptions = mountOpts; };
#                  "@nix"       = { mountpoint = "/nix";        mountOptions = mountOpts; };
#                  "@snapshots" = { mountpoint = "/.snapshots"; mountOptions = mountOpts; };
#                  "@var-log"   = { mountpoint = "/var/log";    mountOptions = mountOpts; };
#                  "@tmp"       = { mountpoint = "/tmp";        mountOptions = mountOpts; };
#                };
#              };
#            };
#          };
#
#        };
#      };
#    };
#  };
#}


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
              mountpoint = "/boot/efi";
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
