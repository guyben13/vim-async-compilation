python import json
python import vim

if !exists('g:async_compilation#compilation_database')
  let g:async_compilation#compilation_database = 'compile_commands.json'
endif
if !exists('g:async_compilation#extra_options')
  let g:async_compilation#extra_options = '-o /dev/null -fsyntax-only -Wno-error'
endif

let g:async_compilation#debug_error = ''

let s:compile_commands = {}
let s:compile_commands_timestamp = 0

function s:FindItem(compile_commands, fname, mods)
  let l:fname = fnamemodify(a:fname, a:mods)
  for item in a:compile_commands
    if fnamemodify(item.file, a:mods) == l:fname
      return item
    endif
  endfor
  return {}
endfunction

let s:compilation_result = ''
function s:TryReadingCompilationResult()
  if empty(s:compilation_result)
    au! AsyncCompilation#Timer
    return
  endif
  if !filereadable(s:compilation_result)
    return
  endif

  au! AsyncCompilation#Timer
  execute 'lgetfile ' . s:compilation_result
endfunction

function s:SendCompilation(fname)
  au! AsyncCompilation#Timer
  if empty(g:async_compilation#compilation_database)
    let g:async_compilation#debug_error = "No compilation database file given"
    return
  endif

  if !filereadable(g:async_compilation#compilation_database)
    let g:async_compilation#debug_error = "Can't read file " . g:async_compilation#compilation_database
    return
  endif

  let l:timestamp = getftime(g:async_compilation#compilation_database)
  if s:compile_commands_timestamp != l:timestamp
    let s:compile_commands =
      \ pyeval('json.loads(open(vim.eval("g:async_compilation#compilation_database"), "r").read())')
    let s:compile_commands_timestamp = l:timestamp
  endif

  let l:item = s:FindItem(s:compile_commands, a:fname, ":p")
  if empty(l:item)
    let l:item = s:FindItem(s:compile_commands, a:fname, ":r")
  endif

  if empty(l:item)
    let g:async_compilation#debug_error = "Couldn't find compilation command for " . a:fname
    return
  endif

  let l:tmpfile = tempname()
  let s:compilation_result = tempname()
  let l:compilation_cmd = l:item.command . ' ' . g:async_compilation#extra_options . ' 2> ' . l:tmpfile
  let l:move_cmd = 'mv ' . l:tmpfile . ' ' . s:compilation_result
  " Run the commands in the background
  silent execute '!(' . l:compilation_cmd . ' ; ' . l:move_cmd . ' )&'
  " Simulate timer using CursorHold
  au! AsyncCompilation#Timer CursorHold * call feedkeys('jk')
  " Use the timer to check if the compilation result exists
  " nested to trigger any QuickFixCmd* autocommands when executing lgetfile
  au! AsyncCompilation#Timer CursorMoved * nested call s:TryReadingCompilationResult()
endfunction

augroup AsyncCompilation
  au!
  autocmd BufWritePost * call s:SendCompilation(expand('<afile>'))
augroup END

augroup AsyncCompilation#Timer
  au!
augroup END

