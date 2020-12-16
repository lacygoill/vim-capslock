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
        redraws | redrawt
        return ''
    elseif a:mode is# 'c'
        let s:cmdline_caps = !s:cmdline_caps
        if s:cmdline_caps
            call s:enable('c')
            au CmdlineLeave [^=] ++once call s:disable('c')
        else
            call s:disable('c')
        endif
        redraws
        return getcmdline()
    endif
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
        augroup MyCapslock | au!
            au InsertLeave   * if s:insert_caps != 2 | call s:disable('i') | endif
            au InsertCharPre * if s:insert_caps
                \ | let v:char = v:char is# tolower(v:char)
                \   ?     toupper(v:char)
                \   :     tolower(v:char)
                \ | endif
        augroup END

    elseif a:mode is# 'c'
        let i = char2nr('A')
        while i <= char2nr('Z')
            exe 'cno <buffer> ' .. nr2char(i) .. ' ' .. nr2char(i + 32)
            exe 'cno <buffer> ' .. nr2char(i + 32) .. ' ' .. nr2char(i)
            let i += 1
        endwhile
    endif
endfu

fu s:disable(mode) abort "{{{2
    if a:mode is# 'i' && exists('#MyCapslock')
        " Leave this block at the very beginning of the function.{{{
        "
        " If an error occurred in the function,  because of `abort`, the rest of the
        " statements would not be processed.
        " We want our autocmd to be cleared no matter what.
        "}}}
        au! MyCapslock
        aug! MyCapslock
        " We already update the value in `#toggle()`.  Why do it here again?{{{
        "
        " `#toggle()` is only invoked when we use our mapping.
        " But `s:disable()` may also be invoked automatically by an autocmd.
        " If that happens, we need to make sure that the variable is updated.
        "}}}
        let s:insert_caps = 0
    elseif a:mode is# 'c' && !maparg('a', 'c')->empty()
        let i = char2nr('A')
        while i <= char2nr('Z')
             sil! exe 'cunmap <buffer> ' .. nr2char(i)
             sil! exe 'cunmap <buffer> ' .. nr2char(i + 32)
            let i += 1
        endwhile
        let s:cmdline_caps = 0
    endif
endfu

