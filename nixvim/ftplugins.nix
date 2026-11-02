# Custom ftplugins with configuration for specific file types.
_: {
  files = {
    # NOTE: The default ftplugin for gitcommit already sets `textwidth=72`
    "after/ftplugin/gitcommit.lua" = {
      localOpts = {
        colorcolumn = "51,73";
        spell = true;
      };
    };

    "after/ftplugin/just.lua" = {
      localOpts = {
        tabstop = 4;
      };
    };

    "after/ftplugin/make.lua" = {
      localOpts = {
        # NOTE: `noexpandtab` is already set in the default ftplugin for make
        tabstop = 4;
      };
    };
  };
}
