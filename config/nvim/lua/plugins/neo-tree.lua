return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = { "Neotree" },
    keys = {
      -- VSCode macOS: Cmd+Shift+E = Toggle explorer, Cmd+B = Toggle sidebar
      { "<D-S-e>", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
      { "<D-b>", "<cmd>Neotree toggle<cr>", desc = "Toggle Sidebar" },
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
      { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus Explorer" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
          -- VSCode-like tree keybindings
          ["<cr>"] = "open",              -- Enter = open file
          ["l"] = "open",                 -- l = open (vim-style)
          ["h"] = "close_node",           -- h = collapse (vim-style)
          ["a"] = { "add", config = { show_path = "relative" } },  -- New file
          ["A"] = "add_directory",        -- New folder
          ["d"] = "delete",              -- Delete
          ["r"] = "rename",             -- Rename (VSCode: F2)
          ["y"] = "copy_to_clipboard",   -- Copy
          ["x"] = "cut_to_clipboard",    -- Cut
          ["p"] = "paste_from_clipboard", -- Paste
          ["c"] = "copy",               -- Copy to path
          ["m"] = "move",               -- Move to path
          ["."] = "toggle_hidden",       -- Toggle dotfiles
          ["/"] = "fuzzy_finder",        -- Search in tree
          ["<C-c>"] = "close_window",    -- Close explorer
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
    },
  },
}
