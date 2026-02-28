
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
