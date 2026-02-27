{ config, pkgs, lib, ... }:

{
  # ── Bootloader ────────────────────────────────────────────────
  # Bootloader - plain systemd-boot for install
  # lanzaboote enabled AFTER first boot once sbctl keys exist
  # boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # lanzaboote - UNCOMMENT after first boot + sbctl create-keys
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
   };

  boot.loader.systemd-boot.extraEntries = {
    "windows.conf" = ''
      title Windows 11
      efi /EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };


  # ── Kernel ────────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "i915" ];
  # ── Plymouth boot splash ──────────────────────────────────────
  boot.plymouth = {
  enable = true;
  theme = "bgrt";
  };

  boot.initrd.systemd.enable = true;

  # Silent boot
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
  "i915.enable_guc=3"
  "i915.enable_fbc=1"
  "i915.enable_psr=1"
  "quiet"
  "splash"
  "rd.udev.log_level=3"
  "udev.log_priority=3"
  ];

  # ── Networking ───────────────────────────────────────────────
  networking.hostName = "ochinix-pc";
  networking.networkmanager.enable = true;


  # ── Locale / Time ────────────────────────────────────────────
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # ── Hardware & Firmware ──────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.fwupd.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
  LIBVA_DRIVER_NAME = "iHD";
  NIXOS_OZONE_WL = "1";
  };
  services.xserver.videoDrivers = [ "modesetting" ];

  services.fstrim.enable = true;
  services.btrfs.autoScrub = { enable = true; interval = "monthly"; };

  zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; priority = 100; };

  # ── Desktop — pure Wayland GNOME ────────────────────────────
  services.displayManager.gdm = { enable = true; wayland = true; };
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour gnome-connections geary epiphany totem
    gnome-maps gnome-music gnome-weather gnome-contacts
    gnome-clocks gnome-calendar gnome-logs gnome-software
  ];

  # ── Power ─────────────────────────────────────────────────────
  powerManagement.cpuFreqGovernor = "performance";

  # ── Flatpak + Flathub ────────────────────────────────────────
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
  };

  # ── Fonts ────────────────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      ubuntu-classic
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      font-awesome
      atkinson-hyperlegible-next
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = { enable = true; style = "slight"; };
      subpixel = { rgba = "rgb"; lcdfilter = "default"; };
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif     = [ "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # ── Audio ────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  wireplumber.enable = true;
  extraConfig.pipewire."10-clock" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [ 44100 48000 96000 192000 ];
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 8192;
      };
    };
  };

  # ── Users ────────────────────────────────────────────────────
  users.users.ochinix = {
    isNormalUser = true;
    description = "ochinix";
    extraGroups = [ "wheel" "networkmanager" "video" "render" "audio" ];
    initialPassword = "changeme";
  };

  # ── Security ─────────────────────────────────────────────────
  security.sudo-rs.enable = true;
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 1716 53317];
  allowedUDPPorts = [ 1716 53317];
  };
  services.openssh = {
    enable = true;
    settings = { PermitRootLogin = "no"; PasswordAuthentication = true; };
  };

  services.fprintd.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  
  # ── Nix ──────────────────────────────────────────────────────
  nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];
  auto-optimise-store = true;
  min-free = 1073741824;
  max-free = 5368709120;
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
   ];
  };

  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-generations +3";
  };
  
 # ── Packages ─────────────────────────────────────────────────
 environment.systemPackages = with pkgs; [
  # Core
  git vim wget curl htop ffmpeg libva-utils
  sbctl btrfs-progs cryptsetup pciutils usbutils lshw
  networkmanagerapplet xdg-utils xdg-desktop-portal-gnome glib gpick  
  
  # Office & Docs
  libreoffice-fresh
  hunspell
  hunspellDicts.en_US
  
  # LaTeX
  texstudio

  # Browsers & Internet
  firefox

  # Terminals
  kitty ghostty

  # Editors
  vscode zed-editor

  # Media
  vlc mpd mpc mpv mplayer smplayer
 
  # services terminal
  syncthing tor gocryptfs fuse

  # File manager tools
  yazi evince gparted baobab
  wl-color-picker localsend exfatprogs qpwgraph

  # GNOME tools
  gnome-tweaks gnome-extension-manager

  # GNOME Extensions
  gnomeExtensions.user-themes
  gnomeExtensions.caffeine
  gnomeExtensions.places-status-indicator
  gnomeExtensions.blur-my-shell
  gnomeExtensions.gsconnect
  gnomeExtensions.desktop-cube
  gnomeExtensions.burn-my-windows
  gnomeExtensions.impatience
  gnomeExtensions.compiz-windows-effect
  gnomeExtensions.compiz-alike-magic-lamp-effect
  gnomeExtensions.ddterm
  gnomeExtensions.search-light
  gnomeExtensions.space-bar
  gnomeExtensions.appindicator
  gnomeExtensions.dash2dock-lite
  gnomeExtensions.tiling-assistant
  gnomeExtensions.logo-menu
  gnomeExtensions.lock-guard
  gnomeExtensions.ip-finder
  gnomeExtensions.color-picker
  gnomeExtensions.dash2dock-lite
  gnomeExtensions.compact-top-bar
  gnomeExtensions.advanced-weather-companion
  gnomeExtensions.adaptive-brightness
  gnomeExtensions.astra-monitor
  gnomeExtensions.gnome-40-ui-improvements
  gnomeExtensions.fuzzy-app-search
  gnomeExtensions.penguin-ai-chatbot
  gnomeExtensions.status-area-horizontal-spacing
  gnomeExtensions.tailscale-status
 ];
 
 # ── Syncthing ─────────────────────────────────────────────────
  services.syncthing = {
    enable = true;
    user = "ochinix";
    dataDir = "/home/ochinix";
    configDir = "/home/ochinix/.config/syncthing";
    openDefaultPorts = true;  # opens 22000/TCP and 21027/UDP automatically
  };

 # ── Tor ───────────────────────────────────────────────────────
   services.tor = {
    enable = true;
    client.enable = true;
    client.dns.enable = true;
  };
  programs.fuse.userAllowOther = true;

  services.fprintd = {
  enable = true;
  tod.enable = true;
  tod.driver = pkgs.libfprint-2-tod1-vfs0090;
  };

  system.stateVersion = "26.05";
}
