export HB_ARCHITECTURE=win
export HB_COMPILER=mingw

QT_VER=5.4
MINGW_VER=491

#C_ROOT=/cygdrive/c
C_ROOT=C:

#export TEMP=$C_ROOT\\tmp
#export TMP=$C_ROOT\\tmp

export PLATFORM_BASE=c:\\Platform

#mkdir $TMP

HB_ROOT=$PLATFORM_BASE\\HB

export PATH=$PLATFORM_BASE\\HB\\bin:$PLATFORM_BASE\\JVM\\bin:$PLATFORM_BASE\\QT\\bin:$PLATFORM_BASE\\PSQL\\bin:$PLATFORM_BASE\\LO\\program:$PATH

# mingw g++

if [ ! -d /c/Qt/Tools/mingw${MINGW_VER}_32 ] ; then
   echo "Qt mingw $MINGW_VER 32bit not installed at location /c/Qt/Tools/mingw${MINGW_VER}_32 !"
   return
else
   echo "Mingw Qt: /c/Qt/Tools/mingw${MINGW_VER}_32"
fi

export PATH=C:\\Qt\\Tools\\mingw${MINGW_VER}_32\\bin:$PATH

echo "HB root: $HB_ROOT"
export HB_INC_INSTALL=$HB_ROOT\\include
export HB_LIB_INSTALL=$HB_ROOT\\lib

export HB_INSTALL_PREFIX=$HB_ROOT

export HB_WITH_QT=$PLATFORM_BASE\\QT\\include
export HB_WITH_PGSQL=$PLATFORM_BASE\\PSQL\\include


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
