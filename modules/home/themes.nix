# modules/home/themes.nix
{ config, pkgs, lib, ... }:

let
  activeTheme = "Orchis-Red-Light-Compact";
  #  activeTheme = "Otis";
  # activeTheme = "Lycia";
  # activeTheme = "Ant";
  # activeTheme = "Dracula";
  # activeTheme = "Sweet-Dark";
  # activeTheme = "Cyber-Dusk-Rounded-Glass";
  # activeTheme = "Orchis-Red-Dark-Compact";
  # activeTheme = "Tokyonight-B-MB-Dark";

  themeBase = ../../themes/${activeTheme};

  hasGtk2   = builtins.pathExists "${themeBase}/gtk-2.0";
  hasGtk3   = builtins.pathExists "${themeBase}/gtk-3.0";
  hasGtk320 = builtins.pathExists "${themeBase}/gtk-3.20";
  hasGtk4   = builtins.pathExists "${themeBase}/gtk-4.0";
  hasAssets = builtins.pathExists "${themeBase}/assets";

  optionalDir = condition: target: src:
    lib.optionalAttrs condition {
      "${target}" = { source = src; recursive = true; };
    };

  # Lycia-specific source layout: themes/Lycia/{Lycia,Lycia-hdpi,Lycia-xhdpi}
  lyciaRoot = ../../themes/Lycia;
  lyciaVariants = [ "Lycia" "Lycia-hdpi" "Lycia-xhdpi" ];

