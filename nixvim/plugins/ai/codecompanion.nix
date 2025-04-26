/*
CodeCompanion - AI-powered coding, seamlessly in Neovim.

https://nix-community.github.io/nixvim/plugins/codecompanion
https://github.com/olimorris/codecompanion.nvim
*/
{
  lib,
  pkgs,
  ...
}: {
  plugins.codecompanion = {
    enable = true;

    settings = {
      adapters = {
        groq.__raw = ''
          function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                -- TODO: Use 1Password CLI for API keys
                -- api_key = "cmd:op read op://Private/[...]/credential --no-newline",
                api_key = vim.env.GROQ_API_KEY,
                url = "https://api.groq.com/openai",
              },
              schema = {
                model = {
                  default = "deepseek-r1-distill-llama-70b",
                  -- default = "deepseek-r1-distill-qwen-32b",
                },
                temperature = {
                  default = 0.6,
                },
              },
            })
          end
        '';

        openrouter.__raw = ''
          function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                -- TODO: Use 1Password CLI for API keys
                api_key = vim.env.OPENROUTER_API_KEY,
                url = "https://openrouter.ai/api",
              },
              schema = {
                model = {
                  default = "openai/gpt-4.1",
                  -- default = "openai/gpt-4.1-mini",
                  -- default = "openai/gpt-4.1-nano",
                },
              },
            })
          end
        '';
      };

      display.chat.show_settings = true;

      strategies = {
        cmd.adapter = "openrouter";

        chat = {
          adapter = "openrouter";

          slash_commands.opts.provider = "snacks";
        };

        inline.adapter = "openrouter";
      };
    };
  };

  extraPackages = with pkgs; [curl];

  keymaps = let
    inherit (lib.custom.nixvim) nxCmdMap xCmdMap;
  in [
    (nxCmdMap {
      key = "<Leader>aa";
      cmd = "CodeCompanionActions";
      desc = "Action palette";
    })
    (nxCmdMap {
      key = "<Leader>ac";
      cmd = "CodeCompanionChat";
      desc = "Create chat";
    })
    (nxCmdMap {
      key = "<Leader>at";
      cmd = "CodeCompanionChat Toggle";
      desc = "Toggle chat";
    })
    (xCmdMap {
      key = "<Leader>ay";
      cmd = "CodeCompanionChat Add";
      desc = "Yank to chat";
    })
  ];
}
