# modules/home/orchis.nix
{ config, pkgs, lib, inputs, theme ? "red", ... }:

let
  themeName = "Orchis-${lib.strings.toUpper (builtins.substring 0 1 theme)}${builtins.substring 1 (builtins.stringLength theme - 1) theme}-Dark-Compact";

  orchis = pkgs.stdenv.mkDerivation {
    name = themeName;
    src  = inputs.orchis-theme;

    nativeBuildInputs = with pkgs; [
      sassc
      gtk3
      bc
      which
      glibc
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes
      export HOME=$TMPDIR

      bash install.sh \
        --dest   $out/share/themes \
        --name   Orchis \
        --theme  ${theme} \
        --color  dark \
        --size   compact \
        --tweaks compact

      runHook postInstall
    '';
  };

in
{
  home.packages = [ orchis ];

  home.file.".local/share/themes/${themeName}".source =
    "${orchis}/share/themes/${themeName}";

  home.file.".config/gtk-4.0/gtk.css".source =
    "${orchis}/share/themes/${themeName}/gtk-4.0/gtk.css";

  home.file.".config/gtk-4.0/gtk-dark.css".source =
    "${orchis}/share/themes/${themeName}/gtk-4.0/gtk-dark.css";

  home.file.".config/gtk-4.0/assets" = {
    source    = "${orchis}/share/themes/${themeName}/gtk-4.0/assets";
    recursive = true;
  };

  gtk.theme = { name = themeName; };

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme = lib.mkForce themeName;
  };

  dconf.settings."org/gnome/shell/extensions/user-theme" = {
    name = lib.mkForce themeName;
  };
}
