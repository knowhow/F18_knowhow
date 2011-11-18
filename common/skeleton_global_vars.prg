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



// -----------------------
// -----------------------
function set_global_vars()

CreParams()

SetSpecifVars()
SetValuta()

public gFirma := "10"
public gTS := "Preduzece"
public gNFirma := space(20)  
public gZaokr := 2
public gTabela := 0
public gPDV := ""

// novi parametri...
f18_get_metric("Zaokruzenje", @gZaokr)
f18_get_metric("FirmaID", @gFirma)
f18_get_metric("FirmaNaziv", @gNFirma)
f18_get_metric("TipSubjekta", @gTS)
f18_get_metric("TipTabele", @gTabela)

if (gModul <> "POS" .and. gModul <> "TOPS" .and. gModul <> "HOPS" )
	if empty(gNFirma)
	  Box(,1,50)
	    Beep(1)
	    @ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
	    read
	  BoxC()
	  f18_set_metric( "FirmaNaziv", gNFirma )
	endif
endif

if gModul <> "TOPS" 

	f18_get_metric( "PDVGlobal", @gPDV )
	ParPDV()
	f18_set_metric( "PDVGlobal", gPDV )

endif

public gPartnBlock
gPartnBlock := nil

public gSecurity := "D"
public gnDebug := 0

gnDebug:=VAL(IzFmkIni("Svi","Debug","0",EXEPATH))

public gOpSist := "-"
gOpSist:=IzFmkIni("Svi","OS","-",EXEPATH)

public cZabrana := "Opcija nedostupna za ovaj nivo !!!"

public gNovine := "N"

if gModul<>"TOPS"
	if goModul:oDataBase:cRadimUSezona == "RADP"
		SetPDVBoje()
	endif
endif

return


function SetPDVBoje()

if IsPDV()
	PDVBoje()
	goModul:oDesktop:showMainScreen()
	StandardBoje()
else
	StandardBoje()
	goModul:oDesktop:showMainScreen()
	StandardBoje()
endif
return



function SetValuta()

// ako se radi o planici Novi Sad onda je naziv valute DIN
public gOznVal
gOznVal:="KM"

return



/*! \fn ParPDV()
 *  \brief Provjeri parametar pdv
 */
function ParPDV()

if (gPDV == "") .or. (gPDV $ "ND" .and. gModul=="TOPS")
	// ako je tekuci datum >= 01.01.2006
	if DATE() >= CToD("01.01.2006")
		gPDV := "D"
	else
		gPDV := "N"
	endif
endif
return



/*! \fn IsPDV()
 *  \brief Da li je pdv rezim rada ili ne
 *  \ret .t. or .f.
 */
function IsPDV()

if gPDV=="D"
	return .t.
endif
return .f.


