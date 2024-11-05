function ColorMyPencils(color)
	color = color or "tokyonight"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    local line_color = "#c8d3f5"
    vim.api.nvim_set_hl(0, 'LineNrAbove', { fg=line_color })
    vim.api.nvim_set_hl(0, 'LineNr', { fg=line_color })
    vim.api.nvim_set_hl(0, 'LineNrBelow', { fg=line_color })
end

return {
    {
        "embark-theme/vim",
        lazy = false,
        priority = 1000,
        name = "embark",
        config = function()
            ColorMyPencils()
        end
    },
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                style = 'moon',
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = false,
                    floats = false,
                }
            })
        end
    },
}
