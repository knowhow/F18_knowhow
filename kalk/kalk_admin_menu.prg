/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "kalk.ch"


function MAdminKALK()
private Opc:={}
private opcexe:={}
AADD(Opc,"1. instalacija db-a                               ")
AADD(opcexe, {|| goModul:oDatabase:install()})
AADD(Opc,"3. markiraj polje roba/sez - sifk")
AADD(opcexe, {|| MPSifK()})
AADD(Opc,"4. ubaci partnera iz dokumenata u sifrarnik robe")
AADD(opcexe, {|| DobUSifK()})
AADD(opc,"5. sredjivanje kartica")
AADD(opcexe, {|| MenuSK() })
AADD(opc,"6. generacija kumulativne baze")
AADD(opcexe, {|| Gen9999()})
AADD(opc,"7. setmarza10")
AADD(opcexe, {|| SetMarza10()})
AADD(opc,"8. brisanje artikala koji se ne koriste")
AADD(opcexe, {|| Mnu_BrisiSifre()})
AADD(opc,"9. konverzija polja SIFRADOB")
AADD(opcexe, {|| c_sifradob()})
AADD(opc,"A. Set pdv cijene mpc/mpc2 u sifrarniku artikala")
AADD(opcexe, {|| SetPdvCijene()})
AADD(opc,"B. Pomnozi sa faktorom mpc/mpc2 u sifrarniku artikala")
AADD(opcexe, {|| SetPomnoziCijene()})
AADD(opc,"D. Brisi dokumente za period")
AADD(opcexe, {|| del_docs()})
AADD(opc,"T. export kalk baza podataka")
AADD(opcexe, {|| kalk_export()})
AADD(opc,"U. spajanje kalk baza podataka iz sezona")
AADD(opcexe, {|| kalk_join()})

private Izbor:=1
Menu_SC("admk")
close all
return


function MenuSK()

PRIVATE Opc:={}
PRIVATE opcexe:={}
AADD(Opc,"1. korekcija prodajne cijene - nivelacija (VPC iz sifr.robe)    ")
AADD(opcexe, {|| KorekPC() })
AADD(Opc,"2. ispravka sifre artikla u dokumentima i sifrarniku")
AADD(opcexe, {|| RobaIdSredi() })
AADD(Opc,"3. korekcija nc storniranjem gresaka tipa NC=0   ")
AADD(opcexe, {|| KorekNC() })
AADD(Opc,"4. korekcija nc pomocu dok.95 (NC iz sifr.robe)")
AADD(opcexe, {|| KorekNC2() })
AADD(Opc,"5. korekcija prodajne cijene - nivelacija (MPC iz sifr.robe)")
AADD(opcexe, {|| KorekMPC() })
AADD(Opc,"6. postavljanje tarife u dokumentima na vrijednost iz sifrarnika")
AADD(opcexe, {|| KorekTar() })
AADD(Opc,"7. svodjenje artikala na primarno pakovanje")
AADD(opcexe, {|| NaPrimPak() })

private Izbor:=1
Menu_SC("kska")

close all
return



