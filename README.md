# F18

## build, deploy


Windows (32-bit): 

    set VERSION=3.2.0
    echo create conan/deploy/x86/... detalji u {msvc}libpaths F18.hbc
    scripts\conan_deploy_x86.cmd
    build_release.cmd
    push_release_to_server.cmd <download_host.bring.out.ba>
    echo %VERSION% > VERSION_E


update VERSION_E, VERSION_X na github.com/knowhow:

    git remote add knowhow git@github.com:knowhow/F18_knowhow.git
    git checkout knowhow/3-std -b knowhow-3-std
    git checkout knowhow-3-std
    git merge 3-std
    git push knowhow 3-std
    

## F18 log promjena

[F18 CHANGELOG.md](CHANGELOG.md)


## F18 klijent korištenje

### vise instanci F18

    ./F18 --dbf-prefix 1
    ./F18 --dbf-prefix 2

### run funkcije pri pokretanju klijenta

    ./F18 --run-on-start kalk_gen_uskladjenje_nc_95\(\)
