
_cmd := "c:\windows\system32\notepad.exe"

_cmd := "start f18_editor.cmd c:\Documents and Settings\hbakir\.f18\bringout_2012\outf.txt"

_cmd := "sed --help"

? "run" 


_stderr := ""
_stdout := ""

_ret := hb_processrun(_cmd, @_stderr, @_stdout)

? "stderr", _stderr
? "stdout", _stdout
? _ret

inkey(0)
