# F18

## build

[![Build status](https://ci.appveyor.com/api/projects/status/eg8qsklygduukk87?svg=true)](https://ci.appveyor.com/project/hernad/f18-knowhow)


## instalacija klijenata


### linux (ubuntu, centos)

    # bash
    curl https://raw.githubusercontent.com/knowhow/F18_knowhow/3/bin/F18_install.sh | bash

### windows

     # u powershell konzoli zadati:
     iex (new-object net.webclient).downloadstring('https://raw.githubusercontent.com/knowhow/F18_knowhow/3/bin/F18_install.ps1')



## F18 log promjena

[F18 CHANGELOG.md](CHANGELOG.md)


## F18 klijent korištenje

### vise instanci F18

    ./F18 --dbf-prefix 1
    ./F18 --dbf-prefix 2

### run funkcije pri pokretanju klijenta

    ./F18 --run-on-start kalk_gen_uskladjenje_nc_95\(\)
