return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar archivos" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar texto (grep)" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers abiertos" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Buscar ayuda" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Archivos recientes" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ❯ ",
        path_display = { "truncate" },
      },
    })
  end,
}
