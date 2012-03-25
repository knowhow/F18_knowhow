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
local nX := 1
local nPadL := 20

O_LD_RJ

Box(, 5, 50 )

    SET CURSOR ON
    
    @ m_x + nX, m_y + 2 SAY PADL( "Radna jedinica", nPadL ) GET gRJ VALID P_LD_Rj( @gRj ) pict "@!"
    
    ++nX

    @ m_x + nX, m_y + 2 SAY PADL( "Mjesec", nPadL ) GET gMjesec pict "99"
    
    ++nX
    
    @ m_x + nX, m_y + 2 SAY PADL( "Godina", nPadL ) GET gGodina pict "9999"
    
    ++nX

    @ m_x + nX, m_y + 2 SAY PADL( "Varijanta obracuna", nPadL ) GET gVarObracun

    ++nX
        
    @ m_x + nX, m_y + 2 SAY PADL( "Obracun broj", nPadL ) GET gObracun ;
            WHEN HelpObr( .f., gObracun ) VALID ValObr( .f., gObracun )
    
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

if gZastitaObracuna=="D"
    IspisiStatusObracuna(gRj, gGodina, gMjesec)
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



