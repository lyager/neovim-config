local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
    print("Installing packer close and reopen Neovim...")
    vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
})

-- Install your plugins here
return packer.startup(function(use)
    use({ "wbthomason/packer.nvim" }) -- Have packer manage itself
    use({ "nvim-lua/plenary.nvim" })  -- Useful lua functions used by lots of plugins
    use({ "windwp/nvim-autopairs" })  -- Autopairs, integrates with both cmp and treesitter
    -- use({ "numToStr/Comment.nvim" })
    use({ "JoosepAlviste/nvim-ts-context-commentstring" })
    use({ "kyazdani42/nvim-web-devicons" })
    use({ "kyazdani42/nvim-tree.lua" })
    use({ "akinsho/bufferline.nvim", tag = "*" })
    use({ "moll/vim-bbye" })
    use({ "nvim-lualine/lualine.nvim" })
    use({ "akinsho/toggleterm.nvim" })
    use({ "ahmedkhalf/project.nvim" })
    use({ "lewis6991/impatient.nvim" })
    use({ "lukas-reineke/indent-blankline.nvim" })
    use({ "goolord/alpha-nvim" })
    use({ "folke/which-key.nvim" })

    -- Copilot
    use({ "zbirenbaum/copilot.lua" })
    use({
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end,
    })
    use({
        "CopilotC-Nvim/CopilotChat.nvim",
        -- tag = "v3.12.0"
        tag = "v4.7.4"
    })

    -- Colorschemes
    use({ "SyedFasiuddin/theme-toggle-nvim" })
    use({ "folke/tokyonight.nvim" })
    use({ "lunarvim/darkplus.nvim" })
    use({ "lifepillar/vim-solarized8" })
    use({ "catppuccin/vim" })
    use({ "decaycs/decay.nvim", as = "decay" })
    use({ "navarasu/onedark.nvim", as = "onedark" })

    -- Cmp
    use({ "hrsh7th/nvim-cmp" })         -- The completion plugin
    use({ "hrsh7th/cmp-buffer" })       -- buffer completions
    use({ "hrsh7th/cmp-path" })         -- path completions
    use({ "saadparwaiz1/cmp_luasnip" }) -- snippet completions
    use({ "hrsh7th/cmp-nvim-lsp" })
    use({ "hrsh7th/cmp-nvim-lua" })
    --use({ "hrsh7th/cmp-copilot" })

    -- Snippets
    use({ "L3MON4D3/LuaSnip" })                               --snippet engine
    use({ "rafamadriz/friendly-snippets" })                   -- a bunch of snippets to use
    use({ "danymat/neogen" })                                 -- Your Annnotation Toolkit
    -- LSP
    use({ "neovim/nvim-lspconfig" })                          -- enable LSP
    use({ "mason-org/mason.nvim", tag = "v2.0.0" })           -- simple to use language server installer
    use({ "mason-org/mason-lspconfig.nvim", tag = "v2.0.0" }) -- locked for NVIM 0.10
    use({ "nvimtools/none-ls.nvim" })                         -- for formatters and linters

    -- Telescope
    use({ "nvim-telescope/telescope.nvim", tag = "0.1.8" })

    -- Outline
    use({ "hedyhli/outline.nvim" })

    -- Treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
    })

    -- fzf
    use("junegunn/fzf")
    use("junegunn/fzf.vim")

    -- Git
    use({ "lewis6991/gitsigns.nvim" })
    use({ "tpope/vim-fugitive" })

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
