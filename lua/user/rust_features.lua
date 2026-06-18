local M = {}

--- Currently enabled features (module-local state)
--- Can be a list of feature names, or the string "all" for --all-features.
--- Defaults to empty (i.e. only Cargo's `default` feature set) so projects with
--- platform-specific features don't force-compile incompatible crates.
---@type string[]|string
M.enabled_features = {}

--- Parse [features] from a Cargo.toml file.
--- Returns a list of feature names (excluding "default").
---@param path string
---@return string[]
function M.parse_cargo_features(path)
	local lines = vim.fn.readfile(path)
	if not lines or #lines == 0 then
		return {}
	end

	local features = {}
	local in_features = false

	for _, line in ipairs(lines) do
		if line:match("^%[features%]") then
			in_features = true
		elseif line:match("^%[") then
			in_features = false
		elseif in_features then
			local stripped = line:match("^%s*(.-)%s*$")
			if stripped ~= "" and stripped:sub(1, 1) ~= "#" then
				local name = stripped:match("^(%S+)%s*=")
				if name and name ~= "default" then
					table.insert(features, name)
				end
			end
		end
	end

	table.sort(features)
	return features
end

--- Resolve the workspace root directory (the dir containing the root Cargo.toml).
---@return string|nil
function M.workspace_root()
	local clients = vim.lsp.get_clients({ name = "rust-analyzer" })
	if #clients > 0 and clients[1].config.root_dir then
		return clients[1].config.root_dir
	end

	-- Fallback: search upward from current file
	local found = vim.fs.find("Cargo.toml", {
		upward = true,
		path = vim.fn.expand("%:p:h"),
	})
	if found[1] then
		return vim.fs.dirname(found[1])
	end
	return nil
end

--- Find the workspace root Cargo.toml
---@return string|nil
function M.find_cargo_toml()
	local root = M.workspace_root()
	if root then
		local path = root .. "/Cargo.toml"
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end
	return nil
end

--- Apply the currently enabled features to the running rust-analyzer
function M.apply_features()
	local clients = vim.lsp.get_clients({ name = "rust-analyzer" })
	if #clients == 0 then
		vim.notify("rust-analyzer is not running", vim.log.levels.WARN)
		return
	end

	local client = clients[1]
	local features = M.enabled_features == "all" and "all" or vim.deepcopy(M.enabled_features)

	client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
		["rust-analyzer"] = {
			cargo = { features = features },
			check = { features = features },
		},
	})

	client:notify("workspace/didChangeConfiguration", { settings = client.settings })

	if features == "all" then
		vim.notify("Rust features: ALL", vim.log.levels.INFO)
	elseif #features == 0 then
		vim.notify("Rust features: (default only)", vim.log.levels.INFO)
	else
		vim.notify("Rust features: " .. table.concat(features, ", "), vim.log.levels.INFO)
	end
end

--- Set the enabled features (entry point for project-local .nvim.lua).
--- Accepts a list of feature names or the string "all". Applies immediately
--- if rust-analyzer is already attached (e.g. when re-sourcing the file).
---@param features string[]|string
function M.set(features)
	if features ~= "all" and type(features) ~= "table" then
		vim.notify("rust_features.set: expected a list or \"all\"", vim.log.levels.ERROR)
		return
	end
	M.enabled_features = features == "all" and "all" or vim.deepcopy(features)

	if #vim.lsp.get_clients({ name = "rust-analyzer" }) > 0 then
		M.apply_features()
	end
end

local BLOCK_BEGIN = "-- >>> rust_features (managed by RustFeatures) >>>"
local BLOCK_END = "-- <<< rust_features <<<"

--- Render the current selection as a Lua argument literal for M.set().
---@return string
local function render_arg()
	if M.enabled_features == "all" then
		return '"all"'
	end
	local quoted = {}
	for _, feat in ipairs(M.enabled_features) do
		table.insert(quoted, string.format("%q", feat))
	end
	return "{ " .. table.concat(quoted, ", ") .. " }"
end

