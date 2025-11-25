{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    jujutsu
    gcc
    pkg-config
    cmake
    ninja
    rustup
    rust-analyzer
    cargo
    rustc
    jdk21
    maven
    gradle
    nodejs_22
    python3
    pipx
    jq
    yq
    fd
    ripgrep
    fzf
    direnv
    nix-direnv
    alejandra
    nil
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
