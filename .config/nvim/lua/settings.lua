vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
vim.opt.undofile = true

vim.opt.scrolloff = 7

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.incsearch = true

vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.colorcolumn = "80"

vim.opt.winborder = "single"

-- disable mouse
vim.o.mouse = ""
vim.keymap.set("", "<up>", "<nop>", { noremap = true })
vim.keymap.set("", "<down>", "<nop>", { noremap = true })
vim.keymap.set("i", "<up>", "<nop>", { noremap = true })
vim.keymap.set("i", "<down>", "<nop>", { noremap = true })
vim.keymap.set("", "<right>", "<nop>", { noremap = true })
vim.keymap.set("", "<left>", "<nop>", { noremap = true })
vim.keymap.set("i", "<right>", "<nop>", { noremap = true })
vim.keymap.set("i", "<left>", "<nop>", { noremap = true })
vim.opt.mousescroll = "ver:0,hor:0"
