@echo on

rem env vars
set PATH "C:\knowhowerp\bin;C:\knowhowerp\lib;C:\knowhowerp\util;C:\knowhowerp\lib;%PATH%"

rem provjeri i kreiraj install dir 
if not exist c:\knowhowERP  md c:\knowhowERP

rem install


xcopy  /i lib c:\knowhowERP\lib
xcopy  /i util c:\knowhowERP\util

echo kopiram fontove
cd  fonts\ptxt_fonts\
xcopy /y   *.ttf "%WINDIR%\Fonts" 

cd ..\.. 

mkdir tmp
cd tmp

rem ima li interneta
PING -n 1 www.google.com|find "Reply from " >NUL
IF NOT ERRORLEVEL 1 goto :ONLINE
IF     ERRORLEVEL 1 goto :OFFLINE

:ONLINE

wget http://knowhow-erp-f18.googlecode.com/files/delphirb_1.0.gz
wget http://knowhow-erp-f18.googlecode.com/files/ptxt_1.55.gz


goto :EXTRACT

:OFFLINE 

echo Internet konekcija nije dostupna nastavljam sa offline instalacijom 
echo kreiran je tmp podfolder ubacite potrebne pakete u isti


:EXTRACT

gzip -dN ptxt_1.55.gz
gzip -dN delphirb_1.0.gz

xcopy  /i ptxt.exe c:\knowhowERP\util
xcopy  /i delphirb.exe c:\knowhowERP\util

cd ..

echo F18 3d_party set uspjesno instaliran
pause
exit