--- Persist the current selection into a managed block in <root>/.nvim.lua,
--- preserving any other content, and trust the file so exrc won't re-prompt.
function M.save()
	local root = M.workspace_root()
	if not root then
		vim.notify("Cannot save Rust features: no workspace root", vim.log.levels.WARN)
		return
	end

	local path = root .. "/.nvim.lua"
	local block = {
		BLOCK_BEGIN,
		'require("user.rust_features").set(' .. render_arg() .. ")",
		BLOCK_END,
	}

	local lines = {}
	if vim.fn.filereadable(path) == 1 then
		lines = vim.fn.readfile(path)
	end

	-- Locate an existing managed block and replace it; otherwise append.
	local begin_idx, end_idx
	for i, line in ipairs(lines) do
		if line == BLOCK_BEGIN then
			begin_idx = i
		elseif line == BLOCK_END and begin_idx then
			end_idx = i
			break
		end
	end

	local out = {}
	if begin_idx and end_idx then
		for i = 1, begin_idx - 1 do
			table.insert(out, lines[i])
		end
		vim.list_extend(out, block)
		for i = end_idx + 1, #lines do
			table.insert(out, lines[i])
		end
	else
		out = lines
		if #out > 0 and out[#out] ~= "" then
			table.insert(out, "")
		end
		vim.list_extend(out, block)
	end

	vim.fn.writefile(out, path)

	-- Trust the file so exrc loads it without prompting on next startup.
	pcall(vim.secure.trust, { action = "allow", path = vim.fn.fnamemodify(path, ":p") })
end

local ALL_FEATURES = "(all)"

--- Open a Telescope picker to toggle Cargo features
function M.pick()
	local cargo_toml = M.find_cargo_toml()
	if not cargo_toml then
		vim.notify("No Cargo.toml found", vim.log.levels.ERROR)
		return
	end

	local individual = M.parse_cargo_features(cargo_toml)
	if #individual == 0 then
		vim.notify("No features found in " .. cargo_toml, vim.log.levels.WARN)
		return
	end

	-- Picker entries: (all) first, then individual features
	local entries = { ALL_FEATURES }
	vim.list_extend(entries, individual)

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Track selections within this picker session
	local selected = {}
	if M.enabled_features == "all" then
		selected[ALL_FEATURES] = true
	elseif type(M.enabled_features) == "table" then
		for _, feat in ipairs(M.enabled_features) do
			selected[feat] = true
		end
	end

	local function make_finder()
		return finders.new_table({
			results = entries,
			entry_maker = function(feat)
				local prefix = selected[feat] and "[x] " or "[ ] "
				return {
					value = feat,
					display = prefix .. feat,
					ordinal = feat,
				}
			end,
		})
	end

	pickers
		.new({}, {
			prompt_title = "Cargo Features (Tab to toggle, Enter to apply)",
			finder = make_finder(),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				-- Toggle feature on Tab
				local function toggle_feature()
					local entry = action_state.get_selected_entry()
					if not entry then
						return
					end

					if entry.value == ALL_FEATURES then
						-- Toggling (all) clears individual selections
						if selected[ALL_FEATURES] then
							selected[ALL_FEATURES] = false
						else
							selected = { [ALL_FEATURES] = true }
						end
					else
						-- Toggling an individual feature clears (all)
						selected[ALL_FEATURES] = false
						selected[entry.value] = not selected[entry.value]
					end

					-- Refresh the picker, preserving cursor position
					local picker = action_state.get_current_picker(prompt_bufnr)
					local row = picker:get_selection_row()
					picker:refresh(make_finder(), { reset_prompt = false })
					vim.schedule(function()
						picker:set_selection(row)
					end)
				end

				map("i", "<Tab>", toggle_feature)
				map("n", "<Tab>", toggle_feature)

				-- Apply on Enter
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					if selected[ALL_FEATURES] then
						M.enabled_features = "all"
					else
						M.enabled_features = {}
						for _, feat in ipairs(individual) do
							if selected[feat] then
								table.insert(M.enabled_features, feat)
							end
						end
					end
					M.apply_features()
					M.save()
				end)

				return true
			end,
		})
		:find()
end

return M
