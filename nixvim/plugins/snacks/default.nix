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
      # Shows `vim.notify` messages as toasts
      notifier.enabled = true;
      statuscolumn.enabled = true;
    };
  };
}
