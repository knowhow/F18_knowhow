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
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc,"1. sredjivanje kartica                                            ")
AADD( _opcexe, {|| MenuSK() })
AADD( _opc,"2. ubaci partnera iz dokumenata u sifrarnik robe")
AADD( _opcexe, {|| DobUSifK()})
AADD( _opc,"3. brisanje artikala koji se ne koriste")
AADD( _opcexe, {|| Mnu_BrisiSifre()})
AADD( _opc,"4. konverzija polja SIFRADOB")
AADD( _opcexe, {|| c_sifradob()})
AADD( _opc,"5. kopiraj set cijena iz/u")
AADD( _opcexe, {|| kopiraj_set_cijena()})
AADD( _opc,"6. pomnozi sa faktorom mpc/mpc2 u sifrarniku artikala")
AADD( _opcexe, {|| SetPomnoziCijene()})
AADD( _opc,"7. export kalk baza podataka")
AADD( _opcexe, {|| kalk_export()})
AADD( _opc,"8. kontrola maloprodajnih cijena ")
AADD( _opcexe, {|| sifre_artikli_provjera_mp_cijena() })
AADD( _opc,"9. kontrola duplih barkodova ")
AADD( _opcexe, {|| rpt_dupli_barkod() })
AADD( _opc,"10. formiraj MPC iz VPC ")
AADD( _opcexe, {|| roba_setuj_mpc_iz_vpc() })

f18_menu("admk", .f., _izbor, _opc, _opcexe )

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



