/*
  kulala.nvim - A fully-featured REST Client Interface for Neovim.

  https://nix-community.github.io/nixvim/plugins/kulala/
  https://github.com/dont-be-evil-company/kulala.nvim

  TODO: Use also kulala-fmt and kulala-ls?
*/
{
  config,
  pkgs,
  self,
  ...
}:
let
  grammarSrc = self.inputs.tree-sitter-kulala-http;
  grammarVersionFile = "${config.plugins.kulala.package}/lua/kulala/globals/versions/treesitter.lua";

  # By default, kulala clones and compiles its grammar on first use, which
  # needs network access and a C compiler on the host
  grammar = pkgs.tree-sitter.buildGrammar {
    language = "kulala_http";
    version = "0.0.0+rev=${grammarSrc.shortRev}";
    src = grammarSrc;

    # kulala expects one exact grammar revision, so fail instead of drifting
    preBuild = ''
      if ! grep -qF '"${grammarSrc.rev}"' ${grammarVersionFile}; then
        echo "Update tree-sitter-kulala-http in flake.nix to the revision" \
          "in ${grammarVersionFile}" >&2
        exit 1
      fi
    '';
  };
in
{
  plugins.kulala = {
    enable = true;

    settings = {
      global_keymaps = true;

      # The parser comes from Nix, see above
      treesitter.enable = false;
    };
  };

  # Replace what kulala would set up with its own parser installation
  plugins.treesitter = {
    grammarPackages = [ grammar ];
    languageRegister.kulala_http = [
      "http"
      "rest"
    ];
  };
}
