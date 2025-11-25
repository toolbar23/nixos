{
  description = "toolbar23 NixOS with installer ISO, Hyprland/Quickshell, home-manager, and machine profiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    nixCats-nvim = {
      url = "github:BirdeeHub/nixCats-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, disko, lanzaboote, nixCats-nvim, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
      localGenerated = ./local/generated.nix;

      mkHost = name: extraModules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules =
            [
              ./modules/core/options.nix
              ./modules/core/nix.nix
              ./modules/core/locale.nix
              ./modules/core/boot.nix
              ./modules/core/users.nix
              ./modules/hardware/common.nix
              ./modules/hardware/btrfs-luks.nix
              ./modules/desktop/greetd.nix
              ./modules/desktop/hyprland.nix
              ./modules/desktop/quickshell.nix
              ./modules/home/base.nix
              ./modules/services/common.nix
              ./modules/dev/development.nix

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs nixCats-nvim; };
              }

              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote

              ./machines/${name}.nix
            ]
            ++ lib.optional (builtins.pathExists localGenerated) localGenerated
            ++ extraModules;
        };
    in {
      nixosConfigurations = {
        lenovo = mkHost "lenovo" [];
        squid  = mkHost "squid"  [];
      };

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          installerIso = (import "${pkgs.path}/nixos/lib/eval-config.nix" {
            inherit system;
            modules = [
              ./iso/installer.nix
              ./modules/core/options.nix
              ./modules/core/nix.nix
              ./modules/core/locale.nix
              ./modules/services/common.nix
              disko.nixosModules.disko
            ];
            specialArgs = { inherit inputs; };
          }).config.system.build.isoImage;
        });
    };
}
