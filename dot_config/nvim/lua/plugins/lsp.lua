return {
    -- LSP installer UI
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>lm", "<cmd>Mason<CR>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = { ui = { border = "rounded" } },
    },

    -- Install LSPs, formatters, linters via mason
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                -- LSPs
                "pyright",
                "clangd",
                "gopls",
                -- Formatters (used by conform.nvim)
                "ruff",
                "goimports",
                "clang-format",
            },
            auto_update = true,
        },
    },

    -- Bridge mason <-> lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = { automatic_installation = true },
    },

    -- LSP configurations
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            { "folke/lazydev.nvim", ft = "lua", opts = {} },
            { "j-hui/fidget.nvim",  opts = {} },
        },
        config = function()
            local lspconfig   = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Python
            lspconfig.pyright.setup({
                capabilities = capabilities,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
            })

            -- C / C++
            lspconfig.clangd.setup({
                capabilities = capabilities,
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--fallback-style=llvm",
                },
            })

            -- Go
            lspconfig.gopls.setup({
                capabilities = capabilities,
                settings = {
                    gopls = {
                        analyses = { unusedparams = true, shadow = true },
                        staticcheck = true,
                        gofumpt = true,
                        hints = {
                            parameterNames = true,
                            assignVariableTypes = true,
                            functionTypeParameters = true,
                        },
                    },
                },
            })
        end,
    },

    -- Rust (replaces plain rust-analyzer setup — adds runnables, macro expand, etc.)
    {
        "mrcjkb/rustaceanvim",
        version = "^5",
        ft = { "rust" },
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    capabilities = (function()
                        -- safely grab capabilities if cmp is loaded
                        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
                        return ok and cmp_lsp.default_capabilities() or {}
                    end)(),
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = { command = "clippy" },
                            inlayHints = { enable = true },
                        },
                    },
                },
            }
            -- Extra Rust keymaps registered at LspAttach for rust files
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("rustacean_keys", { clear = true }),
                pattern = "*.rs",
                callback = function(event)
                    local map = vim.keymap.set
                    map("n", "<leader>rr", "<cmd>RustLsp runnables<CR>",    { buffer = event.buf, desc = "Rust: Runnables" })
                    map("n", "<leader>rt", "<cmd>RustLsp testables<CR>",    { buffer = event.buf, desc = "Rust: Testables" })
                    map("n", "<leader>re", "<cmd>RustLsp expandMacro<CR>",  { buffer = event.buf, desc = "Rust: Expand macro" })
                    map("n", "<leader>rd", "<cmd>RustLsp debuggables<CR>",  { buffer = event.buf, desc = "Rust: Debuggables" })
                end,
            })
        end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
            {
                "L3MON4D3/LuaSnip",
                build = "make install_jsregexp",
                dependencies = { "rafamadriz/friendly-snippets" },
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end,
            },
        },
        config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"]     = cmp.mapping.select_next_item(),
                    ["<C-p>"]     = cmp.mapping.select_prev_item(),
                    ["<C-d>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip",  priority = 750 },
                    { name = "buffer",   priority = 500 },
                    { name = "path",     priority = 250 },
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "…",
                    }),
                },
                window = {
                    completion    = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
            })
        end,
    },

    -- Diagnostics panel
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>dd", "<cmd>Trouble diagnostics toggle<CR>",                 desc = "Workspace diagnostics" },
            { "<leader>db", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",    desc = "Buffer diagnostics" },
            { "<leader>ds", "<cmd>Trouble symbols toggle focus=false<CR>",         desc = "Symbols" },
        },
        opts = {},
    },
}
