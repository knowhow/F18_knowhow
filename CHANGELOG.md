# F18 klijent, lista promjena

## 3.1.6-std, 2017-07-24

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
