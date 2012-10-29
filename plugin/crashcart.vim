"TODO allow for user-defined hotkey
"
"nnoremap <leader>s :set operatorfunc=<SID>StackTrace<cr>g@
"vnoremap <leader>s :<c-u>call <SID>StackTrace(visualmode())<cr>

"TODO add 'quit' function/shortcut that removes marks

"Settings {{{

"Regular expression for a line of stacktrace. The file path and line number
"should be surrounded by parentheses so that they are captured as groups
if !exists('g:crashcart_regex')
	let g:crashcart_regex = '\v^ *File "([^"]+)", line ([0-9]+).+'
endif

"Which group from the regex contains the file
if !exists('g:crashcart_file_subgroup')
	let g:crashcart_file_subgroup = '\1'
endif

"Which group from the regex contains the line
if !exists('g:crashcart_line_subgroup')
	let g:crashcart_line_subgroup = '\2'
endif

if (!exists('g:crashcart_nomap')) || (!g:crashcart_nomap)
	if !exists('g:crashcart_mapkey')
		let g:crashcart_mapkey = '<leader>s'
	endif
	exe 'nnoremap '.g:crashcart_mapkey.' :set operatorfunc=<SID>StackTrace<cr>g@'
	exe 'vnoremap '.g:crashcart_mapkey.' :<c-u>call <SID>StackTrace(visualmode())<cr>'
endif



"Regular expressions for a line of stacktrace. The file path and line number
"should be surrounded by parentheses so that they are captured as groups
let g:crashcart_regexes = [['\v^ *File "([^"]+)", line ([0-9]+).+', '\1', '\2']]

"Whether or not to show signs on error lines (highlights them red)
if !exists('g:crashcart_showsigns')
	let g:crashcart_showsigns = 1
endif "}}}

function! s:StackTrace(type)
	let sel_save = &selection
	let &selection = "inclusive"
	let reg_save = @@

	"echom a:type
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
	"echom files
	call s:OpenStackTrace(files)

	let &selection = sel_save
	let @@ = reg_save

endfunction

"files: [[file1, line1], [file2, line2] ... ] from a stacktrace
function! s:OpenStackTrace(files)
	tabnew
	if (g:crashcart_showsigns)
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
		exe "normal " . lineno . "z+"
		if (g:crashcart_showsigns)
			exe "sign place " . signId . " line=" . lineno . " name=errline buffer=" . bufnr('%')
			let signId += 1
		endif
		"make a new vertical split for the next file
		botright vnew
	endfor
	"after adding the last file, the loop above calls vnew again.
	"delete this last empty vertical split
	exe 'quit'
endfunction

"return [[file1, line1], [file2, line2] ... ] from a stacktrace
function! s:ExtractFiles(stacktrace)
	for [regex, file_subgroup, line_subgroup] in g:crashcart_regexes
		let files = []
		for line in split(a:stacktrace, "\n")
			let fname = substitute(line, g:crashcart_regex, g:crashcart_file_subgroup, '')
			"if this line has a matching filename
			if (fname != line)
				let lineno = substitute(line, g:crashcart_regex, g:crashcart_line_subgroup, '')
				call add(files, [fname, lineno])
			endif
		endfor
		if(!empty(files))
			return files
		endif
	endfor
endfunction
