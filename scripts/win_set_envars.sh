#!/bin/bash

export HB_ARCHITECTURE=win
export HB_COMPILER=mingw

export WIN_HOME=c:\\Users\\Ernad

#QT_HOME=c:\\Qt
#QT_VER=5.3
#MINGW_VER=482_32
QT_HOME=c:\\Qt
QT_VER=5.4
MINGW_VER=491_32
PSQL_HOME=c:\\PostgreSQL

#C_ROOT=/cygdrive/c
C_ROOT=C:

export TEMP=$C_ROOT\\tmp
export TMP=$C_ROOT\\tmp


HB_ROOT=$C_ROOT\\knowhowERP\\hbwin

QT_PLUGIN_PATH=$QT_HOME/$QT_VER/mingw$MINGW_VER/plugins
export PATH=$QT_HOME\\$QT_VER\\mingw$MINGW_VER\\bin:$HB_ROOT\\bin:$PSQL_HOME\\bin:$PATH

# mingw g++
export PATH=$QT_HOME\\Tools\\mingw$MINGW_VER\\bin:$PATH

export HB_INC_INSTALL=$HB_ROOT\\include
export HB_LIB_INSTALL=$HB_ROOT\\lib

export HB_INSTALL_PREFIX=$HB_ROOT

export HB_WITH_QT=$QT_HOME\\$QT_VER\\mingw$MINGW_VER\\include
export HB_WITH_PGSQL=$PSQL_HOME\include
#HB_WITH_MYSQL=c:\\mysql\\include

HB_DBG="."

HB_DBG_PATH="."

. scripts/set_envars.sh

for m in $MODULES
do
      HB_DBG_PATH="$HB_DBG_PATH;$m"
done

export HB_DBG_PATH

echo $HB_DBG_PATH
