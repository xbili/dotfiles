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
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" --- Completion
Plug 'Raimondi/delimitMate'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" --- Golang
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" --- Frontend
Plug 'ap/vim-css-color'
Plug 'mattn/emmet-vim'
Plug 'stephenway/postcss.vim'
Plug 'hail2u/vim-css3-syntax'

" --- JavaScript
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'styled-components/vim-styled-components'
Plug 'heavenshell/vim-jsdoc'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'ruanyl/coverage.vim'
Plug 'flowtype/vim-flow'
Plug 'jxnblk/vim-mdx-js'
Plug 'jparise/vim-graphql'

" --- Devicons
Plug 'ryanoasis/vim-devicons'

" --- Python
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'hdima/python-syntax'
Plug 'jmcomets/vim-pony'
Plug 'lambdalisue/vim-pyenv'
Plug 'davidhalter/jedi-vim'
Plug 'deoplete-plugins/deoplete-jedi'

" --- Verilog
Plug 'vhda/verilog_systemverilog.vim'

" --- Zen Writing
Plug 'junegunn/goyo.vim'

" --- Interactive programming
Plug 'epeli/slimux'

call plug#end()
