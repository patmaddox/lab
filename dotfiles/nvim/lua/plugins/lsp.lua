return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.elixirls.setup({
      cmd = { vim.fn.expand("~/.emacs.dev/dist/elixir-ls-v0.27.2/language_server.sh") },
    })
  end,
}
