function! SourceConfiguration(name)
    exec "source" "~/.vim/" . a:name . ".vim"
endfunction

call SourceConfiguration("ack")
call SourceConfiguration("ale")
call SourceConfiguration("autocomplete")
call SourceConfiguration("coverage")
call SourceConfiguration("ctrlp")
call SourceConfiguration("gitgutter")
call SourceConfiguration("go")
call SourceConfiguration("javascript")
call SourceConfiguration("mapping")
call SourceConfiguration("nerdtree")
call SourceConfiguration("plugins")
call SourceConfiguration("python")
call SourceConfiguration("theme")
