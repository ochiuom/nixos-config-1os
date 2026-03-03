# NixOS Configuration — ThinkPad L14 Gen1

Personal NixOS flake configuration for a Lenovo ThinkPad L14 Gen1 running a pure Wayland GNOME desktop.

> **This config is a full wipe — single OS, entire drive, no dual boot, no Secure Boot.**
> Installation is PXE-only (restricted BIOS, no USB boot option).
>
> Looking for dual boot, Secure Boot, or lanzaboote? See the T480s config instead:
> https://github.com/ochiuom/nixos-config

---

## Hardware

| Component | Detail |
| --- | --- |
| Machine | Lenovo ThinkPad L14 Gen1 |
| CPU | Intel Core i5-10210U (CometLake-U) |
| GPU | Intel UHD Graphics (CometLake-U GT2) |
| RAM | 16GB (~1.2GB used at idle after full boot) |
| Swap | 7.6GB zram (zstd compressed, in-RAM) |
| Storage | 238.5GB NVMe SSD — Toshiba KBG40ZNT256G (LUKS2 encrypted, btrfs) |
| Bluetooth | Intel — disabled on boot |

---

## Disk Layout
```
nvme0n1 (238.5GB NVMe — Toshiba KBG40ZNT256G)
├─ nvme0n1p1     1GB      /boot (EFI — systemd-boot)
└─ nvme0n1p2   237.5GB   LUKS2 encrypted
   └─ cryptroot (btrfs subvolumes)
      ├─ @              /
      ├─ @home          /home
      ├─ @nix           /nix
      ├─ @snapshots     /.snapshots
      ├─ @var-log       /var/log
      └─ @tmp           /tmp

zram0   7.6GB   Compressed swap (zstd, 50% RAM)
```

---

## Features

**Boot & Security**
- systemd-boot (no Secure Boot — restricted BIOS)
- Full disk encryption with LUKS2
- btrfs with zstd compression across all subvolumes
- nftables firewall
- fail2ban with incremental bans
- Firefox sandboxed via firejail
- SSH key-only authentication
- Kernel hardening sysctls

**Power Management**
- TLP with per-state CPU governor (performance on AC, powersave on battery)
- thermald for thermal management
- S3 deep sleep (`mem_sleep_default=deep`)
- Battery charge thresholds for long-term health
- zram swap with zstd compression

**Desktop**
- Pure Wayland GNOME
- GDM display manager
- Flatpak + Flathub
- PipeWire audio with WirePlumber
- Intel VA-API hardware video acceleration (intel-media-driver)
- Plymouth boot splash

**Networking**
- WireGuard VPN via NetworkManager (ProtonVPN)
- Syncthing for file sync
- Tor client with DNS

---

## Structure
```
/etc/nixos/
├── flake.nix                     # Inputs: nixpkgs, home-manager (no lanzaboote)
├── flake.lock
├── configuration.nix             # Entry point, imports all modules
├── hardware-configuration.nix    # Auto-generated from nixos-generate-config
├── disko_1os.nix                 # Declarative disk layout (LUKS2 + btrfs + EFI)
├── home.nix                      # Home Manager configuration
├── POST_INSTALL.md               # Post-install setup
└── modules/
    ├── boot.nix                  # systemd-boot, kernel, Plymouth, kernel params
    ├── hardware.nix              # Intel iGPU, firmware, bluetooth, btrfs, zram
    ├── networking.nix            # Hostname, firewall, SSH, fail2ban
    ├── desktop.nix               # GNOME, GDM, Flatpak, fonts, PipeWire
    ├── power.nix                 # TLP, thermald, sysctls
    ├── security.nix              # firejail, sudo-rs, hardening
    ├── packages.nix              # System packages
    └── services.nix              # Syncthing, Tor, Nix settings, GC
```

---

## Installation

> **Full drive wipe. No dual boot. No Secure Boot.**
> This machine cannot boot from USB — PXE boot via a self-hosted netboot.xyz server is the only method.

### What you need

- Raspberry Pi 5 running as a netboot.xyz PXE server on the same local network
- `pxe.conf` from this repo loaded on the Pi
- Android phone with Termux (or any SSH client) to control the Pi if you have no monitor for it

---

### Step 1 — Start the PXE server on the Pi 5

