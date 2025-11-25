{ config, lib, pkgs, ... }: let
  swapFile = "/swap/swapfile";
  device = config.my.disk.device;
  resumeOffsetFile = "/etc/nixos/secrets/resume_offset";
in {
  disko.devices = {
    disk.main = {
      type = "disk";
      inherit device;
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "EFI";
            name = "ESP";
            size = "1G";
            type = "ef00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0022" "dmask=0022" ];
            };
          };

          luks = {
            label = "cryptroot";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                mountOptions = [ "noatime" "ssd" "space_cache=v2" ];
                subvolumes = {
                  "@".mountpoint = "/";
                  "@home".mountpoint = "/home";
                  "@nix".mountpoint = "/nix";
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "noatime" "ssd" "space_cache=v2" ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [ "noatime" "ssd" "space_cache=v2" "nodatacow" "nodatasum" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/cryptroot";
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  boot.resumeDevice = lib.mkDefault "/dev/mapper/cryptroot";
  swapDevices = [ { device = swapFile; } ];

  boot.kernelParams = lib.mkIf (builtins.pathExists resumeOffsetFile) [
    ("resume_offset=" + lib.removeSuffix "\n" (builtins.readFile resumeOffsetFile))
  ];

  # Prepare swap file on first boot. We size it to the max of
  # requested size (config.my.disk.swapSizeGiB), 64 GiB baseline,
  # and RAM size to keep hibernation viable.
  systemd.services.swapfile-prepare = {
    description = "Create swapfile on Btrfs if missing";
    wantedBy = [ "swap.target" ];
    before = [ "swap.target" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";
    path = [ pkgs.coreutils pkgs.util-linux pkgs.btrfs-progs pkgs.e2fsprogs ];
    script = ''
      set -euo pipefail
      swap_file=${swapFile}
      if [ ! -f "$swap_file" ]; then
        mkdir -p /swap
        chmod 700 /swap
        chattr +C /swap 2>/dev/null || true
        btrfs property set /swap compression none 2>/dev/null || true

        mem_kib=$(awk '/MemTotal/ {print $2}' /proc/meminfo || echo 0)
        mem_gib=$(( (mem_kib + 1048575) / 1048576 ))
        target_gib=${toString config.my.disk.swapSizeGiB}
        : ''${target_gib:=64}
        if [ "$mem_gib" -gt "$target_gib" ]; then
          target_gib=$mem_gib
        fi
        if [ "$target_gib" -lt 64 ]; then
          target_gib=64
        fi

        echo "Creating swapfile of ''${target_gib}G at $swap_file"
        fallocate -l "''${target_gib}G" "$swap_file"
        chmod 600 "$swap_file"
        btrfs property set "$swap_file" compression none 2>/dev/null || true
        chattr +C "$swap_file" 2>/dev/null || true
        mkswap "$swap_file"
      fi

      offset=$(btrfs inspect-internal map-swapfile -r "$swap_file" 2>/dev/null | awk 'END {print $NF}')
      if [ -n "$offset" ]; then
        mkdir -p /etc/nixos/secrets
        printf "%s\n" "$offset" > /etc/nixos/secrets/resume_offset
      fi
    '';
  };

  services.btrfs.autoScrub.enable = true;
}
