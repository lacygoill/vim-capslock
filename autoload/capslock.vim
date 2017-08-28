fu! CapsLock_stl(...) abort "{{{1
    return s:is_active('i') ? '[Caps]' : ''
endfu

fu! s:capslock_leave_insert() abort "{{{1
    if !get(b:, 'capslock_persistent', 0)
        call s:disable('i')
    endif
endfu

fu! s:disable(mode) abort "{{{1
    if a:mode == 'i'
        au! my_capslock
        aug! my_capslock

    elseif a:mode == 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
             sil! exe a:mode.'unmap <buffer> '.nr2char(i)
             sil! exe a:mode.'unmap <buffer> '.nr2char(i+32)
            let i = i + 1
        endwhile
    endif

    redraws
    return ''
endfu

fu! s:enable(mode, ...) abort "{{{1
    if a:mode == 'i'
        augroup my_capslock
            au!
            au User Flags call Hoist('window', 'CapsLock_stl')
            au InsertLeave   * call s:capslock_leave_insert()
            au InsertCharPre *
                            \  if s:is_active('i')
                            \|     let v:char = v:char ==# tolower(v:char)
                            \?         toupper(v:char)
                            \:         tolower(v:char)
                            \| endif
        augroup END

        let b:capslock_persistent = a:0
    endif

    if a:mode == 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
            exe a:mode.'noremap <buffer> '.nr2char(i).' '.nr2char(i+32)
            exe a:mode.'noremap <buffer> '.nr2char(i+32).' '.nr2char(i)
            let i += 1
        endwhile
    endif
    redraws
    return ''
endfu

fu! s:is_active(mode) abort "{{{1
    if a:mode == 'i'
        return exists('#my_capslock')
    else
        return maparg('a', a:mode) == 'A'
    endif
endfu

fu! capslock#toggle(mode, ...) abort "{{{1
    let persistent = a:0

    if s:is_active(a:mode)
        return s:disable(a:mode)
    elseif persistent
        return s:enable(a:mode, 1)
    else
        return s:enable(a:mode)
    endif
endfu
