" Import cost
augroup import_cost_auto_run
  autocmd!
  autocmd InsertLeave *.js,*.jsx,*.ts,*.tsx ImportCost
  autocmd BufEnter *.js,*.jsx,*.ts,*.tsx ImportCost
  autocmd CursorHold *.js,*.jsx,*.ts,*.tsx ImportCost
augroup END

" JSDocs
let g:jsdoc_enable_es6 = 1
let g:jsdoc_underscore_private = 1
let g:jsdoc_access_descriptions = 2

let g:javascript_plugin_flow = 1
let g:javascript_plugin_jsdoc = 1
