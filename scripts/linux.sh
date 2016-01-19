#!/bin/bash

echo "linux setup"

export PLATFORM_ROOT=$HOME/Platform
export HB_VER=3.2.0-dev
export QT_VER=5.4.0
export PGSQL_VER=9.4.0-bdr


if [ `which harbour ` == "/usr/bin/harbour" ] ; then
   HB_LOCAL=1
else
   HB_LOCAL=0
fi


export HB_ROOT=$PLATFORM_ROOT/HB/$HB_VER
export QT_ROOT=$PLATFORM_ROOT/QT/$QT_VER
export PGSQL_ROOT=$PLATFORM_ROOT/PSQL/$PGSQL_VER
export HB_INSTALL_PREFIX=$HB_ROOT

if [ ! -f $HB_ROOT ];  then
  export HB_ROOT=$PLATFORM_ROOT/HB
  export QT_ROOT=$PLATFORM_ROOT/QT
  export PGSQL_ROOT=$PLATFORM_ROOT/PSQL

fi

export HB_INSTALL_PREFIX=$HB_ROOT

let KH_PATH=`echo $PATH | grep -c $KNOWHOW_ERP_ROOT/bin`

if [[ $KH_PATH -eq 0 ]]; then
   # echo "knowhowERP not in path ($KH_PATH) dodajem"
   export PATH=$KNOWHOW_ERP_ROOT/bin:$KNOWHOW_ERP_ROOT/util:$HB_ROOT/bin:$PATH
else
   echo "knowhowERP already in path ($KH_PATH): $PATH"
fi

export HB_COMPILER=gcc

if [ $HB_LOCAL -eq 1 ] ; then
  unset HB_INSTALL_PREFIX
  export HB_INC_INSTALL=/usr/include/harbour
  export HB_LIB_INSTALL=/usr/lib/harbour
else
  export HB_INC_INSTALL=$HB_ROOT/include
  export HB_LIB_INSTALL=$HB_ROOT/lib
fi

export INCLUDE=$HB_INC_INSTALL

LX_64=`uname -a | grep -c x86_64`

if [ "$LX_64" == "1" ] ; then
   export LX_64=1
else
   unset LX_64 
fi

export HB_USER_CFLAGS=-fPIC

if [ "$LX_64" == "1" ] ; then
   gcc_qt=gcc_64
else
   gcc_qt=gcc
fi

echo $QT_ROOT
if [ -f "$QT_ROOT/$qcc_qt" ] 
then
   export QT_ROOT=$QT_ROOT/$gcc_qt
   echo "Qt: $QT_ROOT"
fi
export PATH=$QT_ROOT/bin:$HB_ROOT/bin:$PATH
export HB_WITH_QT=$QT_ROOT/include
export HB_WITH_PGSQL=$PGSQL_ROOT/include
export LD_LIBRARY_PATH=$QT_ROOT/lib:$HB_ROOT/lib:$PGSQL_ROOT/lib

export QT_PLUGIN_PATH=$QT_ROOT/plugins

HB_DBG=`pwd`
