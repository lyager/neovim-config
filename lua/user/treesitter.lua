local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
	return
end

treesitter.setup({})

-- Async, skips parsers that are already installed
treesitter.install({ "lua", "markdown", "markdown_inline", "bash", "python" })

-- The main branch has no highlight/indent modules; enable per buffer instead.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
	callback = function(args)
		-- Fails silently for filetypes without an installed parser
		if not pcall(vim.treesitter.start, args.buf) then
			return
		end
		if vim.bo[args.buf].filetype ~= "python" then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
