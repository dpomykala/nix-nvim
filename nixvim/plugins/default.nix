_: {
  imports = [
    ./ai
    ./blink.nix
    ./conform.nix
    ./flash.nix
    ./gitsigns.nix
    ./grug-far.nix
    ./gx.nix
    ./kulala.nix
    ./lsp.nix
    ./mini
    # Replaced by ui2, see `../ui.nix`. Uncomment to restore noice.nvim.
    # ./noice.nix
    ./persistence.nix
    ./quicker.nix
    ./render-markdown.nix
    ./snacks
    ./todo-comments.nix
    ./treesitter
  ];

  plugins = {
    friendly-snippets.enable = true;
  };
}
