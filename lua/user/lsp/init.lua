---@diagnostic disable: undefined-global
local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

vim.lsp.set_log_level("warn")
require("user.lsp.handlers").setup()
require("user.lsp.mason")
-- require("user.lsp.none-ls")
