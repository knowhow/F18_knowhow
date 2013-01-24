function create_roles {
USER="test1"
ret=`echo "select rolname from pg_roles where rolname='$USER'" | psql -t $PSQL_OPTS | grep -q $USER`

if [[ "$ret" == "0" ]]; then
   echo "$USER postoji"
else
  echo "create user $USER with password '$USER'" | psql $PSQL_OPTS
fi

SQL="create role admin"
echo $SQL | psql $PSQL_OPTS


SQL="create role xtrole"
echo $SQL | psql $PSQL_OPTS

SQL="grant xtrole TO test1 GRANTED BY postgres"
echo $SQL | psql $PSQL_OPTS

SQL="grant xtrole TO admin GRANTED BY postgres"
echo $SQL | psql $PSQL_OPTS
}


PSQL_OPTS="-U postgres -h localhost"
create_roles

