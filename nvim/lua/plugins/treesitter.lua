return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "c", "cpp", "rust", "go", "cmake", "toml", "zig", "asm",
      "javascript", "typescript", "tsx", "html", "css", "json", "yaml",
      "python", "bash", "lua", "vim", "vimdoc", "markdown", "markdown_inline"
    },
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
