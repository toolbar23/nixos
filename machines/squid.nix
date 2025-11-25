{ config, ... }: {
  my = {
    hostName = "squid";
    machineRole = "development";
    disk.device = "/dev/nvme0n1";
    disk.swapSizeGiB = 64;
    gpu = "amd";
  };

  networking.hostName = config.my.hostName;

  system.stateVersion = "24.11";
}
