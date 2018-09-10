 
initdb -D c:/postgresql/data --encoding UTF-8

C:/postgresql/pgsql_10_32/bin/pg_ctl -D c:/postgresql/data -l c:/postgresql/data.log start

createdb hernad

winpty psql