in
{
  home.activation.cleanGtkBackups = lib.hm.dag.entryAfter ["writeBoundary"] ''
    for dir in gtk-2.0 gtk-3.0 gtk-3.20 gtk-4.0; do
      target="$HOME/.config/$dir"
      [ -d "$target" ] && rm -f "$target"/*.backup
    done
  '';

  home.activation.linkThemes = lib.hm.dag.entryAfter ["cleanGtkBackups"] ''
    mkdir -p ~/.local/share/icons
    mkdir -p ~/.local/share/themes

    rm -rf ~/.local/share/icons/Neuwaita
    rm -rf ~/.local/share/icons/Hatter-Yaru
    rm -rf ~/.local/share/icons/Yaru
    rm -rf ~/.local/share/icons/WhiteSur-dark
    rm -rf ~/.local/share/icons/Tela
    rm -rf ~/.local/share/icons/Tela-purple
    rm -rf ~/.local/share/themes/Orchis-Red-Dark-Compact
    rm -rf ~/.local/share/themes/Orchis-Red-Light-Compact
    rm -rf ~/.local/share/themes/Tokyonight-B-MB-Dark
    rm -rf ~/.local/share/themes/Cyber-Dusk-Rounded-Glass

    ln -sfn /etc/nixos/themes/Neuwaita \
      ~/.local/share/icons/Neuwaita
    ln -sfn /etc/nixos/themes/Hatter-Yaru \
      ~/.local/share/icons/Hatter-Yaru
    ln -sfn ${pkgs.yaru-theme}/share/icons/Yaru \
      ~/.local/share/icons/Yaru
    ln -sfn /etc/nixos/themes/WhiteSur-dark \
      ~/.local/share/icons/WhiteSur-dark
    ln -sfn /etc/nixos/themes/Tela \
      ~/.local/share/icons/Tela
    ln -sfn /etc/nixos/themes/Tela-purple \
      ~/.local/share/icons/Tela-purple
    ln -sfn /etc/nixos/themes/Orchis-Red-Dark-Compact \
      ~/.local/share/themes/Orchis-Red-Dark-Compact
    ln -sfn /etc/nixos/themes/Orchis-Red-Light-Compact \
      ~/.local/share/themes/Orchis-Red-Light-Compact
    ln -sfn /etc/nixos/themes/Tokyonight-B-MB-Dark \
      ~/.local/share/themes/Tokyonight-B-MB-Dark

    mkdir -p ~/.local/share/themes/Cyber-Dusk-Rounded-Glass
    ln -sfn /etc/nixos/themes/Cyber-Dusk-Rounded-Glass/gnome-shell \
      ~/.local/share/themes/Cyber-Dusk-Rounded-Glass/gnome-shell
    ln -sfn /etc/nixos/themes/Cyber-Dusk-Rounded-Glass/index.theme \
      ~/.local/share/themes/Cyber-Dusk-Rounded-Glass/index.theme
  '';

  # --- Lycia: real file copies, no symlinks ---
  home.activation.installLyciaTheme = lib.hm.dag.entryAfter ["linkThemes"] ''
    LOCAL_THEMES="$HOME/.local/share/themes"
    mkdir -p "$LOCAL_THEMES"

    ${lib.concatMapStringsSep "\n" (variant: ''
      rm -rf "$LOCAL_THEMES/${variant}"
      cp -rL "${lyciaRoot}/${variant}" "$LOCAL_THEMES/${variant}"
      chmod -R u+w "$LOCAL_THEMES/${variant}"
    '') lyciaVariants}

    ${lib.optionalString (activeTheme == "Lycia") ''
      # Copy gtk-2.0 / gtk-3.0 / gtk-4.0 contents straight into ~/.config
      # Only done when Lycia is the active theme, otherwise this fights
      # with the home.file symlinks below for whichever theme IS active.
      for d in gtk-2.0 gtk-3.0 gtk-4.0; do
        SRC="$LOCAL_THEMES/Lycia/$d"
        DEST="$HOME/.config/$d"
        if [ -d "$SRC" ]; then
          rm -rf "$DEST"
          mkdir -p "$DEST"
          cp -rL "$SRC"/. "$DEST"/
          chmod -R u+w "$DEST"
        fi
      done
    ''}
  '';

  home.file = lib.mkMerge [
    (optionalDir hasGtk2   ".config/gtk-2.0"  "${themeBase}/gtk-2.0")
    (optionalDir hasGtk3   ".config/gtk-3.0"  "${themeBase}/gtk-3.0")
    (optionalDir hasGtk320 ".config/gtk-3.20" "${themeBase}/gtk-3.20")
    (optionalDir hasGtk4   ".config/gtk-4.0"  "${themeBase}/gtk-4.0")
    (optionalDir hasAssets ".config/assets"   "${themeBase}/assets")
  ];

  home.pointerCursor = {
    name       = "Bibata-Modern-Amber";
    package    = pkgs.bibata-cursors;
    size       = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.activation.flatpakTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v flatpak >/dev/null 2>&1; then
      flatpak override --user \
        --filesystem=${config.home.homeDirectory}/.local/share/themes
      flatpak override --user \
        --filesystem=${config.home.homeDirectory}/.local/share/icons
      flatpak override --user \
        --env=GTK_THEME=${activeTheme}
      flatpak override --user \
       # --env=ICON_THEME=Hatter-Yaru
        --env=ICON_THEME=Gruvbox-Plus-Dark
    fi
  '';

  systemd.user.services.refresh-icon-caches = {
    Unit = {
      Description = "Refresh GTK icon caches";
      After       = [ "graphical-session.target" ];
    };
    Service = {
      Type      = "oneshot";
      ExecStart = pkgs.writeShellScript "refresh-icon-caches" ''
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Yaru || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Hatter-Yaru || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Neuwaita || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/WhiteSur-dark || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Tela || true
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
          ${config.home.homeDirectory}/.local/share/icons/Tela-purple || true
      '';
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.packages = [
    pkgs.yaru-theme
    pkgs.bibata-cursors
    pkgs.gruvbox-plus-icons
  ];

  gtk = {
    enable    = true;
    theme     = { name = activeTheme; };
    #iconTheme = { name = "Hatter-Yaru"; };
    iconTheme = { name = "Gruvbox-Plus-Dark"; };
    font      = { name = "Inter"; size = 11; };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-enable-primary-paste          = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-light-theme = 1;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme         = lib.mkForce activeTheme;
    #icon-theme        = lib.mkForce "Hatter-Yaru";
    icon-theme        = lib.mkForce "Gruvbox-Plus-Dark";
    cursor-theme      = "Bibata-Modern-Amber";
    cursor-size       = 24;
    font-antialiasing = "rgba";
    font-hinting      = "slight";
    color-scheme      = "prefer-dark";
  };

  dconf.settings."org/gnome/shell/extensions/user-theme" = {
    name = lib.mkForce "Lycia";
  };

  dconf.settings."org/gtk/settings/file-chooser" = {
    sort-directories-first = true;
  };

  dconf.settings."org/gtk/gtk4/settings/file-chooser" = {
    sort-directories-first = true;
  };
}
