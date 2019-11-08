#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$PG_USER" --dbname "postgres" <<-EOSQL
    CREATE USER admin WITH password 'boutpgmin';
    CREATE ROLE xtrole;
    GRANT xtrole TO admin GRANTED by postgres;
    CREATE user bjasko with password 'bjasko';
    GRANT xtrole TO bjasko GRANTED BY postgres;

    CREATE user hernad with password 'hernad';
    GRANT xtrole TO hernad GRANTED BY postgres;

    CREATE DATABASE test_2018;
    GRANT ALL PRIVILEGES ON DATABASE test_2018 TO admin;
EOSQL