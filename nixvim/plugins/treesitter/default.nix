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
}
