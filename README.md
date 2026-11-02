# nix-nvim

My Neovim configuration, built with [NixVim](https://github.com/nix-community/nixvim)
as a Nix flake. One command gives you the whole editor: Neovim nightly, the
plugins, the Treesitter grammars, the language servers, and the formatters.

```sh
nix run github:dpomykala/nix-nvim
```

It's also part of my main Nix configuration,
[nix-config](https://github.com/dpomykala/nix-config).

## ✨ Features

- **Reproducible.** `flake.lock` pins Neovim, every plugin, and every tool,
  so the editor is the same on every machine. Nix builds all of them up front,
  and no plugin downloads or compiles anything when Neovim starts.
- **Standalone.** One package with the configuration built in. It needs no
  NixOS, nix-darwin, or Home Manager module.
- **Built-in first.** Neovim's own features where they are enough, then the
  mini.nvim and snacks.nvim plugin packs, then a few other plugins.
- **Language support out of the box.** 27 language servers and a formatter
  for each common file type, with format on save. See
  [Supported languages](#-supported-languages).
- **Your project's tools first.** The bundled language servers and formatters
  sit at the end of `PATH`. A dev shell or a system install of the same tool
  wins.
- **Three variants.** Bundle the language tools, use only the ones on `PATH`,
  or skip them completely.
- **Clean UI.** Neovim's built-in `ui2` for messages and the command line,
  the Catppuccin Macchiato theme, and a global status line.
- **Discoverable keymaps.** `mini.clue` shows the next keys after a pause, so
  you don't have to remember every mapping.
- **Two platforms.** Runs on `aarch64-darwin` and `x86_64-linux`.

## 🚀 Quickstart

You need [Nix](https://nixos.org/download/) with flakes enabled.

Run the editor without installing it:

```sh
nix run github:dpomykala/nix-nvim
```

Pick a variant by its package name:

```sh
nix run github:dpomykala/nix-nvim#external # only the tools on PATH
nix run github:dpomykala/nix-nvim#minimal  # no language servers or formatters
```

To install it, add the flake as an input:

```nix
inputs.nix-nvim.url = "github:dpomykala/nix-nvim";
```

Then add the package in a module that has access to `inputs` and `pkgs`. For
NixOS or nix-darwin:

```nix
environment.systemPackages = [
  inputs.nix-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

For Home Manager:

```nix
home.packages = [
  inputs.nix-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

To work on the configuration, clone the repository and use the
[just](https://just.systems) recipes:

```sh
git clone https://github.com/dpomykala/nix-nvim.git
cd nix-nvim
nix develop  # a shell with just, nixfmt, statix, and the other dev tools
just run     # build and start the editor from your working tree
```

## 🧠 Concepts

### Built-in features first, then plugin packs

Each feature comes from the first of these sources that does the job well:

1. **Built-in Neovim features.** The LSP client with `vim.lsp.config`,
   Treesitter node selection with `vim.treesitter.select`, the `ui2` messages
   and command line, and the diagnostic signs. Neovim nightly has the newest of
   them. For example, `ui2` replaced noice.nvim.
2. **The mini.nvim and snacks.nvim plugin packs.** Each pack is a set of small
   modules from one maintainer, so the modules work well together, rarely
   conflict, and get updates together. They cover the file explorers, pickers,
   textobjects, surround, the status line, the dashboard, and more.
3. **A short list of other well-maintained plugins.** They fill the gaps, such
   as completion with blink.cmp, formatting with conform.nvim, and Git hunks
   with gitsigns.nvim.

### A standalone package

The flake output is a complete Neovim package with the configuration built in.
It needs no NixOS, nix-darwin, or Home Manager module. Run it with `nix run`,
or install it like any other package.

The package ignores `~/.config/nvim`, so you can try it next to your current
Neovim config. It still shares `~/.local/share/nvim` and `~/.local/state/nvim`
with it, for example the undo history and the sessions.

### One Nix module per plugin

The flake builds the editor with `makeNixvimWithModule` from the module in
`nixvim/default.nix`. That module imports the rest of the configuration:

```text
nixvim/
├── default.nix       # entry point and the `languageTools` option
├── options.nix       # Vim options
├── keymaps.nix       # general keymaps
├── ui.nix            # ui2 messages and command line
├── dependencies.nix  # tools that several plugins share (git, ripgrep, fd)
└── plugins/          # one file, or one directory, per plugin
    ├── mini/         # one file per mini.nvim module
    ├── snacks/       # one file per snacks.nvim module
    └── treesitter/
```

Each plugin file holds the plugin settings, its keymaps, and the extra
packages it needs. To remove a plugin, delete its line from the `imports` list
in the `default.nix` next to it.

### Language tools and the three variants

The `languageTools` option in `nixvim/default.nix` decides where the language
servers and formatters come from. Each flake package sets it to one value:

| Package    | `languageTools` | Language servers and formatters                |
| ---------- | --------------- | ---------------------------------------------- |
| `default`  | `"bundled"`     | From `PATH`, with bundled copies as a fallback |
| `external` | `"external"`    | Only from `PATH`                               |
| `minimal`  | `"none"`        | Not set up                                     |

In the `default` package, the bundled tools go at the end of `PATH`. If a
project's dev shell has its own `ruff` or `nixfmt`, Neovim uses that version.
A few servers always come from `PATH`.
[Supported languages](#-supported-languages) marks them.

### Plugins that adapt to each other

`lib/nixvim.nix` adds helpers under `lib.custom.nixvim`:

- Keymap builders such as `nMap`, `nCmdMap`, and `nxCmdMap`, which turn
  `{ key, cmd, desc }` into a NixVim keymap.
- `hasSnacksModule` and `hasMiniModule`, which check if a module is enabled.

The second pair lets plugins integrate only when the other side exists. For
example, the LSP "go to definition" keymaps open a Snacks picker when
`snacks.picker` is enabled and call `vim.lsp.buf` otherwise.

### Per-project settings

The `exrc` option is on, so Neovim loads `.nvim.lua` from the current
directory after you trust it. This repository uses its own `.nvim.lua` to
give `nixd` completion for the NixVim options.

## 🌐 Supported languages

| Language               | Language servers                   | Formatter                |
| ---------------------- | ---------------------------------- | ------------------------ |
| Bash, sh               | `bashls` with `shellcheck`         | `shfmt`                  |
| CSS, SCSS              | `cssls`, `tailwindcss`             | `oxfmt`                  |
| Django templates       | `djlsp`\*, `html`, `tailwindcss`   |                          |
| Docker, Compose        | `docker_language_server`           | `dockerfmt` (Dockerfile) |
| Elixir, HEEx           | `expert`, `tailwindcss`            |                          |
| Git commits            | `harper_ls`                        |                          |
| Go                     | `gopls`\*, `golangci_lint_ls`      |                          |
| GraphQL                | `graphql`                          | `oxfmt`                  |
| HTML                   | `html`, `superhtml`, `tailwindcss` |                          |
| JavaScript, TypeScript | `vtsls`, `oxlint`, `tailwindcss`   | `oxfmt`                  |
| JSON                   | `jsonls`                           | `oxfmt`                  |
| just                   | `just`                             | `just`                   |
| Lua                    | `lua_ls`                           | `stylua`                 |
| Markdown               | `marksman`, `harper_ls`            | `oxfmt`                  |
| Nginx                  | `nginx_language_server`            |                          |
| Nix                    | `nixd`                             | `nixfmt`                 |
| Python                 | `ruff`, `ty`                       |                          |
| Rust                   | `rust_analyzer`\*                  |                          |
| TOML                   | `tombi`                            | `oxfmt`                  |
| YAML                   | `yamlls`                           | `oxfmt`                  |
| Zig                    | `zls`\*                            |                          |

\* The server always comes from `PATH`. `gopls`, `rust_analyzer`, and `zls`
must match the project's toolchain, and `djlsp` isn't in nixpkgs.

Where the table lists no formatter, conform.nvim uses the formatting of the
language server, for example Ruff for Python. `golangci_lint_ls` needs
`golangci-lint` on `PATH`. `typos_lsp` checks the spelling in code in every
file type except Git commits, help pages, and Markdown.

## 🧩 Plugins

| Area       | Plugin                                                                                        | What it does here                                          |
| ---------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| Pack       | [mini.nvim](https://github.com/nvim-mini/mini.nvim)                                           | Files, textobjects, surround, clues, status line, and more |
| Pack       | [snacks.nvim](https://github.com/folke/snacks.nvim)                                           | Pickers, explorer, dashboard, lazygit, notifications       |
| Completion | [blink.cmp](https://github.com/Saghen/blink.cmp)                                              | Completion menu with docs, ghost text, and snippets        |
| Completion | [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)                          | Snippet collection for blink.cmp                           |
| LSP        | [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                                    | Server configs for 27 language servers                     |
| Formatting | [conform.nvim](https://github.com/stevearc/conform.nvim)                                      | Format on save, with toggles per buffer and globally       |
| Syntax     | [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                         | Highlighting, indentation, folding, and node selection     |
| Syntax     | [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)         | Shows the enclosing function or class at the top           |
| Syntax     | [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Treesitter captures for the mini.ai textobjects            |
| Navigation | [flash.nvim](https://github.com/folke/flash.nvim)                                             | Jump anywhere with `s`, Treesitter jumps with `S`          |
| Search     | [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim)                                   | Find and replace across files with ripgrep or ast-grep     |
| Search     | [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)                             | Highlights and finds `TODO` and `NOTE` comments            |
| Git        | [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                                   | Hunk signs, navigation, staging, and blame                 |
| Editing    | [quicker.nvim](https://github.com/stevearc/quicker.nvim)                                      | Editable quickfix list with expandable context             |
| Editing    | [persistence.nvim](https://github.com/folke/persistence.nvim)                                 | Saves and restores sessions per directory                  |
| Tools      | [kulala.nvim](https://github.com/dont-be-evil-company/kulala.nvim)                            | REST client for `.http` files                              |
| Tools      | [gx.nvim](https://github.com/chrishrb/gx.nvim)                                                | Opens links, issues, and plugin names in the browser       |
| Tools      | [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)          | Renders Markdown in the buffer                             |
| AI         | [avante.nvim](https://github.com/avante-corp/avante.nvim)                                     | AI chat and code edits through OpenRouter                  |
| Theme      | [catppuccin](https://github.com/catppuccin/nvim)                                              | Macchiato flavor, with plugin integrations                 |

`nixvim/plugins/noice.nix` still holds a noice.nvim config. Neovim's `ui2`
replaces it, and `nixvim/plugins/default.nix` explains how to restore it.

avante.nvim reads the API key from the `OPENROUTER_API_KEY` environment
variable.

## ⌨️ Keymaps

The leader key is <kbd>Space</kbd> and the local leader is <kbd>,</kbd>.
Press the leader and wait to see the groups:

| Prefix      | Group  | Prefix      | Group         |
| ----------- | ------ | ----------- | ------------- |
| `<Leader>a` | AI     | `<Leader>m` | Minimap       |
| `<Leader>b` | Buffer | `<Leader>R` | REST (kulala) |
| `<Leader>c` | Code   | `<Leader>r` | Replace       |
| `<Leader>e` | Edit   | `<Leader>s` | Session       |
| `<Leader>f` | Find   | `gh`        | Git hunks     |
| `<Leader>g` | Git    | `gl`        | LSP           |
| `<Leader>l` | LSP    | `gs`        | Surround      |

A few general keymaps differ from stock Neovim:

- `;` and `:` are swapped, so `;` opens the command line.
- `H` and `L` move to the start and the end of the line.
- `s` starts a flash.nvim jump, so mini.surround uses the `gs` prefix.
- `<CR>` in a buffer with a Treesitter parser selects the node at the cursor
  and then its parents. `<BS>` in Visual mode goes back down.
- `\` starts the toggles, for example `\f` toggles format on save for the
  buffer.

## 🛠️ Development

The dev shell from `nix develop` has every tool that the recipes need. Run
`just` to list them all:

| Recipe                 | What it does                                              |
| ---------------------- | --------------------------------------------------------- |
| `just run [variant]`   | Build and start a variant (`default` if not given)        |
| `just build [variant]` | Build a variant into `./result`                           |
| `just update [inputs]` | Update the lock file and commit it                        |
| `just iupdate`         | Pick the inputs to update with fzf                        |
| `just fmt`             | Format the Nix, Markdown, and justfile sources            |
| `just check`           | Check formatting, lint with statix, run `nix flake check` |
| `just print-init`      | Print the generated `init.lua`                            |

## 📄 License

[MIT](LICENSE)
