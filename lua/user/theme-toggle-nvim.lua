local status_ok, theme_toggle_nvim = pcall(require, "theme-toggle-nvim")
if not status_ok then
    return
end

theme_toggle_nvim.setup({
    colorscheme = {
        light = "onedark",
        dark = "onedark",
    },
})
