set nocompatible              " be iMproved, required
set encoding=utf-8
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"

" --- Making Vim look good ---
Plugin 'altercation/vim-colors-solarized'
Plugin 'tomasr/molokai'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" ----- Vim as a programmer's text editor
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-git'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'rking/ag.vim'
Plugin 'editorconfig/editorconfig-vim'

" --- Completion
Plugin 'Raimondi/delimitMate'
Bundle "garbas/vim-snipmate"
Bundle "honza/vim-snippets"
Bundle "justinj/vim-react-snippets"

" --- Frontend
Plugin 'ap/vim-css-color'
Plugin 'beyondwords/vim-twig'
Plugin 'mattn/emmet-vim'
Bundle 'nikvdp/ejs-syntax'
Plugin 'Valloric/MatchTagAlways'

" --- JavaScript
Plugin 'burnettk/vim-angular'
Plugin 'pangloss/vim-javascript'
Plugin 'digitaltoad/vim-pug'

" --- JSX for React
Plugin 'mxw/vim-jsx'
Plugin 'jparise/vim-graphql'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

let g:solarized_termcolors=256
colorscheme solarized

set nowrap
set backspace=indent,eol,start
set autoindent
set copyindent
set number
set expandtab
set shiftwidth=4
set shiftround
set showmatch
set ignorecase
set smartcase
set smarttab
set hlsearch
set incsearch
set cursorline
set wrap
set relativenumber
set colorcolumn=80

set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set noerrorbells
set guifont=Meslo\ LG\ S\ for\ Powerline:h11
set guioptions-=r
set guioptions-=L

set nobackup
set noswapfile

set mouse=a

syntax enable
set background=dark

let g:delimitMate_expand_cr=1

" --- tabs for different code
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab

" --- ctrlp options
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_use_chaching = 1

" --- gitgutter options
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = 'o'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = 'w'

" --- jistr/vim-nerdtree-tabs ----
" Open/close NERDTree Tabs with \t
nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
" To have NERDTree always open on startup
let g:nerdtree_tabs_open_on_console_startup = 0
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.pyc$']

" --- airline options
let g:airline_powerline_fonts = 1
let g:airline_theme = 'dark'
set laststatus=2
set noshowmode

" --- mappings
nmap <F2> :%! python -m json.tool<CR>

