find . -name "*.prg" > cscope.files
find . -name "*.ch" >> cscope.files

cscope -b
