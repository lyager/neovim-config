local status_ok, copilot_chat = pcall(require, "CopilotChat")
if not status_ok then
    return
end

local select = require("CopilotChat.select")
--local chat = require("CopilotChat.chat")

copilot_chat.setup({
    debug = false,
    trace = false,
    selection = select.unnamed,
    model = 'claude-sonnet-4.5'
})
