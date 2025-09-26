return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
        },
    },
    config = function()
        require('telescope').setup({
            extensions = {
                fzf = {
                    fuzzy = true,                    -- false will only do exact matching
                    override_generic_sorter = true,  -- override the generic sorter
                    override_file_sorter = true,     -- override the file sorter
                    case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                }
            }
        })
        local highlights = {
            "Normal",
            "PreviewNormal",
            "PromptNormal",
            "ResultsNormal",
            "Border",
            "PromptBorder",
            "ResultsBorder",
            "PreviewBorder",
            "Title",
            "PromptTitle",
            "ResultsTitle",
            "PreviewTitle",
        }
        -- for _, h in ipairs(highlights) do
        --     vim.api.nvim_set_hl(0, "Telescope" .. h, { link = "Normal" })
        --     vim.cmd.highlight("Telescope" .. h .. " guibg=none")
        -- end
        -- vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none", force = true })
        -- vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none", force = true })
        -- vim.api.nvim_set_hl(0, "TelescopeTitle", { bg = "none", force = true })
        require('telescope').load_extension('fzf')
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        vim.keymap.set('n', '<leader>r', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>b', function()
            builtin.buffers({ sort_mru = true, ignore_current_buffer = true})
        end)
    end
}
