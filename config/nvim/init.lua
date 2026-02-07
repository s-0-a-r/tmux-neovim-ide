-- ==========================================================
-- Neovim Configuration
-- ==========================================================

-- Leader key (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ==========================================================
-- Core Options
-- ==========================================================
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.pumheight = 10
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

opt.updatetime = 250
opt.timeoutlen = 300
opt.completeopt = "menu,menuone,noselect"
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.wrap = false
opt.fillchars = { eob = " " }

-- ==========================================================
-- Minimal Keymaps (no Cmd keys yet)
-- ==========================================================
local map = vim.keymap.set

-- Window navigation (Ctrl+h/j/k/l - works with vim-tmux-navigator)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Tab / Buffer navigation
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous tab" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next tab" })

-- Line operations (Alt+J/K = move)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

-- Indenting (keep selection)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Comment toggle (Cmd+/)
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<D-/>", "gc", { remap = true, desc = "Toggle comment" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Terminal mode
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- ==========================================================
-- IDE mode: auto-open file tree + terminals (NVIM_IDE=1)
-- ==========================================================
vim.g.is_ide = vim.env.NVIM_IDE == "1"
vim.env.NVIM_IDE = nil -- prevent child processes (e.g. git commit) from inheriting

if vim.g.is_ide then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.defer_fn(function()
        -- レイアウト構築
        vim.cmd("Neotree show filesystem")
        vim.cmd("wincmd l")
        local editor_win = vim.api.nvim_get_current_win()
        Snacks.terminal.toggle(nil, {
          env = { SNACKS_TERM = "bottom" },
          win = { position = "bottom", height = 0.3 },
        })
        Snacks.terminal.toggle(nil, {
          env = { SNACKS_TERM = "right" },
          win = { position = "right", width = 0.3 },
        })
        vim.api.nvim_set_current_win(editor_win)
        vim.cmd("stopinsert")
        Snacks.dashboard.open({ buf = 0, win = 0 })
      end, 200)
    end,
  })
end

-- ==========================================================
-- Bootstrap lazy.nvim
-- ==========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================
-- Load plugins
-- ==========================================================
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
