-- bootstrap lazy.nvim, LazyVim and your plugins
-- only set if NEOVIDE_CWD is set
if vim.fn.exists("neovide") == 1 and vim.fn.getenv("NEOVIDE_CWD") then
  vim.fn.chdir(vim.fn.getenv("NEOVIDE_CWD"))
end
require("config.lazy")
