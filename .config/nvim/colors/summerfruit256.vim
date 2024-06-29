" Vim color file
" Current Maintainer: Andrew Gallant
" Original Maintainer: Martin Baeuml <baeuml@gmail.com>
"
" Original header:
"
" This color file is a modification of the "summerfruit" color scheme by Armin
" Ronacher so that it can be used on 88- and 256-color xterms. The colors are
" translated using Henry So's programmatic approximation of gui colors from his
" "desert256" color scheme.
"
" I removed the "italic" option and the background color from comment-coloring
" because that looks odd on my console.
"
" The original "summerfruit" color scheme and "desert256" are available from
" vim.org.
"
" Updates:
"
" I (burntsushi) have periodically updated this file to include tweaks in
" the coloring. However, in June 2024, a neovim update changed its default
" color scheme.[1] In turns out that this colorscheme relies on aspects of the
" default colorscheme. There is supposed to be work-arounds... Like running
" `colorscheme vim` after `hi clear`, but I couldn't get it to work.
"
" So I basically just re-did the entire thing. And cut out a bunch of weird
" functions whose purpose I don't understand.
"
" [1]: https://github.com/neovim/neovim/issues/26378

set background=light
hi clear
if exists("syntax_on")
    syntax reset
endif
colorscheme vim
let g:colors_name="summerfruit256"

" Restore default vim colors.
hi ErrorMsg       ctermfg=15 ctermbg=1 guifg=White guibg=Red
hi Question       ctermfg=2 gui=bold guifg=SeaGreen
hi TermCursor     cterm=reverse gui=reverse
hi ColorColumn    guibg=LightRed
hi Error          ctermfg=231 ctermbg=160 guifg=#ffffff guibg=#d40000
hi Todo           cterm=bold ctermfg=160 ctermbg=194 gui=bold guifg=#e50808 guibg=#dbf3cd
hi String         ctermfg=32 guifg=#0086d2
hi Constant       ctermfg=32 guifg=#0086d2
hi Number         ctermfg=33 guifg=#0086f7
hi Function       ctermfg=198 guifg=#ff0086
hi Identifier     ctermfg=198 guifg=#ff0086
hi Statement      ctermfg=202 gui=bold guifg=#fb660a
hi Label          ctermfg=198 guifg=#ff0086
hi PreProc        ctermfg=196 guifg=#ff0007
hi Type           ctermfg=65 gui=bold guifg=#70796b
hi Special        cterm=bold ctermfg=208 gui=bold guifg=#eb7f00
hi Visual         ctermbg=7 guibg=#dddddd
hi LineNr         ctermfg=130 guifg=Brown
hi StatusLine     cterm=bold gui=bold guifg=#ffffff guibg=#43c464
hi StatusLineNC   cterm=reverse gui=reverse guifg=#9bd4a9 guibg=#51b069
hi WarningMsg     ctermfg=1 guifg=Red
hi Search         guibg=NvimDarkGrey1 guifg=NvimLightYellow
hi CurSearch      guibg=#dddddd guifg=NvimDarkYellow
hi Conceal        ctermfg=7 ctermbg=242 guifg=#ffffff guibg=DarkGrey
hi Pmenu          ctermfg=16 ctermbg=195 guifg=#000000 guibg=#e8ebff
hi PmenuSel       ctermfg=231 ctermbg=16 guifg=#ffffff guibg=#000000
hi PmenuSbar      ctermbg=248 guibg=Grey
hi PmenuThumb     ctermbg=0 guibg=Black
hi CursorLineNr   cterm=underline ctermfg=130 gui=bold guifg=Brown
hi CursorColumn   ctermbg=7 guibg=Grey90
hi CursorLine     cterm=underline ctermbg=153 guibg=#c0d9eb
hi Cursor         guifg=bg guibg=fg
hi lCursor        guifg=bg guibg=fg
hi link IncSearch      Search
hi link CursorLineSign SignColumn
hi link CursorLineFold FoldColumn
hi link StorageClass   Type
hi link Conditional    Statement
hi link Boolean        Constant
hi link Float          Number
hi link Character      Constant
hi link SpecialChar    Special
hi link Delimiter      Special
hi link SpecialComment Special
hi link Debug          Special
hi link Structure      Type
hi link Typedef        Type
hi link Tag            Special
hi link Define         PreProc
hi link Macro          PreProc
hi link PreCondit      PreProc
hi link Operator       Statement
hi link Keyword        Statement
hi link Exception      Statement
hi link Include        PreProc
hi link Repeat         Statement
hi link Substitute     Search
hi link PmenuKind      Pmenu
hi link PmenuKindSel   PmenuSel
hi link PmenuExtra     Pmenu
hi link PmenuExtraSel  PmenuSel

