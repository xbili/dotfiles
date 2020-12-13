call plug#begin('~/.vim/plugged')

" --- Making Vim look good ---
Plug 'altercation/vim-colors-solarized'
Plug 'mhartington/oceanic-next'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-sensible'

" ----- Vim as a programmer's text editor
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tacahiroy/ctrlp-funky'
Plug 'tpope/vim-git'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'mileszs/ack.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'wincent/terminus'
Plug 'christianrondeau/vim-base64'
Plug 'janko-m/vim-test'
Plug 'junegunn/fzf.vim'
Plug 'kshenoy/vim-signature'
Plug 'honza/vim-snippets'

" --- Completion
Plug 'Raimondi/delimitMate'
Plug 'dense-analysis/ale'

" --- Golang
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" --- Frontend
Plug 'ap/vim-css-color'
Plug 'mattn/emmet-vim'
Plug 'stephenway/postcss.vim'
Plug 'hail2u/vim-css3-syntax'

" --- JavaScript
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'heavenshell/vim-jsdoc', { 'tag': '1.0.0' }
Plug 'ruanyl/coverage.vim'
Plug 'flowtype/vim-flow'
Plug 'jxnblk/vim-mdx-js'
Plug 'jparise/vim-graphql'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'branch': 'release/0.x'
  \ }
Plug 'ianks/vim-tsx'
Plug 'leafgarland/typescript-vim'


" --- Devicons
Plug 'ryanoasis/vim-devicons'

" --- Python
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'hdima/python-syntax'
Plug 'jmcomets/vim-pony'
Plug 'lambdalisue/vim-pyenv'

" --- Verilog
Plug 'vhda/verilog_systemverilog.vim'

" --- Zen Writing
Plug 'junegunn/goyo.vim'

" --- Interactive programming
Plug 'epeli/slimux'

call plug#end()
