{ config, pkgs, lib, ... }:
{
  home.file.".config/kitty" = {
    source    = ./../../kitty; # Adjusted path
    recursive = true;
  };

  home.file.".config/starship.toml".source = ./../../starship/starship.toml;

  home.file.".config/easyeffects/output" = {
    source    = ./../../easyeffects/output;
    recursive = true;
  };

  home.file.".config/easyeffects/irs" = {
    source    = ./../../easyeffects/irs;
    recursive = true;
  };

  home.file.".config/mpd/mpd.conf".source = ./../../mpd/mpd.conf;
  home.file.".config/organize/config.yaml".source = ./../../organize/config.yaml;

  home.file.".local/share/fonts" = {
    source    = ./../../fonts;
    recursive = true;
  };

  # Activation scripts
  home.activation.createVaultDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/Documents/.vault
    mkdir -p ~/Documents/Vault
    mkdir -p ~/Backups
    mkdir -p ~/Videos/.Fragments-vault
    mkdir -p ~/Videos/Fragments
  '';   

  home.activation.copyNvchadCustom = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -d ~/.local/share/nvim/lazy/NvChad ]; then
      mkdir -p ~/.config/nvim/lua/plugins
      mkdir -p ~/.config/nvim/lua/configs
      cp -rf ${./../../nvchad-lua/plugins}/. ~/.config/nvim/lua/plugins/
      cp -f ${./../../nvchad-lua/autocmds.lua}             ~/.config/nvim/lua/autocmds.lua
      cp -f ${./../../nvchad-lua/configs/lspconfig.lua}    ~/.config/nvim/lua/configs/lspconfig.lua
    fi
  '';

  home.activation.refreshFontCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.fontconfig}/bin/fc-cache -f
  '';
}
