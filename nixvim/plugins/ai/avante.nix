/*
  avante.nvim - designed to emulate the behaviour of the Cursor AI IDE.

  https://nix-community.github.io/nixvim/plugins/avante
  https://github.com/avante-corp/avante.nvim
*/
{
  config,
  lib,
  ...
}:
{
  plugins.avante = {
    enable = true;

    settings =
      let
        inherit (lib.custom.nixvim) hasSnacksModule;

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
      // lib.optionalAttrs hasSnacksPicker {
        file_selector.provider = "snacks";
      };
  };
}
