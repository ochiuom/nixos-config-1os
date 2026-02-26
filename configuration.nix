{ config, pkgs, lib, ... }:

{
  # ── Bootloader ────────────────────────────────────────────────
  # Bootloader - plain systemd-boot for install
  # lanzaboote enabled AFTER first boot once sbctl keys exist
  # boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
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
  boot.kernelParams = [ "i915.enable_guc=3" "i915.enable_fbc=1" "i915.enable_psr=1" ];

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

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
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
    simple-scan yelp gnome-backgrounds
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
    enable = true; alsa.enable = true; alsa.support32Bit = true;
    pulse.enable = true; wireplumber.enable = true;
  };

  # ── Users ────────────────────────────────────────────────────
  users.users.ochinix = {
    isNormalUser = true;
    description = "ochinix";
    extraGroups = [ "wheel" "networkmanager" "video" "render" "audio" ];
    initialPassword = "changeme";
  };

  # ── Security ─────────────────────────────────────────────────
  security.sudo.wheelNeedsPassword = true;
  networking.firewall = { enable = true; allowedTCPPorts = [ 22 ]; };
  services.openssh = {
    enable = true;
    settings = { PermitRootLogin = "no"; PasswordAuthentication = true; };
  };
  
  # ── Nix ──────────────────────────────────────────────────────
  nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];
  auto-optimise-store = true;
  min-free = 1073741824;
  max-free = 5368709120;
  };

  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d --max-freed 10G";
  };
  

  # ── Packages ─────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git vim wget curl htop ffmpeg libva-utils vlc firefox
    sbctl btrfs-progs cryptsetup pciutils usbutils lshw networkmanagerapplet
    xdg-desktop-portal-gnome
    firefox kitty ghostty vscode  vlc
    mpd mpc mpv  mplayer smplayer zed yazi


    gnome-tweaks gnome-extension-manager
    gnomeExtensions.appindicator       gnomeExtensions.user-themes
    gnomeExtensions.caffeine           gnomeExtensions.places-status-indicator
    gnomeExtensions.blur-my-shell      gnomeExtensions.gsconnect
    gnomeExtensions.ddterm             gnomeExtensions.search-light
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.compiz-alike-magic-lamp-effect
    gnomeExtensions.burn-my-windows    gnomeExtensions.impatience
    gnomeExtensions.desktop-cube
  ];

  system.stateVersion = "26.05";
}
