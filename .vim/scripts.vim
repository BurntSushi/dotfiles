if did_filetype()
  finish
endif

if getline(1) =~ 'utln.*'
  setfiletype utln
endif
