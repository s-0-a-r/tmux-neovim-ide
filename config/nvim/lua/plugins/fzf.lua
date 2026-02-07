return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      -- VSCode macOS: Cmd+P = Quick open, Cmd+Shift+F = Search, etc.
      { "<D-p>", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<D-S-f>", "<cmd>FzfLua live_grep<cr>", desc = "Search in files" },
      { "<D-S-p>", "<cmd>FzfLua commands<cr>", desc = "Command palette" },
      { "<D-S-o>", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Go to symbol" },
      { "<D-t>", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<D-S-m>", "<cmd>FzfLua diagnostics_document<cr>", desc = "Problems" },
      -- Leader alternatives
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fw", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    },
    opts = {
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = { layout = "vertical", vertical = "up:40%" },
      },
      files = { fd_opts = "--type f --hidden --exclude .git" },
    },
  },
}
