return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "css", "bash", "python", "typescript" },
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = true },
  },
  config = function(_, opts)
    local status, configs = pcall(require, "nvim-treesitter.configs")
    if status then
      configs.setup(opts)
    end
  end,
}
