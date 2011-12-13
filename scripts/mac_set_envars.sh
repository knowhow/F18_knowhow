#!/bin/bash

export PATH=$PATH:/opt/harbour/bin

export HB_WITH_SQLITE3=external
#export HB_WITH_QT=/usr/local/Trolltech/Qt-4.7.4/include
export HB_COMPILER=gcc

#HB_USER_CFLAGS="-arch x86_64"
#HB_USER_LDFLAGS="-arch x86_64"


export HB_INC_INSTALL=/opt/harbour/include/harbour
export HB_LIB_INSTALL=/opt/harbour/lib/harbour


HB_DBG=`pwd`
export HB_DBG_PATH=$HB_DBG/test:$HB_DBG/common:$HB_DBG/pos:$HB_DBG/kalk:$HB_DBG/fin:$HB_DBG/fakt:$HB_DBG/os:$HB_DBG/ld:/$HB_DBG/epdv:$HB_DBG/rnal:$HB_DBG/mat


echo "HB_DBG_PATH="  $HB_DBG_PATH
