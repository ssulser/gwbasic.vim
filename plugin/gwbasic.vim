augroup gwbasic_plugin
  autocmd!
  autocmd FileType gwbasic call GWBASIC_Setup()
augroup END

function! GWBASIC_Setup()
  setlocal expandtab
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4

  inoremap <buffer> <CR> <C-o>:call GWBASIC_InsertNextLine()<CR>
  inoremap <buffer> <C-CR> <CR>
  inoremap <buffer> <C-j> <CR>
  nnoremap <buffer> <C-r> :Run<CR>

  command! -nargs=? Renumber call GWBASIC_Renumber(<f-args>)
  command! Run call GWBASIC_Run()
  command! ResolveLabels call GWBASIC_ResolveLabels()
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

function! GWBASIC_Renumber(...) range
  let l:step = a:0 > 0 ? str2nr(a:1) : 10
  let l:lnum = 10
  let l:new_lines = []
  let l:labels = {}
  let l:label_references = []

  for l:line in getline(1, '$')
    if l:line =~ '^\s*\(\d\+\)\s\+@\(\w\+\)'
      let l:label = matchstr(l:line, '@\w\+')
      let l:labels[l:label] = l:lnum
      let l:line = substitute(l:line, '@\w\+', '', '')
    endif
    if l:line =~ '^\s*\(\d\+\)'
      call add(l:new_lines, printf('%d %s', l:lnum, substitute(l:line, '^\s*\d\+\s*', '', '')))
      let l:lnum += l:step
    else
      call add(l:new_lines, l:line)
    endif
  endfor

  call setline(1, map(l:new_lines, 'GWBASIC_UppercaseKeywords(v:val)'))
  echo "Zeilen neu nummeriert mit Labelauflösung"
endfunction

function! GWBASIC_Run()
  if !executable('pcbasic')
    echoerr "pcbasic nicht installiert oder nicht im PATH"
    return
  endif
  write
  call GWBASIC_ResolveLabels()
  let l:newfile = expand('%:p:r') . '_expanded.bas'
  silent execute '!pcbasic ' . shellescape(l:newfile)
endfunction

function! GWBASIC_ResolveLabels()
  let l:lines = getline(1, '$')
  let l:labels = {}
  let l:resolved = []

  for idx in range(len(l:lines))
    let l:line = l:lines[idx]
    if l:line =~ '^\s*\(\d\+\)\s\+@\(\w\+\)'
      let l:label = matchstr(l:line, '@\w\+')
      let l:num = matchstr(l:line, '^\s*\d\+')
      let l:labels[l:label] = l:num
    endif
  endfor

  for l:line in l:lines
    for [label, num] in items(l:labels)
      let l:line = substitute(l:line, label, num, 'g')
    endfor
    call add(l:resolved, GWBASIC_UppercaseKeywords(l:line))
  endfor

  let l:newfile = expand('%:p:r') . '_expanded.bas'
  call writefile(l:resolved, l:newfile)
  echo "Labels aufgelöst → " . l:newfile
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
