{ inputs, lib, ... }: {
  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
    };

    registry.nixpkgs.flake = inputs.nixpkgs;
    channel.enable = false;
  };
}
