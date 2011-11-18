@ECHO OFF
IF NOT EXIST "%HB_INC_INSTALL%"  GOTO ERR
IF EXIST "%HB_INC_INSTALL%"  GOTO BUILD 

:BUILD
copy fin\*.ch  %HB_INC_INSTALL%
copy fakt\*.ch  %HB_INC_INSTALL%
copy kalk\*.ch  %HB_INC_INSTALL%
copy rnal\*.ch  %HB_INC_INSTALL%
copy epdv\*.ch  %HB_INC_INSTALL%
copy ld\*.ch  %HB_INC_INSTALL%
copy os\*.ch  %HB_INC_INSTALL%
copy pos\*.ch  %HB_INC_INSTALL%
copy common\*.ch %HB_INC_INSTALL%

hbmk2 F18.hbp

GOTO DONE


:ERR
echo "setuj envars" 
GOTO:EOF 
:DONE
echo "zavrseno"




