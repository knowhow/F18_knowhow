export HB_ARCHITECTURE=win
export HB_COMPILER=mingw

QT_VER=5.3
MINGW_VER=482_32

#C_ROOT=/cygdrive/c
C_ROOT=C:

export TEMP=$C_ROOT\\tmp
export TMP=$C_ROOT\\tmp


HB_ROOT=$C_ROOT\\knowhowERP\\hbwin

export PATH=c:\\Qt\\$QT_VER\\mingw$MINGW_VER\\bin:$HB_ROOT\\bin:$C_ROOT\\PostgreSQL\\bin:$PATH

# mingw g++
export PATH=C:\\Qt\\Tools\\mingw$MINGW_VER\\bin:$PATH

export HB_INC_INSTALL=$HB_ROOT\\include
export HB_LIB_INSTALL=$HB_ROOT\\lib

export HB_INSTALL_PREFIX=$HB_ROOT

export HB_WITH_QT=c:\\Qt\\$QT_VER\\mingw$MINGW_VER\\include
export HB_WITH_PGSQL=c:\\PostgreSQL\\include
#HB_WITH_MYSQL=c:\\mysql\\include


#export QT_INC_DIR=$QT_DIR\\include

#export HB_WITH_QT=$QT_DIR\\bin
#export HB_INC_QT=$QT_INC_DIR
#export HB_LIB_QT=$QT_DIR\\lib

HB_DBG="."

HB_DBG_PATH="."

MODULES="main fin kalk fakt os ld virm epdv rnal kadev common"
MODULES="$MODULES base admin brojaci partner konto roba parametri narudzbenica string semaphores dbf_create sql sql_data_access fiskalizacija pdv ui_1990  print"

for m in $MODULES
do
      HB_DBG_PATH="$HB_DBG_PATH;$HB_DBG\\$m"
done

export HB_DBG_PATH

echo $HB_DBG_PATH

