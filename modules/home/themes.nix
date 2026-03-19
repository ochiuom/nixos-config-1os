# modules/home/themes.nix
{ config, pkgs, lib, inputs, ... }:

let
  hatter = pkgs.stdenv.mkDerivation {
    name = "Hatter-icon-theme";
    src  = inputs.hatter;

    nativeBuildInputs = [ pkgs.gtk3 ];

    installPhase = ''
      runHook preInstall

      for variant in Hatter Hatter-Yaru Hatter-Red Hatter-Blue Hatter-Green \
                     Hatter-Purple Hatter-Yellow Hatter-Orange Hatter-Pink \
                     Hatter-Teal Hatter-Slate; do
        if [ -d "$variant" ]; then
          mkdir -p $out/share/icons/$variant
          cp -r $variant/. $out/share/icons/$variant/

          if [ -f "$out/share/icons/$variant/index.theme" ]; then
            sed -i 's|Inherits=.*|Inherits=Yaru|' \
              $out/share/icons/$variant/index.theme
          fi

          ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
            $out/share/icons/$variant || true
        fi
      done

      runHook postInstall
    '';
  };

in
{
  imports = [
    (import ./orchis.nix { inherit config pkgs lib inputs; theme = "green"; })
  ];

  home.packages = [
    pkgs.yaru-theme
    hatter
  ];

  home.file.".local/share/icons/Yaru" = {
    source    = "${pkgs.yaru-theme}/share/icons/Yaru";
    recursive = true;
  };

  home.file.".local/share/icons/Hatter" = {
    source    = "${hatter}/share/icons/Hatter";
    recursive = true;
  };

  home.file.".local/share/icons/Hatter-Yaru" = {
    source    = "${hatter}/share/icons/Hatter-Yaru";
    recursive = true;
  };

  home.file.".local/share/icons/Neuwaita" = {
    source    = inputs.neuwaita;
    recursive = true;
  };

  home.activation.refreshIconCaches = lib.hm.dag.entryAfter ["writeBoundary"] ''
    (
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
        ~/.local/share/icons/Yaru || true
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
        ~/.local/share/icons/Hatter || true
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
        ~/.local/share/icons/Hatter-Yaru || true
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t \
        ~/.local/share/icons/Neuwaita || true
    ) &
    disown
  '';

  gtk = {
    enable      = true;
    iconTheme   = { name = "Neuwaita"; };
    cursorTheme = { name = "Yaru"; package = pkgs.yaru-theme; };
    font        = { name = "Inter"; size = 11; };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme   = lib.mkForce "Neuwaita";
    cursor-theme = "Yaru";
  };
}
