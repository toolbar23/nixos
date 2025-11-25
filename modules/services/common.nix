{ pkgs, ... }: {
  networking.networkmanager.enable = true;

  services.timesyncd.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
      foomatic-db-ppds
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      nerd-fonts.jetbrains-mono
    ];
    enableDefaultPackages = true;
  };

  environment.systemPackages = with pkgs; [
    chromium
    ghostty
    wl-clipboard
    fastfetch
    unzip
  ];
}
