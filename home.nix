{ config, pkgs, lib, ... }:
{
  home.username = "ochinix";
  home.homeDirectory = "/home/ochinix";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
  yaru-theme
  fzf
  zoxide
  fd
  ripgrep
  bat
  btop
  starship
  eza
 
  ];

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = lib.mkForce "Orchis-Dark-Compact";
      icon-theme = lib.mkForce "Hatter-Yaru";
      cursor-theme = "Yaru";
      font-name = lib.mkForce "Inter 12";
      document-font-name = lib.mkForce "Inter 12";
      monospace-font-name = lib.mkForce "JetBrainsMono Nerd Font 12";
      color-scheme = "prefer-dark";
      enable-animations = true;
      text-scaling-factor = 0.9;
      scaling-factor = lib.hm.gvariant.mkUint32 1;
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = lib.mkForce "Inter Bold 11";
      button-layout = "appmenu:minimize,maximize,close";
    };


    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      picture-options = "zoom";
      primary-color = "#300a24";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      picture-options = "zoom";
    };

    "org/gnome/shell" = {
    disable-user-extensions = false;
    enabled-extensions = with pkgs.gnomeExtensions; [
    user-themes.extensionUuid
    caffeine.extensionUuid
    places-status-indicator.extensionUuid
    blur-my-shell.extensionUuid
    gsconnect.extensionUuid
    vitals.extensionUuid
    desktop-cube.extensionUuid
    burn-my-windows.extensionUuid
    tophat.extensionUuid
    impatience.extensionUuid
    compiz-windows-effect.extensionUuid
    compiz-alike-magic-lamp-effect.extensionUuid
    ddterm.extensionUuid
    search-light.extensionUuid
    space-bar.extensionUuid
    appindicator.extensionUuid
    dash2dock-lite.extensionUuid
    tiling-assistant.extensionUuid
    logo-menu.extensionUuid
    lock-guard.extensionUuid
    ip-finder.extensionUuid
     ];
   };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Orchis-Dark-Compact";
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

   "org/gnome/shell/extensions/tiling-assistant" = {
     enable-tiling-popup = true;
     window-gap = 4;
     maximize-with-gap = true;
     default-wrap-mode = 0;
    };

   "org/gnome/mutter" = {
     experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
     edge-tiling = true;
     dynamic-workspaces = true;
    };

   "org/gnome/desktop/wm/preferences" = {
     titlebar-font = "Inter Bold 11";
     button-layout = "appmenu:minimize,maximize,close";
     auto-raise = false;
     focus-mode = "click";
     num-workspaces = 4;
   };

   "org/gnome/desktop/wm/keybindings" = {
     maximize = [ "<Super>Up" ];
     unmaximize = [ "<Super>Down" ];
     tile-left = [ "<Super>Left" ];
     tile-right = [ "<Super>Right" ];
     switch-to-workspace-1 = [ "<Super>1" ];
     switch-to-workspace-2 = [ "<Super>2" ];
     switch-to-workspace-3 = [ "<Super>3" ];
     switch-to-workspace-4 = [ "<Super>4" ];
     move-to-workspace-1 = [ "<Super><Shift>1" ];
     move-to-workspace-2 = [ "<Super><Shift>2" ];
     move-to-workspace-3 = [ "<Super><Shift>3" ];
     move-to-workspace-4 = [ "<Super><Shift>4" ];
     close = [ "<Super>q" ];
   };

    "org/gnome/shell/keybindings" = {
      toggle-overview = [ "<Super>s" ];
};
    
  };


  #gtk = {
   # enable = true;
   # font = { name = "Inter"; size = 12; };
  #};

  gtk = {
  enable = true;
  theme = { name = "Orchis-Dark-Compact"; };
  iconTheme = { name = "Hatter-Yaru"; };
  cursorTheme = { name = "Yaru"; package = pkgs.yaru-theme; };
  font = { name = "Inter"; size = 12; };
  };

  home.file.".config/ghostty/config".text = ''
  window-width = 90
  window-height = 25
  window-step-resize = true
  font-family = JetBrains Mono
  font-size = 12
  cursor-style = block
  cursor-style-blink = true
  shell-integration = bash
  gtk-single-instance = true
  keybind = ctrl+shift+e=new_window
  keybind = ctrl+shift+n=new_tab
  '';


  # ── Shell & Terminal tools ────────────────────────────────────
  programs.bash = {
  enable = true;
  enableCompletion = true;
  shellAliases = {
    ll    = "eza -alh --icons";
    la    = "eza -A --icons";
    l     = "eza --icons";
    ".."  = "cd ..";
    "..." = "cd ../..";
    gs    = "git status";
    ga    = "git add .";
    gc    = "git commit -m";
    gp    = "git push";
    nrs   = "sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc";
    ngc   = "sudo nix-collect-garbage -d";
    cat   = "bat";
    find  = "fd";
    grep  = "rg";
    top   = "btop";
    cd    = "z";
    update = "sudo nix flake update /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc";
    upgrade = "sudo nix flake update /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc && sudo nix-collect-garbage -d";
  };
  initExtra = ''
    export TERM=xterm-256color
    eval "$(zoxide init bash)"
  '';
 };

  home.sessionPath = [
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "/usr/local/texlive/2025/bin/x86_64-linux"
  ];

 programs.fzf = {
  enable = true;
  enableBashIntegration = true;
  defaultOptions = [
    "--height 40%"
    "--layout=reverse"
    "--border"
    "--color=dark"
  ];
 };

 programs.zoxide = {
  enable = true;
  enableBashIntegration = true;
 };

 programs.starship = {
  enable = true;
  settings = {
    add_newline = false;
    character = {
      success_symbol = "[❯](bold green)";
      error_symbol = "[❯](bold red)";
    };
    directory = {
      truncation_length = 3;
      truncate_to_repo = true;
    };
    git_branch.symbol = " ";
    nix_shell.symbol = " ";
  };
 };

 programs.bat = {
  enable = true;
  config = {
    theme = "TwoDark";
    italic-text = "always";
  };
 };

 programs.btop = {
  enable = true;
  settings = {
    color_theme = "dracula";
    vim_keys = true;
  };
 };

  programs.home-manager.enable = true;
}
