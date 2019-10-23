function! SourceConfiguration(name)
    exec "source" "~/.vim/" . a:name . ".vim"
endfunction

call SourceConfiguration("plugins")
call SourceConfiguration("autocomplete")
call SourceConfiguration("theme")
call SourceConfiguration("ack")
call SourceConfiguration("fzf")
call SourceConfiguration("coverage")
call SourceConfiguration("ctrlp")
call SourceConfiguration("gitgutter")
call SourceConfiguration("go")
call SourceConfiguration("javascript")
call SourceConfiguration("mapping")
call SourceConfiguration("nerdtree")
call SourceConfiguration("python")
