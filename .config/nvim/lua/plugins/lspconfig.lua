return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "L3MON4D3/LuaSnip",
        'saghen/blink.cmp',
        'chomosuke/typst-preview.nvim',
    },
    config = function()
        local blink = require('blink.cmp')
        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            blink.get_lsp_capabilities())
        local luasnip = require("luasnip")
        luasnip.setup({
            enable_autosnippets = true,
        })
        require("typst-preview").setup({
            open_cmd = "bash -c 'firefox -P notop --new-window %s 2>&1 1>/dev/null'"
        })
        luasnip.filetype_extend("cpp", { "c" })
        require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/"})
        vim.keymap.set("i", "<C-M-E>", function() luasnip.expand_or_jump(1) end, { silent = true })
        vim.keymap.set({ "i","s" }, "<C-F>", function() luasnip.jump(1) end, { silent = true })
        vim.keymap.set({ "i", "s" }, "<C-B>", function() luasnip.jump(-1) end, { silent = true })
        require("mason").setup({
            PATH = "append",
        })

        vim.lsp.enable({
            "lua_ls",
            "clangd",
            "rust-analyzer",
            "texlab",
            "tinymist",
            "zls"
        })

        vim.lsp.config("*", {
            capabilities = capabilities,
        })
        vim.lsp.config.zls = {
            on_init = function()
                vim.g.zig_fmt_parse_errors = 0
                vim.g.zig_fmt_autosave = 0
            end,
            capabilities = capabilities,
            autoformat = false,
        }
        vim.lsp.config.lua_ls = {
            capabilities = capabilities,
            settings = {
                Lua = {
                    telemetry = { enable = false, },
                    runtime = {
                        version = "LuaJIT",
                        path =  { "lua/?.lua", "lua/?/init.lua", }
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = { vim.env.VIMRUNTIME, },
                    }
                }
            },

        }
        vim.diagnostic.config({
            -- update_in_insert = true,
            virtual_text = true,
            float = {
                focusable = false,
                style = "minimal",
                border = nil,
                source = true,
                header = "",
                prefix = "",
            },
        })
    --     vim.api.nvim_create_autocmd('LspAttach', {
    --         callback = function(event)
    --             local opts = {buffer = event.buf}
    --             vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    --             vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    --             vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    --             vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    --             vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
    --             vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    --             vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
    --             vim.keymap.set('n', 'gR', vim.lsp.buf.rename, opts)
    --             vim.keymap.set({'n', 'x'}, 'gF', vim.lsp.buf.format, opts)
    --             vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, opts)
    --             vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end)
    --             vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end)
    --             vim.keymap.set('n', 'gf', vim.diagnostic.open_float, opts)
    --             vim.keymap.set('n', 'gq', vim.diagnostic.setloclist, opts)
    --         end,
    --     })
    end
}
