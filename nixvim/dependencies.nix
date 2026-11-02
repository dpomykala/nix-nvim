/*
  External tools and runtimes that Neovim itself or several plugins depend on.
  A tool that only one plugin uses goes in the file of that plugin, for example
  lazygit in `plugins/snacks/lazygit.nix`. Language servers and formatters go
  in `plugins/lsp.nix` and `plugins/conform.nix`.

  On macOS, the Python and Ruby of nixpkgs pull a whole compiler toolchain into
  the closure, so the settings here avoid them.
*/
{ pkgs, ... }:
{
  # gitsigns, Snacks, and kulala use Git. The minimal package leaves out the
  # extras that need Python.
  dependencies.git.package = pkgs.gitMinimal;

  # No plugin uses the Python and Ruby providers
  withPython3 = false;
  withRuby = false;
}
