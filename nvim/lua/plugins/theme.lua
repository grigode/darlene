return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- mocha (darkest cyberpunk hacker style)
        transparent_background = true,
        term_colors = true,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          functions = { "bold" },
          keywords = { "bold" },
          numbers = { "bold" },
          booleans = { "bold" },
          types = { "bold" },
        },
        custom_highlights = function(colors)
          return {
            Comment = { fg = colors.overlay1, style = { "italic" } },
            LineNr = { fg = colors.surface2 },
            CursorLineNr = { fg = colors.lavender, style = { "bold" } },
            FloatBorder = { fg = colors.blue, style = { "bold" } },
            WinSeparator = { fg = colors.blue, style = { "bold" } },
          }
        end,
        default_integrations = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          telescope = { enabled = true },
          which_key = true,
          mason = true,
          native_lsp = {
            enabled = true,
          },
        },
      })

      vim.cmd.colorscheme("catppuccin-mocha")

      -- Shortcut to toggle background transparency (<leader>bg)
      local transparent = true
      vim.keymap.set("n", "<leader>bg", function()
        transparent = not transparent
        require("catppuccin").setup({ transparent_background = transparent })
        vim.cmd.colorscheme("catppuccin-mocha")
        if transparent then
          print("Background: Transparent")
        else
          print("Background: Solid Catppuccin Mocha")
        end
      end, { desc = "Toggle background transparency" })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "night", transparent = true },
  },
}
