" Some quick hacks to automatically insert line-by-line comments of highlighted
" source code. This requires that the Comment and EndComment variables are set,
" usually via include/lang.vim.

if !exists("b:Comment")
    let b:Comment="" | let b:EndComment=""
endif

fun! RegexLiteral(str)
    return escape(a:str, "*$.^/")
endfun

fun! CommentLines()
    if b:Comment != ""
        exe ":s/^\\(\\s*\\)/\\1".escape(b:Comment, '/')." /e"
        exe ":s/$/ ".escape(b:EndComment, '/')."/e"
    endif
endfun

fun! UncommentLines()
    exe ":s/^\\(\\s*\\)".RegexLiteral(b:Comment)."\\s*/\\1/e"
    exe ":s/\\s*".RegexLiteral(b:EndComment)."\\s*$//e"
endfun

noremap ,, :call CommentLines()<CR>
noremap ,. :call UncommentLines()<CR>