" More carry over from when before neovim changed its default colorscheme and
" fucked everything up.
hi DiagnosticError           ctermfg=1 guifg=Red
hi DiagnosticWarn            ctermfg=3 guifg=Orange
hi DiagnosticInfo            ctermfg=4 guifg=LightBlue
hi DiagnosticHint            ctermfg=7 guifg=LightGrey
hi DiagnosticOk              ctermfg=10 guifg=LightGreen
hi DiagnosticUnderlineError  cterm=underline gui=underline guisp=Red
hi DiagnosticUnderlineWarn   cterm=underline gui=underline guisp=Orange
hi DiagnosticUnderlineInfo   cterm=underline gui=underline guisp=LightBlue
hi DiagnosticUnderlineHint   cterm=underline gui=underline guisp=LightGrey
hi DiagnosticUnderlineOk     cterm=underline gui=underline guisp=LightGreen
hi DiagnosticDeprecated      cterm=strikethrough gui=strikethrough guisp=Red

hi link DiagnosticVirtualTextError DiagnosticError
hi link DiagnosticVirtualTextWarn  DiagnosticWarn
hi link DiagnosticVirtualTextInfo  DiagnosticInfo
hi link DiagnosticVirtualTextHint  DiagnosticHint
hi link DiagnosticVirtualTextOk    DiagnosticOk
hi link DiagnosticFloatingError    DiagnosticError
hi link DiagnosticFloatingWarn     DiagnosticWarn
hi link DiagnosticFloatingInfo     DiagnosticInfo
hi link DiagnosticFloatingHint     DiagnosticHint
hi link DiagnosticFloatingOk       DiagnosticOk
hi link DiagnosticSignError        DiagnosticError
hi link DiagnosticSignWarn         DiagnosticWarn
hi link DiagnosticSignInfo         DiagnosticInfo
hi link DiagnosticSignHint         DiagnosticHint
hi link DiagnosticSignOk           DiagnosticOk
hi link DiagnosticUnnecessary      Comment

" More carry over. CoC specific.
hi CocErrorSign      ctermfg=9 guifg=#ff0000
hi CocWarningSign    ctermfg=130 guifg=#ff922b
hi CocInfoSign       ctermfg=11 guifg=#fab005
hi CocHintSign       ctermfg=12 guifg=#15aabf
hi CocSelectedText   ctermfg=9 guifg=#fb4934
hi CocCodeLens       ctermfg=248 guifg=#999999
hi CocUnderline      cterm=underline gui=underline
hi CocBold           cterm=bold gui=bold
hi CocItalic         cterm=italic gui=italic
hi CocStrikeThrough  cterm=strikethrough gui=strikethrough
hi CocMarkdownLink   ctermfg=12 guifg=#15aabf
hi CocDisabled       ctermfg=248 guifg=#999999

