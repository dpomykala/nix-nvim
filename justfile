# just: https://just.systems

# List all recipes
_default:
    @just --list --unsorted --justfile {{ justfile() }}

[no-exit-message]
_requires bin:
    @command -v {{ bin }} >/dev/null 2>&1 || { echo '{{ style("error") }}This recipe requires {{ bin }}{{ NORMAL }}'; exit 1; }

# Build Neovim (NixVim), optionally a variant (default, external, minimal)
[group("Neovim")]
build variant="default":
    nix build .#{{ variant }}

# Build and run Neovim (NixVim), optionally a variant
[group("Neovim")]
run variant="default":
    nix run .#{{ variant }}

# List all flake inputs
[group("Inputs")]
inputs: (_requires "jq")
    @nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]'

# Update the lock file and commit (optionally provide input(s))
[group("Inputs")]
update *inputs:
    nix flake update --commit-lock-file {{ inputs }}

# Update the lock file and commit (select input(s) interactively)
[group("Inputs")]
[script]
iupdate: (_requires "fzf") (_requires "jq")
    selected_inputs="$(just inputs | fzf -m --height ~20 | tr '\n' ' ')"
    if [ -z "$selected_inputs" ]; then
        echo "No input selected"
    else
        echo "Updating inputs: $selected_inputs"
        nix flake update --commit-lock-file $selected_inputs
    fi

# Open a development shell
[group("Helpers")]
dev:
    nix develop

# Format all files
[group("Helpers")]
fmt: (_requires "oxfmt")
    just --fmt
    nix fmt .
    oxfmt

# Lint Nix files
[group("Helpers")]
lint: (_requires "statix")
    statix check

# Evaluate the flake outputs for all systems
[group("Helpers")]
check:
    nix flake check --all-systems

# Print the generated init.lua, optionally of a variant
[group("Debug")]
print-init variant="default":
    nix shell .#{{ variant }} --command nixvim-print-init
