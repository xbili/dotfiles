" --- ctrlp options
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'FZF'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git|dist'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_use_caching = 1
let g:ctrlp_working_path_mode = 1
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40
