@echo off

set HB_ARCHITECTURE=win
set HB_COMPILER=msvc

set F18_POS=1
set F18_DEBUG=1
set DATE=25.09.2020
set VERSION=3.2.0

IF [%VERSION%]==[] (
   echo ENVAR VERSION nije definisana. STOP!
   goto end
)

copy /Y include\f18_ver_template.ch include\f18_ver.ch

echo #define F18_VER       "%VERSION%" >> include\f18_ver.ch
echo #define F18_VER_DATE  "%DATE%" >> include\f18_ver.ch

type include\f18_ver.ch


hbmk2 F18 -workdir=.bdebug -ldflag+=/NODEFAULTLIB:LIBCMT

copy F18.exe F18_Windows_%VERSION%
echo pravim F18_Windows_%VERSION%.gz ...
c:\cygwin64\bin\gzip --force F18_Windows_%VERSION%

dir F18_Windows_%VERSION%.gz

:end
echo -- end --