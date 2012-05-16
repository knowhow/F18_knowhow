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


#include "fmk.ch"


// --------------------------------------------------------------------
// tekuci parametri ugovora
// --------------------------------------------------------------------
function DFTParUg( lIni )
local GetList := {}

if lIni == nil
	lIni:=.f.
endif

if !lIni
	private DFTkolicina := 1
    private DFTidroba := PADR("",10)
    private DFTvrsta := "1"
    private DFTidtipdok := "10"
    private DFTdindem := "KM "
    private DFTidtxt := "10"
    private DFTzaokr := 2
    private DFTiddodtxt := "  "
	private gGenUgV2 := "2"
	private gFinKPath := SPACE(50)
endif

DFTKolicina := fetch_metric("ugovori_kolicina", nil, DFTkolicina )
DFTidroba := fetch_metric("ugovori_id_roba", nil, DFTidroba )
DFTvrsta := fetch_metric( "ugovori_vrsta", nil, DFTvrsta )
DFTidtipdok := fetch_metric("ugovori_tip_dokumenta", nil, DFTidtipdok )
DFTdindem := fetch_metric("ugovori_valuta", nil, DFTdindem )
DFTidtxt := fetch_metric("ugovori_napomena_1", nil, DFTidtxt )
DFTzaokr := fetch_metric("ugovori_zaokruzenje", nil, DFTzaokr )
DFTiddodtxt := fetch_metric("ugovori_napomena_2", nil, DFTiddodtxt )
gGenUgV2 := fetch_metric("ugovori_varijanta_2", nil, gGenUgV2 )

if !lIni

	Box(,11,75)
     	@ m_x+ 0,m_y+23 SAY "TEKUCI PODACI ZA NOVE UGOVORE"
     	@ m_x+ 2,m_y+ 2 SAY PADL("Artikal" , 20) GET DFTidroba VALID EMPTY(DFTidroba) .or. P_Roba(@DFTidroba,2,28) PICT "@!"
     	@ m_x+ 3,m_y+ 2 SAY PADL("Kolicina", 20) GET DFTkolicina PICT pickol
     	@ m_x+ 4,m_y+ 2 SAY PADL("Tip ug.(1/2/G)", 20) GET DFTvrsta VALID DFTvrsta$"12G"
     	@ m_x+ 5,m_y+ 2 SAY PADL("Tip dokumenta", 20) GET DFTidtipdok
     	@ m_x+ 6,m_y+ 2 SAY PADL("Valuta", 20) GET DFTdindem PICT "@!"
     	@ m_x+ 7,m_y+ 2 SAY PADL("Napomena 1", 20) GET DFTidtxt VALID P_FTXT(@DFTidtxt)
     	@ m_x+ 8,m_y+ 2 SAY PADL("Napomena 2", 20) GET DFTiddodtxt VALID P_FTXT(@DFTiddodtxt)
     	@ m_x+ 9,m_y+ 2 SAY PADL("Zaokruzenje", 20) GET DFTzaokr PICT "9"
     	@ m_x+10,m_y+ 2 SAY PADL("gen.ug. ver 1/2", 20) GET gGenUgV2 PICT "@!" VALID gGenUgV2 $ "12"
     	READ
    BoxC()

	// snimi promjene
    if LASTKEY()!=K_ESC
    
		set_metric("ugovori_kolicina", nil, DFTkolicina )
		set_metric("ugovori_id_roba", nil, DFTidroba )
		set_metric("ugovori_vrsta", nil, DFTvrsta )
		set_metric("ugovori_tip_dokumenta", nil, DFTidtipdok )
		set_metric("ugovori_valuta", nil, DFTdindem )
		set_metric("ugovori_napomena_1", nil, DFTidtxt )
		set_metric("ugovori_zaokruzenje", nil, DFTzaokr )
		set_metric("ugovori_napomena_2", nil, DFTiddodtxt )
		set_metric("ugovori_varijanta_2", nil, gGenUgV2 )

	endif
    
endif

return



