#!/bin/bash

if [ "$1" != "" ]; then
   SUPERUSER=$1
else
   SUPERUSER=postgres
fi

PSQLCMD="psql -t -h localhost -U $SUPERUSER"

function create_user {
ret=`echo "select rolname from pg_roles where rolname='$USER'" | $PSQLCMD | grep -q $USER`

if [[ "$ret" == "0" ]]; then
   echo "$USER postoji"
else
  echo "create user $USER with password '$USER'" | $PSQLCMD
fi

SQL="grant xtrole TO test1 GRANTED BY $SUPERUSER"
echo $SQL | $PSQLCMD

}


function create_test_roles {


SQL="create role admin"
echo $SQL | $PSQLCMD


SQL="create role xtrole"
echo $SQL | $PSQLCMD

USER="test1"
create_user

USER="test2"
create_user

SQL="grant xtrole TO admin GRANTED BY $SUPERUSER"
echo $SQL | $PSQLCMD
}


create_test_roles
