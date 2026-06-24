vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
