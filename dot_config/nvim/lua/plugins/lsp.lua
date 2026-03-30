return {
    -- Autocompletion (loaded early so capabilities are available for LSP setup)
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

    -- Mason + lspconfig: all in one spec to guarantee setup order
    -- Required order: mason.setup → mason-lspconfig.setup → lspconfig.X.setup
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "williamboman/mason.nvim",          build = ":MasonUpdate" },
            { "williamboman/mason-lspconfig.nvim" },
            {
                "WhoIsSethDaniel/mason-tool-installer.nvim",
                opts = {
                    ensure_installed = {
                        "pyright", "clangd",
                        "ruff", "clang-format",
                    },
                    auto_update = true,
                },
            },
            { "hrsh7th/cmp-nvim-lsp" },
            { "folke/lazydev.nvim", ft = "lua", opts = {} },
            { "j-hui/fidget.nvim",  opts = {} },
        },
        keys = {
            { "<leader>lm", "<cmd>Mason<CR>", desc = "Mason" },
        },
        config = function()
            -- 1. mason
            require("mason").setup({ ui = { border = "rounded" } })

            -- 2. mason-lspconfig
            require("mason-lspconfig").setup({ automatic_installation = true })

            -- 3. Global capabilities (applied to every server)
            vim.lsp.config("*", {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })

            -- 4. Per-server config overrides (nvim 0.11+ native API)
            --    Base configs (cmd, filetypes) come from lspconfig's lsp/ dir on runtimepath.
            vim.lsp.config("pyright", {
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

            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--fallback-style=llvm",
                },
            })

            -- 5. Enable servers (start when matching filetype buffer opens)
            vim.lsp.enable({ "pyright", "clangd" })
        end,
    },

    -- Rust (separate from lspconfig — rustaceanvim manages rust-analyzer directly)
    {
        "mrcjkb/rustaceanvim",
        version = "^5",
        ft = { "rust" },
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    capabilities = (function()
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
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("rustacean_keys", { clear = true }),
                pattern = "*.rs",
                callback = function(event)
                    local map = vim.keymap.set
                    map("n", "<leader>rr", "<cmd>RustLsp runnables<CR>",   { buffer = event.buf, desc = "Rust: Runnables" })
                    map("n", "<leader>rt", "<cmd>RustLsp testables<CR>",   { buffer = event.buf, desc = "Rust: Testables" })
                    map("n", "<leader>re", "<cmd>RustLsp expandMacro<CR>", { buffer = event.buf, desc = "Rust: Expand macro" })
                    map("n", "<leader>rd", "<cmd>RustLsp debuggables<CR>", { buffer = event.buf, desc = "Rust: Debuggables" })
                end,
            })
        end,
    },

    -- Diagnostics panel
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>dd", "<cmd>Trouble diagnostics toggle<CR>",              desc = "Workspace diagnostics" },
            { "<leader>db", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
            { "<leader>ds", "<cmd>Trouble symbols toggle focus=false<CR>",      desc = "Symbols" },
        },
        opts = {},
    },
}
