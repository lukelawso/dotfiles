local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Auto-install lazy.nvim if not present
if not vim.loop.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'L3MON4D3/LuaSnip'},
  {{"nvim-treesitter/nvim-treesitter", tag = 'v0.9.2', build = ":TSUpdate",
                config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = { "cpp", "lua", "python" },
                highlight = { enable = true, }
            }
        end }},
  {'nvim-telescope/telescope.nvim', tag = '0.1.6',
         dependencies = { 'nvim-lua/plenary.nvim' }},
 { 'alexghergh/nvim-tmux-navigation', config = function()

        local nvim_tmux_nav = require('nvim-tmux-navigation')

        nvim_tmux_nav.setup {
            disable_when_zoomed = false -- defaults to false
        }

        vim.keymap.set('n', "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
        vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
        vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
        vim.keymap.set('n', "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
        vim.keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
        vim.keymap.set('n', "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)

 end
},
{
    'terrortylor/nvim-comment',
    config = function()
        require('nvim_comment').setup({create_mappings = false})
     vim.keymap.set('v', '<C-_>', ':CommentToggle<CR>', {noremap = true, silent = true})
     vim.keymap.set('n', '<C-_>', ':CommentToggle<CR>', { noremap = true, silent = true })
    end
},
})

-- if you are using neovim v0.9 or lower
-- this colorscheme is better than the default
vim.cmd.colorscheme('habamax')

-- use system clipboard
vim.o.clipboard = "unnamedplus"

-- tab size
vim.opt.tabstop = 5
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.o.ignorecase = true
vim.o.smartcase = true

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- don't add this function in the `on_attach` callback.
-- `format_on_save` should run only once, before the language servers are active.
lsp_zero.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['clangd'] = {'cpp'},
        ['pylsp'] = {'py'},
  }
})

-- to learn how to use mason.nvim
-- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'clangd', 'pylsp', 'bzl'},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  }
})

local cmp = require('cmp')

cmp.setup({
    mapping = cmp.mapping.preset.insert({
           ['<CR>'] = cmp.mapping.confirm({select = false}),
           ['<C-j>'] = cmp.mapping.select_next_item(),
           ['<C-k>'] = cmp.mapping.select_prev_item(),
    }),
})

-- KEYBINDS:
-- nvim
vim.g.mapleader = ' '

vim.keymap.set('n', '<A-o>', ':ClangdSwitchSourceHeader<CR>', { noremap = true, silent = false })

-- TELESCOPE
-- defaults
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
-- new
vim.keymap.set('n', '<C-p>', builtin.git_files,{})
vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<C-n>', ":Telescope oldfiles<CR>", { noremap = true, silent = true })

local telescope = require('telescope')
local actions = require('telescope.actions')
telescope.setup {
    defaults = {
           mappings = {
                  i = {
                         ["<C-j>"] = actions.move_selection_next,
                         ["<C-k>"] = actions.move_selection_previous,
                  },
           },
    },
}



-- nvim-comment
vim.cmd([[
" when you enter a (new) buffer
augroup set-commentstring-ag
autocmd!
autocmd BufEnter *.cpp,*.h :lua vim.api.nvim_buf_set_option(0, "commentstring", "// %s")
" when you've changed the name of a file opened in a buffer, the file type may have changed
autocmd BufFilePost *.cpp,*.h :lua vim.api.nvim_buf_set_option(0, "commentstring", "// %s")
augroup END
]])

local function quickfix()
    vim.lsp.buf.code_action({
        filter = function(a) return a.isPreferred end,
        apply = true
    })
end

vim.keymap.set('n', '<leader>qf', quickfix, {silent = true, noremap = true})

