find . "*.prg" > cscope.files
find . "*.ch" >> cscope.files

cscope -b
