{ config, lib, pkgs, ... }: let
  user = config.my.user.name;
in {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.graphics = lib.mkDefault { enable = true; };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    fuzzel
    grim
    hyprpicker
    slurp
    swappy
    swaybg
    waybar
    wl-clipboard
    wtype
    xdg-utils
  ];

  home-manager.users.${user} = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;

      settings = {
        monitor = [ ",preferred,auto,1.25" ];

        exec-once = [
          "swaybg --color '#1e1e2e'"
          "waybar"
        ];

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "0xff7aa2f7";
          "col.inactive_border" = "0xff44475a";
        };

        decoration = {
          rounding = 6;
          drop_shadow = false;
          blur.enabled = false;
        };

        input = {
          kb_layout = config.my.keyboardLayout;
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        gestures.workspace_swipe = true;

        bind = [
          "SUPER, Return, exec, ghostty --gtk-single-instance=true"
          "SUPER, Q, killactive"
          "SUPER, F, fullscreen"
          "SUPER, D, exec, fuzzel"
          "SUPER, E, exec, pkill -USR1 waybar || waybar"
          "SUPER, C, exec, hyprpicker --autocopy"
          "SUPER, V, togglefloating"

          "SUPER, left , movefocus, l"
          "SUPER, down , movefocus, d"
          "SUPER, up   , movefocus, u"
          "SUPER, right, movefocus, r"

          "SUPER+SHIFT, left , movewindow, l"
          "SUPER+SHIFT, down , movewindow, d"
          "SUPER+SHIFT, up   , movewindow, u"
          "SUPER+SHIFT, right, movewindow, r"
        ];

        binde = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.5"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          ", XF86MonBrightnessUp  , exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set --min-value=0 5%-"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
      };
    };
  };
}
