{ lib, ... }: {
  plugins.snacks.settings.lazygit.enabled = true;

  dependencies.lazygit.enable = true;

  keymaps =
    let
      inherit (lib.custom.nixvim) nCmdMap;
    in
    [
      # NOTE: Requires Lazygit with an initialized config file
      (nCmdMap {
        key = "<Leader>gg";
        cmd = "lua Snacks.lazygit.open()";
        desc = "Open Lazygit";
      })
    ];
}
