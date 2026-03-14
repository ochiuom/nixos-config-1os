{ config, pkgs, lib, ... }:
{
  dconf.settings = {

    # ── User Theme ───────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/user-theme" = {
      name = "Orchis-Dark-Compact";
    };

    # ── Dash to Panel ────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
      appicon-margin = 1;
      appicon-padding = 4;
      dot-position = "BOTTOM";
      group-apps = true;
      hotkeys-overlay-combo = "TEMPORARILY";
      panel-anchors = ''{"BOE-0x00000000":"MIDDLE"}'';
      panel-element-positions = ''{"BOE-0x00000000":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'';
      panel-lengths = ''{"BOE-0x00000000":100}'';
      panel-positions = ''{"BOE-0x00000000":"TOP"}'';
      panel-sizes = ''{"BOE-0x00000000":29}'';
      show-favorites-all-monitors = false;
      trans-panel-opacity = 0.0;
      trans-use-border = true;
      trans-use-custom-bg = false;
      trans-use-custom-gradient = false;
      trans-use-custom-opacity = true;
      window-preview-title-position = "TOP";
    };

    # ── Blur My Shell ────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.6;
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.6;
      pipeline = "pipeline_default_rounded";
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness = 0.6;
      pipeline = "pipeline_default";
      sigma = 0;
      static-blur = false;
    };

    # ── Astra Monitor ────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/astra-monitor" = {
      memory-header-bars = false;
      memory-header-icon = false;
      memory-header-value = true;
      monitors-order = "['processor','gpu','memory','storage','network','sensors']";
      network-header-graph = false;
      network-header-icon = false;
      network-header-io = true;
      processor-header-graph = false;
      processor-header-icon = false;
      processor-header-percentage = true;
      sensors-header-show = false;
      storage-header-show = false;
      storage-main = "name-cryptroot";
    };

    # ── Tiling Assistant ─────────────────────────────────────────────────────
    "org/gnome/shell/extensions/tiling-assistant" = {
      enable-tiling-popup = true;
      window-gap = 4;
      maximize-with-gap = true;
      default-wrap-mode = 0;
      dynamic-keybinding-behavior = 0;
      default-move-mode = 0;
      focus-hint = 0;
      focus-hint-color = "rgb(53,132,228)";
    };

    # ── Space Bar ────────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/space-bar/behavior" = {
      always-show-numbers = true;
      scroll-wheel = "panel";
      show-empty-workspaces = true;
      smart-workspace-names = true;
      toggle-overview = false;
    };

    "org/gnome/shell/extensions/space-bar/appearance" = {
      workspaces-bar-padding = 12;
      application-styles = ''
        .space-bar {
          -natural-hpadding: 12px;
        }
        .space-bar-workspace-label.active {
          margin: 0 4px;
          background-color: rgba(255,255,255,0.3);
          color: rgba(255,255,255,1);
          border-color: rgba(0,0,0,0);
          font-weight: 700;
          border-radius: 4px;
          border-width: 0px;
          padding: 3px 8px;
        }
        .space-bar-workspace-label.inactive {
          margin: 0 4px;
          background-color: rgba(0,0,0,0);
          color: rgba(255,255,255,1);
          border-color: rgba(0,0,0,0);
          font-weight: 700;
          border-radius: 4px;
          border-width: 0px;
          padding: 3px 8px;
        }
        .space-bar-workspace-label.inactive.empty {
          margin: 0 4px;
          background-color: rgba(0,0,0,0);
          color: rgba(255,255,255,0.5);
          border-color: rgba(0,0,0,0);
          font-weight: 700;
          border-radius: 4px;
          border-width: 0px;
          padding: 3px 8px;
        }
      '';
    };

    # ── Search Light ─────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/search-light" = {
      animation-speed = 100.0;
      blur-brightness = 0.6;
      blur-sigma = 30.0;
      border-thickness = 0;
      entry-font-size = 1;
      scale-height = 0.1;
      scale-width = 0.1;
      shortcut-search = [ "<Control>space" ];
      show-panel-icon = false;
    };

    # ── Caffeine ─────────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/caffeine" = {
      cli-toggle = false;
      indicator-position-max = 2;
    };

    # ── Compiz Windows Effect ────────────────────────────────────────────────
    "com/github/hermes83/compiz-windows-effect" = {
      preset = "R";
      resize-effect = true;
    };

    # ── Compiz Magic Lamp ────────────────────────────────────────────────────
    "ncom/github/hermes83/compiz-alike-magic-lamp-effect" = {
      effect = "sine";
    };

    # ── Compact Top Bar ──────────────────────────────────────────────────────
    "org/gnome/shell/extensions/compact-top-bar" = {
      fade-text-on-fullscreen = false;
    };

    # ── IP Finder ────────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/ip-finder" = {
      position-in-panel = "center";
    };

    # ── TopHat ───────────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/tophat" = {
      mount-to-monitor = "/";
    };

    # ── Advanced Weather ─────────────────────────────────────────────────────
    "org/gnome/shell/extensions/advanced-weather" = {
      weather-provider = "openmeteo";
    };

    # ── Penguin AI Chatbot ───────────────────────────────────────────────────
    # API keys excluded — stored in ~/.api_keys
    "org/gnome/shell/extensions/penguin-ai-chatbot" = {
      anthropic-model = "claude-3-sonnet-20240229";
      gemini-model = "gemini-2.0-flash";
      llm-provider = "openrouter";
      openrouter-model = "arcee-ai/trinity-large-preview:free";
      open-chat-shortcut = [ "<Control><Super>l" ];
      human-message-color = "rgb(0,106,255)";
      human-message-text-color = "rgb(255,255,255)";
      llm-message-color = "rgb(96,99,102)";
      llm-message-text-color = "rgb(255,255,255)";
    };

  };
}
