fu! s:capslock_insert_leave() abort "{{{1
    " If we're permanently in capslock mode, don't do anything.
    if get(b:, 'capslock_permanently', 0)
    "                                  │
    "                                  └─ we're not by default:
    "                                     we're permanently in capslock mode,
    "                                     IFF we hit `c C-l` from normal mode,
    "                                     but not if we've hit `C-l` from insert mode
        return
    endif
    call capslock#disable('i', 0)
endfu

fu! capslock#disable(mode, permanently) abort "{{{1
    if a:mode == 'i'
        au! my_capslock
        aug! my_capslock
        if a:permanently
            unlet! b:capslock_permanently
        endif

    elseif a:mode == 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
             sil! exe 'cunmap <buffer> '.nr2char(i,1)
             sil! exe 'cunmap <buffer> '.nr2char(i+32,1)
            let i += 1
        endwhile
    endif

    " Since the capslock mode is local to a buffer, there's no need to update
    " all statuslines. Hence, no bang after `:redrawstatus`.
    redraws
endfu

fu! s:enable(mode, permanently) abort "{{{1
    if a:mode == 'i'
        augroup my_capslock
            au!
            au InsertLeave   * call s:capslock_insert_leave()
            au InsertCharPre * if s:is_capslock_active('i')
                            \|     let v:char = v:char ==# tolower(v:char)
                            \                 ?     toupper(v:char)
                            \                 :     tolower(v:char)
                            \| endif
        augroup END

        let b:capslock_permanently = a:permanently

    elseif a:mode == 'c'
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
    if a:mode == 'i'
        return exists('#my_capslock')
    elseif a:mode == 'c'
        return maparg('a', 'c') ==# 'A'
    endif
endfu

fu! capslock#status() abort "{{{1
    return s:is_capslock_active('i') ? '[Caps]' : ''
endfu

fu! capslock#toggle(mode, ...) abort "{{{1
    let permanently = a:0
    call call(s:is_capslock_active(a:mode) ? 'capslock#disable' : 's:enable', [a:mode, permanently])
    return ''
endfu
