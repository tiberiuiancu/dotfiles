return {
    -- Syntax highlighting (nvim-treesitter v1.0+ API)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter").setup()

            -- Install parsers (async, runs in background)
            require("nvim-treesitter.install").install({
                "bash", "c", "cpp", "go", "gomod", "gosum",
                "json", "lua", "markdown", "python", "rust",
                "toml", "vim", "vimdoc", "yaml",
            })

            -- Enable treesitter highlight + indent for every buffer
            -- (uses nvim's built-in vim.treesitter when a parser is available)
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    pcall(vim.treesitter.start, args.buf)
                end,
            })
        end,
    },

    -- Auto-close brackets and quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = { check_ts = true },
    },

    -- Comment/uncomment with gc
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },

    -- Surround text with brackets/quotes: ys, cs, ds
    {
        "kylechui/nvim-surround",
        version = "*",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },

    -- Better text objects (cin(, ca", etc.)
    {
        "echasnovski/mini.ai",
        event = { "BufReadPost", "BufNewFile" },
        opts = { n_lines = 500 },
    },

    -- Highlight all occurrences of word under cursor
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("illuminate").configure({
                delay = 200,
                large_file_cutoff = 2000,
            })
        end,
    },

    -- Show colours inline (#fff, rgb(), etc.)
    {
        "NvChad/nvim-colorizer.lua",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },
}
