#!/bin/bash

source scripts/common.sh


function build_harbour {
git submodule init
git submodule update
cd harbour/harbour
make
make install
cd ../../
}


function build_f18_test {
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

echo "HB_INC_INSTALL=$HB_INC_INSTALL, $HB_LIB_INSTALL=$HB_LIB_INSTALL"
. ./build_test.sh
}

function create_roles {
USER="test1"
ret=`echo "select rolname from pg_roles where rolname='$USER'" | psql -t -h localhost -U postgres | grep -q $USER`

if [[ "$ret" == "0" ]]; then
   echo "$USER postoji"
else
  echo "create user $USER with password '$USER'" | psql -h localhost -U postgres
fi

SQL="create role admin"
echo $SQL | psql -U postgres


SQL="create role xtrole"
echo $SQL | psql -U postgres

SQL="grant xtrole TO test1 GRANTED BY postgres"
echo $SQL | psql -U postgres

SQL="grant xtrole TO admin GRANTED BY postgres"
echo $SQL | psql -U postgres
}

function create_databases {
#pg_dump -h localhost -U postgres f18_test > f18_test.sql
echo "CREATE database f18_test" | psql -U postgres
psql -U postgres f18_test < test/data/f18_test.sql > create_databases.log
}


function run_tests {
#./F18_test > F18.test.log

#cat F18.test.log

#grep -q "Test calls failed:[ ]*0" F18.test.log
#./F18_test | grep -q "Test calls failed:[ ]*0"
./F18_test
}

#build_harbour
install_harbour

create_roles
create_databases
if [[ "$?" != "0" ]]
then
   echo "problem kod kreiranja baza"
   cat create_databases.log
fi



build_f18_test

#sudo apt-get install openjdk-6-jre
install_jod_reports

TPL_VER="1.2.6"
install_template

# trebamo samo f-std.odt
rm $F18_INSTALL_ROOT/template/f-std?.odt
rm $F18_INSTALL_ROOT/template/f-std??.odt

#http://about.travis-ci.org/docs/user/gui-and-headless-browsers/

#export DISPLAY=:1

#Xvfb :1 -screen 1 1024x768x16 &
#sh -e /etc/init.d/xvfb start

run_tests

if [ ! $? -eq 0 ] ; then
    echo "---- F18 log ----------------"
    tail -n 30 F18.log
    echo "---- F18 log end ------------"
    exit 1
fi

