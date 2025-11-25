{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.bootspec.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
    configurationLimit = 8;
    generateKeys = true;
  };

  boot.initrd.systemd.enable = true;

  services.fwupd.enable = true;

  environment.systemPackages = [ pkgs.sbctl ];
}
