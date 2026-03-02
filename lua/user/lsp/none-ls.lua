local none_ls_status_ok, none_ls = pcall(require, "none-ls")
if not none_ls_status_ok then
	return
end

local formatting = none_ls.builtins.formatting
local diagnostics = none_ls.builtins.diagnostics

local augroup = vim.api.nvim_create_augroup("NullLsFormatting", { clear = true })

none_ls.setup({
	debug = false,
	sources = {
		formatting.prettier,
		--diagnostics.eslint,
		-- formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.stylua,
		-- diagnostics.phpcs.with({ extra_args = { "--standard=PSR2" } }),
		-- diagnostics.flake8
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function(args)
					if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
						return
					end
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})
