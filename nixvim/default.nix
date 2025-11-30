{self, ...}: {
  imports = [
    ./colorschemes.nix
    ./diagnostics.nix
    ./ftplugins.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];

  # Apply overlays for pkgs used by NixVim
  nixpkgs.overlays = [
    # FIXME: Building blink-fuzzy-lib fails when using flake.nix from official repo
    # Related: https://github.com/NixOS/nixpkgs/commit/876a05aa448239e421a7c6b4c799fc469fe0200d
    # self.overlays.blink-cmp-main
    self.overlays.neovim-nightly
    self.overlays.snacks-nvim-main
  ];
}
