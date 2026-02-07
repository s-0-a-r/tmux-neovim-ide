return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      { "mason-org/mason-lspconfig.nvim" },
    },
    config = function()
      -- Server configurations using Neovim 0.11 native API
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("ts_ls", {})
      vim.lsp.config("ruby_lsp", {})

      -- Mason-lspconfig auto-enables installed servers
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "ruby_lsp",
        },
        automatic_enable = true,
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Keymaps on LSP attach (VSCode-like)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end
          -- VSCode: F12 = Go to definition
          map("n", "<F12>", vim.lsp.buf.definition, "Go to definition")
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          -- VSCode: Shift+F12 = Go to references
          map("n", "<S-F12>", vim.lsp.buf.references, "Go to references")
          map("n", "gr", vim.lsp.buf.references, "Go to references")
          -- VSCode: F2 = Rename symbol
          map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          -- VSCode macOS: Cmd+. = Quick fix / code action
          map({ "n", "v" }, "<D-.>", vim.lsp.buf.code_action, "Code action")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          -- Hover info
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          -- Signature help
          map("i", "<D-S-Space>", vim.lsp.buf.signature_help, "Signature help")
          -- VSCode macOS: Shift+Alt+F = Format document
          map("n", "<S-A-f>", function() vim.lsp.buf.format({ async = true }) end, "Format document")
          -- Other
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
          -- VSCode: F8 / Shift+F8 = Next/prev diagnostic
          map("n", "<F8>", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "<S-F8>", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
        end,
      })
    end,
  },
}
