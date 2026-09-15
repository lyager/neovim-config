local status_ok, indent = pcall(require, "ibl")
if not status_ok then
    vim.notify("indent_blankline not found")
    return
end

local highlight = {
    "Grey",
}

local hooks = require("ibl.hooks")
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "Grey", { fg = "#4b5263" })
end)

indent.setup({
    enabled = true,
    scope = { enabled = false },
    indent = {
        char = "│",
        highlight = highlight,
    },
})
