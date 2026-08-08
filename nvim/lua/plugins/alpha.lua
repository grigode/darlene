return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "                                                              ",
      "  ██████╗  █████╗ ██████╗ ██╗     ███████╗███╗   ██╗███████╗  ",
      "  ██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝████╗  ██║██╔════╝  ",
      "  ██║  ██║███████║██████╔╝██║     █████╗  ██╔██╗ ██║█████╗    ",
      "  ██║  ██║██╔══██║██╔══██╗██║     ██╔══╝  ██║╚██╗██║██╔══╝    ",
      "  ██████╔╝██║  ██║██║  ██║███████╗███████╗██║ ╚████║███████╗  ",
      "  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝  ",
      "                                                              ",
      "                                                              ",
    }

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find files", "<cmd>Telescope find_files<cr>"),
      dashboard.button("e", "  File explorer (Oil)", "<cmd>Oil<cr>"),
      dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("g", "  Find text (grep)", "<cmd>Telescope live_grep<cr>"),
      dashboard.button("q", "  Quit Neovim", "<cmd>qa<cr>"),
    }

    alpha.setup(dashboard.opts)
  end,
}
