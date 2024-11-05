return {
    "windwp/nvim-autopairs",
    opt = true,
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true,
            ts_config = { "string" }
        })
    end
}
