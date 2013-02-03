unstack.vim
=============

Open stack traces in vim splits!

Usage
-----
Visually select part/all of a stacktrace and hit `<leader>s`
 If you want to use a different map key, put `let g:unstack_mapkey=<F10>` (replacing <F10> with the key of your choice.)

Customizing Regexes
-------------------
The `g:unstack_patterns` variable contains a list of patterns to try to match lines against. A pattern is a list of 3 items:

* A regular expression to test a line against
* What to replace the match with to get the file
* What to replace the match with to get the line number

Let's look at a pattern to match python stack traces:

`['\v^ *File "([^"]+)", line ([0-9]+).+', '\1', '\2']`

If a line matches the pattern, unstack will determine the file by replacing the matching line with `'\1'` which refers to the text between the first set of parentheses.

License
-------
Copyright (c) Matthew Boehm.  Distributed under the same terms as Vim itself.
See `:help license`.
