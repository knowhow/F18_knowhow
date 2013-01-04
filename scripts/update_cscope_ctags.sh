find . -name "*.prg" > cscope.files
find . -name "*.ch" >> cscope.files

cscope -b

#http://stackoverflow.com/questions/8193178/excluding-directories-in-exuberant-ctags
ctags -L cscope.files
