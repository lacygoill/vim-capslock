vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

# do *not* name this augroup `MyCapslock`; we already use this name in `autoload/`
augroup HoistCaps | au!
    # In theory, the global capslock flag is not very volatile, so we should give it a low priority.{{{
    #
    # Something like 15.
    #
    # But  in  practice,  the  flag  *is*  volatile,  because  it's  temporarily
    # displayed whenever we've enabled the local capslock and want to disable it
    # without quitting insert mode; in that case we press `C-l` twice:
    #
    #    - first `C-l`: global flag temporarily displayed
    #    - second `C-l`: capslock disabled, and no flag anywhere (status line, tab line)
    #}}}
    const SFILE: string = expand('<sfile>:p') .. ':'
    au User MyFlags statusline#hoist('global',
        \ '%{capslock#status("global")}', 15, SFILE .. expand('<sflnum>'))
    au User MyFlags statusline#hoist('buffer',
        \ '%{capslock#status("buffer")}', 25, SFILE .. expand('<sflnum>'))
augroup END

cno <unique> <c-x>l <c-\>e capslock#toggle('c')<cr>
# see: `:h 'completeopt /ctrl-l`.
ino <expr><unique> <c-l> pumvisible() ? '<c-l>' : capslock#toggle('i')
