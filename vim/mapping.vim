" Search for visually selected word
vnoremap // y/<C-R>"<CR>

" Edit vimrc
:nnoremap <leader>ev :vsplit ~/.vimrc<cr>

" Source vimrc
:nnoremap <leader>sv :source ~/.vimrc<cr>

" Pretty format JSON
nmap <F2> :%! python -m json.tool<CR>

" Strip trailing whitespaces
nmap <F3> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Slimux mappings
nmap <F4> :SlimuxREPLSendLine<CR>
xmap <F4> :SlimuxREPLSendSelection<CR>
nmap <F6> :SlimuxREPLSendBuffer<CR>

" Open/close NERDTree Tabs with \t
nmap <silent> <leader>t :NERDTreeTabsToggle<CR>

" Open CtrlP with \.
nnoremap <leader>. :CtrlPTag<cr>

" Shortcut for ALEFix
:nnoremap <leader>af :ALEFix<cr>

" Supertabs
let g:SuperTabDefaultCompletionType = "<c-n>"
