# adding this comment line
set-option -add global ui_options terminal_assistant=none
colorscheme palenight
# addhl global/ wrap
addhl global/ show-whitespaces -tab '│' -tabpad ' '
map global normal '#' :comment-line<ret>

add-highlighter global/ show-matching

hook global WinCreate ^[^*]+$ %{ add-highlighter window/ number-lines -hlcursor }

define-command dbq %{delete-buffer ; quit}
# Highlight the word under the cursor
declare-option -hidden regex curword
set-face global CurWord default,rgb:4a4a4a
hook global NormalIdle .* %{
  eval -draft %{
    try %{
      exec <space><a-i>w <a-k>\A\w+\z<ret>
      set-option buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
      set-option buffer curword ''
    }
  }
}
add-highlighter global/ dynregex '%opt{curword}' 0:CurWord

# trailing white-space
hook global BufWritePre .* %{ try %{ execute-keys -draft \%s\h+$<ret>d } }
# noexpandtab
# tabs and indent
hook global InsertChar \t %{ exec -draft -itersel h@ }
# map global insert <tab> '<a-;><a-gt>'
# map global insert <s-tab> '<a-;><a-lt>'
# set global indentwidth 2 if using spaces for indent (python)
set global indentwidth 0
set global tabstop 2

# Enable <tab>/<s-tab> for insert completion selection
# hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
# hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }
hook global InsertCompletionShow .* %{
    try %{
        # this command temporarily removes cursors preceded by whitespace;
        # if there are no cursors left, it raises an error, does not
        # continue to execute the mapping commands, and the error is eaten
        # by the `try` command so no warning appears.
        execute-keys -draft 'h<a-K>\h<ret>'
        map window insert <tab> <c-n>
        map window insert <s-tab> <c-p>
        hook -once -always window InsertCompletionHide .* %{
            unmap window insert <tab> <c-n>
            unmap window insert <s-tab> <c-p>
        }
    }
}

eval %sh{kak-lsp --kakoune -s $kak_session}
# lsp-enable
hook global WinSetOption filetype=(nim|fortran|python|vlang|c|cpp) %{
  lsp-enable-window
}


