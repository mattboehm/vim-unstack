"Settings {{{
if !exists('g:unstack_mapkey')
  let g:unstack_mapkey = '<leader>s'
endif
exe 'nnoremap '.g:unstack_mapkey.' :set operatorfunc=unstack#Unstack<cr>g@'
exe 'vnoremap '.g:unstack_mapkey.' :<c-u>call unstack#Unstack(visualmode())<cr>'

"Regular expressions for a line of stacktrace. The file path and line number
"should be surrounded by parentheses so that they are captured as groups
if (!exists('g:unstack_patterns'))
  let g:unstack_patterns = [['\v^ *File "([^"]+)", line ([0-9]+).+', '\1', '\2'], ['\v^[ \t]*from ([^:]+):([0-9]+):in `.+', '\1', '\2']]
endif

"Whether or not to show signs on error lines (highlights them red)
if !exists('g:unstack_showsigns')
  let g:unstack_showsigns = 1
endif "}}}

" vim:foldmethod=marker:foldmarker={{{,}}}
