# F18 klijent, lista promjena

## 3.1.38-std, 2017-08-01

### Developer
#### FAKT
- FIX FAKT_FTXT->naz
- fakt_valid_roba
- fakt cleanup usluge hFaktTtxt[ 'opis_usluga' ]

## 3.1.37-std, 2017-07-31

### Korisnik
#### FIN
- FIX browse <c+F> oBrowse
- Obračun bring.out 07/2017 realizovan sa ovom verzijom


### Developer
#### FIN, FAKT-FIN kontiranje
- Skontao HACK: trfp2 zbog kojeg je zaokruzivao fakt-fin na jednu decimalu. 
  - Ako se na kraju opisa trfp2, odnosno fin_pripr stavi jedan od znakova "0125", izvrsice se zaokruzenje round 0,1,2 ili round5. Uh.
 

## 3.1.36-std, 2017-07-31

### Korisnik
#### FIN
- FIX p_fin_vrsta_naloga 

### Developer
#### Korisnik
- p_sifra fix SEEK cId

## 3.1.35-std, 2017-07-31

### Korisnik
#### FIN
- Unos novog naloga zabrana unosa praznog naloga

### Developer
#### FIN
- FIN nalog unos !prazan konto
- FIN priprema cleanup, OUT_PRIV_VAR: fNovi 

## 3.1.34-std, 2017-07-31

### Korisnik
#### FIN
- Fix fin_specif_proizv_sort

### Developer
#### FIN
- fix hb_default( @cTipDomacaStranaObje, 1 ) // jednovalutni prikaz - KM

## 3.1.33-std, 2017-07-30

- cleanup sastavnice - sastavnice_print.prg, tag "IDRBR"
- cleanup fiskalne funkcije

## 3.1.32-std, 2017-07-30

- fix stanje, lager, uporedna kalk - fakt
- commit x 2 "FAKT sql big-bang-02" trijebljenje svih seek-ova fakt, fakt_doks, fakt_doks2 
 - 74 files +1861 -1862
 - 16 files +255 - 347 


## 3.1.31-std, 2017-07-29

### Developer

#### FAKT
- commit "FAKT sql big-bang-01" [3 91e2c85a7 , 99 files changed, 2147 insertions(+), 1527 deletions(-)
- Ažuriranje i dalje radi sa semaforima
- uvedene funkcije seek_fakt, seek_fakt_3 ( tag "3" ), seek_fakt_doks( cIdFirma, cIdTipDok, cBrDok )
- Kartica - SQL
- Pregled tabelarni sql FAKT_DOKS_PREGLED alias
- COOL fazon u fakt_pregled_reload_tables( cFilter ) - kodni blok Eval( s_bFaktDoksPeriod )


## 3.1.29-std, 2017-07-28

#### Developer
- my_browse - fakt pregled tabela - ok
- my_browse - sinhronizacija ftxt - inkey(0) vs inkey()
- pos prebačeni svi šifarnici na sql set_a_sql_sifarnik( ... )
- Čišćenje fakt_ftxt do iznemoglosti
- sastavnice
- adresar
- NEW_ALIAS: F_FAKT_TXT, fakt_txt, FAKT_TXT


## 3.1.10-std, 2017-07-26

### Developer
#### KALK

- MERGE_BRANCH 3-vindi: koncij.region za konto npr 13202 = "RS" => vpc stampa dokumenta
- MERGE_BRANCH 3-vindi: dokumenti 95, 96, 16, 11

## 3.1.17-std, 2017-07-25

### Developer

#### CORE
- RENAME_FUN_VARS: num_to_str( nNumber, nLen, nDec )
- define NRED_DOS

#### FAKT
- Debug štampa fiskalnog iz liste !OK #36677
- Debug #36676 štampa barkod labela, FAKT priprema ALT+L ne radi
- NEW_PRG_FILE: _fakt_sql.prg, fakt_ftxt.prg
- select_o_fakt_txt()
- RENAME_FUN_NAME to fakt_a_to_public_var_txt(), p_fakt_ftxt()
- fakt_txt_fill_djokeri( nSaldoKup, nSaldoDob, dPUplKup, dPPromKup, dPPromDob, dLUplata, cPartner )
- fakt_ftxt_encode( cFTxtNaz, cTxt1, cTxt3a, cTxt3b, cTxt3c, cVezaUgovor, cDodTxt )
- RENAME_FUN_NAME: ParsMemo -> fakt_ftxt_decode( cTxt ) => aMemo
- RENAME_VAR: _memo -> aMemo
- FUN_ADD: find_fakt_ftxt_by_id

#### FIN
- CLEANUP: fin_bruto_bilans_subanalitika_b.prg


## 3.1.10-std, 2017-07-25

### Developer
- BUGFIX KALK lager lista cOpcine

## 3.1.9-std, 2017-07-25

### Korisnik

#### KALK
- Trgovačka knjig na veliko i malo (TKV, TKM)  export u XLSX

### Developer
- BUGFIX: Dokument 80 unos tarifa alias not found

## 3.1.6-std, 2017-07-24

### Korisnik

#### CORE
- F18 upgrade - ako je F18 patch broj instalirana > F18 aktuelna ne predlagati downgrade.

Primjer:

Ako je aktuelna verzija za tekući kanal (npr. S) 3.1.5, a trenutno instalirana verzija je 3.1.10, tada se ne predlaže downgrade na 3.1.5.

### Developer
- f18_update.prg - nove funkcije f18_builtin_version_h, f18_available_version_h,  f18_preporuci_upgrade( cVersion )
- OUT: f18_admin.prg upgrade_db
- razvoj prebačen u zajednički branch `3`

## 3.0.11-std, 2017-07-24

### Korisnik

#### CORE
- BUGFIX: F18 upgrade za različite kanale
- OUT: izbačen F18 template update iz priče

### Developer
- f18_admin.prg cleanup:
  - iz upotrebe izbačen UPDATE_INFO
  - templates.zip se više ne koristi, nema ga u formi za upgrade
  - lokacija F18 verzija http://download.bring.out.ba/ hardkodirana
  - OUT: update_db

## 3.0.8-std, 2017-07-24

### Korisnik

#### KALK
- specifična opcija import vindija varazdin izbačeno iz standardne verzije

#### FIN
- BUGFIX run sintetički, analitički bruto bilans
- BUGFIX lista naloga sa provjerom integriteta

### Developer
- OUT: kalk/kalk_imp_txt_racuni.prg, kalk/kalk_imp_txt_roba_partn.prg
- "trijebljenje" do iznemoglosti select_o_partner(), select_o_konto()

## Legenda

Korisnik - promjene značajne za korisnike

Developer - tehničke bilješke, promjene bitne za podršku i razvoj
