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

-- Only keymaps that have no Neovim 0.11+ default equivalent.
-- See :help lsp-defaults for the full list of built-in LSP mappings:
--   K (hover), <C-]> (definition), grr (references), gri (implementation),
--   grt (type definition), grn (rename), gra (code action), gO (symbols),
--   <C-S> (signature help), ]d/[d (diagnostics), <C-W>d (diagnostic float),
--   gq (format via formatexpr)
local function lsp_keymaps(bufnr)
    local opts = { silent = true, buffer = bufnr }
    local function opt(desc, others)
        return vim.tbl_extend("force", opts, { desc = desc }, others or {})
    end
    local keymap = vim.keymap.set
    -- The default <C-]> goes through vim.lsp.tagfunc, which uses a synchronous
    -- request with a 1s timeout; slow servers (rust-analyzer) miss it and it
    -- falls back to tags files. The async call has no timeout and still pushes
    -- the tagstack, so <C-t> keeps working.
    keymap("n", "<C-]>", vim.lsp.buf.definition, opt("Goto definition"))
    keymap("n", "<C-w>]", function()
        local from = { vim.fn.bufnr(), vim.fn.line("."), vim.fn.col("."), 0 }
        local tagname = vim.fn.expand("<cword>")
        vim.lsp.buf.definition({
            on_list = function(t)
                local item = t.items[1]
                if not item then
                    return
                end
                vim.cmd("split " .. vim.fn.fnameescape(item.filename))
                vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                vim.fn.settagstack(0, { items = { { tagname = tagname, from = from } } }, "t")
            end,
        })
    end, opt("Goto definition in split"))
    keymap("n", "gD", vim.lsp.buf.declaration, opt("Goto declaration"))
    keymap("n", "<leader>li", "<cmd>LspInfo<cr>", opt("LSP Info"))
    keymap("n", "<leader>lq", vim.diagnostic.setloclist, opt("Quickfix"))
    keymap("n", "<leader>ll", vim.lsp.codelens.run, opt("CodeLens Action"))
end

M.on_attach = function(client, bufnr)
    lsp_keymaps(bufnr)
end

return M
