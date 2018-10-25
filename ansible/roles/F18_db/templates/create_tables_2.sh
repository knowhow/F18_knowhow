#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$PG_USER" --dbname "test_2018" <<-EOSQL
CREATE TABLE IF NOT EXISTS widgets
(
    id SERIAL,
    name TEXT,
    price DECIMAL,
    CONSTRAINT widgets_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS promet
(
    id SERIAL,
    name TEXT,
    price DECIMAL,
    CONSTRAINT promet_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS roba
(
    id varchar(12),
    naz varchar(100),
    price DECIMAL,
    CONSTRAINT roba_pkey PRIMARY KEY (id)
);


GRANT ALL PRIVILEGES ON DATABASE test_2018 TO xtrole;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO xtrole;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO xtrole;


EOSQL