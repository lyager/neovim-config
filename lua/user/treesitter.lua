local M = {}
function M.config()
	local treesitter = require("nvim-treesitter")
	local configs = require("nvim-treesitter.configs")

	configs.setup({
		ensure_installed = { "lua", "markdown", "markdown_inline", "bash", "python" }, -- put the language you want in this array
		-- ensure_installed = "all", -- one of "all" or a list of languages
		ignore_install = { "" }, -- List of parsers to ignore installing
		sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
		auto_installer = true,

		highlight = {
			enable = true, -- false will disable the whole extension
			disable = {}, -- list of language that will be disabled
		},
		autopairs = {
			enable = true,
		},
		indent = { enable = true, disable = { "python" } },

		context_commentstring = {
			enable = true,
			enable_autocmd = false,
		},

		textobjects = {
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]]"] = { query = "@function.outer", desc = "Next function start" },
					["]c"] = { query = "@class.outer", desc = "Next class start" },
				},
				goto_next_end = {
					["]["] = { query = "@function.outer", desc = "Next function end" },
					["]C"] = { query = "@class.outer", desc = "Next class end" },
				},
				goto_previous_start = {
					["[["] = { query = "@function.outer", desc = "Prev function start" },
					["[c"] = { query = "@class.outer", desc = "Prev class start" },
				},
				goto_previous_end = {
					["[]"] = { query = "@function.outer", desc = "Prev function end" },
					["[C"] = { query = "@class.outer", desc = "Prev class end" },
				},
			},
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = { query = "@function.outer", desc = "around function" },
					["if"] = { query = "@function.inner", desc = "inside function" },
					["ac"] = { query = "@class.outer", desc = "around class" },
					["ic"] = { query = "@class.inner", desc = "inside class" },
					["aa"] = { query = "@parameter.outer", desc = "around argument" },
					["ia"] = { query = "@parameter.inner", desc = "inside argument" },
				},
			},
		},
	})
end

return M
