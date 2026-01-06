-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    -- Core plugins
    { "nvim-lua/plenary.nvim" },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },

    -- Comments
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
        config = function()
            require("user.comment")
        end,
    },
    { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },

    -- Icons and UI
    { "kyazdani42/nvim-web-devicons",                lazy = true },
    {
        "kyazdani42/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
        },
        config = function()
            require("user.nvim-tree")
        end,
    },

    -- Bufferline
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("user.bufferline")
        end,
    },

    -- Bbye
    { "moll/vim-bbye",                   cmd = { "Bdelete", "Bwipeout" } },

    -- Lualine
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("user.lualine")
        end,
    },

    -- Terminal
    {
        "akinsho/toggleterm.nvim",
        cmd = { "ToggleTerm", "TermExec" },
        keys = {
            { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
        },
        config = function()
            require("user.toggleterm")
        end,
    },

    -- Project
    {
        "ahmedkhalf/project.nvim",
        event = "VeryLazy",
        config = function()
            require("user.project")
        end,
    },

    -- Impatient
    {
        "lewis6991/impatient.nvim",
        config = function()
            require("user.impatient")
        end,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        config = function()
            require("user.indentline")
        end,
    },

    -- Alpha (dashboard)
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        config = function()
            require("user.alpha")
        end,
    },

    -- Which-key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("user.whichkey")
        end,
    },

    -- Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("user.copilot")
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        tag = "v4.7.4",
        dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
        cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
        config = function()
            require("user.copilotchat")
        end,
    },

    -- Colorschemes
    { "SyedFasiuddin/theme-toggle-nvim", lazy = true },
    { "folke/tokyonight.nvim",           lazy = true },
    { "lunarvim/darkplus.nvim",          lazy = true },
    { "lifepillar/vim-solarized8",       lazy = true },
    { "catppuccin/vim",                  name = "catppuccin",            lazy = true },
    { "decaycs/decay.nvim",              name = "decay",                 lazy = true },
    { "navarasu/onedark.nvim",           name = "onedark",               lazy = true },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("user.cmp")
        end,
    },
    { "hrsh7th/cmp-buffer",       lazy = true },
    { "hrsh7th/cmp-path",         lazy = true },
    { "saadparwaiz1/cmp_luasnip", lazy = true },
    { "hrsh7th/cmp-nvim-lsp",     lazy = true },
    { "hrsh7th/cmp-nvim-lua",     lazy = true },

    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        lazy = true,
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("user.luasnip")
        end,
    },
    { "rafamadriz/friendly-snippets",   lazy = true },

    -- Neogen (annotations)
    {
        "danymat/neogen",
        cmd = "Neogen",
        config = function()
            require("user.neogen")
        end,
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "mason-org/mason.nvim",           tag = "v2.0.0" },
            { "mason-org/mason-lspconfig.nvim", tag = "v2.0.0" },
            { "nvimtools/none-ls.nvim" },
        },
        config = function()
            require("user.lsp")
        end,
    },
    {
        "mason-org/mason.nvim",
        tag = "v2.0.0",
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
    },
    { "mason-org/mason-lspconfig.nvim", tag = "v2.0.0", lazy = true },
    { "nvimtools/none-ls.nvim",         lazy = true },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        cmd = "Telescope",
        keys = {
            { "<leader>f",  desc = "Telescope" },
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("user.telescope")
        end,
    },

    -- Outline
    {
        "hedyhli/outline.nvim",
        cmd = { "Outline", "OutlineOpen" },
        keys = {
            { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Outline" },
        },
        config = function()
            require("user.outline")
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            require("user.treesitter")
        end,
    },

    -- FZF
    { "junegunn/fzf",     build = "./install --all",         version = "*" },
    { "junegunn/fzf.vim", dependencies = { "junegunn/fzf" }, version = "*" },

    -- Git
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("user.gitsigns")
        end,
    },
    { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" } },

    -- Avante.nvim - AI-powered code assistant
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        build = "make",
        opts = {
            provider = "copilot",
            auto_suggestions_provider = "copilot",
            providers = {
                copilot = {
                    model = "claude-opus-4.5",
                },
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true,
                    },
                },
            },
            {
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
}, {
    -- Lazy.nvim settings
    ui = {
        border = "rounded",
        icons = {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            require = "🌙",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 ",
        },
    },
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
