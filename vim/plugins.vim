" set the runtime path to include Vundle and initialize
set rtp+=$HOME/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"

" --- Making Vim look good ---
Plugin 'altercation/vim-colors-solarized'
Plugin 'mhartington/oceanic-next'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-sensible'

" ----- Vim as a programmer's text editor
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tacahiroy/ctrlp-funky'
Plugin 'tpope/vim-git'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'mileszs/ack.vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'wincent/terminus'
Plugin 'christianrondeau/vim-base64'
Plugin 'janko-m/vim-test'
Plugin 'junegunn/fzf.vim'

" --- Completion
Plugin 'Raimondi/delimitMate'
Plugin 'w0rp/ale'
Plugin 'prabirshrestha/asyncomplete.vim'
Plugin 'prabirshrestha/async.vim'
Plugin 'prabirshrestha/vim-lsp'
Plugin 'prabirshrestha/asyncomplete-lsp.vim'

" --- Frontend
Plugin 'ap/vim-css-color'
Plugin 'mattn/emmet-vim'
Bundle 'nikvdp/ejs-syntax'

" --- JavaScript
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'styled-components/vim-styled-components'
Plugin 'heavenshell/vim-jsdoc'
Plugin 'leafgarland/typescript-vim'
Plugin 'peitalin/vim-jsx-typescript'
Plugin 'ruanyl/coverage.vim'
Plugin 'flowtype/vim-flow'
Plugin 'jxnblk/vim-mdx-js'
Plugin 'jparise/vim-graphql'

" --- Devicons
Plugin 'ryanoasis/vim-devicons'

" --- Python
Plugin 'Vimjas/vim-python-pep8-indent'
Plugin 'hdima/python-syntax'
Plugin 'jmcomets/vim-pony'
Plugin 'lambdalisue/vim-pyenv'
Plugin 'davidhalter/jedi-vim'
Plugin 'deoplete-plugins/deoplete-jedi'

" --- Verilog
Plugin 'vhda/verilog_systemverilog.vim'

" --- Zen Writing
Plugin 'junegunn/goyo.vim'

" --- Interactive programming
Plugin 'epeli/slimux'

" --- Golang
" Plugin 'fatih/vim-go'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
" filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
