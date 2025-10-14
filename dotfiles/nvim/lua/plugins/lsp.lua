return {
  "neovim/nvim-lspconfig",
  config = function()
    -- Configure elixirls
    vim.lsp.config.elixirls = {
      cmd = { vim.fn.expand("~/.emacs.dev/dist/elixir-ls-v0.27.2/language_server.sh") },
      filetypes = { "elixir", "eelixir", "heex", "surface" },
      root_dir = vim.fs.root(0, { "mix.exs" }),
    }

    -- Configure clangd
    vim.lsp.config.clangd = {
      cmd = { "/usr/local/llvm19/bin/clangd" },
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      root_dir = vim.fs.root(0, { ".git", "compile_commands.json", "compile_flags.txt" }),
    }

    -- Enable LSP servers
    vim.lsp.enable({ "elixirls", "clangd" })

    -- Set up format on save for Elixir files
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("ElixirFormat", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "elixirls" and client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
      end,
    })
  end,
}
