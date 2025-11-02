{inputs}: {
  # The latest version of blink.cmp from the main branch
  blink-cmp-main = final: prev: {
    vimPlugins =
      prev.vimPlugins
      // {
        inherit (inputs.blink-cmp.packages.${prev.system}) blink-cmp;
      };
  };

  # The latest version of snacks.nvim from the main branch
  snacks-nvim-main = final: prev: {
    vimPlugins =
      prev.vimPlugins
      // {
        snacks-nvim = prev.vimUtils.buildVimPlugin {
          pname = "snacks.nvim";
          src = inputs.snacks-nvim;
          version = inputs.snacks-nvim.shortRev;

          # Skip the "require" check for these Lua modueles
          nvimSkipModule = [
            "snacks.dashboard"
            "snacks.dim"
            "snacks.explorer.init"
            "snacks.gh.actions"
            "snacks.gh.buf"
            "snacks.gh.init"
            "snacks.gh.render.init"
            "snacks.git"
            "snacks.image.convert"
            "snacks.image.image"
            "snacks.image.init"
            "snacks.image.placement"
            "snacks.indent"
            "snacks.input"
            "snacks.lazygit"
            "snacks.notifier"
            "snacks.picker.config.highlights"
            "snacks.picker.core.list"
            "snacks.picker.source.gh"
            "snacks.picker.util.db"
            "snacks.scratch"
            "snacks.scroll"
            "snacks.terminal"
            "snacks.win"
            "snacks.words"
            "snacks.zen"
            "trouble.sources.profiler"
          ];
        };
      };
  };

  neovim-nightly = final: prev: {
    neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
  };
}
