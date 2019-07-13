let g:delimitMate_expand_cr=1

" DelimiteMate - Python
autocmd FileType python let b:delimitMate_nesting_quotes = ['"']

if executable('flow')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'flow',
        \ 'cmd': {server_info->['flow', 'lsp']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), '.flowconfig'))},
        \ 'whitelist': ['javascript', 'javascript.jsx'],
        \ })
endif

let g:lsp_diagnostics_enabled = 0 
