{
  description = "NixOS systems and tools by mitchellh";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Build a custom WSL installer
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # I think technically you're not supposed to override the nixpkgs
    # used by neovim but recently I had failures if I didn't pin to my
    # own. We can always try to remove that anytime.
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    # Other packages
    jujutsu.url = "github:martinvonz/jj";
    zig.url = "github:mitchellh/zig-overlay";
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # Neovim config
    nvim-config = {
      url = "github:jonesaustindev/nvim";
      flake = false;
    };

    # Non-flakes
    # nvim-conform.url = "github:stevearc/conform.nvim/v7.1.0";
    # nvim-conform.flake = false;
    # nvim-dressing.url = "github:stevearc/dressing.nvim";
    # nvim-dressing.flake = false;
    # nvim-gitsigns.url = "github:lewis6991/gitsigns.nvim/v0.9.0";
    # nvim-gitsigns.flake = false;
    # nvim-lspconfig.url = "github:neovim/nvim-lspconfig";
    # nvim-lspconfig.flake = false;
    # nvim-lualine.url ="github:nvim-lualine/lualine.nvim";
    # nvim-lualine.flake = false;
    # nvim-nui.url = "github:MunifTanjim/nui.nvim";
    # nvim-nui.flake = false;
    # nvim-plenary.url = "github:nvim-lua/plenary.nvim";
    # nvim-plenary.flake = false;
    # nvim-telescope.url = "github:nvim-telescope/telescope.nvim/0.1.8";
    # nvim-telescope.flake = false;
    # nvim-treesitter.url = "github:nvim-treesitter/nvim-treesitter/v0.9.2";
    # nvim-treesitter.flake = false;
    nvim-web-devicons.url = "github:nvim-tree/nvim-web-devicons";
    nvim-web-devicons.flake = false;
    # vim-copilot.url = "github:github/copilot.vim/v1.41.0";
    # vim-copilot.flake = false;
    # vim-misc.url = "github:mitchellh/vim-misc";
    # vim-misc.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: let
    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      inputs.jujutsu.overlays.default
      inputs.zig.overlays.default
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
    darwinConfigurations = {
      "macbook-pro-m1" = mkSystem "macbook-pro-m1" {
        system = "aarch64-darwin";
        user = "austin";
        darwin = true;
      };
      "macbook-pro" = mkSystem "macbook-pro" {
        system = "x86_64-darwin";
        user = "austin";
        darwin = true;
      };
    };

    nixosConfigurations = {
      "vm-intel" = mkSystem "vm-intel" {
        system = "x86_64-linux";
        user = "austin";
      };
      "vm-aarch64" = mkSystem "vm-aarch64" {
        system = "aarch64-linux";
        user = "austin";
      };
      "vm-aarch64-utm" = mkSystem "vm-aarch64-utm" {
        system = "aarch64-linux";
        user = "austin";
      };
      "vm-aarch64-prl" = mkSystem "vm-aarch64-prl" {
        system = "aarch64-linux";
        user = "austin";
      };
      "wsl" = mkSystem "wsl" {
        system = "x86_64-linux";
        user = "austin";
        wsl = true;
      };
    };
  };
}
