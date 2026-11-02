/*
  External tools and runtimes that Neovim itself or several plugins depend on.
  A tool that only one plugin uses goes in the file of that plugin, for example
  lazygit in `plugins/snacks/lazygit.nix`. Language servers and formatters go
  in `plugins/lsp.nix` and `plugins/conform.nix`.

  Every tool is a fallback at the end of PATH, so the version on the host or in
  a dev shell wins. This file makes every `dependencies.<name>` a fallback, so
  enabling one is enough. Use `extraPackagesAfter` for a tool that Nixvim has
  no dependency option for.

  On macOS, the Python and Ruby of nixpkgs pull a whole compiler toolchain into
  the closure, so the settings here avoid them.
*/
{
  lib,
  options,
  pkgs,
  ...
}:
{
  dependencies = lib.mkMerge [
    # Also covers the dependencies that Nixvim plugin modules enable
    (lib.genAttrs (lib.attrNames options.dependencies) (_: {
      packageFallback = true;
    }))

    {
      # avante sends its LLM requests with curl, and so does codecompanion
      curl.enable = true;

      # Snacks pickers for files, projects, and explorer search, and avante.
      # The projects picker and the explorer search have no ripgrep fallback.
      fd.enable = true;

      # gitsigns, Snacks (git pickers, blame, gitbrowse), lazygit, and avante.
      # The minimal package leaves out the extras that need Python.
      git = {
        enable = true;
        package = pkgs.gitMinimal;
      };

      # Snacks grep pickers, grug-far, todo-comments, and avante
      ripgrep.enable = true;
    }
  ];

  # The clipboard provider on Wayland, for the `+` register and copying links.
  # `clipboard.providers` would add it to the start of PATH, not as a fallback.
  extraPackagesAfter = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.wl-clipboard;

  # No plugin uses the Python and Ruby providers
  withPython3 = false;
  withRuby = false;
}
