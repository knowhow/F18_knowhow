# TRAVIS

## Database upgrade

Nakon upgrade-a db-a potrebno je osvježiti test/data/f18_test.sql

### 1) upgrade lokalne f18_test db-a

(na osnovu LATEST_VERSIONS)

$ `scripts/knowhow_update_test_database` # moze se kao argument skript navesti verzija npr. `4.5.9`

        12.03.2012, 1.0.0, hernad@bring.out.ba
        f18_db_migrate_package 4.5.2 gz,  ver= 4.5.2, ext= gz
        wget -nc http://knowhow-erp-f18.googlecode.com/files/f18_db_migrate_package_4.5.2.gz
        knowhowERP_package_updater -databaseURL=PSQL7://localhost:5432/f18_test -username=postgres -passwd=pwd -debug -file=~/Downloads/f18_db_migrate_package_4.5.2.gz -autorun


### 2) update travis f81_test.sql

$ scripts/update_travis_test_database 

        brisem fmk.log tabelu
        DELETE 4
        dump f18_test

Nakon ovoga obavit commit/push

## Dijagnoza

        psql -h localhost -U admin -W f18_test # password: admin

