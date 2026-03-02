vim.cmd([[
  augroup _general_settings
    autocmd!
    autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR>
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
    autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200})
    autocmd BufWinEnter * :set formatoptions-=cro
    autocmd FileType qf set nobuflisted
  augroup end

  augroup _git
    autocmd!
    autocmd FileType gitcommit setlocal wrap
    autocmd FileType gitcommit setlocal spell
  augroup end

  augroup _markdown
    autocmd!
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal spell
  augroup end

  augroup _auto_resize
    autocmd!
    autocmd VimResized * tabdo wincmd =
  augroup end

  augroup _alpha
    autocmd!
    autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
  augroup end

]])

-- Autoformat on write (with toggle support)
-- Use :FormatDisable to disable, :FormatEnable to re-enable, :FormatToggle to toggle
-- Use :FormatDisable! to disable only for the current buffer
local lsp_format_augroup = vim.api.nvim_create_augroup("LspFormat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = lsp_format_augroup,
	callback = function(args)
		if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
			return
		end
		vim.lsp.buf.format({ bufnr = args.buf })
	end,
})

vim.api.nvim_create_user_command("FormatDisable", function(opts)
	if opts.bang then
		-- :FormatDisable! disables for current buffer only
		vim.b.disable_autoformat = true
		vim.notify("Autoformat disabled for this buffer", vim.log.levels.INFO)
	else
		vim.g.disable_autoformat = true
		vim.notify("Autoformat disabled globally", vim.log.levels.INFO)
	end
end, { desc = "Disable autoformat-on-save", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
	vim.notify("Autoformat enabled", vim.log.levels.INFO)
end, { desc = "Enable autoformat-on-save" })

vim.api.nvim_create_user_command("FormatToggle", function(opts)
	if opts.bang then
		vim.b.disable_autoformat = not vim.b.disable_autoformat
		vim.notify(
			"Autoformat " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for this buffer",
			vim.log.levels.INFO
		)
	else
		vim.g.disable_autoformat = not vim.g.disable_autoformat
		vim.notify(
			"Autoformat " .. (vim.g.disable_autoformat and "disabled" or "enabled") .. " globally",
			vim.log.levels.INFO
		)
	end
end, { desc = "Toggle autoformat-on-save", bang = true })
