local map = vim.keymap.set

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>",  { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>",  { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })

-- Window navigation — Ctrl+arrow and Ctrl+hjkl both work
map("n", "<C-h>",     "<C-w>h", { desc = "Window left" })
map("n", "<C-j>",     "<C-w>j", { desc = "Window down" })
map("n", "<C-k>",     "<C-w>k", { desc = "Window up" })
map("n", "<C-l>",     "<C-w>l", { desc = "Window right" })
map("n", "<C-Left>",  "<C-w>h", { desc = "Window left" })
map("n", "<C-Down>",  "<C-w>j", { desc = "Window down" })
map("n", "<C-Up>",    "<C-w>k", { desc = "Window up" })
map("n", "<C-Right>", "<C-w>l", { desc = "Window right" })

-- Window resize with Alt+arrow
map("n", "<A-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Shrink window" })
map("n", "<A-Right>", "<cmd>vertical resize +2<CR>", { desc = "Expand window" })
map("n", "<A-Up>",    "<cmd>resize +2<CR>",          { desc = "Expand window" })
map("n", "<A-Down>",  "<cmd>resize -2<CR>",          { desc = "Shrink window" })

-- Buffer navigation
map("n", "<Tab>",   "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
map("n", "<leader>x", "<cmd>bdelete<CR>",           { desc = "Close buffer" })

-- Move selected lines up/down
map("n", "<A-j>", "<cmd>m .+1<CR>==",        { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==",        { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",        { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",        { desc = "Move selection up" })

-- Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "File explorer" })

-- LSP attach keymaps (applied to all LSPs via autocmd)
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
    callback = function(event)
        local m = function(keys, func, desc)
            map("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end
        m("gd",         vim.lsp.buf.definition,      "Go to definition")
        m("gD",         vim.lsp.buf.declaration,     "Go to declaration")
        m("gr",         vim.lsp.buf.references,      "References")
        m("gi",         vim.lsp.buf.implementation,  "Go to implementation")
        m("gy",         vim.lsp.buf.type_definition, "Type definition")
        m("K",          vim.lsp.buf.hover,           "Hover docs")
        m("<leader>lr", vim.lsp.buf.rename,          "Rename symbol")
        m("<leader>la", vim.lsp.buf.code_action,     "Code action")
        m("<leader>li", "<cmd>LspInfo<CR>",          "LSP info")

        -- Enable inlay hints if supported (nvim 0.10+)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        end
    end,
})
