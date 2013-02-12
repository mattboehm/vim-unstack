unstack.vim
=============

Parse stack traces and open the result in vim splits!

Version 0.1.2

No backwards compatability is guaranteed at this time and there are still known issues that need to be resolved.


Usage
-----
Visually select part/all of a stacktrace and hit `<leader>s`. If you want to use a different map key, put `let g:unstack_mapkey=<F10>` (replacing <F10> with the key of your choice.)


Screenshot
----------
<img src="http://i.imgur.com/iQdg3.png" width="800"/>


Signs
-----
By default, Unstack uses signs to highlight lines from stack traces in red. Signs are removed when the tab they were created in is closed. Sometimes a sign will appear to stick around after it's been removed until you switch tabs again. If you want to disable this feature add `set unstack_showsigns=0` to your .vimrc.


Supported Languages
-------------------
Currently the following stack traces are supported:

* Python

Customizing Languages
---------------------
Stack trace "flavors" can be added or removed by changing the  `g:unstack_patterns` variable. This contains a list of patterns to try to match lines against. A pattern is a list of 3 items:

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
