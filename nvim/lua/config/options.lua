local opt = vim.opt

-- Numeración de líneas
opt.number = true
opt.relativenumber = true

-- Tabulación e sangría
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- Búsqueda
opt.ignorecase = true
opt.smartcase = true

-- Apariencia
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false

-- Ventanas y divisiones
opt.splitbelow = true
opt.splitright = true

-- Portapapeles e historial
opt.clipboard = "unnamedplus"
opt.undofile = true

-- Desplazamiento
opt.scrolloff = 8

-- Tiempos de espera
opt.timeoutlen = 300
