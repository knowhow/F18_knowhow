@echo off
REM # ver 1.0.2
REM # bjasko@bring.out.ba
REM # date 22.11.2013
set PATH=%PATH%;C:\knowhowERP\bin;C:\knowhowERP\lib;C:\knowhowERP\util
set DEST=C:\knowhowERP\bin

:SERVICE
echo.
echo.
echo "Provjeravam da li je F18 zatvoren"
echo.
echo.

PING -n 6 www.google.com  >NUL
REM # provjeri dali se F18 vrti
tasklist.exe /FI "IMAGENAME eq F18.exe" 2>NUL | find.exe /I /N "F18.exe" >NUL
if "%ERRORLEVEL%"=="0" echo "izgleda je je F18 aktivan, zatvorite ga" & goto SERVICE  else got UPDATE

:UPDATE

if not exist %1  goto ERR1

echo.
echo.
echo "Provjera ispravnosti arhive"
echo.
echo.
gzip -tv  %1
if errorlevel 1 goto ERR2 if errorlevel 0 goto OK

:OK

If NOT exist "%DEST%\libcurl-4.dll" (
 wget  http://download.bring.out.ba/libcurl-4.dll.gz -O libcurl-4.dll.gz
 gzip -dNfc < libcurl-4.dll.gz > %DEST%\libcurl-4.dll
)

If NOT exist "%DEST%\libnghttp2-14.dll" (
 wget  http://download.bring.out.ba/libnghttp2-14.dll.gz -O libnghttp2-14.dll.gz
 gzip -dNfc < libnghttp2-14.dll.gz > %DEST%\libnghttp2-14.dll
)


gzip -dNfc  < %1 > %DEST%\F18.exe
del /Q  %1
goto END

:ERR1
echo.
echo.
echo "Problem sa F18 update fajlom, Prekidam operaciju UPDATE-a"
echo.
echo.
pause
rem exit

:ERR2

echo.
echo.
echo "Greska unutar F18 update fajla, Prekidam operaciju, ponovite UPDATE"
echo.
echo.
pause
rem exit


:END
echo.
echo.
echo "Update je zavrsen uspjesno"
echo.
echo "Mozete zatvoriti ovaj prozor te ponovo pokrenuti F18"
echo.
echo.
pause
rem exit
