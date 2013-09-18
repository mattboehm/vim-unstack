"Initialization {{{
if !exists("s:unstack_signs")
  let s:unstack_signs = {}
endif
augroup unstack_sign_clear
  autocmd!
  autocmd TabEnter * call unstack#RemoveSignsFromClosedTabs()
augroup end 
"}}}

"unstack#Unstack(selection_type) called by hotkeys {{{
function! unstack#Unstack(selection_type)
  let stack = unstack#ExtractFiles(a:selection_type)
  call unstack#OpenStackTrace(stack)
endfunction
"}}}

"Extraction {{{
"unstack#ExtractFiles(selection_type) extract files and line numbers {{{
function! unstack#ExtractFiles(selection_type)
	if &buftype == "quickfix"
let fileList = unstack#ExtractFilesFromQuickfix(a:selection_type)
	else
	let text = unstack#GetSelectedText(a:selection_type)
let fileList = unstack#ExtractFilesFromText(text)
	endif
	return fileList
	endfunction
	"}}}

	"unstack#ExtractFilesFromQuickfix(type) extract files from selected text or normal cmd range {{{
function! unstack#ExtractFilesFromQuickfix(type)
  if a:type ==# "v" || a:type ==# "V"
    let marks = ["'<", "'>"]
  else
    let marks = ["'[", "']"]
  endif
  let startLine = line(marks[0]) - 1 "lines are 0-indexed in quickfix list
  let stopLine = line(marks[1]) - 1 "lines are 0-indexed in quickfix list
  let fileList = []
  while startLine <= stopLine
    let qfline = getqflist()[startLine]
    let fname = bufname(qfline["bufnr"])
    let lineno = qfline["lnum"]
    call add(fileList, [fname, lineno])
    let startLine = startLine + 1
  endwhile
  return fileList
endfunction
"}}}

"unstack#GetSelectedText(selection_type) extract selected text {{{
function! unstack#GetSelectedText(selection_type)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@
  
    if a:selection_type ==# 'V'
      execute "normal! `<V`>y"
    elseif a:selection_type ==# 'v'
      execute "normal! `<v`>y"
    elseif a:selection_type ==# 'char'
      execute "normal! `[v`]y"
    elseif a:selection_type ==# 'line'
      execute "normal! `[V`]y"
    else
      let &selection = sel_save
      let @@ = reg_save
      return ""
    endif

    let selected_text = @@
    let &selection = sel_save
    let @@ = reg_save
    return selected_text
endfunction
"}}}

"unstack#ExtractFilesFromText(stacktrace) extract files and lines from a stacktrace {{{
"return [[file1, line1], [file2, line2] ... ] from a stacktrace 
function! unstack#ExtractFilesFromText(text)
  for extractor in g:unstack_extractors
    let stack = extractor.extract(a:text)
    if(!empty(stack))
      return stack
    endif
  endfor
endfunction
"}}}
"}}}

"Opening {{{
"unstack#OpenStackTrace(files) open extracted files in new tab {{{
"files: [[file1, line1], [file2, line2] ... ] from a stacktrace
function! unstack#OpenStackTrace(files)
  "disable redraw when opening files
  "still redraws when a split occurs but might *slightly* improve performance
  let lazyredrawSet = &lazyredraw
  set lazyredraw
  tabnew
  if (g:unstack_showsigns)
    sign define errline text=>> linehl=Error texthl=Error
    "sign ID's should be unique. If you open a stack trace with 5 levels,
    "you'd have to wait 5 seconds before opening another or risk signs
    "colliding.
    let signId = localtime()
    let t:unstack_tabId = signId
    let s:unstack_signs[t:unstack_tabId] = []
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
      call add(s:unstack_signs[t:unstack_tabId], signId)
      let signId += 1
    endif
    "make a new vertical split for the next file
    botright vnew
  endfor
  "after adding the last file, the loop above calls vnew again.
  "delete this last empty vertical split
  exe 'quit'
  if (!lazyredrawSet)
    set nolazyredraw
  endif
endfunction
"}}}

"unstack#GetOpenTabIds() get unstack id's for current tabs {{{
function! unstack#GetOpenTabIds()
  let curTab = tabpagenr()
  "determine currently open tabs
  let openTabIds = []
  tabdo if exists('t:unstack_tabId') | call add(openTabIds, string(t:unstack_tabId)) | endif
  "jump back to prev. tab
  exe "tabnext " . curTab 
  return openTabIds
endfunction
"}}}

"unstack#RemoveSigns(tabId) remove signs from the files initially opened in a tab {{{
function! unstack#RemoveSigns(tabId)
  for signId in s:unstack_signs[a:tabId]
    exe "sign unplace " . signId
  endfor
  unlet s:unstack_signs[a:tabId]
endfunction
"}}}

"unstack#RemoveSignsFromClosedTabs() remove signs that were placed in tabs that are {{{
"now closed
function! unstack#RemoveSignsFromClosedTabs()
  let openTabIds = unstack#GetOpenTabIds()
  for tabId in keys(s:unstack_signs)
    if index(openTabIds, tabId) == -1
      call unstack#RemoveSigns(tabId)
    endif
  endfor
endfunction
"}}}
"}}}

" vim: et sw=2 sts=2 foldmethod=marker foldmarker={{{,}}}
