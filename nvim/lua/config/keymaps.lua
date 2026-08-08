vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

-- Guardar y salir rápido
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Cerrar ventana" })
keymap.set("n", "<leader>Q", ":qa!<CR>", { desc = "Salir sin guardar" })

-- Limpiar resaltado de búsqueda
keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Limpiar búsqueda" })

-- Navegación entre divisiones (splits)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Ir a ventana izquierda" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Ir a ventana abajo" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Ir a ventana arriba" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Ir a ventana derecha" })

-- Redimensionar ventanas con flechas
keymap.set("n", "<C-Up>", ":resize -2<CR>")
keymap.set("n", "<C-Down>", ":resize +2<CR>")
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")
