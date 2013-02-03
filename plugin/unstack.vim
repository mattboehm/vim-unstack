"TODO add 'quit' function/shortcut that removes marks

if exists('g:loaded_unstack')
  finish
endif
let g:loaded_unstack = 1

"Settings {{{
if !exists('g:unstack_mapkey')
  let g:unstack_mapkey = '<leader>s'
endif
exe 'nnoremap '.g:unstack_mapkey.' :set operatorfunc=<SID>StackTrace<cr>g@'
exe 'vnoremap '.g:unstack_mapkey.' :<c-u>call <SID>StackTrace(visualmode())<cr>'

"Regular expressions for a line of stacktrace. The file path and line number
"should be surrounded by parentheses so that they are captured as groups
if (!exists('g:unstack_patterns'))
  let g:unstack_patterns = [['\v^ *File "([^"]+)", line ([0-9]+).+', '\1', '\2']]
endif

"Whether or not to show signs on error lines (highlights them red)
if !exists('g:unstack_showsigns')
  let g:unstack_showsigns = 1
endif "}}}

"StackTrace(type) called by hotkeys {{{
function! s:StackTrace(type)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@

  if a:type ==# 'V'
    execute "normal! `<V`>y"
  elseif a:type ==# 'v'
    execute "normal! `<v`>y"
  elseif a:type ==# 'char'
    execute "normal! `[v`]y"
  elseif a:type ==# 'line'
    execute "normal! `[V`]y"
  else
    let &selection = sel_save
    let @@ = reg_save
    return
  endif

  let files = s:ExtractFiles(@@)
  call s:OpenStackTrace(files)

  let &selection = sel_save
  let @@ = reg_save
endfunction "}}}

"ExtractFiles(stacktrace) extract files and lines from a stacktrace {{{
"return [[file1, line1], [file2, line2] ... ] from a stacktrace 
function! s:ExtractFiles(stacktrace)
  for [regex, file_replacement, line_replacement] in g:unstack_patterns
    let files = []
    for line in split(a:stacktrace, "\n")
      let fname = substitute(line, regex, file_replacement, '')
      "if this line has a matching filename
      if (fname != line)
        let lineno = substitute(line, regex, line_replacement, '')
        call add(files, [fname, lineno])
      endif
    endfor
    if(!empty(files))
      return files
    endif
  endfor
endfunction "}}}

"{{{OpenStackTrace(files) open extracted files in new tab
"files: [[file1, line1], [file2, line2] ... ] from a stacktrace
function! s:OpenStackTrace(files)
  tabnew
  if (g:unstack_showsigns)
    sign define errline text=>> linehl=Error texthl=Error
    "unusual number meant to prevent collisions existing signs
    "TODO randomize so that multiple stacktraces can exist in parallel
    let signId = 96224
  endif
  for fileinfo in a:files
    let filepath = fileinfo[0]
    let lineno = fileinfo[1]
    exe "edit ".filepath
    "move line with error to top then show 5 lines of context above
    setl scrolloff=5
    exe "normal! " . lineno . "z+"
    if (g:unstack_showsigns)
      exe "sign place " . signId . " line=" . lineno . " name=errline buffer=" . bufnr('%')
      let signId += 1
    endif
    "make a new vertical split for the next file
    botright vnew
  endfor
  "after adding the last file, the loop above calls vnew again.
  "delete this last empty vertical split
  exe 'quit'
endfunction "}}}

" vim:set foldmethod=marker
