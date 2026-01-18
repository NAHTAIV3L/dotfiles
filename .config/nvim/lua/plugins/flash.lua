return {
    "folke/flash.nvim",
    config = function()
        vim.keymap.set({"n"}, "<C-s>", function() require("flash").jump() end)
    end
}
