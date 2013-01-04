# F18 source

## Podešenja developerskog okruženja

- podesiti `vim`
   - [~/.vimrc](.vimrc)
   - instalirati pluginove definisane u  `:BundleInstall`
- instalirati ctags
   - na mac-u izbrisati /usr/bin/ctags
   - `brew install ctags`
   - podešenja za harbour - [~/.ctags](.ctags)

- instalirati cscope (`brew install cscope`)
- u `F18_knowhow` pokrenuti `scripts/update_cscope_ctags.sh`   
   
## Konvencije i napomene

  - U primjerima se koristi baza `f18_test`
  - HRB - karakteristika programskog jezika harbour
  - Linije koje počinju sa `:` su `vim` komande
  - `vim` editor je pokrenut unutar `F18_knowhow` direktorija čije je stablo:
     - `common/`
     - `fakt/`
     - `fin/`
     - `…`   
   
## FMK, Clipper, F18, harbour

F18 je pisan u programskom jeziku [harbour](http://en.wikipedia.org/wiki/Harbour_compiler).

Aplikativni kod [F18](https://github.com/knowhow/F18_knowhow) je u oktobru 2011 portiran iz [FMK](https://github.com/bringout-fmk)[1].FMK je napisan u programskom jeziku [Clipper (ver 5.2e za DOS)](http://en.wikipedia.org/wiki/Clipper_(programming_language). Glavni problemi FMK su:

  - Aplikacije se izvršavaju DOS protected mod 16-bit
  - Problemi sa integritetom i brzinom u mrežnom radu, ograničenja veličine pojedinačne tabele 1GB (u varijanti mrežnog rada, ponovo)
  - TUI (Text User interfejs)
  
 
## DBF, PostgreSQL

DBF fajlovi su ne-relacijske baze podataka. U F18 praktično služe kao lokalni keš koji F18 klijent koristi za prikaz.

F18 podaci su smješteni na PostgreSQL server. SQL DDL komande se nalaze unutar repozitorija krajnje neintuitivnog imena [fmk](https://github.com/knowhow/fmk/tree/master/database/misc). 

Sa ovim server sql update skriptama se rukuje uz pomoć [updater](https://github.com/knowhow/updater) projekta koji je "uzet" iz [xTuple](http://www.xtuple.org) projekta.

Binarna verzija updatera nalazi se na [google code download](http://code.google.com/p/knowhow-erp/downloads/list?can=2&q=package+updater) sekciji projekta.

## Sinhronizacija dbf<-> sql putem "semafora"

Sinhronizacija lokalnih i sql tabela obavlja se logikom semafora. Odgovarajuće lokacije u source kodu:

  - `:tjump /get_semaphore_status`
  - `:tj ids_synchro`
  - `:tj push_ids_to_semaphore`

Standardna sekvenca korištenja dbf-a (HRB)

`use dbf ALIAS dbf_alias`
 
je u F18 zamjenjen sa `my_use`. Izvorni kod funkcije ćete naći sa

`:tjump my_use`

## alias, ime dbf

Termini:

  - `WORKAREA` - radno područje otvorene dbf tabele (HRB)
  - `Ime dbf-a` - fizičko ime tabele na disku
  - `alias` - alias pod kojim se tabelom rukuje unutar source koda (HRB)
  - `SELECT DRN` - prebaci se na WORKAREA dbf tabele čiji je alias `DRN`

U ~/.f18/f18_test nalazi se `dracun.dbf`, `dracun.cdx`:

 - dbf - tabela, mjesto gdje su smješteni podaci
 - cdx - indeksni fajl dbf-a

Kako je ova tabela definsana u okviru F18 ?

Locirajmo set_a_dbf_funkciju u kojoj se definiše "dracun" dbf: 

`:cs find e set_a_dbf.*dracun`

rezultat (`common/set_a_dbf_temporary.prg`) pretrage:

=> `set_a_dbf_temp("dracun"     ,  "DRN"         , F_DRN        )`

U set_a_dbf, i set_a_dbf_temp[2] funkcijama su definisana mapiranja dbf-ova

----

 - [1^]: kao svojevrsni eksperiment tokom migracije podataka FMK u knowhowERP (xTuple klijent)
 - [2^]: temp tabele - privremene tabele, tabele čiji se podaci sinhronizacijom ne šalju na server
 
