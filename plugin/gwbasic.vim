augroup gwbasic_plugin
  autocmd!
  autocmd FileType gwbasic call GWBASIC_Setup()
  autocmd BufWriteCmd *.bas call GWBASIC_SaveWithLFCR() | execute 'silent! doautocmd BufWritePost' | echo 'GW-BASIC-Datei gespeichert mit CRLF und LFCR'
augroup END

function! GWBASIC_Setup()
  setlocal expandtab
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal fileformat=dos

  inoremap <buffer> <CR> <C-o>:call GWBASIC_InsertNextLine()<CR>
  inoremap <buffer> <C-CR> <CR>
  inoremap <buffer> <C-j> <C-o>:call GWBASIC_InsertLFCR()<CR>
  nnoremap <buffer> <C-r> :Run<CR>

  command! -nargs=? Renumber call GWBASIC_Renumber(<f-args>)
  command! Run call GWBASIC_Run()
endfunction

function! GWBASIC_InsertNextLine()
  let l:line = getline('.')
  let l:match = matchlist(l:line, '^\s*\(\d\+\)\s\+')
  if len(l:match) >= 2
    let l:num = str2nr(l:match[1]) + 10
    call append(line('.'), printf('%d ', l:num))
    call cursor(line('.')+1, strlen(printf('%d ', l:num))+1)
    startinsert
  else
    call append(line('.'), '')
    call cursor(line('.')+1, 1)
    startinsert
  endif
endfunction

function! GWBASIC_InsertLFCR()
  " Markiere Zeile als spezielle LFCR-Zeile (wird später beim Speichern ersetzt)
  call append(line('.'), '<<<LFCR>>>')
  call cursor(line('.')+1, 1)
  startinsert
endfunction

function! GWBASIC_Renumber(...) range
  let l:step = a:0 > 0 ? str2nr(a:1) : 10
  let l:lnum = 10
  let l:new_lines = []

  for l:line in getline(1, '$')
    if l:line =~ '^\s*\(\d\+\)'
      call add(l:new_lines, printf('%d %s', l:lnum, substitute(l:line, '^\s*\d\+\s*', '', '')))
      let l:lnum += l:step
    else
      call add(l:new_lines, l:line)
    endif
  endfor

  call setline(1, map(l:new_lines, 'GWBASIC_UppercaseKeywords(v:val)'))
  echo "Zeilen neu nummeriert"
endfunction

function! GWBASIC_SaveWithLFCR()
  let l:lines = getline(1, '$')
  let l:bytes = []

  for line in l:lines
    if line ==# '<<<LFCR>>>'
      call add(l:bytes, "\x0A\x0D")
    else
      call add(l:bytes, line . "\r\n")
    endif
  endfor

  call add(l:bytes, "\x1A") " EOF
  call writefile(l:bytes, expand('%:p'), 'b')
endfunction

function! GWBASIC_Run()
  if !executable('pcbasic')
    echoerr "pcbasic nicht installiert oder nicht im PATH"
    return
  endif
  write
  silent execute '!pcbasic ' . shellescape(expand('%'))
endfunction

function! GWBASIC_UppercaseKeywords(line)
  let l:keywords = split("PRINT INPUT IF THEN ELSE GOTO GOSUB RETURN FOR TO STEP NEXT WHILE WEND DO LOOP END DIM DATA READ RESTORE DEF FN LET REM CLS STOP ON ERROR RESUME CHAIN CLEAR CLOSE COMMON CONT LPRINT LOCATE POKE PEEK OUT SOUND PLAY RANDOMIZE RUN SYSTEM ABS ASC ATN CHR$ COS EXP FIX INT INSTR LEFT$ LEN LOG MID$ RIGHT$ RND SGN SIN SQR STR$ STRING$ TAN VAL SPACE$ TIME$ DATE$ INKEY$ FRE EOF LOC LOF TIMER CINT CSNG CDBL")
  let l:line = a:line
  for l:kw in l:keywords
    let l:pattern = '\C\<' . tolower(l:kw) . '\>'
    let l:line = substitute(l:line, l:pattern, l:kw, 'g')
  endfor
  return l:line
endfunction
