-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- initialize global var to false -> nvim-cmp turned off per default
vim.g.cmptoggle = false

local cmp = require("cmp")
cmp.setup({
    enabled = function()
        return vim.g.cmptoggle
    end,
})

map("n", "<leader>ua", "<cmd>lua vim.g.cmptoggle = not vim.g.cmptoggle<CR>", { desc = "toggle nvim-cmp" })
