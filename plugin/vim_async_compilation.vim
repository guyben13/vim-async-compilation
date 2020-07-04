python import json
python import vim

let g:guyben_compilation_database = 'compile_commands.json'
let g:guyben_extra_options = '-o /dev/null -fsyntax-only -Wno-error'

function s:SendCompilation(fname)
	let l:compile_commands =
    \ pyeval('json.loads(open(vim.eval("g:guyben_compilation_database"), "r").read())')
  let l:cmd = ''
  let l:dir = ''
  for item in l:compile_commands
    if item.file == a:fname
      let l:cmd = item.command
      let l:dir = item.directory
    endif
  endfor
  if !empty(l:cmd)
    let l:tmpfile = tempname()
    let l:result_file = tempname()
    silent execute '!' . l:cmd . ' ' . g:guyben_extra_options . ' 2> ' . l:tmpfile
      \ . ' ; mv ' . l:tmpfile . ' ' . l:result_file
    execute 'lgetfile ' . l:result_file
    MarkifyClear
    Markify
  else
    echo "Couldn't find compilation command for " . a:fname
  endif
endfunction

autocmd BufWritePost *.cc call s:SendCompilation(expand('<afile>'))
