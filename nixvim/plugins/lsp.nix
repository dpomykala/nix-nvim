{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib.custom.nixvim) hasSnacksModule nCmdMap;

  lspBufMap =
    {
      mode ? "n",
      key,
      action,
      desc,
    }:
    {
      inherit key mode;
      lspBufAction = action;
      options.desc = desc;
    };

  hasSnacksPicker = hasSnacksModule config "picker";
in
{
  plugins.lspconfig.enable = true;

  lsp = {
    inlayHints.enable = true;

    keymaps = [
      # Language servers mappings
      (nCmdMap {
        key = "<Leader>ll";
        cmd = "lua vim.cmd.tabnew(vim.lsp.log.get_filename())";
        desc = "LS logs";
      })
      (nCmdMap {
        key = "<Leader>lr";
        cmd = "lsp restart";
        desc = "LS restart";
      })
      (nCmdMap {
        key = "<Leader>lS";
        cmd = "lsp stop";
        desc = "LS stop";
      })

      # Use signature mappings consistent with `K` for the `hover` action
      (lspBufMap {
        key = "gK";
        action = "signature_help";
        desc = "Signature help (LSP)";
      })
      (lspBufMap {
        mode = "i";
        key = "<C-k>";
        action = "signature_help";
        desc = "Signature help (LSP)";
      })

      (lspBufMap {
        key = "gla";
        action = "code_action";
        desc = "Actions";
      })
      (lspBufMap {
        key = "glR";
        action = "rename";
        desc = "Rename";
      })
    ]
    ++ (
      if hasSnacksPicker then
        [
          (nCmdMap {
            key = "gD";
            cmd = "lua Snacks.picker.lsp_declarations()";
            desc = "Goto declaration (LSP)";
          })
          (nCmdMap {
            key = "gd";
            cmd = "lua Snacks.picker.lsp_definitions()";
            desc = "Goto definition (LSP)";
          })
          (nCmdMap {
            key = "gli";
            cmd = "lua Snacks.picker.lsp_implementations()";
            desc = "Goto implementation";
          })
          (nCmdMap {
            key = "glr";
            cmd = "lua Snacks.picker.lsp_references()";
            desc = "References";
          })
          (nCmdMap {
            key = "glS";
            cmd = "lua Snacks.picker.lsp_workspace_symbols()";
            desc = "Symbols (workspace)";
          })
          (nCmdMap {
            key = "gls";
            cmd = "lua Snacks.picker.lsp_symbols()";
            desc = "Symbols (buffer)";
          })
          (nCmdMap {
            key = "glt";
            cmd = "lua Snacks.picker.lsp_type_definitions()";
            desc = "Goto type definition";
          })
        ]
      else
        [
          (lspBufMap {
            key = "gD";
            action = "declaration";
            desc = "Goto declaration (LSP)";
          })
          (lspBufMap {
            key = "gd";
            action = "definition";
            desc = "Goto definition (LSP)";
          })
          (lspBufMap {
            key = "gli";
            action = "implementation";
            desc = "Goto implementation";
          })
          (lspBufMap {
            key = "glr";
            action = "references";
            desc = "References";
          })
          (lspBufMap {
            key = "glS";
            action = "workspace_symbol";
            desc = "Symbols (workspace)";
          })
          (lspBufMap {
            key = "gls";
            action = "document_symbol";
            desc = "Symbols (buffer)";
          })
          (lspBufMap {
            key = "glt";
            action = "type_definition";
            desc = "Goto type definition";
          })
        ]
    );

    # Prefer the servers on PATH, such as the ones from a dev shell, and use
    # the bundled ones only when they are missing
    servers =
      lib.mapAttrs
        (
          _: server:
          {
            enable = true;
            packageFallback = true;
          }
          // server
        )
        {
          bashls = { };

          cssls = { };

          djlsp = {
            # It isn't in nixpkgs, so it must be on PATH
            package = null;

            # Only Django templates, not plain HTML
            config.filetypes = [ "htmldjango" ];
          };

          docker_language_server.config.init_options.telemetry = "off";

          # Nixvim has no default package for it
          expert.package = pkgs.beamPackages.expert;

          # It runs golangci-lint from PATH
          golangci_lint_ls = { };

          # It must match the Go toolchain on PATH
          gopls.package = null;

          graphql = { };

          # Only prose, because typos checks the code
          harper_ls.config.filetypes = [
            "gitcommit"
            "markdown"
          ];

          html.config.filetypes = [
            "html"
            "htmldjango"
          ];

          jsonls = { };

          just = { };

          lua_ls = { };

          marksman = { };

          nginx_language_server = { };

          # The default, `<nixpkgs>`, depends on NIX_PATH, which isn't set
          # everywhere. A project can override it in `.nvim.lua`.
          nixd.config.settings.nixd.nixpkgs.expr = "import ${self.inputs.nixpkgs} { }";

          oxlint = { };

          # Disable Ruff's hover in favor of ty
          ruff.config.on_attach =
            lib.nixvim.mkRaw
              # Lua
              ''
                function(client)
                  client.server_capabilities.hoverProvider = false
                end
              '';

          # It must match the Rust toolchain on PATH
          rust_analyzer.package = null;

          # Use only its diagnostics, because html covers the rest
          superhtml.config.on_attach =
            lib.nixvim.mkRaw
              # Lua
              ''
                function(client)
                  client.server_capabilities = {
                    textDocumentSync = client.server_capabilities.textDocumentSync,
                  }
                end
              '';

          tailwindcss.config.filetypes = [
            "css"
            "elixir"
            "heex"
            "html"
            "htmldjango"
            "javascript"
            "javascriptreact"
            "scss"
            "typescript"
            "typescriptreact"
          ];

          tombi = { };

          ty = { };

          # Disable typos LSP in help pages, and in prose that harper_ls checks
          typos_lsp.config.on_attach =
            lib.nixvim.mkRaw
              # Lua
              ''
                function(client, bufnr)
                  -- Use schedule to make sure that a file type is already set
                  vim.schedule(function()
                    local filetype = vim.bo[bufnr].filetype
                    if vim.list_contains({"gitcommit", "help", "markdown"}, filetype) then
                      vim.lsp.buf_detach_client(bufnr, client.id)
                    end
                  end)
                end
              '';

          vtsls.config.settings.vtsls.autoUseWorkspaceTsdk = true;

          yamlls = { };

          # It must match the Zig release on PATH
          zls.package = null;
        };
  };

  # bashls runs shellcheck from PATH
  extraPackagesAfter = [ pkgs.shellcheck ];

  # Neovim has no Compose file type, which docker_language_server needs
  filetype.filename = lib.genAttrs [
    "compose.yaml"
    "compose.yml"
    "docker-compose.yaml"
    "docker-compose.yml"
  ] (_: "yaml.docker-compose");

  # Global mappings (available also if there is no LS attached)
  keymaps = [
    # Language servers mappings
    (nCmdMap {
      key = "<Leader>li";
      cmd = "checkhealth vim.lsp";
      desc = "LS info";
    })
    (nCmdMap {
      key = "<Leader>ls";
      cmd = "lsp enable";
      desc = "LS start";
    })
  ];
}
