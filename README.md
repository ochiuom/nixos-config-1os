# NixOS Configuration — ThinkPad T480s

Personal NixOS flake configuration for a Lenovo ThinkPad T480s running a pure Wayland GNOME desktop.

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
├── hardware-configuration.nix    # Auto-generated, do not edit
├── configuration.nix             # Entry point, imports all modules
├── home.nix                      # Home Manager configuration
├── modules/
│   ├── boot.nix                  # Bootloader, kernel, Plymouth, kernel params
│   ├── hardware.nix              # GPU, firmware, bluetooth, btrfs, zram
│   ├── networking.nix            # Hostname, firewall, SSH, fail2ban
│   ├── desktop.nix               # GNOME, GDM, Flatpak, fonts, PipeWire
│   ├── power.nix                 # TLP, throttled, thermald, sysctls
│   ├── security.nix              # firejail, sudo-rs, hardening
│   ├── packages.nix              # System packages
│   └── services.nix              # Syncthing, Tor, Nix settings, GC
├── mpd/
│   └── mpd.conf                  # MPD configuration
├── kitty/                        # Kitty terminal config
├── starship/                     # Starship prompt config
├── easyeffects/                  # EasyEffects presets and IRs
└── themes/                       # GTK themes and icon packs
```

---

## Key Commands

These aliases are defined in `home.nix`:

```bash
# Rebuild and switch
nrs

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

## First Install

> These steps assume a fresh NixOS install with LUKS2 + btrfs already set up.

**1. Clone this config:**
```bash
sudo git clone https://github.com/ochiuom/nixos-config /etc/nixos
```

**2. Generate hardware config:**
```bash
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
```

**3. First build (without Secure Boot):**

In `modules/boot.nix`, temporarily comment out lanzaboote and enable systemd-boot:
```nix
boot.loader.systemd-boot.enable = true;
# boot.loader.systemd-boot.enable = lib.mkForce false;
# boot.lanzaboote = { ... };
```

```bash
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```


## Setting up Secure Boot

**1. In BIOS — disable Secure Boot and reset to Setup Mode:**
- Enter BIOS (F1 on ThinkPad)
- Security → Secure Boot → Disable
- Security → Reset to Setup Mode (clears existing keys)
- Save and boot into NixOS

**2. First build without lanzaboote:**

In `modules/boot.nix`, temporarily swap to systemd-boot:
```nix
boot.loader.systemd-boot.enable = true;
# boot.loader.systemd-boot.enable = lib.mkForce false;
# boot.lanzaboote = { ... };
```
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```

**3. Generate and enroll keys:**
```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
```

**4. Re-enable lanzaboote in `modules/boot.nix` and rebuild:**
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```

**5. Re-enable Secure Boot in BIOS, boot and verify:**
```bash
sudo sbctl verify
sudo sbctl status
```

---

## Adding a New SSH Client

When you need to allow a new machine to SSH in:

1. Set `PasswordAuthentication = true` in `modules/networking.nix` and rebuild
2. From the new client: `ssh-copy-id ochinix@<T480s-IP>`
3. Set `PasswordAuthentication = false` and rebuild

---

## VPN

ProtonVPN via WireGuard:

```bash
# Download WireGuard config from account.proton.me
# Rename to a valid interface name
mv ProtonVPN-config.conf protonvpn-xx.conf
nmcli connection import type wireguard file protonvpn-xx.conf
nmcli connection modify protonvpn-xx ipv6.method ignore

# Connect / disconnect
nmcli connection up protonvpn-xx
nmcli connection down protonvpn-xx
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

To enable, uncomment and rebuild. It will only recompile if the version changes upstream — subsequent rebuilds use the cached store path and are instant.

---

## License

Personal configuration, use freely as reference.
