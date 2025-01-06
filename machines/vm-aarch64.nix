{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware/vm-aarch64.nix
    ../modules/vmware-guest.nix
    ./vm-shared.nix
  ];

  # setup qemu so we can run x86_64 binaries
  boot.binfmt.emulatedSystems = ["x86_64-linux"];

  # disable the default module and import our override. we have
  # customizations to make this work on aarch64.
  disabledModules = [ "virtualisation/vmware-guest.nix" ];
  # disabledModules = [ "nixos/modules/virtualisation/vmware-guest.nix" ];

  # interface is this on m1
  networking.interfaces.ens160.useDHCP = true;

  # lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # this works through our custom module imported above
  virtualisation.vmware.guest.enable = true;

  # share our host filesystem
  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "umask=22"
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };

  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    pkg-config
    unzip
    pinentry
    pinentry-tty
  ];

  # enable postgresql service
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    initialScript = pkgs.writeText "initialScript.sql" ''
      create user postgres with password 'postgres' createdb;
      create database ndever_dev;
      grant all privileges on database ndever_dev to postgres;
    '';
    settings = {
      listen_addresses = "*";
      max_connections = 100;
    };
  };

  programs.gnupg = {
    agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-tty;
    };
    dirmngr.enable = true;
    agent.settings = {
      # Use mkForce to override the default value
      pinentry-program = lib.mkForce "${pkgs.pinentry-tty}/bin/pinentry-tty";
    };
  };
}

