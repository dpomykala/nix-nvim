-- nixd completes the Nixvim options of this flake. Neovim starts nixd in the
-- project root, so `./.` is this repository.
vim.lsp.config("nixd", {
	settings = {
		nixd = {
			options = {
				nixvim = {
					expr = "(builtins.getFlake (toString ./.)).packages.${builtins.currentSystem}.default.options",
				},
			},
		},
	},
})
