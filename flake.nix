{
  description = "Neovim configuration using NixVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixvim.url = "github:nix-community/nixvim";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Neovim plugins
    blink-cmp = {
      url = "github:Saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snacks-nvim = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixvim,
    self,
    ...
  }: let
    supportedSystems = ["x86_64-darwin" "x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Extend the default lib with custom functions
    lib = nixpkgs.lib.extend (final: prev: {
      custom = import ./lib {lib = final;};
    });
    # Extend the lib used for NixVim with the default NixVim lib
    libForNixvim = lib.extend nixvim.lib.overlay;
  in {
    packages = forAllSystems (system: {
      # Run NixVim as the default program for this flake with `nix run`
      default = nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit system;

        extraSpecialArgs = {
          inherit self;

          # Use the custom (extended) lib
          lib = libForNixvim;
        };

        module = import ./nixvim;
      };
    });

    # TODO: Add checks for NixVim?

    # Run development environment with `nix develop`
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          alejandra
          just
        ];
      };
    });

    # Format Nix files with `nix fmt .`
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Export custom overlays
    overlays = import ./overlays {inherit inputs;};
  };
}
