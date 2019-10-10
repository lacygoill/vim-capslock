if exists('g:loaded_capslock')
    finish
endif
let g:loaded_capslock = 1

augroup disable_capslock_on_command_line
    au!
    au CmdlineLeave : call capslock#disable('c', 1)
augroup END

cno <unique> <c-x>l <c-r>=capslock#toggle('c')<cr>
" See: `:h 'cot /ctrl-l`.
ino <expr><silent><unique> <c-l> pumvisible() ? '<c-l>' : capslock#toggle('i')
nno <silent><unique> <c-g><c-l> :<c-u>call capslock#toggle('i', 1)<cr>
"                                                           │
"                   flag:  make capslock persist            ┘
"                          even after we leave insert mode
