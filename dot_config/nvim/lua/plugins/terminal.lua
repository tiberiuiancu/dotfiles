return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys = {
            { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>",      desc = "Float terminal" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
            { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",   desc = "Vertical terminal" },
            { "<C-\\>",     "<cmd>ToggleTerm<CR>",                      desc = "Toggle terminal", mode = { "n", "t" } },
        },
        opts = {
            size = function(term)
                if term.direction == "horizontal" then return 15
                elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4)
                end
            end,
            open_mapping = nil,     -- we set keys manually above
            float_opts = {
                border = "curved",
                width  = math.floor(vim.o.columns * 0.85),
                height = math.floor(vim.o.lines * 0.85),
            },
            shade_terminals = false,
            highlights = {
                FloatBorder = { link = "FloatBorder" },
            },
        },
        config = function(_, opts)
            require("toggleterm").setup(opts)
            -- Escape from terminal mode with Esc
            vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
        end,
    },
}
