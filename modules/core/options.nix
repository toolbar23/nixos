{ lib, ... }: let
  inherit (lib) mkOption types;
in {
  options.my = {
    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "Hostname for this machine.";
    };

    machineRole = mkOption {
      type = types.enum [ "development" ];
      default = "development";
      description = "High-level role that selects package/profile sets.";
    };

    timeZone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
      description = "System time zone.";
    };

    locale = mkOption {
      type = types.submodule {
        options = {
          primary = mkOption {
            type = types.str;
            default = "en_US.UTF-8";
            description = "Primary locale.";
          };
          secondary = mkOption {
            type = types.str;
            default = "de_DE.UTF-8";
            description = "Secondary locale.";
          };
        };
      };
      default = { };
      description = "Locale settings.";
    };

    keyboardLayout = mkOption {
      type = types.str;
      default = "de";
      description = "Keyboard layout for TTY and Wayland.";
    };

    user = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "pm";
            description = "User account name.";
          };

          fullName = mkOption {
            type = types.str;
            default = "Paul Mallach";
            description = "Full name for the user.";
          };

          email = mkOption {
            type = types.str;
            default = "paul.mallach@gmail.com";
            description = "Email for git/JJ.";
          };

          extraGroups = mkOption {
            type = types.listOf types.str;
            default = [ "wheel" "networkmanager" "video" "audio" "input" "lp" "scanner" ];
            description = "Supplementary groups for the user.";
          };
        };
      };
      default = { };
      description = "Primary user configuration.";
    };

    disk = mkOption {
      type = types.submodule {
        options = {
          device = mkOption {
            type = types.str;
            default = "/dev/nvme0n1";
            description = "Target disk for disko layout.";
          };

          swapSizeGiB = mkOption {
            type = types.ints.positive;
            default = 64;
            description = "Swap size in GiB (cap at RAM via installer).";
          };
        };
      };
      default = { };
      description = "Disk layout knobs.";
    };

    gpu = mkOption {
      type = types.enum [ "amd" "nvidia" "intel" ];
      default = "amd";
      description = "GPU vendor hint for driver selection.";
    };
  };
}
