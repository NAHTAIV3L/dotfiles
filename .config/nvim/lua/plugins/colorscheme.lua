function ColorMyPencils(color)
	color = color or "tokyonight"
	vim.cmd.colorscheme(color)

	-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    local colors = require("tokyonight.colors").setup()
    vim.api.nvim_set_hl(0, 'LineNrAbove', { fg=colors.fg })
    vim.api.nvim_set_hl(0, 'LineNr', { fg=colors.fg })
    vim.api.nvim_set_hl(0, 'LineNrBelow', { fg=colors.fg })
    vim.api.nvim_set_hl(0, 'Comment', { fg=colors.fg_dark })
    vim.api.nvim_set_hl(0, 'DiffAdd', { fg=colors.green1, bg=colors.bg })
    vim.api.nvim_set_hl(0, 'DiffDelete', { fg=colors.red1, bg=colors.bg })
end

return {
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                style = 'moon',
                transparent = false,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = false,
                    floats = false,
                }
            })
            ColorMyPencils()
        end
    },
}
