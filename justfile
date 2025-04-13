# just: https://just.systems

# List all recipes
default:
    @just --list --justfile {{ justfile() }}

# Build Neovim (NixVim)
build:
    nix build .

# Build and run Neovim (NixVim)
run:
    nix run .

# Update the lock file and commit (optionally provide specific input(s))
update *INPUTS:
    nix flake update --commit-lock-file {{ INPUTS }}

# Open a development shell
dev:
    nix develop

# Format all files
fmt:
    just --unstable --fmt
    nix fmt .
