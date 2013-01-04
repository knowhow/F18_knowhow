# F18 source

## vim podešenje

podesiti vim za cscope, ctags [.vimrc](.vimrc)

## Napomene

  - U primjerima se koristi baza `f18_test`
  - HRB - karakteristika programskog jezika harbour

## dbf navigacija

## dbf tabela - alias, ime tabele

Termini:

  - `WORKAREA` - radno područje otvorene dbf tabele (HRB)
  - `Ime dbf-a` - fizičko ime tabele na disku
  - `alias` - alias pod kojim se tabelom rukuje unutar source koda (HRB)
  - `SELECT DRN` - prebaci se na WORKAREA dbf tabele čiji je alias `DRN`

U ~/.f18/f18_test nalazi se `dracun.dbf`, `dracun.cdx`:

 - dbf - tabela, mjesto gdje su smješteni podaci
 - cdx - indeksni fajl dbf-a

Kako je ova tabela definsana u okviru F18 ?

Locirajmo set_a_dbf_funkciju u kojoj se definiše dracun: 

`:cs find e set_a_dbf.*racun`

rezultat (u `common/set_a_dbf_temporary.prg`):

`set_a_dbf_temp("dracun"     ,  "DRN"         , F_DRN        )`

U set_a_dbf, i set_a_dbf_temp[1^] funkcijama su definisana mapiranja dbf-ova

----

[1^]: temp tabele - koje ne "idu" na server
 
