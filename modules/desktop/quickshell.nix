{ config, lib, pkgs, ... }: let
  user = config.my.user.name;
  hasQuickshell = pkgs ? quickshell;
in {
  environment.systemPackages = lib.optional hasQuickshell pkgs.quickshell;

  home-manager.users.${user} = lib.mkIf hasQuickshell {
    xdg.configFile."quickshell/README.txt".text = ''
      Quickshell is installed. Add a QML config here (e.g. quickshell.qml)
      and start it from Hyprland exec-once once ready.
    '';
  };
}
