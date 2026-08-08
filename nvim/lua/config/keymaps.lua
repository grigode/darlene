vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

-- Quick save & quit
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Close window" })
keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Quit without saving" })

-- Clear search highlight
keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Navigation between splits
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize splits with arrows
keymap.set("n", "<C-Up>", ":resize -2<CR>")
keymap.set("n", "<C-Down>", ":resize +2<CR>")
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")
