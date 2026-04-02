{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    git vim wget curl htop ffmpeg libva-utils tree ncdu ticker nvd
    sbctl btrfs-progs cryptsetup pciutils usbutils lshw openssl
    xdg-utils glib glib-networking
  
    usbguard
    tailscale
    ffmpegthumbnailer
    gobject-introspection
    (python3.withPackages (ps: with ps; [ pygobject3 ]))
    
    syncthing tor gocryptfs fuse exfatprogs
    poppler-utils pdfcpu
    
    # Modern replacements (some in HM but good for root too)
    fd ripgrep bat eza btop
  ];
}
