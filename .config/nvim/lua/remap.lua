vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("i", "<C-BS>", "<Esc>caw")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader>k", "<cmd>:bd<CR>")
vim.keymap.set("n", "<leader>k", "<cmd>:bd<CR>")

vim.keymap.set({"n", "v"}, "<leader>d", "\"_d")
vim.keymap.set("n", "<leader>p", "\"+p")
vim.keymap.set("v", "<leader>y", "\"+y")
