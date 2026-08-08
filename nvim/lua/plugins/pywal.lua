return {
  "AlphaTechnolog/pywal.nvim",
  name = "pywal",
  lazy = false,
  priority = 1000,
  config = function()
    local pywal = require("pywal")
    pywal.setup()
    vim.cmd("colorscheme pywal")

    -- Load dynamic colors directly from Pywal's JSON cache
    local json_file = vim.fn.expand("~/.cache/wal/colors.json")
    if vim.fn.filereadable(json_file) == 1 then
      local f = io.open(json_file, "r")
      if f then
        local content = f:read("*a")
        f:close()
        local ok, data = pcall(vim.json.decode, content)
        if ok and data and data.colors then
          local c = data.colors
          local bg = data.special and data.special.background or c.color0
          local fg = data.special and data.special.foreground or c.color7

          -- Base UI & Borders
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg, fg = fg })
          vim.api.nvim_set_hl(0, "FloatBorder", { bg = bg, fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "LineNr", { fg = c.color8 })
          vim.api.nvim_set_hl(0, "CursorLine", { bg = c.color0 })
          vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "Search", { bg = c.color4, fg = bg, bold = true })
          vim.api.nvim_set_hl(0, "IncSearch", { bg = c.color2, fg = bg, bold = true })
          vim.api.nvim_set_hl(0, "Visual", { bg = c.color8, fg = fg })
          vim.api.nvim_set_hl(0, "VertSplit", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "WinSeparator", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })

          -- Code Syntax Highlighting
          vim.api.nvim_set_hl(0, "Comment", { fg = c.color8, italic = true })
          vim.api.nvim_set_hl(0, "Constant", { fg = c.color3, bold = true })
          vim.api.nvim_set_hl(0, "String", { fg = c.color2 })
          vim.api.nvim_set_hl(0, "Character", { fg = c.color2 })
          vim.api.nvim_set_hl(0, "Number", { fg = c.color3, bold = true })
          vim.api.nvim_set_hl(0, "Boolean", { fg = c.color3, bold = true })
          vim.api.nvim_set_hl(0, "Identifier", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "Function", { fg = c.color6, bold = true })
          vim.api.nvim_set_hl(0, "Statement", { fg = c.color5, bold = true })
          vim.api.nvim_set_hl(0, "Keyword", { fg = c.color5, bold = true })
          vim.api.nvim_set_hl(0, "Operator", { fg = c.color4 })
          vim.api.nvim_set_hl(0, "PreProc", { fg = c.color6 })
          vim.api.nvim_set_hl(0, "Type", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "Special", { fg = c.color6 })
          vim.api.nvim_set_hl(0, "Todo", { bg = c.color4, fg = bg, bold = true })

          -- Markdown Syntax & Headers
          vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = c.color5, bold = true })
          vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = c.color6, bold = true })
          vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = c.color2, bold = true })
          vim.api.nvim_set_hl(0, "@markup.list.markdown", { fg = c.color3, bold = true })
          vim.api.nvim_set_hl(0, "@markup.list.checked.markdown", { fg = c.color2, bold = true })
          vim.api.nvim_set_hl(0, "@markup.list.unchecked.markdown", { fg = c.color1, bold = true })
          vim.api.nvim_set_hl(0, "@markup.bold.markdown", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "@markup.italic.markdown", { fg = c.color6, italic = true })
          vim.api.nvim_set_hl(0, "@markup.link.label.markdown", { fg = c.color4, underline = true })
          vim.api.nvim_set_hl(0, "@markup.link.url.markdown", { fg = c.color6, underline = true })
          vim.api.nvim_set_hl(0, "@markup.raw.markdown", { fg = c.color2 })

          -- Classic Vim Markdown Fallbacks
          vim.api.nvim_set_hl(0, "markdownH1", { fg = c.color4, bold = true })
          vim.api.nvim_set_hl(0, "markdownH2", { fg = c.color5, bold = true })
          vim.api.nvim_set_hl(0, "markdownH3", { fg = c.color6, bold = true })
          vim.api.nvim_set_hl(0, "markdownListMarker", { fg = c.color3, bold = true })
          vim.api.nvim_set_hl(0, "markdownCode", { fg = c.color2 })
          vim.api.nvim_set_hl(0, "markdownBold", { fg = c.color4, bold = true })
        end
      end
    end
  end,
}
