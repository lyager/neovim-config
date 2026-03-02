---@diagnostic disable: undefined-global
local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
	return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

M.setup = function()
	local config = {
		-- virtual_text = false, -- disable virtual text
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "",
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.HINT] = "",
				[vim.diagnostic.severity.INFO] = "",
			},
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)
end

local function lsp_keymaps(bufnr)
	-- local opts = { noremap = true, silent = true, buffer = bufnr }
	local opts = { silent = true }
	local function opt(desc, others)
		return vim.tbl_extend("force", opts, { desc = desc }, others or {})
	end
	local keymap = vim.keymap.set
	keymap("n", "gD", vim.lsp.buf.declaration, opt("Goto declaration"))
	-- keymap("n", "gd", function() vim.lsp.buf.definition() end, opt("Goto definition"))
	keymap("n", "gd", vim.lsp.buf.definition, opt("Goto definition"))
	keymap("n", "K", vim.lsp.buf.hover, opts)
	keymap("n", "gI", vim.lsp.buf.implementation, opts)
	-- keymap("n", "gr", vim.lsp.buf.references, opt("Goto references"))
	keymap("n", "gl", vim.diagnostic.open_float, opts)
	keymap("n", "<leader>lf", function()
		vim.lsp.buf.format({ async = true })
	end, opts)
	keymap("n", "<leader>li", "<cmd>LspInfo<cr>", opts)
	keymap("n", "<leader>lI", "<cmd>LspInstallInfo<cr>", opts)
	keymap("n", "<leader>la", vim.lsp.buf.code_action, opts)
	keymap("n", "<leader>lj", function()
		vim.diagnostic.jump({ count = 1, buffer = 0 })
	end, opts)
	keymap("n", "<leader>lk", function()
		vim.diagnostic.jump({ count = -1, buffer = 0 })
	end, opts)
	keymap("n", "<leader>lr", vim.lsp.buf.rename, opts)
	keymap("n", "<leader>ls", vim.lsp.buf.signature_help, opts)
	keymap("n", "<leader>lq", vim.diagnostic.setloclist, opts)
end

M.on_attach = function(client, bufnr)
	lsp_keymaps(bufnr)
end

return M
