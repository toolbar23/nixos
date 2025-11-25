{ config, lib, ... }: let
  inherit (lib) mkDefault;
in {
  time.timeZone = mkDefault config.my.timeZone;

  i18n.defaultLocale = mkDefault config.my.locale.primary;
  i18n.extraLocales = [ config.my.locale.secondary ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = config.my.locale.secondary;
    LC_IDENTIFICATION = config.my.locale.secondary;
    LC_MEASUREMENT    = config.my.locale.secondary;
    LC_MONETARY       = config.my.locale.secondary;
    LC_NAME           = config.my.locale.secondary;
    LC_NUMERIC        = config.my.locale.secondary;
    LC_PAPER          = config.my.locale.secondary;
    LC_TELEPHONE      = config.my.locale.secondary;
    LC_TIME           = config.my.locale.secondary;
  };

  console = {
    keyMap = mkDefault config.my.keyboardLayout;
  };

  services.xserver.xkb = {
    layout = config.my.keyboardLayout;
    variant = "";
  };
}
