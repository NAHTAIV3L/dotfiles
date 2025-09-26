vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("n", "<leader>h", "<cmd>:noh<CR>")

vim.keymap.set("n", "<leader>k", "<cmd>:bd<CR>")

vim.keymap.set({"n", "v"}, "<leader>d", "\"_d")
vim.keymap.set("n", "<leader>p", "\"+p")
vim.keymap.set("v", "<leader>y", "\"+y")

vim.keymap.set("n", "<leader>c", "<cmd>:cclose<CR>")
vim.keymap.set("n", "<leader>o", "<cmd>:copen<CR>")

vim.keymap.set({"n", "i", "v", "s"}, "<F1>", "<Nop>")
