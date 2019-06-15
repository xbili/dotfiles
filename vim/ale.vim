" --- ALE
let g:ale_linters = {
\   'javascript': ['eslint', 'flow'],
\   'python': ['pylint'],
\}
let g:ale_fixers = {
\    'javascript': ['prettier'],
\    'json': ['prettier'],
\    'css': ['prettier'],
\    'go': ['gofmt', 'goimports'],
\}
" Only run linters named in ale_linters settings.
let g:ale_linters_explicit = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0

" Do not change directory on my behalf
let g:ale_python_pylint_change_directory = 0
