_: {
  plugins.mini = {
    modules.basics = {
      # Manage options manually
      options.basic = false;

      /*
        Set additional mappings for handling windows:
        - <C-jhkl> for window navigation
        - <C-arrow> for window resizing
      */
      mappings.windows = true;
    };

    # Drop the gO/go empty line mappings in favor of the built-in [<Space> and
    # ]<Space>. mini.basics overwrote the built-in LSP gO, so map it again.
    luaConfig.post =
      # Lua
      ''
        vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol, { desc = "vim.lsp.buf.document_symbol()" })
        vim.keymap.del("n", "go")
      '';
  };
}
