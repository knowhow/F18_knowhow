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
private opc:={}
private opcexe:={}
private Izbor:=1

// obezbijedimo da se prodavac nalazi u radnom podrucju ! 
if gRadnoPodr<>"RADP"
	goModul:oDatabase:logAgain(STR(YEAR(DATE()),4),.t.,STR(YEAR(DATE()),4))
endif

if gRadniRac=="D"
	AADD(opc,"1. narudzba                           ")
    	AADD(opcexe,{|| pos_narudzba() })
    	AADD(opc,"2. zakljuci racun")
    	AADD(opcexe,{|| ZakljuciRacun() })
else
	private aRabat:={}
    	AADD(opc,"1. priprema racuna                        ")
    	AADD(opcexe,{|| pos_narudzba(), ZakljuciRacun() })
	if gStolovi == "D"
		AADD(opc,"2. zakljucenje - placanje stola ")
    		AADD(opcexe,{|| g_zak_sto() })
	endif
endif

AADD(opc,"3. promijeni nacin placanja")
AADD(opcexe,{|| PromNacPlac() })
AADD(opc,"4. prepis racuna           ")
AADD(opcexe,{|| PrepisRacuna() })
if (gModul == "HOPS" .and. gBrojSto=="D") .and. gRadniRac=="N"
	AADD(opc,"5. zakljucivanje racuna    ")
	AADD(opcexe,{|| MnuZakljRacuna() })
endif
AADD(opc,"T. trenutni pazar smjene")
AADD(opcexe,{|| realizacija_radnik(.t., "P", .f.) })

AADD(opc,"R. trenutna realizacija po robama")
AADD(opcexe,{|| realizacija_radnik(.t.,"R",.f.) })

if IsPdv()
	AADD(opc,"P. porezna faktura za posljednji racun")
	AADD(opcexe, {|| f7_pf_traka()})
endif

if gFc_use == "D"
	AADD(opc,"T. kopija fiskalnog racuna")
	AADD(opcexe, {|| fisc_rn_kopija()})
endif	 

Menu_SC("prod")

if gRadniRac=="N" .and. gVodiTreb=="D"
	O_DIO
    O_ODJ
    O__POS
    Trebovanja()
endif

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

