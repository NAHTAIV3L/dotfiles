return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('telescope').setup({})
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        vim.keymap.set('n', '<leader>r', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>b', function()
            builtin.buffers({ sort_mru = true, ignore_current_buffer = true})
        end)
    end
}
