"Settings {{{
if !exists('g:unstack_mapkey')
  let g:unstack_mapkey = '<leader>s'
endif
exe 'nnoremap '.g:unstack_mapkey.' :set operatorfunc=unstack#Unstack<cr>g@'
exe 'vnoremap '.g:unstack_mapkey.' :<c-u>call unstack#Unstack(visualmode())<cr>'

"List of text extractors
if (!exists('g:unstack_extractors'))
  let g:unstack_extractors = unstack#extractors#GetDefaults()
endif

"Whether or not to show signs on error lines (highlights them red)
if !exists('g:unstack_showsigns')
  let g:unstack_showsigns = 1
endif "}}}

" vim:foldmethod=marker:foldmarker={{{,}}}
