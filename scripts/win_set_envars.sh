
#mkdir /c/tmp


export TEMP=/c/tmp
export TMP=/c/tmp

export HB_ARCHITECTURE=win
export HB_COMPILER=mingw

HB_ROOT=/c/knowhowERP/hbout

#HB_ROOT=/c/hbout

export PATH=$HB_ROOT/bin:/c/MinGW/bin:/c/PostgreSQL/9.1/bin:/c/mysql/bin:$PATH
export HB_INC_INSTALL=$HB_ROOT/include
export HB_LIB_INSTALL=$HB_ROOT/lib/win/mingw

export HB_INSTALL_PREFIX=$HB_ROOT

export HB_WITH_QT=c:\\Qt\\4.7.4\\include
export HB_WITH_PGSQL=c:\\PostgreSQL\\9.1\\include
export HB_WITH_MYSQL=c:\\mysql\\include


#export QT_DIR=/c/Qt/4.7.4
#export QT_DIR=c:\\Qt\\4.7.4


#export PATH=/c/Qt/4.7.4/bin:$PATH

#export QT_INC_DIR=$QT_DIR\\include

#export HB_WITH_QT=$QT_DIR\\bin
#export HB_INC_QT=$QT_INC_DIR
#export HB_LIB_QT=$QT_DIR\\lib

HB_DBG=/c/github/F18_knowhow

export HB_DBG_PATH=$HB_DBG/test:$HB_DBG/common:$HB_DBG/pos:$HB_DBG/kalk:$HB_DBG/fin:$HB_DBG/fakt:$HB_DBG/os:$HB_DBG/ld:/$HB_DBG/epdv:$HB_DBG/rnal:$HB_DBG/virm:$HB_DBG/mat:$HB_DBG/reports:$HB_DBG/kadev

echo HB_DBG_PATH=$HB_DBG_PATH

