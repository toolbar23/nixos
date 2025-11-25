{ config, inputs, lib, pkgs, ... }: let
  dollar = "$";
  installerScript = pkgs.writeShellScript "run-installer" ''
    set -euo pipefail

    user="pm"
    default_repo="https://github.com/toolbar23/nixos"
    read -p "Config repo URL [$default_repo]: " repo
    repo=''${repo:-$default_repo}

    echo "Ensuring network connectivity (launching nmtui until online)..."
    while ! nm-online -q --timeout=5; do
      nmtui
    done

    workdir=/tmp/nixos-config
    rm -rf "$workdir"
    jj git clone "$repo" "$workdir"

    machines=()
    while IFS= read -r file; do
      base=$(basename "$file" .nix)
      machines+=("$base")
    done < <(find "$workdir/machines" -maxdepth 1 -name '*.nix' | sort)

    if [ ${dollar}{#machines[@]} -eq 0 ]; then
      echo "No machines found in $workdir/machines" >&2
      exit 1
    fi

    echo "Select machine profile:"
    select machine in "${dollar}{machines[@]}"; do
      [ -n "${dollar}{machine:-}" ] && break
      echo "Invalid choice"
    done

    read -p "Target disk [/dev/nvme0n1]: " disk
    disk=''${disk:-/dev/nvme0n1}

    echo "About to wipe $disk and install $machine from $repo"
    read -p "Type YES to continue: " confirm
    if [ "$confirm" != "YES" ]; then
      echo "Aborting."
      exit 1
    fi

    echo "Set password for root/$user (used for both accounts):"
    while true; do
      read -s -p "Password: " pw1; echo
      read -s -p "Repeat  : " pw2; echo
      [ "$pw1" = "$pw2" ] && [ -n "$pw1" ] && break
      echo "Passwords do not match, try again."
    done
    hash=$(printf "%s" "$pw1" | openssl passwd -6 -stdin)

    mkdir -p /etc/nixos/secrets
    passfile="/etc/nixos/secrets/$user.passwd"
    printf "%s\n" "$hash" > "$passfile"

    echo "Running disko-install..."
    nix run 'github:nix-community/disko/latest#disko-install' -- --flake "$workdir#$machine" --disk main "$disk"

    echo "Copying password hash into target..."
    mkdir -p /mnt/etc/nixos/secrets
    cp "$passfile" /mnt/etc/nixos/secrets/$user.passwd

    cat <<'EOF'
Install finished.
On first boot:
  - swapfile will be created automatically; run 'sudo nixos-rebuild switch' once to pick up resume_offset for hibernate.
  - hyprland autologin via greetd is enabled for user pm.
EOF
  '';
in {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  isoImage.squashfsCompression = "zstd";

  services.getty.autologinUser = lib.mkForce "root";
  networking.hostName = "nixos-installer";

  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ] && [ -z "''${INSTALLER_DONE:-}" ]; then
      INSTALLER_DONE=1 ${installerScript}
    fi
  '';

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    git
    jujutsu
    networkmanager
    openssl
    disko
  ];
}
