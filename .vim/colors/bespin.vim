" Vim color file
" Converted from Textmate theme Bespin using Coloration v0.2.5 (http://github.com/sickill/coloration)

set background=dark
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "Bespin"

hi Cursor  guifg=NONE guibg=#a7a7a7 gui=NONE
hi Visual  guifg=NONE guibg=#4c4a49 gui=NONE
hi CursorLine  guifg=NONE guibg=#2e2823 gui=NONE
hi CursorColumn  guifg=NONE guibg=#2e2823 gui=NONE
hi LineNr  guifg=#71685d guibg=#28211c gui=NONE
hi VertSplit  guifg=#443c35 guibg=#443c35 gui=NONE
hi MatchParen  guifg=#5ea6ea guibg=NONE gui=NONE
hi StatusLine  guifg=#baae9e guibg=#443c35 gui=bold
hi StatusLineNC  guifg=#baae9e guibg=#443c35 gui=NONE
hi Pmenu  guifg=#937121 guibg=NONE gui=NONE
hi PmenuSel  guifg=NONE guibg=#4c4a49 gui=NONE
hi IncSearch  guifg=NONE guibg=#41434a gui=NONE
hi Search  guifg=NONE guibg=#41434a gui=NONE
hi Directory  guifg=#cf6a4c guibg=NONE gui=NONE
hi Folded  guifg=#666666 guibg=#28211c gui=NONE

hi Normal  guifg=#baae9e guibg=#28211c gui=NONE
hi Boolean  guifg=#cf6a4c guibg=NONE gui=NONE
hi Character  guifg=#cf6a4c guibg=NONE gui=NONE
hi Comment  guifg=#666666 guibg=NONE gui=italic
hi Conditional  guifg=#5ea6ea guibg=NONE gui=NONE
hi Constant  guifg=#cf6a4c guibg=NONE gui=NONE
hi Define  guifg=#5ea6ea guibg=NONE gui=NONE
hi ErrorMsg  guifg=NONE guibg=NONE gui=NONE
hi WarningMsg  guifg=NONE guibg=NONE gui=NONE
hi Float  guifg=#cf6a4c guibg=NONE gui=NONE
hi Function  guifg=#937121 guibg=NONE gui=NONE
hi Identifier  guifg=#f9ee98 guibg=NONE gui=NONE
hi Keyword  guifg=#5ea6ea guibg=NONE gui=NONE
hi Label  guifg=#54be0d guibg=NONE gui=NONE
hi NonText  guifg=#5e5955 guibg=#2e2823 gui=NONE
hi Number  guifg=#cf6a4c guibg=NONE gui=NONE
hi Operator  guifg=#5ea6ea guibg=NONE gui=NONE
hi PreProc  guifg=#5ea6ea guibg=NONE gui=NONE
hi Special  guifg=#baae9e guibg=NONE gui=NONE
hi SpecialKey  guifg=#5e5955 guibg=#2e2823 gui=NONE
hi Statement  guifg=#5ea6ea guibg=NONE gui=NONE
hi StorageClass  guifg=#f9ee98 guibg=NONE gui=NONE
hi String  guifg=#54be0d guibg=NONE gui=NONE
hi Tag  guifg=#5ea6ea guibg=NONE gui=NONE
hi Title  guifg=#baae9e guibg=NONE gui=bold
hi Todo  guifg=#666666 guibg=NONE gui=inverse,bold,italic
hi Type  guifg=#937121 guibg=NONE gui=NONE
hi Underlined  guifg=NONE guibg=NONE gui=underline
hi rubyClass  guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyFunction  guifg=#937121 guibg=NONE gui=NONE
hi rubyInterpolationDelimiter  guifg=NONE guibg=NONE gui=NONE
hi rubySymbol  guifg=#cf6a4c guibg=NONE gui=NONE
hi rubyConstant  guifg=#9b859d guibg=NONE gui=NONE
hi rubyStringDelimiter  guifg=#54be0d guibg=NONE gui=NONE
hi rubyBlockParameter  guifg=#7587a6 guibg=NONE gui=NONE
hi rubyInstanceVariable  guifg=#7587a6 guibg=NONE gui=NONE
hi rubyInclude  guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyGlobalVariable  guifg=#7587a6 guibg=NONE gui=NONE
hi rubyRegexp  guifg=#e9c062 guibg=NONE gui=NONE
hi rubyRegexpDelimiter  guifg=#e9c062 guibg=NONE gui=NONE
hi rubyEscape  guifg=#cf6a4c guibg=NONE gui=NONE
hi rubyControl  guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyClassVariable  guifg=#7587a6 guibg=NONE gui=NONE
hi rubyOperator  guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyException  guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyPseudoVariable  guifg=#7587a6 guibg=NONE gui=NONE
hi rubyRailsUserClass  guifg=#9b859d guibg=NONE gui=NONE
hi rubyRailsARAssociationMethod  guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsARMethod  guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsRenderMethod  guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsMethod  guifg=#dad085 guibg=NONE gui=NONE
hi erubyDelimiter  guifg=NONE guibg=NONE gui=NONE
hi erubyComment  guifg=#666666 guibg=NONE gui=italic
hi erubyRailsMethod  guifg=#dad085 guibg=NONE gui=NONE
hi htmlTag  guifg=#ac885b guibg=NONE gui=NONE
hi htmlEndTag  guifg=#ac885b guibg=NONE gui=NONE
hi htmlTagName  guifg=#ac885b guibg=NONE gui=NONE
hi htmlArg  guifg=#ac885b guibg=NONE gui=NONE
hi htmlSpecialChar  guifg=#cf6a4c guibg=NONE gui=NONE
hi javaScriptFunction  guifg=#f9ee98 guibg=NONE gui=NONE
hi javaScriptRailsFunction  guifg=#dad085 guibg=NONE gui=NONE
hi javaScriptBraces  guifg=NONE guibg=NONE gui=NONE
hi yamlKey  guifg=#5ea6ea guibg=NONE gui=NONE
hi yamlAnchor  guifg=#7587a6 guibg=NONE gui=NONE
hi yamlAlias  guifg=#7587a6 guibg=NONE gui=NONE
hi yamlDocumentHeader  guifg=#54be0d guibg=NONE gui=NONE
hi cssURL  guifg=#7587a6 guibg=NONE gui=NONE
hi cssFunctionName  guifg=#dad085 guibg=NONE gui=NONE
hi cssColor  guifg=#cf6a4c guibg=NONE gui=NONE
hi cssPseudoClassId  guifg=#937121 guibg=NONE gui=NONE
hi cssClassName  guifg=#937121 guibg=NONE gui=NONE
hi cssValueLength  guifg=#cf6a4c guibg=NONE gui=NONE
hi cssCommonAttr  guifg=#cf6a4c guibg=NONE gui=NONE
hi cssBraces  guifg=NONE guibg=NONE gui=NONE
