# F18

## build

[![Build status](https://ci.appveyor.com/api/projects/status/eg8qsklygduukk87?svg=true)](https://ci.appveyor.com/project/hernad/f18-knowhow)

Push 3.1.204 release

     git commit -am "BUILD_RELEASE 3.1.204"
     git tag 3.1.204
     git push origin 3-std --tags


     curl -LO https://bintray.com/hernad/F18/download_file?file_path=F18_windows_x86_2.3.205.zip

## F18 log promjena

[F18 CHANGELOG.md](CHANGELOG.md)


## F18 klijent korištenje

### vise instanci F18

    ./F18 --dbf-prefix 1
    ./F18 --dbf-prefix 2

### run funkcije pri pokretanju klijenta

    ./F18 --run-on-start kalk_gen_uskladjenje_nc_95\(\)

## Update


### Update kanal

* S - stabilne
* E - edge, posljednje verzije
* X - eksperimentalne - razvoj
