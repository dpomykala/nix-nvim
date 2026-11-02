/*
  Neovim's built-in UI for messages and the command line (ui2), which replaces
  noice.nvim. It turns off while noice.nvim is enabled, so importing
  `plugins/noice.nix` again restores noice.

  ui2 is still experimental, see `:help ui2`.
*/
{ config, lib, ... }:
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
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local value = ev.data.params.value
          local title = value.title
          if client then
            title = ('%s: %s'):format(client.name, title)
          end
          vim.api.nvim_echo({ { value.message or 'done' } }, false, {
            -- Each server numbers its own tokens, so they can repeat
            id = ('lsp.%d.%s'):format(ev.data.client_id, ev.data.params.token),
            kind = 'progress',
            source = 'vim.lsp',
            title = title,
            status = value.kind ~= 'end' and 'running' or 'success',
            percent = value.percentage,
          })
        end
      '';
      desc = "Show LSP progress as progress messages";
    }
  ];
}
