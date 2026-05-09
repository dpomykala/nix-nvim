{config, ...}: {
  imports = [
    ./context.nix
    ./textobjects.nix
  ];

  plugins.treesitter = {
    enable = true;

    settings = {
      highlight.enable = true;

      incremental_selection = {
        enable = true;
        keymaps = {
          init_selection = "<CR>";
          node_decremental = "<BS>";
          node_incremental = "<CR>";
          scope_incremental = false;
        };
      };

      indent.enable = true;
    };

    grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
      bash
      css
      csv
      dockerfile
      editorconfig
      gitignore
      html
      htmldjango
      http
      javascript
      json
      just
      lua
      make
      markdown
      markdown_inline
      nginx
      nix
      python
      regex
      sql
      toml
      typescript
      vim
      xml
      yaml
    ];
  };

  /*
  Configure folding manually as the `plugins.treesitter.folding` option
  sets `foldexpr` to `nvim_treesitter#foldexpr()` which does not work
  */
  opts = {
    # Use Treesitter based folding
    foldexpr = "v:lua.vim.treesitter.foldexpr()";
    # Use `foldexpr` for calculating fold levels
    foldmethod = "expr";
  };
}
