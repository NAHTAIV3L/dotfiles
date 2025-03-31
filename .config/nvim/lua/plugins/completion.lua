return {
    'saghen/blink.cmp',
    version = "*",
    -- build = "cargo build --release",
    opts = {
        snippets = { preset = 'luasnip', },
        completion = {
            keyword = {
                range = 'prefix',
            },
            trigger = {
                -- show_in_snippet = false,
                -- show_on_keyword = false,
                -- show_on_trigger_character = false,
                -- show_on_accept_on_trigger_character = false,
                -- show_on_insert_on_trigger_character = false,
            },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },
            menu = {
                draw = {
                    columns = { { "label", "label_description", gap = 1 }, { "kind" , "source_name", gap = 1} },
                },
            },
            documentation = {
                auto_show = true,
            },
            ghost_text = {
                enabled = true,
            },
        },
        fuzzy = {
            prebuilt_binaries = {
                download = true,
            },
        },
        keymap = {
            preset = 'default',
            ['<Tab>'] = { 'accept', 'fallback' },
            ['<CR>'] = { 'accept', 'fallback' },
            ['<C-M-i>'] = { 'show', 'select_and_accept', 'fallback' },
        },
        cmdline = {
            completion = {
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = false,
                    },
                },
            },
            keymap = {
                preset = 'cmdline',
                ['<Tab>'] = { 'show', 'accept', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
                ['<C-M-i>'] = { 'show', 'select_and_accept', 'fallback' },
            },
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                buffer = {
                    name = 'Buffer',
                    module = 'blink.cmp.sources.buffer',
                    opts = {
                        -- all buffers of same filetype
                        get_bufnrs = function()
                            return vim
                                .iter(vim.api.nvim_list_bufs())
                                :filter(
                                    function (buf)
                                        return vim.bo[buf].buftype ~= 'nofile'
                                            and vim.bo[buf].filetype == vim.bo.filetype
                                    end)
                                :totable()
                        end,
                    }
                },
            }
        },
    },
}
