set F18_POS=1
set VERSION=3.1.128
set DATE=10.07.2020

copy /Y include\f18_ver_template.ch include\f18_ver.ch

echo #define F18_VER       "%VERSION%" >> include\f18_ver.ch
echo #define F18_VER_DATE  "%DATE%" >> include\f18_ver.ch

type include\f18_ver.ch


hbmk2 F18 -clean
hbmk2 F18 -trace- -ldflag+=/NODEFAULTLIB:LIBCMT

copy F18.exe F18_Windows_%VERSION%
c:\cygwin64\bin\gzip F18_Windows_%VERSION%

dir F18_Windows_%VERSION%.gz