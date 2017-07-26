# F18 klijent, lista promjena

## 3.1.20-vindi, 2017-07-26

### Korisnik
#### KALK

- koncij.region za konto npr 13202 = "RS" => vpc stampa dokumenta
- dokumenti 95, 96, 16, 11

### Developer

Merge from 3-std fix barkod, ftxt

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

## 3.1.17-vindi, 2017-07-26

### Developer

#### KALK
- kalk finansijsko stanje magacin Rbr C(6), vpc_magacin_rs()

## 3.1.15-vindi, 2017-07-25

### Developer

#### CORE
- FIX info_bar u toku start_print() ... end_print()

#### KALK
- NAKUKURIKATI: vpc_magacin_rs(), TKV po prodajnim RS, lager lista magacin

## 3.1.11-vindi, 2017-07-25

### Developer
- BUGFIX KALK lager lista cOpcine

## 3.1.8-vindi, 2017-07-25

### Korisnik

#### KALK
- Trgovačka knjig na veliko i malo (TKV, TKM)  export u XLSX

### Developer
- BUGFIX: Dokument 80 unos tarifa alias not found

### Korisnik

#### KALK
- Trgovačka knjig na veliko i malo (TKV, TKM)  export u XLSX

### Developer
- BUGFIX: Dokument 80 unos tarifa alias not found

## 3.1.7-vindi, 2017-07-24

### Korisnik

#### CORE
- F18 upgrade - ako je F18 patch broj instalirana > F18 aktuelna ne predlagati downgrade.

Primjer:

Ako je aktuelna verzija za tekući kanal (npr. S) 3.1.5, a trenutno instalirana verzija je 3.1.10, tada se ne predlaže downgrade na 3.1.5.

### Developer
- f18_update.prg - nove funkcije f18_builtin_version_h, f18_available_version_h,  f18_preporuci_upgrade( cVersion )
- OUT: f18_admin.prg upgrade_db

## 3.1.4-vindi, 2017-07-24

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

## 3.0.10-vindi, 2017-07-24

### Korisnik
#### KALK
- BUGFIX import vindija varaždin kalk_imp_txt.tipdok 96, ignorisati partnera

### Developer
- iz std verzije izbacena opcija import vindija varazdin

## 3.0.9-vindi, 2017-07-24

### Korisnik

#### FIN
- BUGFIX run sintetički, analitički bruto bilans
- BUGFIX lista naloga sa provjerom integriteta

### Developer

- "trijebljenje" do iznemoglosti select_o_partner(), select_o_konto()


## Legenda

Korisnik - promjene značajne za korisnike

Developer - tehničke bilješke, promjene bitne za podršku i razvoj
