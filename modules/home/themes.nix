# modules/home/themes.nix
{ config, pkgs, lib, ... }:

{
  # ── Create dirs before Home Manager tries to link into them ──────────
  home.activation.createThemeDirs = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    mkdir -p ~/.local/share/themes
    mkdir -p ~/.local/share/icons
    mkdir -p ~/.config/gtk-3.0
    mkdir -p ~/.config/gtk-4.0
  '';

  # ── Themes → ~/.local/share/themes ───────────────────────────────────
  home.file.".local/share/themes/Orchis-Red-Dark-Compact".source =
    ../../themes/Orchis-Red-Dark-Compact;

  # ── Icons → ~/.local/share/icons ─────────────────────────────────────
  home.file.".local/share/icons/Yaru" = {
    source    = "${pkgs.yaru-theme}/share/icons/Yaru";
    recursive = true;
  };

  home.file.".local/share/icons/Hatter-Yaru" = {
    source    = ../../themes/Hatter-Yaru;
    recursive = true;
  };

  home.file.".local/share/icons/Neuwaita" = {
    source    = ../../themes/Neuwaita;
    recursive = true;
  };

  # ── GTK 3 fix ─────────────────────────────────────────────────────────
  home.file.".config/gtk-3.0/gtk.css" = {
    source    = ../../themes/Orchis-Red-Dark-Compact/gtk-3.0/gtk.css;
    recursive = false;
  };

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

  # ── Icon cache refresh (background, non-blocking) ─────────────────────
  home.activation.refreshIconCaches = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
  ];

  # ── GTK declaration ───────────────────────────────────────────────────
  gtk = {
    enable      = true;
    theme       = { name = "Orchis-Red-Dark-Compact"; };
    iconTheme   = { name = "Neuwaita"; };
    cursorTheme = { name = "Yaru"; package = pkgs.yaru-theme; };
    font        = { name = "Inter"; size = 11; };
  };

  # ── dconf ─────────────────────────────────────────────────────────────
  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme    = lib.mkForce "Orchis-Red-Dark-Compact";
    icon-theme   = lib.mkForce "Neuwaita";
    cursor-theme = "Yaru";
  };

  dconf.settings."org/gnome/shell/extensions/user-theme" = {
    name = lib.mkForce "Orchis-Red-Dark-Compact";
  };
}
