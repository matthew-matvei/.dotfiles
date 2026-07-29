vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- 1. Updated global function to gracefully scan CWD on startup
_G.get_current_project_root = function()
  local current_buf_path = vim.api.nvim_buf_get_name(0)
  local path_to_check

  -- If no file buffer is open (empty startup screen), look from the working directory
  if current_buf_path == "" then
    path_to_check = vim.fn.getcwd()
  else
    path_to_check = current_buf_path
  end

  -- Search for project markers starting from our decided path
  local root_path = vim.fs.root(path_to_check, { ".git", "Makefile", "package.json" })

  if root_path then
    -- Return just the project folder name
    return vim.fs.basename(root_path)
  else
    -- Final fallback: name of the folder you launched Neovim from
    return vim.fs.basename(vim.fn.getcwd())
  end
end

-- 2. Enable terminal titles
vim.opt.title = true

-- 3. Set your titlestring using the global Lua function
vim.opt.titlestring = "nvim - %<%t (%{v:lua.get_current_project_root()})"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
