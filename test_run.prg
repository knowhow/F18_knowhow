
_cmd := "c:\windows\system32\notepad.exe"

_cmd := "start f18_editor.cmd c:\Documents and Settings\hbakir\.f18\bringout_2012\outf.txt"

_cmd := "java -version"

? "run" 

_ret := hb_run(_cmd)

? _cmd
? _ret

inkey(0)
