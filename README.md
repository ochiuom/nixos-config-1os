# NixOS Configuration — ThinkPad T480s

Personal NixOS flake configuration for a Lenovo ThinkPad T480s running a pure Wayland GNOME desktop.

---

## Why NixOS

Coming from Arch, Fedora, and Ubuntu — NixOS is a fundamentally different approach to managing a system.

**Reproducibility** — the entire OS is declared in one git repo. After a fresh install, a single `nixos-rebuild switch` restores everything exactly as it was — packages, services, dotfiles, extensions, themes, audio config, power management. Nothing manual, nothing forgotten.

**Rollbacks** — every rebuild creates a new generation. If something breaks, boot into the previous generation from the bootloader. No recovery mode, no reinstall, no stress.

**Stability through declaration** — you can't accidentally break the system through random package installs or config edits that pile up over time. Everything is explicit. What's not declared doesn't exist.

**Minimal footprint** — despite running full GNOME with all extensions, PipeWire, Syncthing, Tor, fail2ban and more, idle RAM sits at ~1.2GB after boot. NixOS only runs what you declare.

**Package isolation** — Flatpak for browsers and KDE apps keeps them containerized and self-contained. Firefox is installed via NixOS packages for better system integration but sandboxed via firejail to limit system-wide access. Best of both worlds.

**Learning curve** — NixOS is completely different from any other Linux distro. Took 3 days to learn from zero. Once it clicks, going back feels like a step backwards. With this repo, a new machine is fully up and running in under 30 minutes from a fresh install — reduced 3 days of setup to half an hour.

**Shell out of the box** — ble.sh (bash line editor) is declared as a Nix package in `home.nix`. No manual installation needed — autocomplete, syntax highlighting, and menu-style completion work automatically after first rebuild.

---

## Hardware

| Component | Detail |
|-----------|--------|
| Machine | Lenovo ThinkPad T480s |
| CPU | Intel Core i5-8250U (KabyLake-R) |
| GPU | Intel UHD 620 (iGPU) |
| RAM | 24GB (~1.2GB used at idle after full boot)  |
| Swap | 11.6GB zram (zstd compressed, in-RAM) |
| Storage | 476.9GB NVMe SSD (LUKS2 encrypted, btrfs) |

---

## Disk Layout

Dual boot with Windows 11 on the same NVMe drive.

```
nvme0n1 (476.9GB NVMe)
├─ nvme0n1p1   200MB    /boot (EFI — shared with Windows)
├─ nvme0n1p2   16MB     Microsoft Reserved Partition
├─ nvme0n1p3   243.4GB  Windows 11 (NTFS)
└─ nvme0n1p4   233.3GB  LUKS2 encrypted
   └─ cryptroot (btrfs subvolumes)
      ├─ @              /
      ├─ @home          /home
      ├─ @nix           /nix
      ├─ @snapshots     /.snapshots
      ├─ @var-log       /var/log
      └─ @tmp           /tmp

zram0          11.6GB   Compressed swap (zstd, 50% RAM)
```

---

## Features

**Security**
- Secure Boot via [lanzaboote](https://github.com/nix-community/lanzaboote)
- Full disk encryption with LUKS2
- btrfs with zstd compression across subvolumes
- nftables firewall
- fail2ban with incremental bans
- Firefox sandboxed via firejail
- SSH key-only authentication
- Kernel hardening sysctls

**Power Management**
- TLP with per-state CPU governor (performance on AC, powersave on battery)
- throttled — fixes Intel BD PROCHOT throttling bug on T480s
- thermald for thermal management
- S3 deep sleep (`mem_sleep_default=deep`)
- Battery charge thresholds (40–80%) for long-term health
- zram swap with zstd compression

**Desktop**
- Pure Wayland GNOME
- GDM display manager
- Flatpak + Flathub
- PipeWire audio with WirePlumber
- Intel VA-API hardware video acceleration
- Plymouth boot splash

**Networking**
- WireGuard VPN via NetworkManager (ProtonVPN)
- Syncthing for file sync
- Tor client with DNS

---

## Structure

```
/etc/nixos/
├── flake.nix                     # Inputs: nixpkgs, lanzaboote, home-manager
├── flake.lock
├── configuration.nix             # Entry point, imports all modules
├── hardware-configuration.nix    # Auto-generated, do not edit
├── home.nix                      # Home Manager configuration
└── modules/
    ├── boot.nix                  # Bootloader, kernel, Plymouth, kernel params
    ├── hardware.nix              # GPU, firmware, bluetooth, btrfs, zram
    ├── networking.nix            # Hostname, firewall, SSH, fail2ban
    ├── desktop.nix               # GNOME, GDM, Flatpak, fonts, PipeWire
    ├── power.nix                 # TLP, throttled, thermald, sysctls
    ├── security.nix              # firejail, sudo-rs, hardening
    ├── packages.nix              # System packages
    └── services.nix              # Syncthing, Tor, Nix settings, GC
```

---

## Key Commands

These aliases are defined in `home.nix`:

```bash
# Rebuild and switch
nos

# Update flake inputs and rebuild
update

# Update + rebuild + garbage collect
upgrade

# Full system upgrade (NixOS + Flatpak + firmware + GC)
UP

# Garbage collect (keep last 3 generations)
ngc

# Unlock encrypted vault
unlockv

# Lock vault
lockv
```

---

## Adding a Package — Workflow

One-time setup (run once as normal user):

```bash
sudo git config --system --add safe.directory /etc/nixos
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

## Quick Start

>Assumes you have already completed [Fresh Install from Scratch](INSTALL.md) — working NixOS base system with Secure Boot enrolled.



```bash
sudo git clone https://github.com/ochiuom/nixos-config /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```

---

## Heavy Packages

Some packages are expensive to build from source and should only be added when needed.

### RustDesk

RustDesk compiles from source (Rust + Flutter) and is very resource intensive:
- ~100% CPU for the entire build
- ~9GB RAM during compilation
- ~10-15 minutes build time

It is commented out by default in `modules/packages.nix`:

```nix
# Uncomment only when needed — expensive to build
# rustdesk
```

To enable, uncomment and rebuild. Subsequent rebuilds use the cached store path and are instant.

---

## Post Installation

See [POST_INSTALL.md](POST_INSTALL.md) for complete post installation setup including fonts, Tor, Neovim, organize-tool, and Flatpak apps.

## References

- EasyEffects community presets: https://github.com/wwmm/easyeffects/wiki/Community-presets
- Orchis GTK theme: https://www.gnome-look.org/p/1357889
- Hatteru Yaru icon theme: https://www.gnome-look.org/p/2146096
- NvChad: https://nvchad.com/docs/quickstart/install/

---

## License

Personal configuration, use freely as reference.
