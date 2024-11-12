function FormatBuffer()
    local save_cursor = vim.fn.getpos('.')
    local save_view = vim.fn.winsaveview()

    vim.api.nvim_command('normal! ggVG')
    vim.api.nvim_command('normal! ==')

    vim.fn.setpos('.', save_cursor)
    vim.fn.winrestview(save_view)
end

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = ":%s/\\s\\+$//e",
})

vim.filetype.add {
    extension = { rasi = 'rasi' },
    pattern = {
        ['.*/waybar/config'] = 'jsonc',
        ['.*/mako/config'] = 'dosini',
        ['.*/kitty/*.conf'] = 'bash',
        ['.*/hypr/.*%.conf'] = 'hyprlang',
    },
}
