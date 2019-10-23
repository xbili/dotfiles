let g:delimitMate_expand_cr=1

" DelimiteMate - Python
autocmd FileType python let b:delimitMate_nesting_quotes = ['"']

" Coc.nvim - remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Coc.nvim - remap keys for renaming
nmap <leader>rn <Plug>(coc-rename)

" Coc.nvim - remap keys for prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile
nmap <leader>af :Prettier<CR>

let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/bundle/vim-snippets/Ultisnips']
