_: {
  imports = [
    ./bufdelete.nix
    ./dashboard.nix
    ./explorer.nix
    ./git.nix
    ./gitbrowse.nix
    ./lazygit.nix
    ./picker.nix
    ./rename.nix
    ./scratch.nix
  ];

  plugins.snacks = {
    enable = true;

    settings = {
      input.enabled = true;
      # NOTE: Used by noice.nvim
      notifier.enabled = true;
      statuscolumn.enabled = true;
    };
  };
}
