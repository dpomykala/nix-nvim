# just: https://just.systems

set unstable

# List all recipes
default:
    @just --list --justfile {{ justfile() }}

[no-exit-message]
_requires bin:
    @command -v {{ bin }} >/dev/null 2>&1 || { echo '{{ style("error") }}This recipe requires {{ bin }}{{ NORMAL }}'; exit 1; }

# Build Neovim (NixVim), optionally a variant (default, external, minimal)
build variant="default":
    nix build .#{{ variant }}

# Build and run Neovim (NixVim), optionally a variant
run variant="default":
    nix run .#{{ variant }}

# Print the generated init.lua, optionally of a variant
print-init variant="default":
    nix shell .#{{ variant }} --command nixvim-print-init

# Evaluate the flake outputs for all systems
check:
    nix flake check --all-systems

# List all flake inputs
inputs: (_requires "jq")
    @nix flake metadata --json | jq '.locks.nodes.root.inputs | keys[]' | tr -d '"'

# Update the lock file and commit (optionally provide input(s))
update *inputs:
    nix flake update --commit-lock-file {{ inputs }}

# Update the lock file and commit (select input(s) interactively)
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
dev:
    nix develop

# Format all files
fmt: (_requires "oxfmt")
    just --unstable --fmt
    nix fmt .
    oxfmt

# Lint Nix files
lint: (_requires "statix")
    statix check
