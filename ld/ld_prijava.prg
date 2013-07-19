/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */



#include "ld.ch"


// ----------------------------------------
// funkcija za prijavu u obracun
// ----------------------------------------
function ParObracun()
local _x := 1
local _pad_l := 20
local _v_obr_unos := fetch_metric( "ld_vise_obracuna_na_unosu", my_user(), "N" ) == "D"

O_LD_RJ

Box(, 6 + IF( _v_obr_unos, 1, 0 ), 50 )

    SET CURSOR ON
   
    @ m_x + _x, m_y + 2 SAY PADC( "*** PRISTUPNI PODACI ZA OBRACUN ***", 50 )
 
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADL( "Radna jedinica", _pad_l ) GET gRJ VALID P_LD_Rj( @gRj ) PICT "@!"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADL( "Mjesec", _pad_l ) GET gMjesec pict "99"
    
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY PADL( "Godina", _pad_l ) GET gGodina pict "9999"
    
    // varijanta obracuna nam ne treba, imamo je u parametrima
    //++ _x
    //@ m_x + _x, m_y + 2 SAY PADL( "Varijanta obracuna", _pad_l ) GET gVarObracun

    // samo ako treba odabirati obracune u parametrima onda prikazi i ovo
    if _v_obr_unos

        ++ _x
        
        @ m_x + _x, m_y + 2 SAY PADL( "Obracun broj", _pad_l ) GET gObracun ;
                WHEN HelpObr( .f., gObracun ) VALID ValObr( .f., gObracun )

    endif

    READ
    
    ClvBox()
    
BoxC()

if LASTKEY() <> K_ESC
        
    set_metric( "ld_godina", my_user(), gGodina )
    set_metric( "ld_mjesec", my_user(), gMjesec )
    set_metric( "ld_rj", my_user(), gRj )
    set_metric( "ld_obracun", my_user(), gObracun )
    set_metric( "ld_varijanta_obracuna", NIL, gVarObracun ) 

endif

if gZastitaObracuna == "D"
    IspisiStatusObracuna( gRj, gGodina, gMjesec )
endif

return



function IspisiStatusObracuna(cRj,nGodina,nMjesec)

if GetObrStatus( cRj, nGodina, nMjesec ) $ "ZX"
    cStatusObracuna := "Obracun zakljucen !!!    "
    cClr := "W/R"
endif

if GetObrStatus( cRj, nGodina, nMjesec ) $ "UP"
    cStatusObracuna := "Obracun otvoren          "
    cClr := "W/B"
endif

if GetObrStatus( cRj, nGodina, nMjesec )=="N"
    cStatusObracuna := "Nema otvorenog obracuna !"
    cClr := "W/R"
endif

@ 24,1 SAY cStatusObracuna COLOR cClr

return



