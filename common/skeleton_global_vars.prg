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


#include "f18.ch"



// ----------------------------------------------------
// setovanje podataka organizacione jedinice
// ----------------------------------------------------
function org_params( set_params )
local _x := 1
local _left := 20

if ( set_params == nil )
    set_params := .t.
endif

gZaokr := fetch_metric( "zaokruzenje", nil, gZaokr )
gFirma := fetch_metric( "org_id", nil, gFirma)
gNFirma := PADR( fetch_metric( "org_naziv", nil, gNFirma ), 50 )
gMjStr := fetch_metric( "org_mjesto", nil, gMjStr )
gTS := fetch_metric( "tip_subjekta", nil, gTS )
gTabela := fetch_metric( "tip_tabele", nil, gTabela )
gBaznaV := fetch_metric( "bazna_valuta", nil, gBaznaV )
gPDV := fetch_metric( "pdv_global", nil, gPDV )

if EMPTY( ALLTRIM( gNFirma ) )
    gNFirma := PADR( "", 50 )
    set_params := .t.
endif

// setovati parametre org.jedinice
if set_params == .t.

    Box(, 10, 70 )

        @ m_x + _x, m_y + 2 SAY "Inicijalna podesenja organizacije ***" COLOR "I"

        ++ _x
        ++ _x

        @ m_x + _x, m_y + 2 SAY PADL( "Oznaka firme:", _left ) GET gFirma
        @ m_x + _x, col() + 2 SAY "naziv:" GET gNFirma PICT "@S35"
       
        ++ _x

        @ m_x + _x, m_y + 2 SAY PADL( "Grad:", _left ) GET gMjStr PICT "@S20"
        
        ++ _x

        @ m_x + _x, m_y + 2 SAY PADL( "Tip subjekta:", _left ) GET gTS PICT "@S10"
        @ m_x + _x, col() + 1 SAY "U sistemu pdv-a (D/N) ?" GET gPDV VALID gPDV $ "DN" PICT "@!"
        
        ++ _x
        ++ _x

        @ m_x + _x, m_y + 2 SAY PADL( "Bazna valuta (D/P):" , _left ) GET gBaznaV PICT "@!" VALID gBaznaV $ "DPO"

        ++ _x

        @ m_x + _x, m_y + 2 SAY PADL( "Zaokruzenje:", _left ) GET gZaokr

        read

    BoxC()

    // snimi parametre...
    if LastKey() <> K_ESC
        set_metric( "org_id", nil, gFirma ) 
        set_metric( "zaokruzenje", nil, gZaokr ) 
        set_metric( "tip_subjekta", nil, gTS ) 
        set_metric( "org_naziv", nil, gNFirma ) 
        set_metric( "bazna_valuta", nil, gBaznaV ) 
        set_metric( "pdv_global", nil, gPDV )
        set_metric( "org_mjesto", nil, gMjStr )
    endif

endif

return .t.




// -----------------------
// -----------------------
function set_global_vars()

_kreiraj_params_tabele()

SetSpecifVars()
SetValuta()

public gFirma := "10"
public gTS := PADR( "Preduzece", 20 )
public gNFirma := PADR( "", 50 )
public gBaznaV := "D"
public gZaokr := 2
public gTabela := 0
public gPDV := "D"
public gMjStr := PADR( "Sarajevo", 30 )
public gModemVeza := "N"
public gNW := "D"

// setuj podatke ako ne postoje
org_params( .f. )

public gPartnBlock
gPartnBlock := nil

public gSecurity := "D"
public gnDebug := 0
public gOpSist := "-"

public cZabrana := "Opcija nedostupna za ovaj nivo !!!"

SetPDVBoje()

return


function SetPDVBoje()

if VALTYPE(goModul:oDesktop) != "O"
    return .f.
endif

if IsPDV()
    PDVBoje()
    goModul:oDesktop:showMainScreen()
    StandardBoje()
else
    StandardBoje()
    goModul:oDesktop:showMainScreen()
    StandardBoje()
endif

return .t.



function SetValuta()
public gOznVal := "KM"
return


function IsPDV()
if gPDV == "D"
    return .t.
endif
return .f.


