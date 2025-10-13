---@diagnostic disable: undefined-global
local servers = {
    "lua_ls",
    -- "cssls",
    -- "html",
    -- "tsserver",
    "pyright",
    -- "bashls",
    "jsonls",
    -- "yamlls",
}

local settings = {
    ui = {
        border = "none",
        icons = {
            package_installed = "◍",
            package_pending = "◍",
            package_uninstalled = "◍",
        },
    },
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 4,
}

require("mason").setup(settings)
local status_malsp_ok, malsp = pcall(require, "mason-lspconfig")
if not status_malsp_ok then
    vim.notify("mason-lspconfig not found")
    return
end

malsp.setup({
    ensure_installed = servers,
    automatic_enable = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
    return
end

local opts = {}

function printTable(t, indent)
    indent = indent or ""

    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indent .. tostring(key) .. " = {")
            printTable(value, indent .. "    ")
            print(indent .. "}")
        else
            print(indent .. tostring(key) .. " = " .. tostring(value))
        end
    end
end

-- The interfaces to servers are controlled by nvim-lspconfig (path: .local/share/nvim/site/pack/packer/start/nvim-lspconfig)
for _, server in pairs(malsp.get_installed_servers()) do
    opts = {
        on_attach = require("user.lsp.handlers").on_attach,
        capabilities = require("user.lsp.handlers").capabilities,
    }

    -- server = vim.split(server, "@")[1]

    local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
    if require_ok then
        opts = vim.tbl_deep_extend("force", conf_opts, opts)
    end

    -- printTable(lspconfig)
    vim.lsp.config[server] = opts
end
