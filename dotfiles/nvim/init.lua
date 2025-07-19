vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true -- spaces

require('config.lazy')

local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fj', telescope.git_files, { desc = 'Telescope jj files (currently git)' })

local neotest = require('neotest')
vim.keymap.set('n', '<leader>tt', function() neotest.run.run() end, { desc = "Run nearest test" })
vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run current file" })
vim.keymap.set('n', '<leader>ta', function() neotest.run.run(vim.fn.getcwd()) end, { desc = "Run all tests" })
vim.keymap.set('n', '<leader>to', function() neotest.output.open({ enter = true }) end, { desc = "Show test output" })
vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end, { desc = "Toggle test summary" })
