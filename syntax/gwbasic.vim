if exists("b:current_syntax")
  finish
endif

syntax case ignore

syntax match gwbLineNumber /^\d\+\s/

syntax keyword gwbKeyword PRINT INPUT IF THEN ELSE GOTO GOSUB RETURN FOR TO STEP NEXT WHILE WEND DO LOOP END DIM DATA READ RESTORE DEF FN LET REM CLS STOP ON ERROR RESUME
syntax keyword gwbFunction ABS ASC CHR$ COS EXP INT LEFT$ LEN LOG MID$ RIGHT$ RND SGN SIN SQR STR$ STRING$ TAN VAL
syntax match gwbNumber "\<\d\+\(\.\d*\)\=\([eE][+-]\=\d\+\)\=\>"
syntax region gwbString start=+"+ skip=+""+ end=+"+
syntax match gwbComment /REM.*/ contains=gwbTodo
syntax match gwbComment /'.*/ contains=gwbTodo

highlight link gwbKeyword Statement
highlight link gwbFunction Function
highlight link gwbNumber Number
highlight link gwbString String
highlight link gwbComment Comment
highlight link gwbLineNumber LineNr

let b:current_syntax = "gwbasic"
