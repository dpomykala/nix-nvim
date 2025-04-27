/*
avante.nvim - designed to emulate the behaviour of the Cursor AI IDE.

https://nix-community.github.io/nixvim/plugins/avante
https://github.com/yetone/avante.nvim
*/
{
  config,
  lib,
  ...
}: {
  plugins.avante = {
    enable = true;

    settings = let
      inherit (lib.custom.nixvim) hasSnacksModule;

      hasSnacksPicker = hasSnacksModule config "picker";
    in
      {
        auto_suggestions_provider = "openrouter_gpt41_mini";

        behaviour = {
          # auto_suggestions = true;
          enable_cursor_planning_mode = true;
        };

        cursor_applying_provider = "openrouter";

        hints.enabled = false;

        provider = "openrouter";

        vendors = {
          groq = {
            __inherit_from = "openai";
            api_key_name = "GROQ_API_KEY";
            endpoint = "https://api.groq.com/openai/v1/";
            max_tokens = 32768;
            model = "deepseek-r1-distill-qwen-32b";
            temperature = 0.6;
          };
          groq_llama33 = {
            __inherit_from = "groq";
            model = "llama-3.3-70b-versatile";
          };

          openrouter = {
            __inherit_from = "openai";
            api_key_name = "OPENROUTER_API_KEY";
            endpoint = "https://openrouter.ai/api/v1/";
            max_tokens = 32768;
            model = "openai/gpt-4.1";
          };
          openrouter_gpt41_mini = {
            __inherit_from = "openrouter";
            model = "openai/gpt-4.1-mini";
          };
        };
      }
      // lib.optionalAttrs hasSnacksPicker {
        file_selector.provider = "snacks";
      };
  };
}
