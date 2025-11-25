{ config, lib, pkgs, ... }: let
  gpu = config.my.gpu;
in {
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = [ "kvm-amd" ];
    supportedFilesystems = [ "btrfs" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = lib.optionals (gpu == "amd") (with pkgs; [ rocmPackages.clr.icd amdvlk ]);
    };
  };

  services.xserver.videoDrivers = lib.mkDefault (
    if gpu == "nvidia" then [ "nvidia" ]
    else if gpu == "intel" then [ "modesetting" ]
    else [ "amdgpu" ]
  );
}
