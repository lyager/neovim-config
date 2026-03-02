local ls = require("luasnip")

-- some shorthands...
local snip = ls.snippet
local func = ls.function_node

local date = function()
	return { os.date("%Y-%m-%d") }
end

ls.add_snippets("all", {
	snip({
		trig = "date",
		namr = "Date",
		dscr = "Date in the form of YYYY-MM-DD",
	}, {
		func(date, {}),
	}),
})
