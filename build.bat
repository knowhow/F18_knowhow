IF NOT EXIST "%HB_INC_INSTALL%"  GOTO END
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

hbmk2 *.prg fin\*.prg fakt\*.prg kalk\*.prg rnal\*.prg epdv\*.prg ld\*.prg os\*.prg pos\*.prg common\*.prg



:END
echo "setuj envars" 
