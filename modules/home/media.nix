{ config, pkgs, lib, ... }:
{
  services.easyeffects = {
    enable = true;
    preset = "C+Cry+BE+Max";
  };

  services.mpd = {
    enable         = true;
    musicDirectory = "/home/ochinix/Music";
  };

  programs.mpv = {
    enable  = true;
    package = pkgs.mpv;
    config = {
      profile                    = "gpu-hq";
      gpu-api                    = "vulkan";
      hwdec                      = "vaapi";
      vo                         = "gpu-next";
      deband                     = true;
      deband-iterations          = 4;
      dither-depth               = "auto";
      correct-downscaling        = true;
      linear-downscaling         = true;
      sigmoid-upscaling          = true;
      scale                      = "ewa_lanczossharp";
      cscale                     = "ewa_lanczossharp";
      audio-normalize-downmix    = true;
      audio-pitch-correction     = true;
      af                         = "acompressor";
      volume                     = 100;
      volume-max                 = 150;
      sub-auto                   = "fuzzy";
      sub-font                   = "JetBrains Mono";
      sub-font-size              = 42;
      sub-color                  = "#FFFFFF";
      sub-border-size            = 2;
      sub-border-color           = "#000000";
      sub-shadow-offset          = 2;
      sub-shadow-color           = "#000000";
      sub-ass-override           = "force";
      osc                        = false;
      osd-font                   = "JetBrains Mono";
      osd-font-size              = 28;
      autofit-larger             = "40%x40%";
      autofit-smaller            = "30%x30%";
      geometry                   = "30%:30%";
      force-window               = true;
      keep-open                  = true;
      save-position-on-quit      = true;
      screenshot-format          = "png";
      screenshot-directory       = "~/Pictures/Screenshots";
      screenshot-png-compression = 4;
      screenshot-tag-colorspace  = true;
      ytdl-format                = "bestvideo[height<=1080]+bestaudio/best[height<=1080]";
    };

    bindings = {
      "l"      = "seek 5";
      "h"      = "seek -5";
      "L"      = "seek 30";
      "H"      = "seek -30";
      "j"      = "add volume -5";
      "k"      = "add volume 5";
      "m"      = "cycle mute";
      "="      = "add speed 0.1";
      "-"      = "add speed -0.1";
      "BS"     = "set speed 1.0";
      "s"      = "cycle sub";
      "S"      = "cycle sub down";
      ">"      = "playlist-next";
      "<"      = "playlist-prev";
      "f"      = "cycle fullscreen";
      "ctrl+s" = "screenshot video";
      "ctrl+S" = "screenshot";
      "i"      = "script-binding stats/display-stats-toggle";
      "A"      = "cycle-values video-aspect-override 16:9 4:3 2.35:1 -1";
    };

    scripts = with pkgs.mpvScripts; [
      uosc
      sponsorblock
      thumbfast
      autoload
      inhibit-gnome
      quality-menu
      mpris
      videoclip
    ];
  };
}
