/*
  avante.nvim - designed to emulate the behaviour of the Cursor AI IDE.

  https://nix-community.github.io/nixvim/plugins/avante
  https://github.com/avante-corp/avante.nvim
*/
{
  config,
  lib,
  pkgs,
  ...
}:
{
  plugins.avante = {
    enable = true;

    # nixpkgs adds dressing.nvim, which is archived. Its `vim.ui.input` and
    # `vim.ui.select` replace the Snacks ones, and avante works without it.
    package = pkgs.vimPlugins.avante-nvim.overrideAttrs (old: {
      dependencies = lib.remove pkgs.vimPlugins.dressing-nvim old.dependencies;
    });

    settings =
      let
        inherit (lib.custom.nixvim) hasSnacksModule;

        hasSnacksInput = hasSnacksModule config "input";
        hasSnacksPicker = hasSnacksModule config "picker";

        openrouter_params = {
          __inherited_from = "openai";
          api_key_name = "OPENROUTER_API_KEY";
          endpoint = "https://openrouter.ai/api/v1/";
        };
      in
      {
        auto_suggestions_provider = "openrouter_gpt41_mini";

        behaviour = {
          # auto_suggestions = true;
        };

        provider = "openrouter";

        providers = {
          openrouter = openrouter_params // {
            extra_request_body = {
              max_tokens = 32768;
            };
            model = "openai/gpt-4.1";
          };
          openrouter_gpt41_mini = openrouter_params // {
            model = "openai/gpt-4.1-mini";
          };
        };
      }
      // lib.optionalAttrs hasSnacksInput {
        input.provider = "snacks";
      }
      // lib.optionalAttrs hasSnacksPicker {
        selector.provider = "snacks";
      };
  };
}
