{ lib, self, ... }:
{
  imports = [
    ./colorschemes.nix
    ./dependencies.nix
    ./diagnostics.nix
    ./ftplugins.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
    ./ui.nix
  ];

  options.languageTools = lib.mkOption {
    type = lib.types.enum [
      "bundled"
      "external"
      "none"
    ];
    default = "bundled";
    description = ''
      Where the language servers and formatters come from: "bundled" adds them
      as a fallback for the ones on PATH, "external" uses only the ones on PATH,
      and "none" sets up no language servers or formatters.
    '';
  };

  # Apply overlays for pkgs used by NixVim
  config.nixpkgs.overlays = [
    self.overlays.neovim-nightly
  ];
}
