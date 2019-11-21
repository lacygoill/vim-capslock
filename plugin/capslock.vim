if exists('g:loaded_capslock')
    finish
endif
let g:loaded_capslock = 1

" Do *not* name this augroup `my_capslock`; we already use this name in `autoload/`.
augroup my_capslock_interface
    au!
    au CmdlineLeave : call capslock#disable('c', 1)
    au User MyFlags call statusline#hoist('buffer', '%-7{capslock#status()}')
augroup END

cno <unique> <c-x>l <c-r>=capslock#toggle('c')<cr>
" See: `:h 'cot /ctrl-l`.
ino <expr><silent><unique> <c-l> pumvisible() ? '<c-l>' : capslock#toggle('i')
nno <silent><unique> <c-g><c-l> :<c-u>call capslock#toggle('i', 1)<cr>
"                                                           │
"                   flag:  make capslock persist            ┘
"                          even after we leave insert mode
