if exists('g:loaded_capslock')
    finish
endif
let g:loaded_capslock = 1

cno          <unique>   <c-x>l       <c-r>=capslock#toggle('c')<cr>
ino  <silent><unique>   <c-l>        <c-r>=capslock#toggle('i')<cr>
nno  <silent><unique>  <c-g><c-l>   :<c-u>call capslock#toggle('i', 1)<cr>
"                                                               │
"                       flag:  make capslock persist            ┘
"                              even after we leave insert mode
