{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.fish.enable = true;

  users.users.austin = {
    isNormalUser = true;
    home = "/home/austin";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$B3Dht0DM5AgoKSQQ$Gch.GPw.vzsArVHL.BD3fGxKHhkmv433b1tgU4jB8ZRlMQTr6bWG.9LQiPxFB34ZAOlPmiwncEq1LvT96umP1.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeC5UrbA3V1jl9Syp0fkTm2XEQEHW01t9hhrcXLXH28 jonesaustindev@gmail.com"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix { inherit inputs; })
  ];
}
