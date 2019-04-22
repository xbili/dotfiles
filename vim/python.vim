autocmd Filetype python setlocal ts=4 sw=4 softtabstop=4 expandtab
autocmd Filetype htmldjango setlocal ts=2 sw=2 expandtab

" Highlight all the syntax in Python
let python_highlight_all=1

if jedi#init_python()
  function! s:jedi_auto_force_py_version() abort
    let g:jedi#force_py_version = pyenv#python#get_internal_major_version()
  endfunction
  augroup vim-pyenv-custom-augroup
    autocmd! *
    autocmd User vim-pyenv-activate-post   call s:jedi_auto_force_py_version()
    autocmd User vim-pyenv-deactivate-post call s:jedi_auto_force_py_version()
  augroup END
endif
