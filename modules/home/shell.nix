{ config, pkgs, lib, ... }:
{
  programs.bash = {
    enable           = true;
    enableCompletion = true;
    shellAliases = {
      # Navigation
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "~"    = "cd ~";
      c      = "clear";
      reload = "source ~/.bashrc";
      j      = "zi";

      # Safety
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";

      # eza
      ls = "eza -a --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --time-style=long-iso";
      lt = "eza -T --level=2 --icons";
      la = "eza -A --icons";
      l  = "eza --icons";

      # Modern replacements
      cat  = "bat";
      grep = "rg";
      top  = "btop";
      find = "fd";
      a2   = "aria2c -x 16 -s 16 -k 1M";

      # Git
      gs  = "git status";
      ga  = "git add .";
      gc  = "git commit -m";
      gp  = "git push";
      lg  = "lazygit";
      gd  = "git diff";
      gds = "git diff --staged";

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
      unlockv = "gocryptfs -allow_other ~/Documents/.vault ~/Documents/Vault";
      lockv   = "fusermount -u -z ~/Documents/Vault";
      backupv = "mkdir -p ~/Backups && rsync -av --delete ~/Documents/.vault ~/Backups/Vault_Encrypted_Backup/";

      # NixOS — use nh as the canonical rebuild command (shows diffs via nvd)
      nos     = "nh os switch --hostname ochinix-pc";
      nrs     = "nh os switch --hostname ochinix-pc";   # alias for muscle memory
      ngc     = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-store --gc";
      update  = "cd /etc/nixos && sudo nix flake update && nh os switch --hostname ochinix-pc";
      upgrade = "cd /etc/nixos && sudo nix flake update && nh os switch --hostname ochinix-pc && ngc";

      # Tmux
      ta = "tmux attach || tmux new-session -s main";
      tn = "tmux new-session -s";
      tl = "tmux list-sessions";
      tk = "tmux kill-session -t";

      # Disk
      du = "dust";
      df = "duf";
      bw = "sudo bandwhich";

      br  = "broot";
      nav = "navi";
      f   = "pay-respects";

    sage-env    = "cd ~/Projects/Sage && nix develop --profile ~/.local/state/nix/profiles/sage";     
    torrent-open  = "gocryptfs ~/Videos/.Fragments-vault ~/Videos/Fragments";
    torrent-play  = "gocryptfs ~/Videos/.Fragments-vault ~/Videos/Fragments && mpv ~/Videos/Fragments";
    torrent-close = "fusermount -u ~/Videos/Fragments";
    
  };

    initExtra = ''
      export TERM=xterm-256color
      shopt -s checkwinsize histappend globstar
      PROMPT_COMMAND="history -a; history -c; history -r"
      
      # ── UP: full system upgrade ───────────────────────────────────────────
      UP() {
        # ... (rest of UP function)
        _up_header() {
          echo -e "\n\033[1;36m╔══════════════════════════════════════╗\033[0m"
          echo -e "\033[1;36m║       🚀 Full System Upgrade          ║\033[0m"
          echo -e "\033[1;36m║   $(date '+%Y-%m-%d %H:%M:%S')            ║\033[0m"
          echo -e "\033[1;36m╚══════════════════════════════════════╝\033[0m\n"
        }
        _up_step() { echo -e "\033[1;33m▶ $1...\033[0m"; }
        _up_ok()   { echo -e "\033[1;32m  ✔ $1\033[0m"; }
        _up_fail() { echo -e "\033[1;31m  ✘ $1 failed\033[0m"; failed+=("$1"); }
        _up_run() {
          local name="$1"; shift
          _up_step "$name"
          if "$@"; then _up_ok "$name"; else _up_fail "$name"; fi
          echo
        }
        _up_header
        _up_run "Updating Nix Flake"   bash -c "cd /etc/nixos && sudo nix flake update"
        _up_run "Rebuilding NixOS"     nh os switch --hostname ochinix-pc
        _up_run "Updating Flatpaks"    bash -c "flatpak update -y && flatpak uninstall --unused -y"
        _up_run "Checking Firmware"    bash -c "sudo fwupdmgr get-updates -y; sudo fwupdmgr update -y; exit 0"
        _up_run "Cleaning Generations" bash -c "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-store --gc"
        # ...
      }

      if [ -f "${pkgs.blesh}/share/blesh/ble.sh" ]; then
        source "${pkgs.blesh}/share/blesh/ble.sh" --noattach
        ble-attach
        bleopt complete_style=menu
        bleopt suggest_style=faint
      fi
      
      if command -v carapace >/dev/null 2>&1; then
      blehook ATTACH+='source <(carapace _carapace bash)'
      fi
      eval "$(fzf --bash)"
    '';
  };

  programs.fzf = { enable = true; enableBashIntegration = true; };
  programs.zoxide = { enable = true; enableBashIntegration = true; };
  programs.starship = { enable = true; enableBashIntegration = true; };
  programs.pay-respects = { enable = true; enableBashIntegration = true; };
  programs.direnv = { enable = true; enableBashIntegration = true; nix-direnv.enable = true; };
  programs.bat = { enable = true; config.theme = "TwoDark"; };
  programs.btop = { enable = true; settings.vim_keys = true; };
  programs.carapace = { enable = true; enableBashIntegration = false; };
  programs.broot = { enable = true; enableBashIntegration = true; };
}
