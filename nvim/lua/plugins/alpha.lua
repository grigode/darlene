return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "                                                ",
      "  ███╗   ██╗██xFF  ███████╗██████╗ ██╗   ██╗███╗   ███╗ ",
      "  ████╗  ██║██║   ██╔════╝██╔══██╗██║   ██║████╗ ████║ ",
      "  ██╔██╗ ██║██║   █████╗  ██║  ██║██║   ██║██╔████╔██║ ",
      "  ██║╚██╗██║██║   ██╔══╝  ██║  ██║██║   ██║██║╚██╔╝██║ ",
      "  ██║ ╚████║██║   ███████╗██████╔╝╚██████╔╝██║ ╚═╝ ██║ ",
      "  ╚═╝  ╚═══╝╚═╝   ╚══════╝╚═════╝  ╚═════╝ ╚═╝     ╚═╝ ",
      "                                                ",
      "               ⚡ HACKER EDITION ⚡              ",
    }

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Buscar archivos", "<cmd>Telescope find_files<cr>"),
      dashboard.button("e", "  Explorador de archivos (Oil)", "<cmd>Oil<cr>"),
      dashboard.button("r", "  Archivos recientes", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("g", "  Buscar texto (grep)", "<cmd>Telescope live_grep<cr>"),
      dashboard.button("q", "  Salir de Neovim", "<cmd>qa<cr>"),
    }

    alpha.setup(dashboard.opts)
  end,
}
