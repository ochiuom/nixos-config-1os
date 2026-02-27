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
    pipx
    aria2
    fastfetch
    rsync
    blesh
    easyeffects
    weylus
    xournalpp
    tigervnc
    remmina
    audacious
    audacious-plugins
    audacity
    warp-terminal
    ncmpcpp
  ];

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" "xwayland-native-scaling" ];
      edge-tiling = true;
      dynamic-workspaces = true;
    };

    "org/gnome/desktop/interface" = {
      gtk-theme = lib.mkForce "Orchis-Dark-Compact";
      icon-theme = lib.mkForce "Hatter-Yaru";
      cursor-theme = "Yaru";
      font-name = lib.mkForce "Inter 11";
      document-font-name = lib.mkForce "Inter 11";
      monospace-font-name = lib.mkForce "JetBrainsMono Nerd Font 10";
      color-scheme = "prefer-dark";
      enable-animations = true;
      text-scaling-factor = 0.95;
      scaling-factor = lib.hm.gvariant.mkUint32 1;
    };

    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = lib.mkForce "Inter Bold 10";
      button-layout = "appmenu:minimize,maximize,close";
      auto-raise = false;
      focus-mode = "click";
      num-workspaces = 4;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        user-themes.extensionUuid
        caffeine.extensionUuid
        places-status-indicator.extensionUuid
        blur-my-shell.extensionUuid
        gsconnect.extensionUuid
        desktop-cube.extensionUuid
        burn-my-windows.extensionUuid
        impatience.extensionUuid
        compiz-windows-effect.extensionUuid
        compiz-alike-magic-lamp-effect.extensionUuid
        ddterm.extensionUuid
        search-light.extensionUuid
        space-bar.extensionUuid
        appindicator.extensionUuid
        tiling-assistant.extensionUuid
        logo-menu.extensionUuid
        lock-guard.extensionUuid
        ip-finder.extensionUuid
        color-picker.extensionUuid
        dash2dock-lite.extensionUuid
        compact-top-bar.extensionUuid
        advanced-weather-companion.extensionUuid
        adaptive-brightness.extensionUuid
        astra-monitor.extensionUuid
        gnome-40-ui-improvements.extensionUuid
        fuzzy-app-search.extensionUuid
        penguin-ai-chatbot.extensionUuid
        status-area-horizontal-spacing.extensionUuid
        tailscale-status.extensionUuid
        workspace-matrix.extensionUuid
        wallpaper-slideshow.extensionUuid
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Orchis-Dark-Compact";
    };

    "org/gnome/shell/extensions/tiling-assistant" = {
      enable-tiling-popup = true;
      window-gap = 4;
      maximize-with-gap = true;
      default-wrap-mode = 0;
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
  };

  gtk = {
    enable = true;
    theme = { name = "Orchis-Dark-Compact"; };
    iconTheme = { name = "Hatter-Yaru"; };
    cursorTheme = { name = "Yaru"; package = pkgs.yaru-theme; };
    font = { name = "Inter"; size = 11; };
  };

  home.file.".config/ghostty/config".text = ''
    window-width = 90
    window-height = 25
    window-step-resize = true
    font-family = JetBrains Mono
    font-size = 10
    cursor-style = block
    cursor-style-blink = true
    shell-integration = bash
    gtk-single-instance = true
    background = #2c2c2c
    keybind = ctrl+shift+e=new_window
    keybind = ctrl+shift+n=new_tab
  '';

   home.file.".local/share/themes/Orchis-Dark-Compact".source = ./themes/Orchis-Dark-Compact;
   home.file.".local/share/icons/Hatter-Yaru".source = ./themes/Hatter-Yaru;
   
  programs.bash = {
  enable = true;
  enableCompletion = true;

  shellAliases = {
    # Navigation
    ".."    = "cd ..";
    "..."   = "cd ../..";
    "~"     = "cd ~";
    c       = "clear";
    reload  = "source ~/.bashrc";
    j       = "zi";

    # Safety
    cp      = "cp -i";
    mv      = "mv -i";
    rm      = "rm -i";

    # eza
    ls      = "eza -a --icons --group-directories-first";
    ll      = "eza -l --icons --group-directories-first --time-style=long-iso";
    lt      = "eza -T --level=2 --icons";
    la      = "eza -A --icons";
    l       = "eza --icons";

    # Modern replacements
    cat     = "bat";
    grep    = "rg";
    top     = "btop";
    find    = "fd";
    a2      = "aria2c -x 16 -s 16 -k 1M";

    # Git
    gs      = "git status";
    ga      = "git add .";
    gc      = "git commit -m";
    gp      = "git push";

    # System
    cleanram      = "sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null && echo 'RAM cleared'";
    clean-journal = "sudo journalctl --vacuum-time=7d";
    big           = "sudo du -ahx / | sort -rh | head -n 20";
    lsblk         = "lsblk -e7";
    bootload      = "systemd-analyze blame | head -n 10";
    zstat         = "zramctl";
    ssd           = "sudo compsize -x /";
    battery       = "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'state|to empty|percentage'";
    watts         = "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep energy-rate";

    # Vault
    unlockv  = "gocryptfs -allow_other ~/Documents/.vault ~/Documents/Vault";
    lockv    = "fusermount -u -z ~/Documents/Vault";
    backupv  = "mkdir -p ~/Backups && rsync -av --delete ~/Documents/.vault ~/Backups/Vault_Encrypted_Backup/";

    # NixOS
    nrs     = "sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc";
    ngc     = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-store --gc";
    update  = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc";
    upgrade = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc && ngc";
  };

  sessionVariables = {
    EDITOR   = "nvim";
    VISUAL   = "nvim";
    CLICOLOR = "1";
    LESS     = "-RFMX";
    HISTSIZE         = "50000";
    HISTFILESIZE     = "200000";
    HISTCONTROL      = "ignoredups:erasedups:ignorespace";
    HISTTIMEFORMAT   = "%F %T ";
    HISTIGNORE       = "ls:ll:la:cd:pwd:exit:clear";
    FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --inline-info --color=header:italic";
    FZF_COMPLETION_TRIGGER = "**";
  };

  initExtra = ''
    export TERM=xterm-256color

    # Path
    _path_append() {
      for arg do
        case ":$PATH:" in
          *:"$arg":*) ;;
          *) PATH="''${PATH:+$PATH:}$arg" ;;
        esac
      done
    }
    _path_append "$HOME/.local/bin" "$HOME/.cargo/bin" "/usr/local/texlive/2025/bin/x86_64-linux"
    export PATH

    [ -f ~/.api_keys ] && source ~/.api_keys

    shopt -s checkwinsize histappend globstar
    PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
    bind "set bell-style none" 2>/dev/null
    bind "set completion-ignore-case on" 2>/dev/null


    bind -x '"\ec": "zi\n"'

    UP() {
      echo "Starting Full System Upgrade..."
      cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake /etc/nixos#ochinix-pc
      echo "Updating Flatpaks..."
      flatpak update -y
      flatpak uninstall --unused -y
      echo "Checking Firmware..."
      sudo fwupdmgr get-updates && sudo fwupdmgr update
      echo "Cleaning old generations..."
      ngc
      echo "System Peak Performance Reached!"
    }

   fif() {
      rg --files-with-matches --no-messages "$1" | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}" | xargs -r nvim
    }

    # FZF directory picker Ctrl+F
    _fzf_cd() {
      local dir
      dir=$(fd -t d | fzf --preview 'eza --tree --level=2 --icons {}' --preview-window=right:50%)
      [ -n "$dir" ] && cd "$dir"
    }
     
    eval "$(starship init bash)"

    # ble.sh first
    if [ -f "${pkgs.blesh}/share/blesh/ble.sh" ]; then
      source "${pkgs.blesh}/share/blesh/ble.sh" --noattach
      ble-attach
      bleopt complete_style=menu
      bleopt complete_ambiguous=menu
      bleopt complete_menu_style=desc
      bleopt complete_menu_maxlines=15
      bleopt suggest_style=faint
    fi

    # fzf after ble.sh
    eval "$(fzf --bash)"
    _fzf_comprun() {
      local command=$1
      shift
      case "$command" in
        cd)           fzf --preview 'eza --tree --level=2 --icons {}' "$@" ;;
        export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
        ssh)          fzf --preview 'dig {}' "$@" ;;
        *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
      esac
    }
    bind -x '"\C-f": _fzf_cd'
    command -v fastfetch >/dev/null 2>&1 && fastfetch

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

systemd.user.services.organize-downloads = {
  Unit.Description = "Organize Downloads folder";
  Service = {
    Type = "oneshot";
    ExecStart = "${pkgs.bash}/bin/bash -c '${config.home.homeDirectory}/.local/bin/organize run'";
  };
};

systemd.user.timers.organize-downloads = {
  Unit.Description = "Run organize-downloads hourly";
  Timer = {
    OnCalendar = "hourly";
    Persistent = true;
  };
  Install.WantedBy = [ "timers.target" ];
};
 
  #Neovim declare then install via github
  # git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
  programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  };
  
  home.file.".config/easyeffects/output".source = ./easyeffects/output;
  home.file.".config/easyeffects/input".source  = ./easyeffects/input;
  home.file.".config/easyeffects/irs".source = ./easyeffects/irs;
  programs.home-manager.enable = true;
}
