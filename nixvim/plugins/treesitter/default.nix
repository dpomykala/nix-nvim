{ config, ... }: {
  imports = [
    ./context.nix
    ./textobjects.nix
  ];

  plugins.treesitter = {
    enable = true;

    highlight.enable = true;
    indent.enable = true;
    folding.enable = true;

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
    Incremental selection: <CR> selects the node at the cursor and then its
    parents, and <BS> goes back down. Neovim maps the same to `an` and `in` in
    Visual mode, but mini.ai takes those keys for its "around/inside next"
    textobjects. Only buffers with a parser get the mappings, so <CR> keeps
    its default action elsewhere, for example in the quickfix list.
  */
  autoCmd = [
    {
      event = "FileType";
      callback.__raw = ''
        function(args)
          if not vim.treesitter.get_parser(args.buf, nil, { error = false }) then
            return
          end

          local function map(mode, key, target, desc)
            vim.keymap.set(mode, key, function()
              vim.treesitter.select(target, vim.v.count1)
            end, { buffer = args.buf, desc = desc })
          end

          map({ 'n', 'x' }, '<CR>', 'parent', 'Select parent node')
          map('x', '<BS>', 'child', 'Select child node')
        end
      '';
      desc = "Map Treesitter incremental selection";
    }
  ];
}
