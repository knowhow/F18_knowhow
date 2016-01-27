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


// -----------------------------------
// parametar datum obrade ...
// -----------------------------------
function os_set_datum_obrade()
local _dat_obr := DATE()
local _os_sii := "O"

_dat_obr := fetch_metric( "os_datum_obrade", my_user(), _dat_obr )
_os_sii := fetch_metric( "os_sii_modul", my_user(), _os_sii )

Box(, 4, 50)
    SET CURSOR ON
    @ m_x + 2, m_y + 2 SAY "Obrada (O) OS / (S) SII" GET _os_sii VALID _os_sii $ "OS" PICT "@!"
    @ m_x + 3, m_y + 2 SAY "Datum obrade  " GET _dat_obr
    READ
BoxC()

IF LastKey() <> K_ESC

    set_metric( "os_datum_obrade", my_user(), _dat_obr )
    set_metric( "os_sii_modul", my_user(), _os_sii )

    gDatObr := _dat_obr
    gOsSii := _os_sii

ENDIF

return


// -----------------------------------------
// ispisuje info na glavnom ekranu...
// -----------------------------------------
function set_os_info()
local _mod_name := PADC( "O S N O V N A    S R E D S T V A", MAXCOLS() ) 
if gOsSii == "S"
    _mod_name := PADC( "S I T A N    I N V E N T A R", MAXCOLS() )
endif

@ MAXROWS() - 2, 1 SAY _mod_name COLOR "I"

return



// -------------------------------------------
// meni parametara modula os
// -------------------------------------------
function os_parametri()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD( _opc, "1. osnovni podaci org.jedinice         " )
AADD( _opcexe, { || org_params() } )
AADD( _opc, "2. parametri os/sii" )
AADD( _opcexe, { || _os_sii_parametri() } )

f18_menu( "params", .f., _izbor, _opc, _opcexe )

return




// -----------------------------------
// parametri
// -----------------------------------
function _os_sii_parametri()
local _dat_obr := gDatObr
local _pic_iznos := gPicI
local _metoda := gMetodObr
local _id_unikat := gIBJ
local _druga_valuta := gDrugaVal
local _varijanta := gVObracun
local _obr_pocetak := gVarDio
local _obr_pocetak_datum := gDatDio
local _os_rj := gRJ

_dat_obr := fetch_metric( "os_datum_obrade", my_user(), _dat_obr )
_pic_iznos := fetch_metric( "os_prikaz_iznosa", nil, _pic_iznos )
_metoda := fetch_metric( "os_metoda_obracuna", nil, _metoda )
_id_unikat := fetch_metric( "os_id_broj_je_unikatan", nil, _id_unikat )
_druga_valuta := fetch_metric( "os_prikaz_u_dvije_valute", nil, _druga_valuta )
_varijanta := fetch_metric( "os_varijanta_obracuna", nil, _varijanta )
_obr_pocetak := fetch_metric( "os_pocetak_obracuna", nil, _obr_pocetak )
_obr_pocetak_datum := fetch_metric( "os_pocetak_obracuna_datum", nil, _obr_pocetak_datum )
_os_rj := fetch_metric( "os_radna_jedinica", nil, _os_rj )

_pic_iznos := PADR( _pic_iznos, 15 )

Box(,20,70)

    set cursor on

    @ m_x+3,m_y+2 SAY "Radna jedinica" GET _os_rj

    @ m_x+4,m_y+2 SAY "Datum obrade  " GET _dat_obr

    @ m_x+5,m_y+2 SAY "Prikaz iznosa " GET _pic_iznos

    @ m_x+7,m_y+2 SAY "Inv. broj je unikatan(jedinstven) D/N" GET _id_unikat valid _id_unikat $ "DN" pict "@!"

    @ m_x+9,m_y+2 SAY "Izvjestaji mogu i u drugoj valuti ? (D/N)" GET _druga_valuta valid _druga_valuta $ "DN" pict "@!"
 
    @ m_x+11,m_y+2 SAY "Obracun pocinje od (1) odmah / (2) od 1.u narednom mjesecu" GET _metoda valid _metoda $ "12"

    @ m_x+15,m_y+2 SAY "Varijanta 1 - sredstvo rashodovano npr 10.05, "
    @ m_x+16,m_y+2 SAY "              obracun se NE vrsi za 05 mjesec"
    @ m_x+17,m_y+2 SAY "Varijanta 2 - obracun se vrsi za 05. mjesec  " GET _varijanta  valid _varijanta $ "12" pict "@!"
    @ m_x+19,m_y+2 SAY "Obracun pocinje od datuma razlicitog od 01.01. tekuce godine (D/N)" GET _obr_pocetak valid _obr_pocetak $ "DN" pict "@!"
    @ m_x+20,m_y+2 SAY "Obracun pocinje od datuma" GET _obr_pocetak_datum WHEN _obr_pocetak == "D"

    read

    _pic_iznos := ALLTRIM( _pic_iznos )

BoxC()

if lastkey() <> K_ESC

    // set sql/db parametri

    set_metric( "os_radna_jedinica", nil, _os_rj )
    gRJ := _os_rj
    
    set_metric( "os_datum_obrade", my_user(), _dat_obr )
    gDatObr := _dat_obr

    set_metric( "os_prikaz_iznosa", nil, _pic_iznos )
    gPicI := _pic_iznos

    set_metric( "os_metoda_obracuna", nil, _metoda )
    gMetodObr := _metoda

    set_metric( "os_id_broj_je_unikatan", nil, _id_unikat )
    gIBJ := _id_unikat

    set_metric( "os_prikaz_u_dvije_valute", nil, _druga_valuta )
    gDrugaVal := _druga_valuta

    set_metric( "os_varijanta_obracuna", nil, _varijanta )
    gVObracun := _varijanta

    set_metric( "os_pocetak_obracuna", nil, _obr_pocetak )
    gVarDio := _obr_pocetak

    set_metric( "os_pocetak_obracuna_datum", nil, _obr_pocetak_datum )
    gDatDio := _obr_pocetak_datum

endif

return



