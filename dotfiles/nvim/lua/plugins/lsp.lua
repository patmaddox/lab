return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.elixirls.setup({
      cmd = { vim.fn.expand("~/.emacs.dev/dist/elixir-ls-v0.27.2/language_server.sh") },
      on_attach = function(client, bufnr)
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("ElixirFormat", { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
      end,
    })

    lspconfig.clangd.setup({
      cmd = { "/usr/local/llvm19/bin/clangd" }
    })
  end,
}
