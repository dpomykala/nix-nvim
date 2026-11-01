{
  config,
  lib,
  ...
}:
{
  plugins.mini.modules.icons = {
    file = {
      ".keep" = {
        glyph = "󰊢";
        hl = "MiniIconsGrey";
      };
    };

    filetype = {
      "text.kulala_ui" = lib.mkIf config.plugins.kulala.enable { glyph = "🐼"; };
      "codecompanion" = lib.mkIf config.plugins.codecompanion.enable { glyph = " "; };
    };
  };
}
