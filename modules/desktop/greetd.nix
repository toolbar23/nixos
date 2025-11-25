{ config, pkgs, ... }: let
  user = config.my.user.name;
in {
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd Hyprland --user ${user} --autologin ${user}";
        user = "greeter";
      };
    };
  };
}
