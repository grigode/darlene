return {
  "AlphaTechnolog/pywal.nvim",
  name = "pywal",
  lazy = false,
  priority = 1000,
  config = function()
    local pywal = require("pywal")
    pywal.setup()
    vim.cmd("colorscheme pywal")

    -- High contrast solid background matching pywal theme
    local function set_solid_bg()
      local bg_color = "#0d1b1e"
      local colors_file = vim.fn.expand("~/.cache/wal/colors.sh")
      if vim.fn.filereadable(colors_file) == 1 then
        for line in io.lines(colors_file) do
          local bg = line:match("^background='(.-)'")
          if bg then
            bg_color = bg
            break
          end
        end
      end

      vim.api.nvim_set_hl(0, "Normal", { bg = bg_color })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = bg_color })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = bg_color })
    end

    set_solid_bg()

    -- Toggle background transparency shortcut (<leader>bg)
    local is_transparent = false
    vim.keymap.set("n", "<leader>bg", function()
      is_transparent = not is_transparent
      if is_transparent then
        vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
        print("Background: Transparent")
      else
        set_solid_bg()
        print("Background: Solid Dark")
      end
    end, { desc = "Toggle background transparency" })
  end,
}
