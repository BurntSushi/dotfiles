if exists("did_load_filetypes")
    finish
endif

augroup filetypedetect
  au! BufRead,BufNewFile
    \ *.go
    \ setfiletype go

  au! BufRead,BufNewFile
    \ *.rs
    \ setfiletype rust

  au! BufRead,BufNewFile
    \ *.hsc
    \ setfiletype haskell

  au! BufRead,BufNewFile
    \ *.t
    \ setfiletype lua

  au! BufRead,BufNewFile
    \ *.md
    \ setfiletype pandoc.markdown

  au! BufRead,BufNewFile
    \ *.mako
    \ setfiletype mako

  au! BufRead,BufNewFile
    \ *.wini
    \ setfiletype dosini

  au! BufRead,BufNewFile
    \ *.tpl
    \ setfiletype mako

  au! BufRead,BufNewFile
    \ *.h
    \ setfiletype c
  au! BufRead,BufNewFile
    \ *.imp,*.scm
    \ setfiletype lisp

  au! BufRead,BufNewFile
    \ *.grades
    \ setfiletype utln

  au! BufRead,BufNewFile
    \ mkfile*,*.mk
    \ setfiletype make

  au! BufRead,BufNewFile
    \ *.sig
    \ setfiletype sml

  au! BufRead,BufNew
    \ *.djt.html
    \ setfiletype htmldjango

  au! BufRead,BufNewFile
    \ *.tsv
    \ setfiletype tsv
augroup END

