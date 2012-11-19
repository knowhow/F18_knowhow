#!/bin/bash

# export QT_DIR=c:/knowhowERP/Qt

# export QT_DIR=c:\\Qt\\4.7.4
# export QT_DIR_CYGWIN=/c/Qt/4.7.4

# export HB_WITH_GTALLEGRO=no
# export HB_WITH_ALLEGRO=no
# export HB_WITH_GTWVG=yes




# export HB_INC_COMPILE=c:\harbour\include

# HB_INC_MYSQL=C:\mysql\5.0\include
# HB_LIB_MYSQL=c:\mysql\5.0\lib\opt

CUR_DIR=`pwd`
export HB_INSTALL_PREFIX=$CUR_DIR/hbout

# export HB_WITH_CURL=C:\\MinGW\\build\\include
# export HB_WITH_QT=${QT_DIR}\\include

# export HB_WITH_PGSQL=C:\\PostgreSQL\\9.1\\include

# export HB_WITH_MYSQL=c:\\MySQL\\include

export HB_WITH_SQLITE3=yes


export PATH=$PATH:$HB_INSTALL_PREFIX/bin

cd harbour/harbour
make
make install
