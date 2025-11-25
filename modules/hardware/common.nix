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
    ] ++ lib.optionals (gpu == "intel") [ "i915" ];

    kernelModules =
      lib.optionals (gpu == "amd") [ "kvm-amd" ]
      ++ lib.optionals (gpu == "intel") [ "kvm-intel" ];

    supportedFilesystems = [ "btrfs" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  hardware = {
    enableRedistributableFirmware = true;
    cpu = {
      amd.updateMicrocode = lib.mkIf (gpu == "amd") true;
      intel.updateMicrocode = lib.mkIf (gpu == "intel") true;
    };

    graphics = {
      enable = true;
      extraPackages =
        lib.optionals (gpu == "amd") (with pkgs; [ rocmPackages.clr.icd ]) ++
        lib.optionals (gpu == "intel") (with pkgs; [ intel-media-driver intel-vaapi-driver libvdpau-va-gl ]);
    };
  };

  services.xserver.videoDrivers = lib.mkDefault (
    if gpu == "nvidia" then [ "nvidia" ]
    else if gpu == "intel" then [ "modesetting" ]
    else [ "amdgpu" ]
  );

  hardware.nvidia = lib.mkIf (gpu == "nvidia") {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    open = lib.mkDefault false;
  };
}
