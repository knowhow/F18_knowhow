
#mkdir /c/tmp


export TEMP=/c/tmp
export TMP=/c/tmp

HB_ROOT=/c/harbour/b1
export PATH=$HB_ROOT/bin:/c/PostgreSQL/9.1/include:/c/PostgreSQL/9.1/lib:$PATH
export HB_INC_INSTALL=$HB_ROOT/include
export HB_LIB_INSTALL=$HB_ROOT/lib/win/mingw

HB_DBG=`pwd`
export HB_DBG_PATH=$HB_DBG/common:$HB_DBG/pos:$HB_DBG/kalk:$HB_DBG/fin:$HB_DBG/fakt:$HB_DBG/os:$HB_DBG/ld:/$HB_DBG/epdf:$HB_DBG/rnal

echo "HB_DBG_PATH="  $HB_DBG_PATH

