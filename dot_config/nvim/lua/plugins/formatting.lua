return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>lf",
                function() require("conform").format({ async = true, lsp_fallback = true }) end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                python = { "ruff_format" },
                rust   = { "rustfmt", lsp_format = "fallback" },
                c      = { "clang_format" },
                cpp    = { "clang_format" },
                go     = { "goimports" },
                lua    = { "stylua" },
            },
            -- Format on save
            format_on_save = {
                timeout_ms   = 3000,
                lsp_fallback = true,
            },
        },
    },
}
