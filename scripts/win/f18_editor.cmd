set FN=%1

if "%2"==""  goto :full

set FN=%FN% %2

if "%3"==""  goto :full

set FN=%FN% %3


if "%4"==""  goto :full

set FN=%FN% %4

:full

rem win - gvim
rem iconv na mac-u: brew install icon

del /Q  %FN%.conv.txt
type "%FN%" | iconv -c -f IBM852 -t UTF-8 > "%FN%.conv.txt"

rem export BANG=\!
start gvim  -c ":set encoding=utf-8" "%FN%.conv.txt" 

