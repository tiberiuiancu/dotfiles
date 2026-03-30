return {
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = "FzfLua",
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<CR>",            desc = "Find files" },
            { "<leader>fg", "<cmd>FzfLua live_grep<CR>",        desc = "Live grep" },
            { "<leader>fb", "<cmd>FzfLua buffers<CR>",          desc = "Buffers" },
            { "<leader>fr", "<cmd>FzfLua oldfiles<CR>",         desc = "Recent files" },
            { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
            { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
            { "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", desc = "Document diagnostics" },
            { "<leader>f/", "<cmd>FzfLua blines<CR>",           desc = "Search in buffer" },
            { "<leader>fc", "<cmd>FzfLua commands<CR>",         desc = "Commands" },
            { "<leader>fk", "<cmd>FzfLua keymaps<CR>",          desc = "Keymaps" },
            -- Also map gr and gd to fzf-lua for a nicer list UI
            { "gr",         "<cmd>FzfLua lsp_references<CR>",   desc = "LSP references" },
        },
        opts = {
            winopts = {
                height = 0.85,
                width  = 0.80,
                preview = { layout = "vertical", vertical = "down:50%" },
            },
            fzf_opts = { ["--layout"] = "reverse" },
        },
    },
}
