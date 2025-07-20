" GW-BASIC Plugin für Vim

if exists("g:loaded_gwbasic")
  finish
endif
let g:loaded_gwbasic = 1

" Automatische Zeilennummern bei <CR>
autocmd FileType gwbasic inoremap <buffer> <CR> <C-o>:call GWBASIC_NewLine()<CR>

" Leere Zeile bei <C-j> (statt <C-CR>) erzeugt GW-BASIC-kompatible 0x0A 0x0D Sequenz
autocmd FileType gwbasic inoremap <buffer> <C-j> <C-o>:call GWBASIC_EmptyLine()<CR>

" Ausführen mit <C-r>
autocmd FileType gwbasic nnoremap <buffer> <C-r> :call GWBASIC_Run()<CR>

" Verstecke Markerzeilen <<<GWBASIC_EMPTY>>> durch Conceal
augroup gwbasic_syntax
  autocmd!
  autocmd FileType gwbasic syntax match gwbasicEmpty /^<<<GWBASIC_EMPTY>>>$/ conceal
  autocmd FileType gwbasic setlocal conceallevel=2
augroup END

command! -nargs=? Renumber call GWBASIC_Renumber(<f-args>)
command! ResolveLabels call GWBASIC_ResolveLabels()
command! Run call GWBASIC_Run()

function! GWBASIC_EmptyLine()
  " Füge Markerzeile ein, die beim Schreiben als 0D 0A (ohne Inhalt) ausgegeben wird
  call append(line('.'), '<<<GWBASIC_EMPTY>>>')
  call cursor(line('.') + 1, 1)
  startinsert
endfunction

function! GWBASIC_WriteWithEOF(lines, filename)
  let bin = []
  for line in a:lines
    if line ==# '<<<GWBASIC_EMPTY>>>'
      call add(bin, "
") " GW-BASIC interpretiert diese Umkehrung als leere logische Zeile
    else
      call add(bin, line . "
") " normale Zeilen bekommen CRLF später automatisch
    endif
  endfor
  call add(bin, "\x1A")
  call writefile(bin, a:filename, 'b')
endfunction

function! GWBASIC_NewLine()
  let lnum = line('.')
  let line_text = getline(lnum)
  let nextnum = 10
  if line_text =~ '^\d\+'
    let current = str2nr(matchstr(line_text, '^\d\+'))
    let nextnum = current + 10
  endif
  call append(lnum, nextnum . ' ')
  call cursor(lnum + 1, strlen(nextnum . ' ') + 1)
  startinsert
endfunction

function! GWBASIC_CollectLabels(lines)
  let labels = {}
  let duplicates = []
  for i in range(len(a:lines))
    let line = a:lines[i]
    if line =~ '^@\w\+'
      let label = matchstr(line, '^@\zs\w\+')
      if has_key(labels, label)
        call add(duplicates, label)
      else
        let j = i + 1
        while j < len(a:lines) && a:lines[j] !~ '^\d\+'
          let j += 1
        endwhile
        if j < len(a:lines)
          let target = matchstr(a:lines[j], '^\d\+')
          let labels[label] = target
        endif
      endif
    endif
  endfor
  if !empty(duplicates)
    echohl WarningMsg
    echo 'WARNUNG: doppelte Labels gefunden: ' . join(duplicates, ', ')
    echohl None
  endif
  return labels
endfunction

function! GWBASIC_ReplaceLabels(lines, labels)
  let replaced = []
  let undefined = []
  for line in a:lines
    if line =~ '^@\w\+'
      continue
    endif
    let original = line
    while match(line, '@\w\+') >= 0
      let ref = matchstr(line, '@\w\+')
      let name = strpart(ref, 1)
      if has_key(a:labels, name)
        let line = substitute(line, '@' . name, a:labels[name], '')
      else
        if index(undefined, name) == -1
          call add(undefined, name)
        endif
        break
      endif
    endwhile
    call add(replaced, line)
  endfor
  if !empty(undefined)
    echohl WarningMsg
    echo 'WARNUNG: undefinierte Labels verwendet: ' . join(undefined, ', ')
    echohl None
  endif
  return replaced
endfunction

function! GWBASIC_UppercaseKeywords(lines)
  let keywords = ['PRINT', 'INPUT', 'IF', 'THEN', 'ELSE', 'FOR', 'NEXT', 'GOTO', 'GOSUB', 'RETURN', 'END', 'REM', 'DIM', 'READ', 'DATA', 'RESTORE', 'LET', 'ON', 'STOP', 'CLS']
  let uppered = []
  for line in a:lines
    let newline = line
    for word in keywords
      let pattern = '\C\<'.tolower(word).'\>'
      let newline = substitute(newline, pattern, word, 'g')
    endfor
    call add(uppered, newline)
  endfor
  return uppered
endfunction

function! GWBASIC_Renumber(...)
  let step = a:0 > 0 ? str2nr(a:1) : 10
  let lines = getline(1, '$')
  let newlines = []
  let counter = 10
  for line in lines
    if line =~ '^\d\+ '
      let code = substitute(line, '^\d\+ ', '', '')
      call add(newlines, counter . ' ' . code)
      let counter += step
    elseif line =~ '^@\w\+'
      call add(newlines, line)
    else
      call add(newlines, line)
    endif
  endfor
  let labels = GWBASIC_CollectLabels(newlines)
  let final = GWBASIC_ReplaceLabels(newlines, labels)
  let final = GWBASIC_UppercaseKeywords(final)
  call setline(1, final)
  echo 'Renumber abgeschlossen.'
endfunction

function! GWBASIC_ResolveLabels()
  let lines = getline(1, '$')
  let labels = GWBASIC_CollectLabels(lines)
  let resolved = GWBASIC_ReplaceLabels(lines, labels)
  let resolved = GWBASIC_UppercaseKeywords(resolved)
  let outname = expand('%:p:r') . '_expanded.bas'
  call GWBASIC_WriteWithEOF(resolved, outname)
  echo 'Labels aufgelöst → ' . outname
endfunction

function! GWBASIC_Run()
  let lines = getline(1, '$')
  let labels = GWBASIC_CollectLabels(lines)
  let resolved = GWBASIC_ReplaceLabels(lines, labels)
  let resolved = GWBASIC_UppercaseKeywords(resolved)
  let outname = expand('%:p:r') . '_expanded.bas'
  call GWBASIC_WriteWithEOF(resolved, outname)
  if executable('pcbasic')
    call system('pcbasic ' . shellescape(outname) . ' &')
    echo 'Starte mit pcbasic: ' . outname
  else
    echo 'Fehler: pcbasic nicht im $PATH gefunden.'
  endif
endfunction
