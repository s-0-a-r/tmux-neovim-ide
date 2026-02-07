return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "catppuccin/nvim",
    },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin tab" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other tabs" },
    },
    opts = function()
      return {
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(_, _, diag)
            local icons = { error = " ", warning = " ", hint = " " }
            local ret = (diag.error and icons.error .. diag.error .. " " or "")
              .. (diag.warning and icons.warning .. diag.warning .. " " or "")
            return vim.trim(ret)
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Explorer",
              highlight = "Directory",
              text_align = "left",
            },
          },
          close_command = function(bufnr)
            local bufs = vim.tbl_filter(function(b)
              return b ~= bufnr and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.bo[b].buftype == ""
            end, vim.api.nvim_list_bufs())
            if #bufs > 0 then
              vim.cmd("buffer " .. bufs[#bufs])
            else
              vim.cmd("enew")
            end
            vim.cmd("bdelete! " .. bufnr)
            if vim.g.is_ide and #bufs == 0 then
              Snacks.dashboard.open({ buf = 0, win = 0 })
            end
          end,
          separator_style = "thin",
          show_buffer_close_icons = true,
          show_close_icon = false,
        },
        highlights = require("catppuccin.special.bufferline").get_theme()(),
      }
    end,
  },
}
