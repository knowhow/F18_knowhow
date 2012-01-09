export PATH=$PATH:/c/hb30/bin:/c/postgres/include:/c/postgres/lib
export HB_INC_INSTALL=/c/hb30/include
export HB_LIB_INSTALL=/c/hb30/lib/win/mingw

HB_DBG=`pwd`
export HB_DBG_PATH=$HB_DBG/common:$HB_DBG/pos:$HB_DBG/kalk:$HB_DBG/fin:$HB_DBG/fakt:$HB_DBG/os:$HB_DBG/ld:/$HB_DBG/epdf:$HB_DBG/rnal

echo "HB_DBG_PATH="  $HB_DBG_PATH

