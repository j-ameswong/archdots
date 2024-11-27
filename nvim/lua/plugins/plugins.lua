return {
    {
        "nvim-neorg/neorg",
        lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
        version = "*", -- Pin Neorg to the latest stable release
        config = true,
    },

    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
                ["<C-q>"] = cmp.mapping.confirm({ select = true }),
                -- ["<C-R>"] = cmp.config.disable,
            })
        end,
    },

    {
        "atiladefreitas/dooing",
        config = function()
            require("dooing").setup({
                -- your custom config here (optional)
            })
        end,
    },
}
