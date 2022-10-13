call plug#begin()
  Plug 'morhetz/gruvbox' "https://github.com/morhetz/gruvbox
  Plug 'preservim/nerdtree'
  Plug 'nvim-lualine/lualine.nvim'
  " If you want to have icons in your statusline choose one of these
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
  " or                                , { 'branch': '0.1.x' }
  Plug 'nvim-treesitter/nvim-treesitter'
  Plug 'sharkdp/fd'
  Plug 'nvim-telescope/telescope-file-browser.nvim'
  Plug 'dinhhuy258/git.nvim'
  Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'tomtom/tcomment_vim'
  Plug 'tpope/vim-rails'
  Plug 'tpope/vim-dispatch'
  Plug 'thoughtbot/vim-rspec'
  Plug 'tpope/vim-endwise'
  Plug 'vimwiki/vimwiki'
  Plug 'ervandew/supertab'
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/vim-vsnip'
  " post install (yarn install | npm install) then load plugin only for editing supported files
  Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
call plug#end()

set ruler
set number
syntax enable
set mouse=a
set tabstop=2
set shiftwidth=2

set termguicolors
set background=dark
colorscheme gruvbox

" Start NERDTree and put the cursor back in the other window.
" autocmd VimEnter * NERDTree | wincmd p

let mapleader = ','

" shortcuts for NERDTree
nnoremap <leader>ntfo :NERDTreeFocus<CR>
nnoremap <leader>nt :NERDTree<CR>
nnoremap <leader>ntt :NERDTreeToggle<CR>
nnoremap <leader>ntf :NERDTreeFind<CR>

" All generic shortcuts
nmap <leader>z :u<CR>
nmap <leader>Q :qa!<CR>
nmap <leader>q :bw<CR>
nnoremap <C-S-Up>   :m '<-2<CR>gv=gv
nnoremap <C-S-Down> :m '>+1<CR>gv=gv

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" setup all Lua based Neovim configs - e.g. lualine, git.nvim

lua << EOF
  require('lualine').setup({
    options = {
      icons_enabled = false,
    }
  })
  require('git').setup()
  require('nvim-web-devicons').setup()
  vim.opt.termguicolors = true
  -- Setup Bufferline
  require('bufferline').setup{}
  -- Setup Gitsings - not using often
  require('gitsigns').setup()
  -- Setup nvim-cmp - autoxomplete
  local cmp = require'cmp'
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })
  -- Setup Solargraph
  local nvim_lsp = require('lspconfig')
  local servers = {'solargraph'}
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = on_attach,
    }
  end
  require'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true
    },
  }
  -- Setup Telescope with webicons
  local status, telescope = pcall(require, "telescope")
  if (not status) then return end
  local actions = require('telescope.actions')
  local builtin = require("telescope.builtin")
  local function telescope_buffer_dir()
    return vim.fn.expand('%:p:h')
  end
  local fb_actions = require "telescope".extensions.file_browser.actions
  telescope.setup {
    defaults = {
      mappings = {
        n = {
          ["q"] = actions.close
        },
      },
    },
    extensions = {
      file_browser = {
        theme = "dropdown",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true,
        mappings = {
          -- your custom insert mode mappings
          ["i"] = {
            ["<C-w>"] = function() vim.cmd('normal vbd') end,
          },
          ["n"] = {
            -- your custom normal mode mappings
            ["N"] = fb_actions.create,
            ["h"] = fb_actions.goto_parent_dir,
            ["/"] = function()
              vim.cmd('startinsert')
            end
          },
        },
      },
    },
  }
  telescope.load_extension("file_browser")
  vim.keymap.set("n", "sf", function()
    telescope.extensions.file_browser.file_browser({
      path = "%:p:h",
      cwd = telescope_buffer_dir(),
      respect_gitignore = false,
      hidden = true,
      grouped = true,
      previewer = false,
      initial_mode = "normal",
      layout_config = { height = 40 }
    })
  end)
  -- keymaps
  vim.keymap.set('n', ';f',
    function()
      builtin.find_files({
        no_ignore = false,
        hidden = true
      })
    end)
  vim.keymap.set('n', ';r', function()
    builtin.live_grep()
  end)
  vim.keymap.set('n', '\\\\', function()
    builtin.buffers()
  end)
  vim.keymap.set('n', ';t', function()
    builtin.help_tags()
  end)
  vim.keymap.set('n', ';;', function()
    builtin.resume()
  end)
  vim.keymap.set('n', ';e', function()
    builtin.diagnostics()
  end)
EOF
