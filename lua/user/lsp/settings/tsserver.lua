return {
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = "/opt/homebrew/lib/node_modules/@vue/typescript-plugin/",
                languages = { "javascript", "typescript", "vue" },
            },
            {
                name = "@vue/language-plugin-pug",
                location = "/opt/homebrew/lib/node_modules/@vue/language-plugin-pug/",
                languages = { "javascript", "typescript", "vue" },
            },
        },
    },
    filetypes = {
        "javascript",
        "typescript",
        "vue",
    },
}
