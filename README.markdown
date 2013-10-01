unstack.vim
=============

Parse stack traces or quickfix entries and open the result in vim splits!

Go from this:

<img src="http://i.imgur.com/DgXSAkq.png" width="800"/>

To this!

<img src="http://i.imgur.com/Q31wohX.png" width="800"/>

Version 0.3.4

No backwards compatability is guaranteed at this time.

Usage
-----
Visually select part/all of a stacktrace and hit `<leader>s`. If you want to use a different map key, put `let g:unstack_mapkey=<F10>` (replacing <F10> with the key of your choice.)

If this results in too many vsplits crowding the screen, consider taking a look at the [accordion](https://github.com/mattboehm/vim-accordion) plugin (shameless plug).

Signs
-----
By default, Unstack uses signs to highlight lines from stack traces in red. Signs are removed when the tab they were created in is closed. Sometimes a sign will appear to stick around after it's been removed until you switch tabs again. If you want to disable this feature add `set unstack_showsigns=0` to your .vimrc.

Portrait Layout
---------------
If you want the levels of the stack to open in hsplits (top to bottom instead of left to right), add the following to your .vimrc:

    let g:unstack_layout = "portrait"

Supported Languages
-------------------
Currently the following stack traces are supported:

* Python
* Ruby
* C#
* Perl
* Go

Is there another language you'd like supported? Open an issue with some sample stack traces or read on to learn how to add custom languages (pull requests welcome).

Customizing Languages
---------------------
Unstack can easily be extended to support additional stack trace formats. Check out `:help unstack-extractors` and `:help unstack-regex-extractors` for more information.

Feel free to submit pull requests or open issues for other stack trace languages.

License
-------
Copyright (c) Matthew Boehm.  Distributed under the same terms as Vim itself.
See `:help license`.
