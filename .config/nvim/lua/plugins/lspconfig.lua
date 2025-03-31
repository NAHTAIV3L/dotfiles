return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "L3MON4D3/LuaSnip",
        'saghen/blink.cmp',
    },
    config = function()
        local blink = require('blink.cmp')
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            blink.get_lsp_capabilities())
        local luasnip = require("luasnip")
        vim.keymap.set({ "i","s" }, "<C-F>", function() luasnip.jump(1) end, { silent = true})
        vim.keymap.set({ "i", "s" }, "<C-B>", function() luasnip.jump(-1) end, { silent = true})
        require("mason").setup({
            PATH = "append",
        })
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "zls",
                "texlab",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["zls"] = function ()
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        capabilities = capabilities,
                        autoformat = false,
                    })
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })
        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = true,
                header = "",
                prefix = "",
            },
        })
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(event)
                local opts = {buffer = event.buf}
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                vim.keymap.set({'n', 'x'}, '<F3>', vim.lsp.buf.format, opts)
                vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
            end,
        })
    end
}
