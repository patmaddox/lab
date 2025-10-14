return {
  "dhruvasagar/vim-table-mode",
  ft = { "markdown", "text", "org" },
  config = function()
    -- Table mode corner character for markdown tables
    vim.g.table_mode_corner = "|"

    -- Enable markdown-compatible tables
    vim.g.table_mode_markdown_compatible_tables = 1

    -- Fill cells with dashes to match cell width
    vim.g.table_mode_fillchar = "-"

    -- Disable default mappings if you want to set your own
    -- vim.g.table_mode_disable_mappings = 1
  end,
}
