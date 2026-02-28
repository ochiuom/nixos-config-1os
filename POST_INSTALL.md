
## Post Installation

### Boot Splash Theme

Using `systemd-boot` with `lanzaboote`, not GRUB. Plymouth splash is configured in `modules/boot.nix`:
```nix
boot.plymouth.theme = "bgrt";
```

`bgrt` displays your vendor logo (Lenovo on T480s). Change to any installed Plymouth theme. No GRUB config needed.

---

### Fonts

Fonts are managed via `home.nix` and deployed automatically on every rebuild — no manual installation needed.

**Inter** (UI font) is downloaded from Google Fonts and tracked in the repo under `fonts/`:
- Download: https://fonts.google.com/specimen/Inter

On rebuild, fonts are copied to `~/.local/share/fonts/` and the font cache is refreshed automatically. GNOME picks them up without any manual Tweaks configuration.

Fonts applied automatically:
- Interface text: `Inter Regular 11`
- Document text: `Noto Sans Regular 11`
- Monospace text: `JetBrains Mono 10`

---

### Tor + Thunderbird

Tor client runs locally on `localhost:9050`. To route Thunderbird email over Tor for secure sending and receiving:

In Thunderbird → Settings → General → Network Settings → Manual proxy:
- SOCKS Host: `localhost`
- Port: `9050`
- Select: `SOCKS v5`
- Check: **Proxy DNS when using SOCKS v5**

---

### organize-tool

Automatically sorts `~/Downloads` by file type into subfolders hourly via a systemd user timer declared in `home.nix`.

Install after first rebuild:
```bash
pipx install organize-tool
pipx ensurepath
organize --version
```

The config is tracked in this repo at `organize/config.yaml` and deployed automatically via `home.nix` on every rebuild — no manual file creation needed.

---

### Neovim / (NvChad + LaTeX Workflow)

Neovim is installed via NixOS packages but without any config files — it's a bare install. To set up NvChad as the config and plugin manager, run after first rebuild:


### Step 1 — Install NvChad
```bash
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
```

NvChad will auto-install on first launch. Let it complete then restart nvim.


### Step 2 — Apply NvChad Custom Layer from This Repo

After NvChad finishes installing on first `nvim` launch, rebuild NixOS to copy the custom config layer from this repo on top of NvChad:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
```

This copies the extra config files declared in `home.nix` into `~/.config/nvim/` without replacing or breaking NvChad — safe to run after every NvChad update as well.
> Reference: https://nvchad.com/docs/quickstart/install/


---

## Adding a New SSH Client

When you need to allow a new machine to SSH in:

1. Set `PasswordAuthentication = true` in `modules/networking.nix` and rebuild
2. From the new client: `ssh-copy-id ochinix@<T480s-IP>`
3. Set `PasswordAuthentication = false` and rebuild

> If SSH connection is suddenly refused from a known client, fail2ban may have banned your IP after too many failed attempts. Unban it on the T480s:
> ```bash
> sudo fail2ban-client unban 192.xxx.xx.xx
> ```
> Replace with your host machine's IP. Connection will work immediately after.

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

### Encrypted Vault

Vault directories are created automatically on every rebuild via `home.nix`:
```
~/
├── Documents/
│   ├── .vault/     ← encrypted storage (hidden, tracked by gocryptfs)
│   └── Vault/      ← mount point (empty when locked, files visible when unlocked)
└── Backups/
    └── Vault_Encrypted_Backup/  ← rsync backup of encrypted vault
```

**One-time setup after fresh install:**
```bash
gocryptfs -init ~/Documents/.vault
# Set a strong password when prompted — this is your vault password
# Never needed again on this machine
```

**Daily usage via aliases:**
```bash
unlockv    # mount — enter vault password, files appear in ~/Documents/Vault
lockv      # unmount — files hidden again
backupv    # rsync encrypted .vault to ~/Backups (safe to backup encrypted)
```

> The vault is encrypted at rest. Even if someone accesses your disk, `.vault` contents are unreadable without the password. `lockv` before suspending or leaving the machine unattended.

---

### Flatpak Applications

Installed via Flathub. Browsers and KDE apps kept as Flatpak for sandboxing and self-containment.

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

Install all at once:
```bash
flatpak install flathub com.brave.Browser com.microsoft.Edge com.opera.Opera com.github.PintaProject.Pinta com.github.ahrm.sioyek com.github.iwalton3.jellyfin-media-player com.orama_interactive.Pixelorama io.github.alainm23.planify io.github.electronstudio.WeylusCommunityEdition org.kde.elisa org.kde.krita org.kde.okular org.localsend.localsend_app org.octave.Octave org.onlyoffice.desktopeditors org.signal.Signal org.telegram.desktop org.mozilla.Thunderbird
```

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
