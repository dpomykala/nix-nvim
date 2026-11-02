{
  description = "Neovim configuration using NixVim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixvim.url = "github:nix-community/nixvim";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # The kulala.nvim grammar, pinned to the revision that kulala expects. The
    # build fails when they differ, see `nixvim/plugins/kulala.nix`.
    tree-sitter-kulala-http = {
      url = "github:mistweaverco/tree-sitter-kulala-http/630e2b8523c775ba866564c2b4ad88d649a56c00";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixvim,
      self,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Extend the default lib with custom functions
      lib = nixpkgs.lib.extend (
        final: prev: {
          custom = import ./lib { lib = final; };
        }
      );
      # Extend the lib used for NixVim with the default NixVim lib
      libForNixvim = lib.extend nixvim.lib.overlay;
    in
    {
      packages = forAllSystems (
        system:
        let
          nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit system;

            extraSpecialArgs = {
              inherit self;

              # Use the custom (extended) lib
              lib = libForNixvim;
            };

            module = import ./nixvim;
          };
        in
        {
          # Run NixVim as the default program for this flake with `nix run`. It
          # bundles the language servers and formatters, so it works anywhere.
          default = nvim;

          # Uses only the language servers and formatters on PATH
          external = nvim.extend { languageTools = "external"; };

          # Sets up no language servers or formatters
          minimal = nvim.extend { languageTools = "none"; };
        }
      );

      # TODO: Add checks for NixVim?

      # Run development environment with `nix develop`
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              just
              nixfmt-tree
            ];
          };
        }
      );

      # Format Nix files with `nix fmt .`
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Export custom overlays
      overlays = import ./overlays { inherit inputs; };
    };
}
