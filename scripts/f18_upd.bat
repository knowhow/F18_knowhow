@echo off
REM # ver 1.0.1
REM # bjasko@bring.out.ba
REM # date 22.11.2013
set PATH=%PATH%;C:\knowhowERP\bin;C:\knowhowERP\lib;C:\knowhowERP\util
set DEST=C:\knowhowERP\bin

:SERVICE
echo  "Provjeravam dali je F18 zatvoren"
PING -n 1 www.google.com  >NUL
REM # provjeri dali se F18 vrti
tasklist /FI "IMAGENAME eq F18.exe" 2>NUL | find /I /N "F18.exe">NUL
if "%ERRORLEVEL%"=="0" goto :SERVICE  else GOTO :UPDATE

:UPDATE

if not exist %1 echo "F18 update fajl ne postoji"  
goto :ERR 
if %z1 eq 0 
del %1 
goto :ERR

gzip -dNfc  < %1 > %DEST%\F18.exe 
del /Q  %1 
goto :END

:ERR
echo "Prekidam operaciju UPDATE-a"
exit /b

:END
echo ""
echo ""
echo "UPDATE OK"
echo ""
echo ""
PING -n 2 www.google.com  >NUL
exit /b