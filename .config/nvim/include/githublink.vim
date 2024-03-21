fun! CopyGithubPermaLinkWithLineNumber() range
    let path = expand("%:p")
    if a:firstline == a:lastline
      call system('github-link --clip ' . path . ' ' . a:firstline)
    else
      call system('github-link --clip ' . path . ' ' . a:firstline . ' ' . a:lastline)
    endif
endfun
noremap <Leader>ll :call CopyGithubPermaLinkWithLineNumber()<CR>

fun! CopyGithubPermaLink() range
    let path = expand("%:p")
    call system('github-link --clip ' . path)
endfun
noremap <Leader>l :call CopyGithubPermaLink()<CR>
