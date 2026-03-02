local lspconfig = require("lspconfig")

local root_dir = lspconfig.util.root_pattern(".git")

return {
	root_dir = root_dir,
}
