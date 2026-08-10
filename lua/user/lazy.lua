-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
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
	{ "kyazdani42/nvim-web-devicons", lazy = true },
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
	{ "moll/vim-bbye", cmd = { "Bdelete", "Bwipeout" } },

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

	-- Colorschemes
	{ "SyedFasiuddin/theme-toggle-nvim", lazy = true },
	{ "folke/tokyonight.nvim", lazy = true },
	{ "lunarvim/darkplus.nvim", lazy = true },
	{ "lifepillar/vim-solarized8", lazy = true },
	{ "catppuccin/vim", name = "catppuccin", lazy = true },
	{ "decaycs/decay.nvim", name = "decay", lazy = true },
	{ "navarasu/onedark.nvim", name = "onedark", lazy = true },

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
	{ "hrsh7th/cmp-buffer", lazy = true },
	{ "hrsh7th/cmp-path", lazy = true },
	{ "saadparwaiz1/cmp_luasnip", lazy = true },
	{ "hrsh7th/cmp-nvim-lsp", lazy = true },
	{ "hrsh7th/cmp-nvim-lua", lazy = true },

	-- Snippets
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("user.luasnip")
		end,
	},
	{ "rafamadriz/friendly-snippets", lazy = true },

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
			{ "mason-org/mason.nvim", tag = "v2.0.0" },
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
	{ "nvimtools/none-ls.nvim", lazy = true },

	-- Rust
	{
		"mrcjkb/rustaceanvim",
		version = "^8",
		lazy = false,
		init = function()
			vim.g.rustaceanvim = {
				server = {
					on_attach = function(client, bufnr)
						require("user.lsp.handlers").on_attach(client, bufnr)
						-- Apply any features recorded by a project-local .nvim.lua
						-- (via require("user.rust_features").set(...)). Stay silent
						-- when nothing was selected so plain projects are untouched.
						local rf = require("user.rust_features")
						local sel = rf.enabled_features
						if sel == "all" or (type(sel) == "table" and #sel > 0) then
							rf.apply_features()
						end
					end,
					capabilities = require("user.lsp.handlers").capabilities,
					default_settings = {
						["rust-analyzer"] = {
							checkOnSave = true,
							check = {
								command = "clippy",
							},
							cargo = {},
						},
					},
				},
			}

			vim.api.nvim_create_user_command("RustFeatures", function()
				require("user.rust_features").pick()
			end, { desc = "Toggle Cargo features for rust-analyzer" })

			-- rust-analyzer reports workspace health (e.g. cargo metadata failed)
			-- via this custom notification. Surface it as an error so feature /
			-- toolchain incompatibilities aren't silently swallowed.
			vim.lsp.handlers["experimental/serverStatus"] = function(_, result)
				if result and result.health ~= "ok" then
					local level = result.health == "error" and vim.log.levels.ERROR or vim.log.levels.WARN
					vim.notify(
						"rust-analyzer: " .. (result.message or ("health=" .. tostring(result.health))),
						level,
						{ title = "rust-analyzer" }
					)
				end
			end

		end,
	},

	-- Oil
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		-- Optional dependencies
		dependencies = { { "nvim-mini/mini.icons", opts = {} } },
		-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		cmd = "Telescope",
		keys = {
			{ "<leader>f", desc = "Telescope" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
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
			{ "<leader>lo", "<cmd>Outline<cr>", desc = "Toggle Outline" },
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
	{ "junegunn/fzf", build = "./install --all", version = "*" },
	{ "junegunn/fzf.vim", dependencies = { "junegunn/fzf" }, version = "*" },

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("user.gitsigns")
		end,
	},
	{ "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gw", "Gwrite" } },
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
