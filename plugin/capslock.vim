if exists('g:loaded_capslock')
    finish
endif
let g:loaded_capslock = 1

" do *not* name this augroup `my_capslock`; we already use this name in `autoload/`
augroup hoist_caps
    au!
    " In theory, the global capslock flag is not very volatile, so we should give it a low priority.{{{
    "
    " Something like 15.
    "
    " But  in  practice,  the  flag  *is*  volatile,  because  it's  temporarily
    " displayed whenever we've enabled the local capslock and want to disable it
    " without quitting insert mode; in that case we press `C-l` twice:
    "
    "    - first `C-l`: global flag temporarily displayed
    "    - second `C-l`: capslock disabled, and no flag anywhere (status line, tab line)
    "}}}
    au User MyFlags call statusline#hoist('global', '%{capslock#status("global")}', 35)
    au User MyFlags call statusline#hoist('buffer', '%{capslock#status("buffer")}', 55)
augroup END

cno <unique> <c-x>l <c-r>=capslock#toggle('c')<cr>
" see: `:h 'cot /ctrl-l`.
ino <expr><silent><unique> <c-l> pumvisible() ? '<c-l>' : capslock#toggle('i')
