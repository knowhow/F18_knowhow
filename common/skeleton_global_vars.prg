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
gZaokr := fetch_metric( "zaokruzenje", nil, gZaokr)
gFirma := fetch_metric( "firma_id", nil, gFirma)
gNFirma := fetch_metric( "firma_naziv", nil, gNFirma)
gTS := fetch_metric( "tip_subjekta", nil, gTS)
gTabela := fetch_metric( "tip_tabele", nil, gTabela)

if (gModul <> "POS" .and. gModul <> "TOPS" .and. gModul <> "HOPS" )
	if empty(gNFirma)
	  Box(,1,50)
	    Beep(1)
	    @ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
	    read
	  BoxC()
	  set_metric( "firma_naziv", nil, gNFirma )
	endif
endif

if gModul <> "TOPS" 

	gPDV := fetch_metric( "pdv_global", nil, gPDV )
	ParPDV()
	set_metric( "pdv_global", nil, gPDV )

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