hi link CocFadeOut              Conceal
hi link CocMenuSel              PmenuSel
hi link CocErrorFloat           CocErrorSign
hi link CocWarningFloat         CocWarningSign
hi link CocInfoFloat            CocInfoSign
hi link CocHintFloat            CocHintSign
hi link CocErrorHighlight       CocUnderline
hi link CocWarningHighlight     CocUnderline
hi link CocInfoHighlight        CocUnderline
hi link CocHintHighlight        CocUnderline
hi link CocDeprecatedHighlight  CocStrikeThrough
hi link CocUnusedHighlight      CocFadeOut
hi link CocListMode             ModeMsg
hi link CocListPath             Comment
hi link CocHighlightText        CursorColumn
hi link CocHoverRange           Search
hi link CocCursorRange          Search
hi link CocHighlightRead        CocHighlightText
hi link CocHighlightWrite       CocHighlightText
hi link CocSnippetVisual        Visual
hi link CocTreeTitle            Title
hi link CocTreeDescription      Comment
hi link CocTreeOpenClose        CocBold
hi link CocTreeSelected         CursorLine

" Global
hi Normal guifg=#000000 guibg=#ffffff

" Search
hi Search guifg=#800000 guibg=#ffae00
hi IncSearch guifg=#800000 guibg=#ffae00

" Interface Elements
hi StatusLine guifg=#ffffff guibg=#43c464 gui=bold
hi StatusLineNC guifg=#9bd4a9 guibg=#51b069
hi VertSplit guifg=#3687a2 guibg=#3687a2
hi Folded guifg=#3c78a2 guibg=#c3daea
hi IncSearch guifg=#708090 guibg=#f0e68c
hi Pmenu guifg=#000000 guibg=#e8ebff
hi PmenuSel guifg=#ffffff guibg=#000000
" hi SignColumn
hi CursorLine guifg=#c0d9eb
" hi LineNr guifg=#eeeeee guibg=#438ec3 gui=bold
" hi MatchParen

" Specials
hi Todo guifg=#e50808 guibg=#dbf3cd gui=bold
hi Title guifg=#000000
hi Special guifg=#EB7F00 gui=bold

" Syntax Elements
hi String guifg=#0086d2
hi Constant guifg=#0086d2
hi Number guifg=#0086f7
hi Statement guifg=#fb660a
hi Function guifg=#ff0086
hi PreProc guifg=#ff0007
hi Comment guifg=#22a21f gui=bold
hi Type guifg=#70796b
hi Error guifg=#ffffff guibg=#d40000
hi Identifier guifg=#ff0086
hi Label guifg=#ff0086

" Python Highlighting
hi pythonCoding guifg=#ff0086
hi pythonRun guifg=#ff0086
hi pythonBuiltinObj guifg=#2b6ba2
hi pythonBuiltinFunc guifg=#2b6ba2
hi pythonException guifg=#ee0000
hi pythonExClass guifg=#66cd66
" hi pythonSpaceError
hi pythonDocTest guifg=#2f5f49
hi pythonDocTest2 guifg=#3b916a
hi pythonFunction guifg=#ee0000
hi pythonClass guifg=#ff0086

" HTML Highlighting
hi htmlTag guifg=#00bdec
hi htmlEndTag guifg=#00bdec
hi htmlSpecialTagName guifg=#4aa04a
hi htmlTagName guifg=#4aa04a
hi htmlTagN guifg=#4aa04a

" Jinja Highlighting
hi jinjaTagBlock guifg=#ff0007 guibg=#fbf4c7 gui=bold
hi jinjaVarBlock guifg=#ff0007 guibg=#fbf4c7
hi jinjaString guifg=#0086d2 guibg=#fbf4c7
hi jinjaNumber guifg=#bf0945 guibg=#fbf4c7 gui=bold
hi jinjaStatement guifg=#fb660a guibg=#fbf4c7 gui=bold
hi jinjaComment guifg=#008800 guibg=#002300 gui=italic
hi jinjaFilter guifg=#ff0086 guibg=#fbf4c7
hi jinjaRaw guifg=#aaaaaa guibg=#fbf4c7
hi jinjaOperator guifg=#ffffff guibg=#fbf4c7
hi jinjaVariable guifg=#92cd35 guibg=#fbf4c7
hi jinjaAttribute guifg=#dd7700 guibg=#fbf4c7
hi jinjaSpecial guifg=#008ffd guibg=#fbf4c7
