@echo on

set I_VER="0.1.2"
set I_DATE="14.12.2011"
set DELRB_VER="1.0"
set PTXT_VER="1.55"
set F18_VER="0.9.17"

echo "F18 windows third party install ver %I_VER%, %I_DATE%"

rem env vars
set PATH=%PATH%;C:\knowhowERP\bin;C:\knowhowERP\lib;C:\knowhowERP\util

rem provjeri i kreiraj install dir 
if not exist c:\knowhowERP  md c:\knowhowERP

rem install


xcopy  /Y /i lib c:\knowhowERP\lib
xcopy  /Y /i util c:\knowhowERP\util

echo kopiram fontove
cd  fonts\ptxt_fonts\
xcopy /Y /i   *.ttf "%WINDIR%\Fonts" 

cd ..\.. 


mkdir tmp
cd tmp

rem ima li interneta
PING -n 1 www.google.com|find "Reply from " >NUL
IF NOT ERRORLEVEL 1 goto :ONLINE
IF     ERRORLEVEL 1 goto :OFFLINE

:ONLINE

wget http://knowhow-erp-f18.googlecode.com/files/delphirb_%DELRB_VER%.gz
wget http://knowhow-erp-f18.googlecode.com/files/ptxt_%PTXT_VER%.gz
wget http://knowhow-erp-f18.googlecode.com/files/F18_Windows_%F18_VER%.gz


goto :EXTRACT

:OFFLINE 

echo Internet konekcija nije dostupna nastavljam sa offline instalacijom 
echo kreiran je tmp podfolder ubacite potrebne pakete u isti


:EXTRACT

gzip -dN ptxt_%PTXT_VER%.gz
gzip -dN delphirb_%DELRB_VER%.gz
gzip -dN F18_Windows_%F18_VER%.gz

xcopy  /Y /i ptxt.exe c:\knowhowERP\util
xcopy  /Y /i delphirb.exe c:\knowhowERP\util
mkdir  c:\knowhowERP\bin
xcopy  /Y /i F18.exe c:\knowhowERP\bin
xcopy /Y   c:\knowhowERP\util\F18.lnk "%USERPROFILE%\Desktop"

cd ..

echo F18 3d_party set uspjesno instaliran
pause
exit
