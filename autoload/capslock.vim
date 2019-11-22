if exists('g:autoloaded_capslock')
    finish
endif
let g:autoloaded_capslock = 1

" Init {{{1

" 0 = disabled, 1 = enabled until leaving insert mode, 2 = enabled permanently
let s:insert_caps = 0

" 0 = disabled, 1 = enabled until leaving command-line
let s:cmdline_caps = 0

" Interface {{{1
fu capslock#toggle(mode) abort "{{{2
    if a:mode is# 'i'
        let s:insert_caps += 1
        let s:insert_caps %= 3
        if s:insert_caps
            call s:enable('i')
        else
            call s:disable('i')
        endif
        let &l:ro = &l:ro
    elseif a:mode is# 'c'
        let s:cmdline_caps = ! s:cmdline_caps
        if s:cmdline_caps
            call s:enable('c')
        else
            call s:disable('c')
        endif
        redraws
        au CmdlineLeave * ++once call s:disable('c')
    endif
    return ''
endfu

fu capslock#status(scope) abort "{{{2
    if a:scope is# 'buffer'
        return s:insert_caps == 1 || s:cmdline_caps == 1 ? '[Caps]' : ''
    else
        return s:insert_caps == 2 ? '[Caps]' : ''
    endif
endfu
"}}}1
" Core {{{1
fu s:enable(mode) abort "{{{2
    if a:mode is# 'i'
        augroup my_capslock
            au!
            au InsertLeave   * call s:maybe_disable_on_insert_leave()
            au InsertCharPre * if s:insert_caps
                           \ |     let v:char = v:char is# tolower(v:char)
                           \                  ?     toupper(v:char)
                           \                  :     tolower(v:char)
                           \ | endif
        augroup END

    elseif a:mode is# 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
            exe 'cno <buffer> '..nr2char(i,1)..' '..nr2char(i+32,1)
            exe 'cno <buffer> '..nr2char(i+32,1)..' '..nr2char(i,1)
            let i += 1
        endwhile
    endif
endfu

fu s:disable(mode) abort "{{{2
    if a:mode is# 'i'
        " Leave this block at the very beginning of the function.{{{
        "
        " If an error occurred in the function,  because of `abort`, the rest of the
        " statements would not be processed.
        " We want our autocmd to be cleared no matter what.
        "}}}
        au! my_capslock
        aug! my_capslock
        " We already update the value in `#toggle()`. Why do it here again?{{{
        "
        " `#toggle()` is only invoked when we use our mapping.
        " But `s:disable()` may also be invoked automatically by an autocmd.
        " If that happens, we need to make sure that the variable is updated.
        "}}}
        let s:insert_caps = 0
    " Why `!empty(...)`?{{{
    "
    " Otherwise, when we debug Vim (`:set vbs=2 vfile=/tmp/log`),
    " the logfile contains too many errors:
    "
    "     E31: No such mapping~
    "     Error detected while processing function <SNR>123_disable:~
    "
    " This creates way too much noise, and makes us lose time finding what we're
    " really looking for.
    "}}}
    elseif a:mode is# 'c' && !empty(maparg('a', 'c'))
        let i = char2nr('A')
        while i <= char2nr('Z')
             sil! exe 'cunmap <buffer> '..nr2char(i,1)
             sil! exe 'cunmap <buffer> '..nr2char(i+32,1)
            let i += 1
        endwhile
        let s:cmdline_caps = 0
    endif
endfu

fu s:maybe_disable_on_insert_leave() abort "{{{2
    if s:insert_caps == 2 | return | endif
    call s:disable('i')
endfu

