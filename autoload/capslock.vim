fu! s:capslock_insert_leave() abort "{{{1
    " If we're permanently in capslock mode, don't do anything.
    if get(b:, 'capslock_permanently', 0)
    "                                  │
    "                                  └ we're not by default:
    "                                    we're permanently in capslock mode,
    "                                    IFF we hit `c C-l` from normal mode,
    "                                    but not if we've hit `C-l` from insert mode
        return
    endif
    call capslock#disable('i', 0)
endfu

fu! capslock#disable(mode, permanently) abort "{{{1
    if a:mode is# 'i'
        " Leave this block at the very beginning of the function.{{{
        "
        " If an error occurred in the function,  because of `abort`, the rest of the
        " statements would not be processed.
        " We want our autocmd to be cleared no matter what.
        "}}}
        au! my_capslock
        aug! my_capslock
        if a:permanently
            unlet! b:capslock_permanently
        endif
        " Since the capslock mode is local to a buffer, there's no need to update
        " all statuslines. Hence, no bang after `:redrawstatus`.
        redraws
    " Why `!empty(...)`?{{{
    "
    " Otherwise, when we debug Vim (`:set vbs=2 vfile=/tmp/log`),
    " the logfile contains too many errors:
    "
    "     E31: No such mapping
    "     Error detected while processing function capslock#disable:
    "
    " This creates way too much noise, and makes us lose time finding what we're
    " really looking for.
    "}}}
    elseif a:mode is# 'c' && !empty(maparg('a', 'c'))
        let i = char2nr('A')
        while i <= char2nr('Z')
             sil! exe 'cunmap <buffer> '.nr2char(i,1)
             sil! exe 'cunmap <buffer> '.nr2char(i+32,1)
            let i += 1
        endwhile
        redraws
    endif
    " Do *not* move `:redraws` outside the `if` block to put it here.{{{
    "
    " It would make the screen flicker in some circumstances.
    " For  example, when  you press  `gl`  to count  the  number of  lines in  a
    " function, or `SPC p` to format a paragraph.
    "
    " This is because  those mappings enter the command-line to  run a function,
    " and vim-capslock has installed this autocmd:
    "
    "     au CmdlineLeave : call capslock#disable('c', 1)
    "
    " As a result, `:redraws` would be  run UNconditionally whenever one of your
    " mapping enters the command-line, which may be undesirable.
    "
    " ---
    "
    " This kind of issue could be fixed by using the argument `<cmd>` in our mappings:
    " https://github.com/vim/vim/issues/4784
    "}}}
endfu

fu! s:enable(mode, permanently) abort "{{{1
    if a:mode is# 'i'
        augroup my_capslock
            au!
            au InsertLeave   * call s:capslock_insert_leave()
            au InsertCharPre * if s:is_capslock_active('i')
                           \ |     let v:char = v:char is# tolower(v:char)
                           \                  ?     toupper(v:char)
                           \                  :     tolower(v:char)
                           \ | endif
        augroup END

        let b:capslock_permanently = a:permanently

    elseif a:mode is# 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
            exe 'cno  <buffer>  '.nr2char(i,1).' '.nr2char(i+32,1)
            exe 'cno  <buffer>  '.nr2char(i+32,1).' '.nr2char(i,1)
            let i += 1
        endwhile
    endif

    redraws
endfu

fu! s:is_capslock_active(mode) abort "{{{1
    if a:mode is# 'i'
        return exists('#my_capslock')
    elseif a:mode is# 'c'
        return maparg('a', 'c') is# 'A'
    endif
endfu

fu! capslock#status() abort "{{{1
    return s:is_capslock_active('i') || s:is_capslock_active('c') ? '[Caps]' : ''
endfu

fu! capslock#toggle(mode, ...) abort "{{{1
    let permanently = a:0
    call call(s:is_capslock_active(a:mode) ? 'capslock#disable' : 's:enable', [a:mode, permanently])
    return ''
endfu
