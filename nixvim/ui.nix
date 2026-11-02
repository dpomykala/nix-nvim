/*
  Neovim's built-in UI for messages and the command line (ui2), which replaces
  noice.nvim. It turns off while noice.nvim is enabled, so importing
  `plugins/noice.nix` again restores noice.

  ui2 is still experimental, see `:help ui2`.
*/
{ config, lib, ... }:
let
  inherit (lib.custom.nixvim) nMap;
in
lib.mkIf (!config.plugins.noice.enable) {
  # Load it before the plugins, so that it also shows their startup messages
  extraConfigLuaPre = ''
    require('vim._core.ui2').enable({
      -- Show progress in a floating window above the statusline, and other
      -- messages in the command line
      msg = { targets = { default = 'cmd', progress = 'msg' } },
    })
  '';

  # Neovim tracks LSP progress but doesn't show it
  autoCmd = [
    {
      event = "LspProgress";
      callback.__raw = ''
        function(ev)
          local value = ev.data.params.value
          vim.api.nvim_echo({ { value.message or 'done' } }, false, {
            id = 'lsp.' .. ev.data.params.token,
            kind = 'progress',
            source = 'vim.lsp',
            title = value.title,
            status = value.kind ~= 'end' and 'running' or 'success',
            percent = value.percentage,
          })
        end
      '';
      desc = "Show LSP progress as progress messages";
    }
  ];

  # Hover docs have no border by default
  lsp.keymaps = [
    (nMap {
      key = "K";
      action.__raw = "function() vim.lsp.buf.hover({ border = 'rounded' }) end";
      desc = "Hover (LSP)";
    })
  ];
}
