if exists('g:loaded_capslock')
    finish
endif
let g:loaded_capslock = 1

" do *not* name this augroup `my_capslock`; we already use this name in `autoload/`
augroup capslock_flag
    au!
    au User MyFlags call statusline#hoist('buffer', '%-7{capslock#status("buffer")}', 35)
    au User MyFlags call statusline#hoist('global', '%{capslock#status("global")}', -50)
augroup END

cno <unique> <c-x>l <c-r>=capslock#toggle('c')<cr>
" see: `:h 'cot /ctrl-l`.
ino <expr><silent><unique> <c-l> pumvisible() ? '<c-l>' : capslock#toggle('i')
