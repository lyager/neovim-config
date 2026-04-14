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

--- Find the workspace root Cargo.toml
---@return string|nil
function M.find_cargo_toml()
	local clients = vim.lsp.get_clients({ name = "rust-analyzer" })
	if #clients > 0 and clients[1].config.root_dir then
		local path = clients[1].config.root_dir .. "/Cargo.toml"
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end

	-- Fallback: search upward from current file
	local found = vim.fs.find("Cargo.toml", {
		upward = true,
		path = vim.fn.expand("%:p:h"),
	})
	return found[1]
end

--- Apply the currently enabled features to the running rust-analyzer.
--- @param bufnr number|nil A Rust buffer to restart in (needed because Telescope
---   may have changed the current buffer by the time this runs).
function M.apply_features(bufnr)
	local clients = vim.lsp.get_clients({ name = "rust-analyzer" })
	if #clients == 0 then
		vim.notify("rust-analyzer is not running", vim.log.levels.WARN)
		return
	end

	-- Fall back to any buffer attached to the rust-analyzer client
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		bufnr = vim.lsp.get_buffers_by_client_id(clients[1].id)[1]
	end

	local features = M.enabled_features == "all" and "all" or vim.deepcopy(M.enabled_features)

	-- Mutate rustaceanvim's *cached* config directly — the module is loaded
	-- once and returned by reference, so this is the single source of truth
	-- for both the running client and any future restart.
	local ra_config = require("rustaceanvim.config.internal")
	local ra = ra_config.server.default_settings["rust-analyzer"]
	ra.cargo = ra.cargo or {}
	ra.cargo.features = features
	ra.check = ra.check or {}
	ra.check.features = features

	local msg = features == "all" and "ALL"
		or type(features) == "table" and #features == 0 and "(default only)"
		or type(features) == "table" and table.concat(features, ", ")
		or tostring(features)
	-- Use rustaceanvim's own restart (stop → poll until stopped → start).
	-- It reads from the cached config we mutated above.
	require("rustaceanvim.lsp").restart(bufnr)
	vim.notify("rust-analyzer restarting (features: " .. msg .. ") …", vim.log.levels.INFO)
end

local ALL_FEATURES = "(all)"

--- Open a Telescope picker to toggle Cargo features
function M.pick()
	-- Capture the Rust buffer *before* Telescope opens its own buffer.
	local rust_bufnr = vim.api.nvim_get_current_buf()
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
					M.apply_features(rust_bufnr)
				end)

				return true
			end,
		})
		:find()
end

return M
