" --- vim-go
au Filetype go nnoremap <leader>gdv :vsp <CR>:exe "GoDef" <CR>
au Filetype go nnoremap <leader>gds :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>gdt :tab split <CR>:exe "GoDef"<CR>
