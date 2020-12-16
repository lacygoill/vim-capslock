if exists('g:loaded_capslock')
    finish
endif
let g:loaded_capslock = 1

" do *not* name this augroup `MyCapslock`; we already use this name in `autoload/`
augroup HoistCaps | au!
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
    const s:SFILE = expand('<sfile>:p') .. ':'
    au User MyFlags call statusline#hoist('global',
        \ '%{capslock#status("global")}', 15, s:SFILE .. expand('<sflnum>'))
    au User MyFlags call statusline#hoist('buffer',
        \ '%{capslock#status("buffer")}', 25, s:SFILE .. expand('<sflnum>'))
augroup END

cno <unique> <c-x>l <c-\>e capslock#toggle('c')<cr>
" see: `:h 'cot /ctrl-l`.
ino <expr><unique> <c-l> pumvisible() ? '<c-l>' : capslock#toggle('i')
