# F18

## build, deploy


Windows (32-bit): 

    set VERSION=3.1.328
    build_release.cmd
    push_release_to_server.cmd <download_host.bring.out.ba>
    echo %VERSION% > VERSION_E


## F18 log promjena

[F18 CHANGELOG.md](CHANGELOG.md)


## F18 klijent korištenje

### vise instanci F18

    ./F18 --dbf-prefix 1
    ./F18 --dbf-prefix 2

### run funkcije pri pokretanju klijenta

    ./F18 --run-on-start kalk_gen_uskladjenje_nc_95\(\)
