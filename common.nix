{ lib, config, pkgs, ... }:
let
  kentSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzXYZ0uwhhyOeHSBHSGQF+Y++qyoLEuyWnmF3/BJ5jp kent";
  danielSShkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqloVs3g8afwA4R3VBV8d6QSkzdRqZbvPh5NdEn60a7 KeyPass Auth";
in
{
  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Set your time zone.
  time.timeZone = "Pacific/Auckland";
  
    # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  users.defaultUserShell = pkgs.zsh;

  users.users = { 
    daniel = {
    isNormalUser = true;
    initialPassword = "vsEjQUp4" ;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ danielSshKey ];
    };

    root = {
      openssh.authorizedKeys.keys = [ kentSshKey danielSshKey ];
    };

    testdashboard = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ kentSshKey ];
    };
  };

  environment.systemPackages = with pkgs; [
    pciutils
    killall
    file
    schedtool
    nix-prefetch-github
    usbutils
    lsof
    smem
    sysstat
    wget
    gnupg
    git
    htop

    direnv
    starship
    tmux

    (aspellWithDicts (d: [d.en d.en-computers d.en-science]))

    irssi
    vim

    # ktest / dev
    brotli
    config.boot.kernelPackages.perf
    getopt
    flex
    bison
    gcc
    gdb
    gnumake
    bc
    pkg-config
    binutils
    (python3.withPackages (p: with p; [ ply GitPython ]))
    pahole
    qemu
    nixos-shell
    minicom
    socat
    vde2
    elfutils
    ncurses
    openssl
    zlib
  ];


  programs.zsh = with pkgs; {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    promptInit = ''
     eval "$(${direnv}/bin/direnv hook zsh)"
     eval "$(${starship}/bin/starship init zsh)"
     '';
  };

  services.openssh.enable = true;
  
  nix = {
    daemonCPUSchedPolicy = "idle";
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
