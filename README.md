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

**Learning curve** — NixOS is completely different from any other Linux distro. Took 3 days to learn from zero. Once it clicks, going back feels like a step backwards.

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

## Flatpak Applications

Installed via Flathub. Browsers and KDE apps are kept as Flatpak for sandboxing and self-containment.

| Name | Application ID |
|------|----------------|
| Brave | com.brave.Browser |
| Microsoft Edge | com.microsoft.Edge |
| Opera | com.opera.Opera |
| Pinta | com.github.PintaProject.Pinta |
| Sioyek | com.github.ahrm.sioyek |
| Jellyfin Media Player | com.github.iwalton3.jellyfin-media-player |
| Pixelorama | com.orama_interactive.Pixelorama |
| Planify | io.github.alainm23.planify |
| Weylus Community Edition | io.github.electronstudio.WeylusCommunityEdition |
| Elisa | org.kde.elisa |
| Krita | org.kde.krita |
| Okular | org.kde.okular |
| LocalSend | org.localsend.localsend_app |
| GNU Octave | org.octave.Octave |
| ONLYOFFICE Desktop Editors | org.onlyoffice.desktopeditors |
| Signal Desktop | org.signal.Signal |
| Telegram | org.telegram.desktop |
| Thunderbird | org.mozilla.Thunderbird |

> Install all at once:
> ```bash
> flatpak install flathub com.brave.Browser com.microsoft.Edge com.opera.Opera com.github.PintaProject.Pinta com.github.ahrm.sioyek com.github.iwalton3.jellyfin-media-player com.orama_interactive.Pixelorama io.github.alainm23.planify io.github.electronstudio.WeylusCommunityEdition org.kde.elisa org.kde.krita org.kde.okular org.localsend.localsend_app org.octave.Octave org.onlyoffice.desktopeditors org.signal.Signal org.telegram.desktop org.mozilla.Thunderbird
> ```

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

## Quick Start

> Assumes you have already completed **Fresh Install from Scratch** below — working NixOS base system with Secure Boot enrolled.

```bash
sudo git clone https://github.com/ochiuom/nixos-config /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```

---

## Adding a New SSH Client

When you need to allow a new machine to SSH in:

1. Set `PasswordAuthentication = true` in `modules/networking.nix` and rebuild
2. From the new client: `ssh-copy-id ochinix@<T480s-IP>`
3. Set `PasswordAuthentication = false` and rebuild

---

## VPN

ProtonVPN via WireGuard — no app needed, built into NetworkManager.

```bash
# Download WireGuard config from account.proton.me
# Rename to a valid interface name
mv ProtonVPN-config.conf protonvpn-xx.conf
nmcli connection import type wireguard file protonvpn-xx.conf
nmcli connection modify protonvpn-xx ipv6.method ignore

# Connect / disconnect via terminal
nmcli connection up protonvpn-xx
nmcli connection down protonvpn-xx
```

Or toggle on/off directly from the GNOME top panel → network icon → VPN section — no terminal needed.

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

## Fresh Install from Scratch

> This documents the exact install process used for this machine.
> Assumes Windows 11 already installed on nvme0n1p3, NixOS goes into nvme0n1p4.
> Complete this entire guide before using Quick Start above.

### Phase 0 — UEFI Prep (before booting ISO)

Enter UEFI firmware (F1 on ThinkPad):
- Disable Fast Boot
- Disable CSM / Legacy Boot — UEFI only
- Secure Boot → Reset to Setup Mode (on but no keys = correct starting state)
- **CRITICAL: Disable BitLocker in Windows BEFORE this step** — new keys change TPM state and will lock BitLocker
- Save and exit, boot NixOS ISO

---

### Phase 1 — Disk Setup

**1.1 Wipe old LUKS header from P4:**
```bash
sudo wipefs -a /dev/nvme0n1p4
```

**1.2 Create LUKS2 container:**
```bash
sudo cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --pbkdf argon2id /dev/nvme0n1p4
# Type YES (uppercase) then set passphrase
```

**1.3 Open LUKS:**
```bash
sudo cryptsetup open /dev/nvme0n1p4 cryptroot
```

**1.4 Format btrfs:**
```bash
sudo mkfs.btrfs -f -L nixos /dev/mapper/cryptroot
```

**1.5 Create subvolumes:**
```bash
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var-log
btrfs subvolume create /mnt/@tmp
umount /mnt
```

