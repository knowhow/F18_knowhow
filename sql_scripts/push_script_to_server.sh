

# ~/.pgpass
# f18-test:5432:*:admin:xxxxxxx


if [ "$3" == "" ] ; then
  echo Primjer: "cat test.sql | psql -U admin -w -h f18-test bringout_2012"
  echo $0 f18-test bringout_2012 test.sql 
  exit 1
fi

cat $3 | psql -U admin -w -h $1 $2
