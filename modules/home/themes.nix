# modules/home/themes.nix
{ config, pkgs, lib, ... }:

{
  # ── Symlink themes and icons, always force ────────────────────────────
  home.activation.linkThemes = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.local/share/icons
    mkdir -p ~/.local/share/themes
    mkdir -p ~/.config/gtk-3.0
    mkdir -p ~/.config/gtk-4.0

    rm -rf ~/.local/share/icons/Neuwaita
    rm -rf ~/.local/share/icons/Hatter-Yaru
    rm -rf ~/.local/share/icons/Yaru
    rm -rf ~/.local/share/themes/Orchis-Red-Dark-Compact

    ln -sfn /etc/nixos/themes/Neuwaita \
      ~/.local/share/icons/Neuwaita
    ln -sfn /etc/nixos/themes/Hatter-Yaru \
      ~/.local/share/icons/Hatter-Yaru
    ln -sfn ${pkgs.yaru-theme}/share/icons/Yaru \
      ~/.local/share/icons/Yaru
    ln -sfn /etc/nixos/themes/Orchis-Red-Dark-Compact \
      ~/.local/share/themes/Orchis-Red-Dark-Compact
  '';

  # ── GTK 3 ─────────────────────────────────────────────────────────────
  home.file.".config/gtk-3.0/gtk.css".source =
    ../../themes/Orchis-Red-Dark-Compact/gtk-3.0/gtk.css;

  home.file.".config/gtk-3.0/assets" = {
    source    = ../../themes/Orchis-Red-Dark-Compact/gtk-3.0/assets;
    recursive = true;
  };

  # ── GTK 4 libadwaita fix ─────────────────────────────────────────────
  home.file.".config/gtk-4.0/gtk.css".source =
    ../../themes/Orchis-Red-Dark-Compact/gtk-4.0/gtk.css;

  home.file.".config/gtk-4.0/gtk-dark.css".source =
    ../../themes/Orchis-Red-Dark-Compact/gtk-4.0/gtk-dark.css;

  home.file.".config/gtk-4.0/assets" = {
    source    = ../../themes/Orchis-Red-Dark-Compact/gtk-4.0/assets;
    recursive = true;
  };

  # ── Cursor ────────────────────────────────────────────────────────────
  home.pointerCursor = {
    name       = "Bibata-Modern-Ice";
    package    = pkgs.bibata-cursors;
    size       = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ── Flatpak theming ───────────────────────────────────────────────────
  home.activation.flatpakTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v flatpak >/dev/null 2>&1; then
      flatpak override --user \
        --filesystem=${config.home.homeDirectory}/.local/share/themes
      flatpak override --user \
        --filesystem=${config.home.homeDirectory}/.local/share/icons
      flatpak override --user \
        --env=GTK_THEME=Orchis-Red-Dark-Compact
      flatpak override --user \
        --env=ICON_THEME=Neuwaita
    fi
  '';

  # ── Icon cache refresh (background, non-blocking) ─────────────────────
  home.activation.refreshIconCaches = lib.hm.dag.entryAfter ["linkThemes"] ''
    (
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
        ~/.local/share/icons/Yaru || true
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
        ~/.local/share/icons/Hatter-Yaru || true
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
        ~/.local/share/icons/Neuwaita || true
    ) &
    disown
  '';

  # ── Packages ──────────────────────────────────────────────────────────
  home.packages = [
    pkgs.yaru-theme
    pkgs.bibata-cursors
    pkgs.gnomeExtensions.rounded-window-corners-reborn
  ];

  # ── GTK declaration ───────────────────────────────────────────────────
  gtk = {
    enable    = true;
    theme     = { name = "Orchis-Red-Dark-Compact"; };
    iconTheme = { name = "Neuwaita"; };
    font      = { name = "Inter"; size = 11; };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-enable-primary-paste          = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # ── dconf ─────────────────────────────────────────────────────────────
  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme         = lib.mkForce "Orchis-Red-Dark-Compact";
    icon-theme        = lib.mkForce "Neuwaita";
    cursor-theme      = "Bibata-Modern-Ice";
    cursor-size       = 24;
    font-antialiasing = "rgba";
    font-hinting      = "slight";
    color-scheme      = "prefer-dark";
  };

  dconf.settings."org/gnome/shell/extensions/user-theme" = {
    name = lib.mkForce "Orchis-Red-Dark-Compact";
  };

  dconf.settings."org/gnome/shell/extensions/rounded-window-corners-reborn" = {
    border-radius        = 8;
    smoothing            = 0;
    keep-rounded-corners = false;
    skip-libadwaita-app  = true;
  };

  dconf.settings."org/gtk/settings/file-chooser" = {
    sort-directories-first = true;
  };

  dconf.settings."org/gtk/gtk4/settings/file-chooser" = {
    sort-directories-first = true;
  };
}
