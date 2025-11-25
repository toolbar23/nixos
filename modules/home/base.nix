{ config, inputs, pkgs, ... }: let
  my = config.my;
  user = my.user.name;
in {
  home-manager.users.${user} = { pkgs, ... }: {
    home.username = user;
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "24.11";

    programs.bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
        export EDITOR=nvim
      '';
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.git = {
      enable = true;
      settings = {
        user.name = my.user.fullName;
        user.email = my.user.email;
        init.defaultBranch = "main";
      };
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        user.name = my.user.fullName;
        user.email = my.user.email;
        ui.default-command = "log";
      };
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };

    programs.fzf.enable = true;
    programs.zoxide.enable = true;

    services.udiskie.enable = true;
  };
}
