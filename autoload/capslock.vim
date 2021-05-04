vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# Init {{{1

# 0 = disabled, 1 = enabled until leaving insert mode, 2 = enabled permanently
var insert_caps: number = 0

# false = disabled, true = enabled until leaving command-line
var cmdline_caps: bool = false

# Interface {{{1
def capslock#toggle(mode: string): string #{{{2
    if mode == 'i'
        ++insert_caps
        insert_caps %= 3
        if insert_caps != 0
            Enable('i')
        else
            Disable('i')
        endif
        redraws
        redrawt
        return ''
    elseif mode == 'c'
        cmdline_caps = !cmdline_caps
        if cmdline_caps
            Enable('c')
            au CmdlineLeave [^=] ++once Disable('c')
        else
            Disable('c')
        endif
        redraws
        return getcmdline()
    endif
    return ''
enddef

def capslock#status(scope: string): string #{{{2
    if scope == 'buffer'
        return insert_caps == 1 || cmdline_caps ? '[Caps]' : ''
    else
        return insert_caps == 2 ? '[Caps]' : ''
    endif
enddef
#}}}1
# Core {{{1
def Enable(mode: string) #{{{2
    if mode == 'i'
        augroup MyCapslock | au!
            au InsertLeave   * if insert_caps != 2
                |     Disable('i')
                | endif
            au InsertCharPre * if insert_caps != 0
                |     v:char = v:char == tolower(v:char) ? toupper(v:char) : tolower(v:char)
                | endif
        augroup END

    elseif mode == 'c'
        var i: number = char2nr('A')
        while i <= char2nr('Z')
            exe 'cno <buffer> ' .. nr2char(i) .. ' ' .. nr2char(i + 32)
            exe 'cno <buffer> ' .. nr2char(i + 32) .. ' ' .. nr2char(i)
            ++i
        endwhile
    endif
enddef

def Disable(mode: string) #{{{2
    if mode == 'i' && exists('#MyCapslock')
        # Leave this block at the very beginning of the function.{{{
        #
        # If an error occurred in the function,  because of `abort`, the rest of the
        # statements would not be processed.
        # We want our autocmd to be cleared no matter what.
        #}}}
        au! MyCapslock
        aug! MyCapslock
        # We already update the value in `#toggle()`.  Why do it here again?{{{
        #
        # `#toggle()` is only invoked when we use our mapping.
        # But `Disable()` may also be invoked automatically by an autocmd.
        # If that happens, we need to make sure that the variable is updated.
        #}}}
        insert_caps = 0
    elseif mode == 'c' && !maparg('a', 'c')->empty()
        var i: number = char2nr('A')
        while i <= char2nr('Z')
             exe 'sil! cunmap <buffer> ' .. nr2char(i)
             exe 'sil! cunmap <buffer> ' .. nr2char(i + 32)
            ++i
        endwhile
        cmdline_caps = false
    endif
enddef

