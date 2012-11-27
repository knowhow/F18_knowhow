# F18 knowhowERP

[![Build
Status](https://secure.travis-ci.org/knowhow/F18_knowhow.png?branch=master)](https://travis-ci.org/knowhow/F18_knowhow)

## dev environment

<pre>
$ source scripts/(ubuntu | mac | win)_set_envars.sh
$
$ echo --- build debug ----
$ ./build.sh
$ ./F18
$ 
$ echo --- build test exe ---
$ ./build_test.sh
$ ./F18_test
$ .
$ echo --- build release (no debug) exe ---
$ ./build_release.sh
$ ./F18
</pre>


## Nakon upgrade-a database-e

### knowhow-erp-f18 downloads

postaviti na gcode aktuelnu verziju:

    http://code.google.com/p/knowhow-erp-f18/downloads/detail?name=f18_db_migrate_package_4.5.2.gz

### LASTEST_VERSIONS 

Postaviti aktuelnu verziju u [LATEST_VERSIONS](https://github.com/knowhow/F18_knowhow/blob/master/LATEST_VERSIONS#L1)

F18_knowhow$ cat LATEST_VERSIONS | grep f18_db_migrate
    
     f18_db_migrate_package 4.5.2 gz



[Update test database for travis](https://github.com/knowhow/F18_knowhow/blob/master/TRAVIS.md)
