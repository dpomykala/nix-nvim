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
    self.overlays.neovim-nightly
    self.overlays.snacks-nvim-main
  ];
}
