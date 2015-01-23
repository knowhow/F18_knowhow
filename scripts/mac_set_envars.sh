#!/bin/bash

if [ -d /opt/knowhowERP/hbout ]
then
  BASE=/opt/knowhowERP/hbout
else
  BASE=/opt/harbour
fi

export HB_ROOT=$BASE
export PATH=$PATH:$BASE/bin

export HB_WITH_SQLITE3=external
export HB_COMPILER=clang
export HB_USER_CFLAGS=-fPIC

echo $BASE

export HB_INC_INSTALL=$BASE/include/harbour
export HB_LIB_INSTALL=$BASE/lib/harbour
export HB_WITH_QT=/usr/local/opt/qt5/include
export HB_QTPATH=/usr/local/opt/qt5/bin

. scripts/set_envars.sh

HB_DBG=`pwd`
for m in $MODULES
do
    HB_DBG_PATH="$HB_DBG_PATH:$HB_DBG/$m"
done

export HB_DBG_PATH
echo "HB_DBG_PATH="  $HB_DBG_PATH

export PATH=$HB_QTPATH:$PATH

export DYLD_LIBRARY_PATH=.:$HB_LIB_INSTALL

