return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local pywal_theme = "pywal"

    -- Load dynamic colors directly for a bold, vibrant Lualine bar
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

          pywal_theme = {
            normal = {
              a = { bg = c.color4, fg = bg, gui = "bold" },
              b = { bg = c.color8, fg = fg },
              c = { bg = bg, fg = fg },
            },
            insert = {
              a = { bg = c.color2, fg = bg, gui = "bold" },
              b = { bg = c.color8, fg = fg },
              c = { bg = bg, fg = fg },
            },
            visual = {
              a = { bg = c.color5, fg = bg, gui = "bold" },
              b = { bg = c.color8, fg = fg },
              c = { bg = bg, fg = fg },
            },
            replace = {
              a = { bg = c.color1, fg = bg, gui = "bold" },
              b = { bg = c.color8, fg = fg },
              c = { bg = bg, fg = fg },
            },
            command = {
              a = { bg = c.color3, fg = bg, gui = "bold" },
              b = { bg = c.color8, fg = fg },
              c = { bg = bg, fg = fg },
            },
            inactive = {
              a = { bg = bg, fg = c.color8 },
              b = { bg = bg, fg = c.color8 },
              c = { bg = bg, fg = c.color8 },
            },
          }
        end
      end
    end

    require("lualine").setup({
      options = {
        theme = pywal_theme,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", fmt = function(str) return "󰀘 " .. str end } },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
