{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib.custom.nixvim) hasSnacksModule nCmdMap;

  hasSnacksPicker = hasSnacksModule config "picker";
in
{
  plugins.lsp = {
    enable = true;

    inlayHints = true;

    keymaps = {
      extra = [
        # Language servers mappings
        (nCmdMap {
          key = "<Leader>ll";
          cmd = "LspLog";
          desc = "LS logs";
        })
        (nCmdMap {
          key = "<Leader>lr";
          cmd = "LspRestart";
          desc = "LS restart";
        })
        (nCmdMap {
          key = "<Leader>lS";
          cmd = "LspStop";
          desc = "LS stop";
        })
      ]
      ++ lib.optionals hasSnacksPicker [
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
      ];

      lspBuf = {
        # Use signature mappings consistent with `K` for the `hover` action
        gK = {
          action = "signature_help";
          desc = "Signature help (LSP)";
        };
        "<C-k>" = {
          mode = "i";
          action = "signature_help";
          desc = "Signature help (LSP)";
        };

        gla = {
          action = "code_action";
          desc = "Actions";
        };
        glR = {
          action = "rename";
          desc = "Rename";
        };
      }
      // lib.optionalAttrs (!hasSnacksPicker) {
        gD = {
          action = "declaration";
          desc = "Goto declaration (LSP)";
        };
        gd = {
          action = "definition";
          desc = "Goto definition (LSP)";
        };
        gli = {
          action = "implementation";
          desc = "Goto implementation";
        };
        glr = {
          action = "references";
          desc = "References";
        };
        glS = {
          action = "workspace_symbol";
          desc = "Symbols (workspace)";
        };
        gls = {
          action = "document_symbol";
          desc = "Symbols (buffer)";
        };
        glt = {
          action = "type_definition";
          desc = "Goto type definition";
        };
      };

      silent = true;
    };

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
            filetypes = [ "htmldjango" ];
          };

          docker_language_server.extraOptions.init_options.telemetry = "off";

          # Nixvim has no default package for it
          expert.package = pkgs.beamPackages.expert;

          # Only prose, because typos checks the code
          harper_ls.filetypes = [
            "gitcommit"
            "markdown"
          ];

          html.filetypes = [
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
          nixd.settings.nixpkgs.expr = "import ${self.inputs.nixpkgs} { }";

          oxlint = { };

          ruff = {
            # Disable Ruff's hover in favor of ty
            onAttach.function =
              # Lua
              ''
                client.server_capabilities.hoverProvider = false
              '';
          };

          # They must match the Rust toolchain on PATH
          rust_analyzer = {
            installCargo = false;
            installRustc = false;
            package = null;
          };

          superhtml = {
            # Use only its diagnostics, because html covers the rest
            onAttach.function =
              # Lua
              ''
                client.server_capabilities = {
                  textDocumentSync = client.server_capabilities.textDocumentSync,
                }
              '';
          };

          tailwindcss.filetypes = [
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

          typos_lsp = {
            # Disable typos LSP in help pages, and in prose that harper_ls checks
            onAttach.function =
              # Lua
              ''
                -- Use schedule to make sure that a file type is already set
                vim.schedule(function()
                  local filetype = vim.bo[bufnr].filetype
                  if vim.list_contains({"gitcommit", "help", "markdown"}, filetype) then
                    vim.lsp.buf_detach_client(bufnr, client.id)
                    return
                  end
                end)
              '';
          };

          vtsls.settings.vtsls.autoUseWorkspaceTsdk = true;

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
      cmd = "check lspconfig";
      desc = "LS info";
    })
    (nCmdMap {
      key = "<Leader>ls";
      cmd = "LspStart";
      desc = "LS start";
    })
  ];
}
