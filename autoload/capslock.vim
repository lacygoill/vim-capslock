fu! CapsLock_stl() abort "{{{1
    return s:is_active('i') ? '[Caps]' : ''
endfu

fu! s:capslock_insert_leave() abort "{{{1
    " If we're permanently in capslock mode, don't do anything.
    if get(b: 'capslock_permanent', 0)
    "                               │
    "                               └─ we're not by default:
    "                                  we're PERMANENTLY in capslock mode,
    "                                  iff we hit `c C-l` from normal mode,
    "                                  but not if we've hit `C-l` from insert mode
        return
    endif
    call s:disable('i', 0)
endfu

fu! s:disable(mode, permanent) abort "{{{1
    if a:mode == 'i'
        au! my_capslock
        aug! my_capslock
        if a:permanent
            unlet! b:capslock_permanent
        endif

    elseif a:mode == 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
             sil! exe 'cunmap <buffer> '.nr2char(i)
             sil! exe 'cunmap <buffer> '.nr2char(i+32)
            let i += 1
        endwhile
    endif

    " Since the capslock mode is local to a buffer, there's no need to update
    " all statuslines. Hence, no bang after `:redrawstatus`.
    redraws
endfu

fu! s:enable(mode, permanent) abort "{{{1
    if a:mode == 'i'
        augroup my_capslock
            au!
            au InsertLeave   * call s:capslock_insert_leave()
            au InsertCharPre * if s:is_active('i')
                            \|     let v:char = v:char ==# tolower(v:char)
                            \?                      toupper(v:char)
                            \:                      tolower(v:char)
                            \| endif
        augroup END

        let b:capslock_permanent = a:permanent

    elseif a:mode == 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
            exe 'cno <buffer> '.nr2char(i).' '.nr2char(i+32)
            exe 'cno <buffer> '.nr2char(i+32).' '.nr2char(i)
            let i += 1
        endwhile
    endif

    redraws
endfu

fu! s:is_active(mode) abort "{{{1
    if a:mode == 'i'
        return exists('#my_capslock')
    else
        return maparg('a', 'c') ==# 'A'
    endif
endfu

fu! capslock#toggle(mode, ...) abort "{{{1
    let permanent = a:0
    call s:{s:is_active(a:mode) ? 'disable' : 'enable'}(a:mode, permanent)
    return ''
endfu
