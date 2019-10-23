let g:go_bin_path = $HOME."/go/bin"
let g:go_def_mapping_enabled = 0

" --- vim-go
au Filetype go nnoremap <leader>gdv :vsp <CR>:exe "GoDef" <CR>
au Filetype go nnoremap <leader>gds :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>gdt :tab split <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>af :GoFmt<CR>

" Golang uses tabs!
au Filetype go set noet ci pi sts=0 sw=4 ts=4
