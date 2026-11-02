{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) genAttrs;
  inherit (lib.custom.nixvim) nCmdMap nxCmdMap;
in
lib.mkIf (config.languageTools != "none") {
  plugins.conform-nvim = {
    enable = true;

    settings = {
      default_format_opts = {
        # Try using LSP formatting if no other formatters are available
        lsp_format = "fallback";
      };

      format_on_save.__raw = ''
        function(bufnr)
          -- Disable automatic formatting with a global or buffer-local variable
          if vim.g.autoformat_disable or vim.b[bufnr].autoformat_disable then
            return
          end
          return {}
        end
      '';

      # NOTE: LSP formatting is used for some languages (e.g. Python)
      formatters_by_ft = {
        dockerfile = [ "dockerfmt" ];
        just = [ "just" ];
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
      }
      # File types formatted using oxfmt
      // genAttrs [
        "css"
        "graphql"
        "javascript"
        "javascriptreact"
        "json"
        "jsonc"
        "markdown"
        "scss"
        "toml"
        "typescript"
        "typescriptreact"
        "yaml"
      ] (_: [ "oxfmt" ])
      # File types formatted using shfmt
      // genAttrs [ "bash" "sh" ] (_: [ "shfmt" ]);

      # Without it, dockerfmt drops the final newline
      formatters.dockerfmt.prepend_args = [ "--newline" ];
    };
  };

  # Prefer the formatters on PATH, such as the ones from a dev shell, and use
  # the bundled ones only when they are missing
  extraPackagesAfter = lib.mkIf (config.languageTools == "bundled") (
    with pkgs;
    [
      dockerfmt
      just
      nixfmt
      oxfmt
      shfmt
      stylua
    ]
  );

  keymaps = [
    (nCmdMap {
      key = "<Leader>cF";
      cmd = "ConformInfo";
      desc = "Formatters info";
    })
    (nxCmdMap {
      key = "<Leader>cf";
      cmd = "lua require('conform').format()";
      desc = "Format file/range";
    })
    (nCmdMap {
      key = "\\F";
      cmd = "AutoformatToggle";
      desc = "Toggle formatting";
    })
    (nCmdMap {
      key = "\\f";
      cmd = "AutoformatBufferToggle";
      desc = "Toggle formatting (buffer)";
    })
  ];

  opts = {
    # Use conform.nvim for built-in formatting operations (e.g. with `gq`)
    formatexpr = "v:lua.require'conform'.formatexpr()";
  };

  userCommands = {
    AutoformatToggle = {
      command.__raw = ''
        function()
          vim.g.autoformat_disable = not vim.g.autoformat_disable
          local status = not vim.g.autoformat_disable and "enabled" or "disabled"
          print("Auto-formatting (global): " .. status)
        end
      '';
      desc = "Toggle automatic formatting (globally)";
    };

    AutoformatBufferToggle = {
      command.__raw = ''
        function()
          vim.b.autoformat_disable = not vim.b.autoformat_disable
          local status = not vim.b.autoformat_disable and "enabled" or "disabled"
          print("Auto-formatting (buffer): " .. status)
        end
      '';
      desc = "Toggle automatic formatting for the current buffer";
    };
  };
}
