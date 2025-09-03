return {
  'mrjones2014/smart-splits.nvim',
  lazy = false, -- Don't lazy load for tmux integration
  config = function()
    require('smart-splits').setup({
      ignored_filetypes = { 'nofile', 'quickfix', 'prompt' },
      ignored_buftypes = { 'nofile' },
    })
    
    vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
    vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
    vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
    vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
    vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)

    -- netrw binds C-l to refresh, which breaks smart splits
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'netrw',
      callback = function()
        vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right, { buffer = true, silent = true })
      end
    })
  end
}
