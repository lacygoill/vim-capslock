fu! CapsLock_stl() abort "{{{1
    return s:is_active('i') ? '[Caps]' : ''
endfu

fu! s:capslock_insert_leave() abort "{{{1
    if !get(b:, 'capslock_permanent', 0)
        call s:disable('i', 0)
    endif
endfu

fu! s:disable(mode, persistent) abort "{{{1
    if a:mode == 'i'
        au! my_capslock
        aug! my_capslock
        if a:persistent
            unlet! b:capslock_permanent
        endif

    elseif a:mode == 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
             sil! exe a:mode.'unmap <buffer> '.nr2char(i)
             sil! exe a:mode.'unmap <buffer> '.nr2char(i+32)
            let i += 1
        endwhile
    endif

    " Since the capslock mode is local to a buffer, there's no need to update
    " all statuslines. Hence, no bang after `:redrawstatus`.
    redraws
endfu

fu! s:enable(mode, persistent) abort "{{{1
    if a:mode == 'i'
        augroup my_capslock
            au!
            au InsertLeave   * call s:capslock_insert_leave()
            au InsertCharPre *
                            \  if s:is_active('i')
                            \|     let v:char = v:char ==# tolower(v:char)
                            \?         toupper(v:char)
                            \:         tolower(v:char)
                            \| endif
        augroup END

        let b:capslock_permanent = a:persistent

    elseif a:mode == 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
            exe a:mode.'noremap <buffer> '.nr2char(i).' '.nr2char(i+32)
            exe a:mode.'noremap <buffer> '.nr2char(i+32).' '.nr2char(i)
            let i += 1
        endwhile
    endif

    redraws
endfu

fu! s:is_active(mode) abort "{{{1
    if a:mode == 'i'
        return exists('#my_capslock')
    else
        return maparg('a', a:mode) ==# 'A'
    endif
endfu

fu! capslock#toggle(mode, ...) abort "{{{1
    let persistent = a:0
    call s:{s:is_active(a:mode) ? 'disable' : 'enable'}(a:mode, persistent)
    return ''
endfu
