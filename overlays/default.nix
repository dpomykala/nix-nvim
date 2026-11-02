{ inputs }: {
  neovim-nightly = final: prev: {
    neovim-unwrapped =
      inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;
  };
}
