{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    networkmanagerapplet xdg-desktop-portal-gnome gpick
    libreoffice-fresh hunspell hunspellDicts.en_US
    fragments qbittorrent texstudio firefox ghostty vscode sublime4
    vlc mpd mpc mpv mplayer smplayer audacious audacious-plugins audacity
    cava cavalier yazi evince gparted baobab wl-color-picker localsend qpwgraph
    strawberry gimp inkscape imagemagick shotwell ymuse plattenalbum
    nextcloud-client gemini-cli opencode zathura pdfsam-basic
    gnome-tweaks gnome-extension-manager
  ];
}
