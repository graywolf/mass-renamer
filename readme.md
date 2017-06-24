Renamer
=======

Rename multiple files at once using your favourite text editor.

## Supported

### Ruby

Ruby 2.4.1 is tested. Older may or may not work, dunno.

### OS

* Linux - supported system
* MacOS - seems to work
* Windows - dunno, not testing, patches accepted

How to use
----------

When you run the renamer, it opens text editor of your choice and fills it
with file path. You edit the file, close your editor and renamer will do its
thing and rename stuff.

Rules for editing the rename file
---------------------------------

Lines without a whitespace at the start are source lines, lines starting
with a whitespace are target lines. Anything which ruby (`/\s/`) recognizes
as whitespace is acceptable, `\t` is default.

By removing all targets for file you are marking that file for deletion.

### Leave file where it is

	file
		file

This is default for all file.

### Move file

	file
		other_file_name

You can use any path that ruby will recognize, so both absolute

	file
		/tmp/file

and relative

	file
		../file

are fine. Relative paths are relative towards CWD, not to the file.

### Copy file

	file
		file
		copy_1
		copy_2
		../copy_3
		/tmp/copy_4

### Delete file

	file

Just delete the target for this file. So if I have `file1` and `file2` and I want
to delete the first one, I would do

	file1
	file2
		file2

Known issues
------------

### 1. Filenames with \n and other special things

To put simply, each filename (new, old) must be displayable (is that a word?)
on one line and it must be able to absolve roundtrip
`filename -> editor -> filename` for script to be able to pick it up. No escaping
is supported at the moment, so you cannot put new line in file name. I don't
this is a problem for anyone.

### 2. File path cannot start with space

Filenames can contain spaces, just not as first character or last character. After
the lines with file names are processed, [String#strip](https://ruby-doc.org/core-2.4.1/String.html#method-i-rstrip) is called. Reasoning here is that unwanted trailing
whitespace is way more common then intentional whitespace at beginning or end
of file name.

If you really need space as first character, provide path as absolute and then
you will not suffer from this.

	$ renamer /file/starting/with

will produce

	/file/starting/with/ a space
	  /file/starting/with/ a space

which is valid and should work.

### Can above issues be solved?

In general yes, I just don't see reason why bother. Both are **very** weird
things (imho) to do. If you have compelling reason why you need them, file
an issue ticket here on github.
