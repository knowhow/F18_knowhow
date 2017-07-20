# Developer build environment

## database

### kreiranje inicijalnih rola test1, test2, admin (zastarjelo):

    scripts/init_postgresql.sh `whoami`

### kreiranje f18_test baze (zastarjelo)

    export DB=f18_test
    echo "create database ${DB}" | psql -h localhost
    psql -h localhost ${DB} < test/data/${DB}.sql
    echo "SELECT u2.knowhow_package_version('fmk')" | psql -h localhost ${DB}


## git

### delete tag

   scripts/delete_tag.sh 3.0.0


### git config --global --list

       user.email=hernad@bring.out.ba
       user.name=Ernad Husremovic
       user.signingkey=40E1A4FDE2C67C31
       credential.helper=cache --timeout=43200

 signing commits:

        git config --global commit.gpgsign true


## Windows build

### windows MSYS2

       #pacman -Sy git  mingw-w64-i686-make
       pacman -Sy   mingw-w64-i686-postgresql mingw-w64-i686-openssl
       pacman  -Sy base-devel msys2-devel mingw-w64-i686-toolchain upx p7zip
