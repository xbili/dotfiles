" Theme
syntax on
if strftime("%H") >= 9 && strftime("%H") < 19
  set background=dark
  colorscheme solarized
else
  set background=dark
  colorscheme solarized
endif

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

" Devicons
let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '
let g:WebDevIconsUnicodeDecorateFolderNodes = 1

" Airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
set laststatus=2
set noshowmode

" For italics
set t_ZH=[3m
set t_ZR=[23m
