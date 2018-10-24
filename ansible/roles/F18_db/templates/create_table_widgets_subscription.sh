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

-- DROP ROLE IF EXISTS replikant;
-- CREATE ROLE replikant WITH REPLICATION LOGIN PASSWORD 'repliciram';

GRANT ALL PRIVILEGES ON DATABASE test_2018 TO xtrole;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO xtrole;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO xtrole;

DROP SUBSCRIPTION IF EXISTS subscription_1;
CREATE SUBSCRIPTION subscription_1 CONNECTION 'host=192.168.124.245 port=5432 password=repliciram user=replikant dbname=test_2018' PUBLICATION publication_1;

EOSQL