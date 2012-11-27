# TRAVIS

## Upgrade test database

promjena verzije baze

F18_knowhow$ scripts/knowhow_update_test_database 

        12.03.2012, 1.0.0, hernad@bring.out.ba
        f18_db_migrate_package 4.5.2 gz,  ver= 4.5.2, ext= gz
        wget -nc http://knowhow-erp-f18.googlecode.com/files/f18_db_migrate_package_4.5.2.gz
        Datoteka `f18_db_migrate_package_4.5.2.gz' već tamo; ne vraćam.

        knowhowERP_package_updater -databaseURL=PSQL7://localhost:5432/f18_test -username=postgres -passwd=admin -debug -file=/home/vagrant/Downloads/f18_db_migrate_package_4.5.2.gz -autorun


F18_knowhow$ scripts/update_travis_test_database 

        brisem fmk.log tabelu
        DELETE 4
        dump f18_test


