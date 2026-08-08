return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open Oil explorer" },
    { "<leader>pv", "<cmd>Oil<cr>", desc = "File explorer" },
  },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = {
        "icon",
        "permissions",
        "size",
      },
      view_options = {
        show_hidden = true,
      },
    })
  end,
}
