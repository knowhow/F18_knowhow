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


#include "pos.ch"


function pos_main_menu_prodavac()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. priprema racuna                        ")
AADD(_opcexe, {|| pos_narudzba(), zakljuciracun(), .t. } )
	
if gStolovi == "D"
	AADD(_opc,"2. zakljucenje - placanje stola ")
    AADD(_opcexe,{|| g_zak_sto() })
endif

AADD(_opc,"2. pregled azuriranih racuna  ")
AADD(_opcexe,{|| pos_pregled_racuna(.f.) })

AADD(_opc,"-------------------------------------------")
AADD(_opcexe,{|| nil })

AADD(_opc,"5. trenutna realizacija radnika")
AADD(_opcexe,{|| realizacija_radnik( .t., "P", .f. ) })

AADD(_opc,"6. trenutna realizacija po artiklima")
AADD(_opcexe,{|| realizacija_radnik( .t., "R", .f. ) })

//AADD(opc,"7. porezna faktura za posljednji racun")
//AADD(opcexe, {|| f7_pf_traka()})

AADD(_opc,"-------------------------------------------")
AADD(_opcexe,{|| nil })


if fiscal_opt_active()

	AADD(_opc,"F. fiskalne opcije za prodavaca")
	AADD(_opcexe, {|| fisc_rpt( .t., .t. ) })

endif	 

f18_menu( "prod", .f., _izbor, _opc, _opcexe )

close all
return





function MnuZakljRacuna()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. napravi zbirni racun            ")
AADD(opcexe,{|| RekapViseRacuna() })
AADD(opc,"2. pregled nezakljucenih racuna    ")
AADD(opcexe,{|| PreglNezakljRN() })
AADD(opc,"3. setuj sve RN na zakljuceno      ")
AADD(opcexe,{|| SetujZakljuceno() })

Menu_SC("zrn")

return

