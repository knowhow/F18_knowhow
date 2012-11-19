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

cd ../../

export KNOWHOW_ERP_ROOT=$CUR_DIR
export HARBOUR_ROOT=$KNOWHOW_ERP_ROOT/hbout

let KH_PATH=`echo $PATH | grep -c $KNOWHOW_ERP_ROOT/bin`

if [[ $KH_PATH -eq 0 ]]; then
     # echo "knowhowERP not in path ($KH_PATH) dodajem"
     export PATH=$KNOWHOW_ERP_ROOT/bin:$KNOWHOW_ERP_ROOT/util:$HARBOUR_ROOT/bin:$PATH
else
     echo "knowhowERP already in path ($KH_PATH): $PATH"
fi

export HB_COMPILER=gcc

export HB_INC_INSTALL=$HARBOUR_ROOT/include
export HB_LIB_INSTALL=$HARBOUR_ROOT/lib

. ./build_test.sh


USER="test1"
ret=`echo "select rolname from pg_roles where rolname='$USER'" | psql -t -h localhost -U postgres | grep -q $USER`

if [[ $ret -eq 0 ]]; then
   echo "$USER postoji"
else
  echo "create user $USER with password '$USER'" | psql -h localhost -U postgres
fi

#pg_dump -h localhost -U postgres f18_test > f18_test.sql
echo "CREATE database f18_test" | psql -U postgres 


psql -U postgres f18_test < test/data/f18_test.sql

SQL="create role xtrole"
echo $SQL | psql -U postgres 

SQL="grant xtrole TO test1 GRANTED BY postgres"
echo $SQL | psql -U postgres 

./F18_test
