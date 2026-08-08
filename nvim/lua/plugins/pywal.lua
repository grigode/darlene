return {
  "AlphaTechnolog/pywal.nvim",
  name = "pywal",
  lazy = false,
  priority = 1000,
  config = function()
    local pywal = require("pywal")
    pywal.setup()
    vim.cmd("colorscheme pywal")
  end,
}
