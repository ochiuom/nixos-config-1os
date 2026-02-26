{ config, pkgs, lib, ... }:
{
  home.username = "ochinix";
  home.homeDirectory = "/home/ochinix";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    yaru-theme
  ];

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "Yaru-dark";
      icon-theme = "Yaru";
      cursor-theme = "Yaru";
      font-name = "Ubuntu 12";
      document-font-name = "Ubuntu 12";
      monospace-font-name = "Ubuntu Mono 12";
      color-scheme = "prefer-dark";
      enable-animations = true;
      text-scaling-factor = 0.9;
      scaling-factor = lib.hm.gvariant.mkUint32 1;
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Ubuntu Bold 11";
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      primary-color = "#300a24";
    };
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "caffeine@patapon.info"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "blur-my-shell@aunetx"
        "gsconnect@andyholmes.github.io"
        "ddterm@amezin.github.com"
        "search-light@icedman.github.com"
        "compiz-windows-effect@hermes83.github.com"
        "compiz-alike-magic-lamp-effect@hermes83.github.com"
        "burn-my-windows@schneegans.github.com"
        "impatience@gfxmonk.net"
        "desktop-cube@schneegans.github.com"
      ];
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "Yaru-dark";
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      natural-scroll = true;
      disable-while-typing = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-battery-timeout = 900;
      power-button-action = "suspend";
      ambient-enabled = false;
    };
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 0;
    };
    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
      idle-activation-enabled = false;
    };
  };

  home.file.".config/gtk-3.0/gtk.css".text = ''
  * { 
    padding: 0px;
  }
  '';

  home.file.".config/gtk-4.0/gtk.css".text = ''
  * {
    padding: 0px;
  }
  '';

   home.file.".config/gnome-shell/extensions/user-theme/stylesheet.css".text = ''
  #panel {
    height: 28px;
    font-size: 11px;
  }
  '';  

  gtk = {
    enable = true;
    theme = { name = "Yaru-dark"; package = pkgs.yaru-theme; };
    iconTheme = { name = "Yaru"; package = pkgs.yaru-theme; };
    cursorTheme = { name = "Yaru"; package = pkgs.yaru-theme; };
    font = { name = "Ubuntu"; size = 12; };
  };

  programs.home-manager.enable = true;
}
