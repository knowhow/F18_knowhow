@echo on

set I_VER="0.1.1"
set I_DATE="07.12.2011"
set URL="http://knowhow-erp-f18.googlecode.com/files"

echo "F18 windows update  ver %I_VER%, %I_DATE%"

rem env vars
set PATH=%PATH%;C:\knowhowERP\bin;C:\knowhowERP\lib;C:\knowhowERP\util

if not exist c:\knowhowERP  goto :ERR

mkdir tmp
cd tmp

rem ima li interneta
PING -n 1 www.google.com|find "Reply from " >NUL
IF NOT ERRORLEVEL 1 goto :ONLINE
IF     ERRORLEVEL 1 goto :OFFLINE

:ONLINE


wget %URL%/F18_Windows_%1.gz

if not exist F18_Windows_%1.gz  goto :ERR2

goto :EXTRACT

:OFFLINE 

echo Internet konekcija nije dostupna nastavljam sa offline instalacijom 
echo kreiran je tmp podfolder ubacite potrebne pakete u isti


:EXTRACT

gzip -dN F18_Windows_%F18_VER%.gz
xcopy  /i F18.exe c:\knowhowERP\bin

cd ..

echo F18 3d_party set uspjesno instaliran
pause
exit

:ERR

echo F18 updater trazi c:\knowhowERP direktorij

exit

:ERR2

echo F18 updater nije nasao %URL%/F18_Windows_%1.gz  