**1.6 Mount everything:**
```bash
mount -o subvol=@,compress=zstd:1,noatime,discard=async /dev/mapper/cryptroot /mnt

mkdir -p /mnt/{boot,home,nix,.snapshots,var/log,tmp}

mount -o subvol=@home,compress=zstd:1,noatime,discard=async      /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,compress=zstd:1,noatime,discard=async       /dev/mapper/cryptroot /mnt/nix
mount -o subvol=@snapshots,compress=zstd:1,noatime,discard=async /dev/mapper/cryptroot /mnt/.snapshots
mount -o subvol=@var-log,compress=zstd:1,noatime,discard=async   /dev/mapper/cryptroot /mnt/var/log
mount -o subvol=@tmp,compress=zstd:1,noatime,discard=async       /dev/mapper/cryptroot /mnt/tmp

mount /dev/nvme0n1p1 /mnt/boot
```

**1.7 Generate base config:**
```bash
nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/hardware-configuration.nix` automatically.

---

### Phase 2 — Git Init

```bash
cd /mnt/etc/nixos
git init
git config --local user.email "your@email.com"
git config --local user.name "yourusername"
git add .
git commit -m "initial install config"
```

---

### Phase 3 — Install

```bash
nixos-install --root /mnt --flake .#ochinix-pc
# Downloads ~3-8 GB from cache.nixos.org — takes 20-40 min
# Sets root password at end — do not skip
```

Reboot into NixOS.

---

### Phase 4 — First Boot: Enroll Secure Boot Keys

> CRITICAL: Firmware is still in Setup Mode — no keys enrolled yet. Do this immediately after first boot.
> `sbctl` is available on the NixOS live ISO and is also included in this config's `modules/packages.nix`.

```bash
# 1. Create own PK/KEK/db keys
sudo sbctl create-keys

# 2. Enroll into firmware — --microsoft is REQUIRED for Windows dual boot
sudo sbctl enroll-keys --microsoft

# 3. Rebuild so lanzaboote signs with the new enrolled keys
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc

# 4. Verify all EFI binaries are signed
sudo sbctl verify
# Every entry must show: Signed: yes

# 5. Confirm Secure Boot is active
sudo sbctl status
# Secure Boot: enabled  <-- must say this
# Owned:       yes
```

> lanzaboote auto-signs every new kernel on every `nixos-rebuild`. Never run `sbctl sign` manually.
> After rebuild, enter BIOS → Security → Secure Boot → Enable → Save and reboot.
> If NixOS boots normally you are done. If it fails, go back to BIOS → Reset to Setup Mode and repeat Phase 4 from the beginning — check `sbctl verify` output carefully for any unsigned entries. It is usually straightforward, do not panic.

---

### Phase 5 — Apply This Config

Now clone this repo and rebuild with the full config:

```bash
sudo git clone https://github.com/ochiuom/nixos-config /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```

---

### Phase 6 — Post Install Checks

**Change password:**
```bash
passwd ochinix
```

**Verify Intel VA-API:**
```bash
vainfo
# Should show iHD driver with H264 HEVC AV1 decode profiles
```

**Verify btrfs:**
```bash
sudo btrfs subvolume list /
sudo btrfs filesystem usage /
```

**Verify microcode:**
```bash
sudo dmesg | grep -i microcode
```

---

### Troubleshooting

| Problem | Fix |
|---------|-----|
| Windows won't boot after key enroll | Forgot `--microsoft`. Re-run: `sudo sbctl enroll-keys --microsoft` |
| Secure Boot disabled after reboot | UEFI may have reset. Re-enter firmware, confirm User Mode |
| Kernel not signed after rebuild | Check `lanzaboote.enable = true` and `pkiBundle = /var/lib/sbctl` |
| LUKS won't open at boot | UUID mismatch. Check `hardware-configuration.nix` vs `blkid /dev/nvme0n1p4` |
| BitLocker locked after key change | Use recovery key. Always disable BitLocker before enrolling keys |
| vainfo: no iHD driver | Check `LIBVA_DRIVER_NAME=iHD` in sessionVariables. Log out and back in |
| WiFi not detected | Confirm `hardware.enableRedistributableFirmware = true`. Check `dmesg | grep firmware` |
| btrfs error at boot | Subvol names in `hardware-configuration.nix` must match `btrfs subvolume list /` |

---

## License

Personal configuration, use freely as reference.