From Termux on your Android phone (or any terminal with SSH access to the Pi):
```bash
# SSH into the Pi 5
ssh pi@<pi5-ip>

# Start dnsmasq with the PXE config
sudo dnsmasq -C pxe.conf -d
```

Leave this running. dnsmasq will now respond to PXE boot requests on the network.

---

### Step 2 — Enable PXE boot on the L14

Power on the laptop and enter BIOS (`F1` on ThinkPad boot).

Go to **Startup → Boot** and check if a network/PXE boot entry exists. If not:

1. Go to **Network** settings in BIOS
2. Enable **PXE Boot** (may be listed as "Network Boot" or "IPv4/IPv6 Network Stack")
3. Save and exit BIOS

Most distros and network adapters have this option available — just needs to be enabled once.

---

### Step 3 — PXE boot into NixOS live environment

Reboot the laptop. Select the network boot entry from the boot menu (`F12` on ThinkPad).

The laptop will get a DHCP lease from dnsmasq on the Pi and load the netboot.xyz menu automatically. From there select the NixOS live environment.

Once booted into the NixOS live shell:
```bash
nix-shell -p git
git clone https://github.com/ochiuom/nixos-config-1os
cd nixos-config-1os
```

---

### Step 4 — Verify disk target

> **This will wipe the entire drive.** Double check before running anything.
```bash
lsblk
ls -l /dev/disk/by-id/ | grep TOSHIBA
# Expected: nvme-KBG40ZNT256G_TOSHIBA_MEMORY_90SPCCRXQA81
# Confirm this matches disko_1os.nix before proceeding
```

---

### Step 5 — Format and mount
```bash
sudo wipefs -a /dev/nvme0n1
lsblk

sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- --mode format,mount ./disko_1os.nix
```

---

### Step 6 — Install
```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run nixpkgs#nixos-install -- --flake .#ochinix-pc
```

When prompted, set the **root password**.

---

### Step 7 — Reboot
```bash
reboot
```

- Default user password: `changeme` — **change it immediately after login**
- No BIOS changes needed after reboot — Secure Boot is not in use

Proceed to [POST_INSTALL.md](./POST_INSTALL.md) for the rest of the setup.

---

## Key Commands
```bash
nos       # Rebuild and switch
update    # Update flake inputs and rebuild
upgrade   # Update + rebuild + garbage collect
UP        # Full system upgrade (NixOS + Flatpak + firmware + GC)
ngc       # Garbage collect (keep last 3 generations)
unlockv   # Unlock encrypted vault
lockv     # Lock vault
```

---

## Adding a Package — Workflow

One-time setup (run once as normal user):

```bash
sudo chown -R ochinix:users /etc/nixos
```

Daily workflow as normal user:

```bash
cd /etc/nixos
# edit the relevant .nix file e.g. modules/packages.nix
git add .
git commit -m "add: packagename"
nos
```

---



## Heavy Packages

Some packages are expensive to build from source and should only be added when needed.

### RustDesk

RustDesk compiles from source (Rust + Flutter) and is very resource intensive:
- ~100% CPU for the entire build
- ~9GB RAM during compilation
- ~10–15 minutes build time

Commented out by default in `modules/packages.nix`:

```nix
# Uncomment only when needed — expensive to build
# rustdesk
```

To enable, uncomment and rebuild. Subsequent rebuilds use the cached store path and are instant.

### PDFStudio Viewer

PDFStudio Viewer downloads from an external server during install which can occasionally stall or fail due to server availability issues.

It is commented out by default in `modules/packages.nix`:
```nix
# Uncomment only when needed — external server can stall on download
# pdfstudioviewer
```
To enable, uncomment and rebuild.

---



## Post Installation

See [POST_INSTALL.md](POST_INSTALL.md) for complete post-installation setup including fonts, Tor, Neovim, organize-tool, and Flatpak apps.

---

## Troubleshooting

See [TROUBLESHOOT.md](TROUBLESHOOT.md) for chroot recovery, password reset, and other system rescue procedures.

---


## References

- EasyEffects presets: https://github.com/wwmm/easyeffects/wiki/Community-presets
- Orchis GTK theme: https://www.gnome-look.org/p/1357889
- Hatteru Yaru icon theme: https://www.gnome-look.org/p/2146096
- NvChad: https://nvchad.com/docs/quickstart/install/
- netboot.xyz: https://netboot.xyz/docs/

---

## License

Personal configuration, use freely as reference.
