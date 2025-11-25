{ config, lib, pkgs, ... }: let
  inherit (lib) mkDefault mkMerge mkIf;

  user = config.my.user.name;
  passwordFile = "/etc/nixos/secrets/${user}.passwd";
in
mkMerge [
  {
    users.mutableUsers = true;
    users.defaultUserShell = pkgs.bashInteractive;

    users.users.${user} = {
      isNormalUser = true;
      description = config.my.user.fullName;
      extraGroups = config.my.user.extraGroups;
      openssh.authorizedKeys.keys = [ ];
    };

    users.users.root = {
      openssh.authorizedKeys.keys = [ ];
    };

    programs.bash = {
      promptInit = "";
      interactiveShellInit = ''
        if [ -x /run/current-system/sw/bin/starship ]; then
          eval "$(/run/current-system/sw/bin/starship init bash)"
        fi
      '';
    };
  }

  (mkIf (builtins.pathExists passwordFile) {
    users.users.${user}.hashedPasswordFile = passwordFile;
    users.users.root.hashedPasswordFile = passwordFile;
  })
]
