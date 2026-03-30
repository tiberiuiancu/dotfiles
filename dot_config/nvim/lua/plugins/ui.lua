return {
    -- Catppuccin theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            integrations = {
                bufferline = true,
                cmp = true,
                gitsigns = true,
                indent_blankline = { enabled = true },
                lsp_trouble = true,
                mason = true,
                mini = { enabled = true },
                neo_tree = true,
                treesitter = true,
                which_key = true,
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = require("lualine.themes.catppuccin"),
                    globalstatus = true,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_c = {
                        { "filename", path = 1 },
                    },
                    lualine_x = {
                        "diagnostics", "encoding", "filetype",
                    },
                },
            })
        end,
    },

    -- Buffer tabs
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                diagnostics = "nvim_lsp",
                always_show_bufferline = false,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Explorer",
                        highlight = "Directory",
                        separator = true,
                    },
                },
            },
        },
    },

    -- Keybinding hints
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            spec = {
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>l", group = "lsp" },
                { "<leader>t", group = "terminal" },
                { "<leader>d", group = "diagnostics" },
                { "<leader>r", group = "rust" },
            },
        },
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        opts = {
            scope = { enabled = true },
        },
    },

    -- Better vim.ui.input / vim.ui.select
    {
        "stevearc/dressing.nvim",
        lazy = true,
        init = function()
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.select(...)
            end
            vim.ui.input = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.input(...)
            end
        end,
    },

    -- Notification popups
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        opts = {
            timeout = 3000,
            stages = "fade",
            render = "compact",
        },
        config = function(_, opts)
            local notify = require("notify")
            notify.setup(opts)
            vim.notify = notify
        end,
    },

    -- Icons (used by many plugins)
    { "nvim-tree/nvim-web-devicons", lazy = true },
}
