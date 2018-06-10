set nocompatible              " be iMproved, required
set encoding=utf8
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
Plugin 'mhartington/oceanic-next'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" ----- Vim as a programmer's text editor
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-git'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'mileszs/ack.vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'wincent/terminus'
Plugin 'w0rp/ale'

" --- Completion/Snippets
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'Raimondi/delimitMate'

" --- Frontend
Plugin 'ap/vim-css-color'
Plugin 'mattn/emmet-vim'
Bundle 'nikvdp/ejs-syntax'

" --- JavaScript
Plugin 'digitaltoad/vim-pug'
Plugin 'othree/yajs.vim'
Plugin 'othree/es.next.syntax.vim'
Plugin 'othree/javascript-libraries-syntax.vim'
Plugin 'flowtype/vim-flow'
Plugin 'rschmukler/pangloss-vim-indent'

" --- JSX for React
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'epilande/vim-react-snippets'

" --- Devicons
Plugin 'ryanoasis/vim-devicons'

" --- Python
Plugin 'Vimjas/vim-python-pep8-indent'
Plugin 'hdima/python-syntax'
Plugin 'davidhalter/jedi-vim'
Plugin 'tweekmonster/django-plus.vim'

" --- Verilog
Plugin 'vhda/verilog_systemverilog.vim'

" --- Zen Writing
Plugin 'junegunn/goyo.vim'

" --- Interactive programming
Plugin 'epeli/slimux'

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
"
"

" Theme

syntax on
set background=dark
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
set wrap
set relativenumber
set colorcolumn=80
set linespace=3
set cursorline

set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set noerrorbells
set guioptions-=r
set guioptions-=L

set nobackup
set noswapfile

set mouse=a

let g:delimitMate_expand_cr=1

" --- tabs for different code
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype htmldjango setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype eruby setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype python setlocal ts=4 sw=4 expandtab
autocmd Filetype scss setlocal ts=2 sw=2 expandtab
autocmd Filetype yaml setlocal ts=2 sw=2 expandtab

" --- ack options
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" --- ctrlp options
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'
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
let NERDTreeIgnore=['node_modules', '\.pyc$', '.DS_Store', '\.class$', '__pycache__']

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
exec 'autocmd FileType nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
exec 'autocmd FileType nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('py', 'green', 'none', '#75A8D4', 'NONE')
call NERDTreeHighlightFile('jade', 'green', 'none', 'green', 'NONE')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', 'NONE')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', 'NONE')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', 'NONE')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', 'NONE')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', 'NONE')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', 'NONE')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', 'NONE')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', 'NONE')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', 'NONE')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', 'NONE')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', 'NONE')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', 'NONE')
call NERDTreeHighlightFile('ds_store', 'Gray', 'none', '#686868', 'NONE')
call NERDTreeHighlightFile('gitconfig', 'Gray', 'none', '#686868', 'NONE')
call NERDTreeHighlightFile('gitignore', 'Gray', 'none', '#686868', 'NONE')
call NERDTreeHighlightFile('bashrc', 'Gray', 'none', '#686868', 'NONE')
call NERDTreeHighlightFile('bashprofile', 'Gray', 'none', '#686868', 'NONE')


" --- Devicons
let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '

" --- airline options
let g:airline_powerline_fonts = 1
let g:airline_theme='oceanicnext'
set laststatus=2
set noshowmode

" --- mappings

" Pretty format JSON
nmap <F2> :%! python -m json.tool<CR>

" Strip trailing whitespaces
nmap <F3> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" --- Python
let python_highlight_all = 1
let g:ultisnips_python_style = 'google'

" Use yapf to format our Python code
autocmd FileType python nnoremap <leader>y :0,$!yapf<Cr><C-o>

" --- Javascript
let g:jsx_ext_required = 0 " Allow JSX in normal JS files
let g:xml_syntax_folding = 0
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_flow = 1
let g:used_javascript_libs = 'react,underscore'
let g:flow#enable = 1

" --- Ultisnips
let g:UltiSnipsExpandTrigger       = "<c-j>"
let g:UltiSnipsJumpForwardTrigger  = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-p>"
let g:UltiSnipsListSnippets        = "<c-k>" "List possible snippets based on current file
