augroup gwbasic_plugin
  autocmd!
  autocmd FileType gwbasic call GWBASIC_Setup()
augroup END

function! GWBASIC_Setup()
  " Keine Tabs erlauben, nur Spaces
  setlocal expandtab
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4

  " <CR>: Neue Zeile mit nächster Zeilennummer
  inoremap <buffer> <CR> <C-o>:call GWBASIC_InsertNextLine()<CR>

  " <C-CR>: Normale neue Zeile ohne Zeilennummer
  inoremap <buffer> <C-CR> <CR>
  inoremap <buffer> <C-j> <CR>  " fallback für Terminals

  " Befehl zum Neu-nummerieren
  command! -nargs=? Renumber call GWBASIC_Renumber(<f-args>)
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

  for l:line in getline(1, '$')
    let l:match = matchlist(l:line, '^\s*\(\d\+\)\s\(.*\)$')
    if len(l:match) == 3
      call add(l:new_lines, printf('%d %s', l:lnum, l:match[2]))
      let l:lnum += l:step
    else
      call add(l:new_lines, l:line)
    endif
  endfor

  call setline(1, l:new_lines)
  echo "Zeilen neu nummeriert mit Schrittweite " . l:step
endfunction
