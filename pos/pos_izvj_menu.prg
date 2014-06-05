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


function pos_izvjestaji()

if gModul=="HOPS"
	pos_izvjestaji_hops()
else
	pos_izvjestaji_tops()
endif
return .f.


function pos_izvjestaji_tops()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. realizacija                               ")
AADD(opcexe,{|| pos_menu_realizacija()})

if gVrstaRS=="K"
	AADD(opc,"----------------------------")
	AADD(opcexe,nil)
  	AADD(opc,"3. najprometniji artikli")
	AADD(opcexe,{|| pos_top_narudzbe() })
	AADD(opc,"4. stampa azuriranog dokumenta")
	AADD(opcexe,{|| pos_prepis_dokumenta() })
else
  	// server, samostalna kasa TOPS
	
	AADD(opc,"2. stanje artikala ukupno")
	AADD(opcexe,{|| pos_stanje_artikala_pm() })
	
  	if gVodiOdj=="D"
    		AADD(opc,"3. stanje artikala po odjeljenjima")
		AADD(opcexe,{|| pos_stanje_artikala()})
  	else
    		AADD(opc,"--------------------")
		AADD(opcexe,nil)
  	endif
  	
	AADD(opc,"4. kartice artikala")
	AADD(opcexe,{|| pos_kartica_artikla()})
	AADD(opc,"5. porezi po tarifama")
	AADD(opcexe,{|| IF(IsPDV(), PDVPorPoTar(),PorPoTar())})
	AADD(opc,"6. najprometniji artikli")
	AADD(opcexe,{|| pos_top_narudzbe()})
	AADD(opc,"7. stanje partnera")
	AADD(opcexe,{|| pos_rpt_stanje_partnera()})
	AADD(opc,"A. štampa azuriranog dokumenta")
	AADD(opcexe,{|| pos_prepis_dokumenta()})
endif

AADD(opc,"-------------------")
AADD(opcexe,nil)

if gPVrsteP
  AADD(opc,"N. pregled prometa po vrstama plaćanja")
  AADD(opcexe,{|| PrometVPl()})
endif

if fiscal_opt_active()
    AADD(opc,"F. fiskalni izvještaji i komande")
    AADD(opcexe,{|| fiskalni_izvjestaji_komande( NIL, .t. ) })
endif

Menu_SC("izvt")
return .f.



function pos_izvjestaji_hops()
private opc:={}
private opcexe:={}
private Izbor:=1

// Provjeravam usaglasenost podataka
UPodataka() 

AADD(opc,"1. realizacija                         ")
AADD(opcexe,{|| pos_menu_realizacija()})
AADD(opc,"2. stanje racuna gostiju")
//HOPS - Stanje racuna gostiju ... ovo niko ne koristi ...
AADD(opcexe,{|| I_RNGostiju() })
if gVrstaRS=="K"
	AADD(opc,"----------------------------")
	AADD(opcexe,nil)
  	AADD(opc,"4. najprometniji artikli")
	AADD(opcexe,{|| pos_top_narudzbe() })
else
  	// server, samostalna kasa
  	AADD(opc,"3. stanje artikala ukupno")
	AADD(opcexe,{|| pos_stanje_artikala_pm() })
  	if gVodiOdj=="D"
    		AADD(opc,"4. stanje artikala po odjeljenjima")
		AADD(opcexe,{|| pos_stanje_artikala()})
  	else
    		AADD(opc,"--------------------")
		AADD(opcexe,nil)
  	endif
  	AADD(opc,"5. kartice artikala")
	AADD(opcexe,{|| pos_kartica_artikla()})
	AADD(opc,"6. porezi po tarifama")
	AADD(opcexe,{|| IF(IsPDV(), PDVPorPoTar(), PorPoTar())})
	AADD(opc,"7. najprometniji artikli")
	AADD(opcexe,{|| pos_top_narudzbe()})
endif

AADD(opc,"8. stanje partnera")
AADD(opcexe,{|| pos_rpt_stanje_partnera()})
AADD(opc,"A. stampa azuriranog dokumenta")
AADD(opcexe,{|| pos_prepis_dokumenta()})

Menu_SC("izvh")
return



function UPodataka()

if gModul=="HOPS"
	xx:=m_x 
	yy:=m_y
  	MsgO("Da provjerimo usaglasenost podataka...")
    	O_POS 
	O_POS_DOKS
    	SET ORDER TO TAG "4"
    	SEEK "42"+OBR_NIJE
  	MsgC()
  	if pos_doks->(FOUND())
    		// ima neobradjenih racuna ili su racuni mijenjani!!!
    		close all
    		GenUtrSir(gDatum,gDatum,gSmjena)
  	endif
  	close all
  	m_x:=xx
	m_y:=yy
  	@ m_x+1,m_y+1 SAY ""
endif
return
*}

