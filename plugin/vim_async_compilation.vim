python import json
python import vim

let g:guyben_compilation_database = 'compile_commands.json'
let g:guyben_extra_options = '-o /dev/null -fsyntax-only -Wno-error'

function s:FindItem(compile_commands, fname, mods)
  let l:fname = fnamemodify(a:fname, a:mods)
  for item in a:compile_commands
    if fnamemodify(item.file, a:mods) == l:fname
      return item
    endif
  endfor
  return {}
endfunction

function s:SendCompilation(fname)
	let l:compile_commands =
    \ pyeval('json.loads(open(vim.eval("g:guyben_compilation_database"), "r").read())')
  let l:item = s:FindItem(l:compile_commands, a:fname, ":p")
  if empty(l:item)
    let l:item = s:FindItem(l:compile_commands, a:fname, ":r")
  endif
  if !empty(l:item)
    let l:tmpfile = tempname()
    let l:result_file = tempname()
    silent execute '!' . l:item.command . ' ' . g:guyben_extra_options . ' 2> ' . l:tmpfile
      \ . ' ; mv ' . l:tmpfile . ' ' . l:result_file
    execute 'lgetfile ' . l:result_file
  else
    echo "Couldn't find compilation command for " . a:fname
  endif
endfunction

" nested to trigger any QuickFixCmd* autocommands when executing lgetfile
autocmd BufWritePost *.cc,*.h nested call s:SendCompilation(expand('<afile>'))

