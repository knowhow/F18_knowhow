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


#include "ld.ch"


// ------------------------------------------------------
// specifikacija kredita 
// ------------------------------------------------------
function ld_kred_specifikacija()
local _params := hb_hash()
local _data

// parametri
if !_get_vars( @_params )
    return
endif

// daj mi podatke...
_data := _get_data( _params )

if _data:LastRec() == 0
    return
endif

// prikaz podataka...
_print_data( _data, _params )

return



// ------------------------------------------------------
// podaci...
// ------------------------------------------------------
static function _get_data( params )
local _data := {}
local _qry
local _where
local _order
local _server := pg_server()

// where condition
_where := " lk.godina = " + ALLTRIM( STR( params["godina"] ))
_where += " AND lk.mjesec = " + ALLTRIM( STR( params["mjesec"] ) )

if !EMPTY( params["kreditor"] )
    _where += " AND lk.idkred = " + _sql_quote( params["kreditor"] )
endif

if !EMPTY( params["radnik"] )
    _where += " AND lk.idradn = " + _sql_quote( params["radnik"] )
endif


// order condition
if params["tip_sorta"] == 1
    _order := " lk.idradn, lk.idkred, lk.naosnovu "
else
    _order := " lk.idkred, lk.idradn, lk.naosnovu "
endif

_qry := "SELECT " + ;
        " lk.idradn, " + ;
        " rd.naz AS radn_prezime, " + ;
        " rd.ime AS radn_ime, " + ;
        " rd.imerod AS radn_imerod, " + ;
        " lk.idkred, " + ;
        " kr.naz AS kred_naz, " + ;
        " lk.naosnovu, " + ;
        " lk.placeno AS iznos_rate, " + ;
        " ( SELECT COUNT(iznos) FROM fmk.ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu) AS kredit_rate_ukupno, " + ; 
        " ( SELECT COUNT(placeno) FROM fmk.ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu AND placeno <> 0 ) AS kredit_rate_uplaceno, " + ;
        " ( SELECT SUM(iznos) FROM fmk.ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu) AS kredit_ukupno, " + ;
        " ( SELECT SUM(iznos) FROM fmk.ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu AND placeno <> 0) AS kredit_uplaceno " + ;
        " FROM fmk.ld_radkr lk " + ;
        " LEFT JOIN fmk.ld_radn rd ON lk.idradn = rd.id " + ;
        " LEFT JOIN fmk.kred kr ON lk.idkred = kr.id " + ;
        " WHERE " + _where + ;
        " ORDER BY " + _order 

MsgO( "formiranje sql upita u toku ..." )
_data := _sql_query( _server, _qry )
MsgC()

if _data == NIL
    return NIL
endif

_data:Refresh()
_data:GoTo(1)

return _data


// ---------------------------------------------------------------
// parametri specifikacije
// ---------------------------------------------------------------
static function _get_vars( params )
local _ok := .f.
local _x := 1
local _godina, _mjesec
local _id_radn, _id_kred, _sort

// ucitaj parametre
// fetch_metric()...
_godina := fetch_metric( "ld_kred_spec_godina", my_user(), 2013 )
_mjesec := fetch_metric( "ld_kred_spec_mjesec", my_user(), 1 )
_id_radn := fetch_metric( "ld_kred_spec_radnik", my_user(), SPACE(6) )
_id_kred := fetch_metric( "ld_kred_spec_kreditor", my_user(), SPACE(6) )
_sort := fetch_metric( "ld_kred_spec_sort", my_user(), 2 )

Box(, 15, 60 )

    @ m_x + _x, m_y + 2 SAY "Godina" GET _godina PICT "9999"
    @ m_x + _x, col() + 1 SAY "Godina" GET _mjesec PICT "99"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Radnik (prazno-svi):" GET _id_radn VALID EMPTY( _id_radn ) .or. P_Radn( @_id_radn )

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Kreditor (prazno-svi):" GET _id_kred VALID EMPTY( _id_kred ) .or. P_Kred( @_id_kred )

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Sortiranje: 1 (radnik) 2 (kreditor):" GET _sort PICT "9" 

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// save params
// set_metric()...
set_metric( "ld_kred_spec_godina", my_user(), _godina )
set_metric( "ld_kred_spec_mjesec", my_user(), _mjesec )
set_metric( "ld_kred_spec_radnik", my_user(), _id_radn )
set_metric( "ld_kred_spec_kreditor", my_user(), _id_kred )
set_metric( "ld_kred_spec_sort", my_user(), _sort )

// save hash
params["godina"] := _godina
params["mjesec"] := _mjesec
params["kreditor"] := _id_kred
params["radnik"] := _id_radn
params["tip_sorta"] := _sort

_ok := .t.

return _ok


// ----------------------------------------------------------
// printanje podataka
// ----------------------------------------------------------
static function _print_data( data, params )
local _template := "kred_spec.odt"

// kreiraj xml
_cre_xml( data, params )

// printaj odt report
if f18_odt_generate( _template )
    // printaj odt
    f18_odt_print()
endif

return

// --------------------------------------------
// kreiranje xml fajla...
// --------------------------------------------
static function _cre_xml( data, params )
local oRow
local _xml_file := my_home() + "data.xml"
local _id_kred
local _sort := params["tip_sorta"]
local _t_rata_iznos := 0
local _t_rata_ukupno := 0
local _t_rata_uplaceno := 0
local _t_kred_ukupno := 0
local _t_kred_uplaceno := 0 
local _t_ostatak := 0

open_xml( _xml_file )
xml_head()

xml_subnode( "spec", .f. )

// header
xml_node( "firma", to_xml_encoding( gNFirma ) )
xml_node( "godina", STR( params["godina"] ) )
xml_node( "mjesec", STR( params["mjesec"] ) )
xml_node( "kreditor", to_xml_encoding( params["kreditor"] ) )
xml_node( "radnik", to_xml_encoding( params["radnik"] ) )

data:GoTo(1)

do while !data:EOF()

    oRow := data:GetRow()

    _id_kred := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("idkred") ) )
    _id_radn := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("idradn") ) )

    xml_subnode( "kred", .f. )

    xml_node( "k_naz", to_xml_encoding( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "kred_naz" ) ) ) ) )
    xml_node( "k_id", to_xml_encoding( hb_utf8tostr( _id_kred ) ) )

    _t_rata_iznos := 0
    _t_rata_ukupno := 0
    _t_rata_uplaceno := 0
    _t_kred_ukupno := 0
    _t_kred_uplaceno := 0 
    _t_ostatak := 0

    do while !data:EOF() .and. _id_kred == hb_utf8tostr( data:FieldGet( data:FieldPos( "idkred" ) ) )
    
        oRow2 := data:GetRow()
    
        xml_subnode( "data", .f. )
 
            xml_node( "r_id", to_xml_encoding( hb_utf8tostr( oRow2:FieldGet( oRow2:FieldPos( "idradn" ) )) ) )
            xml_node( "r_prez", to_xml_encoding( hb_utf8tostr( oRow2:FieldGet( oRow2:FieldPos( "radn_prezime" ) ) ) ))
            xml_node( "r_ime", to_xml_encoding( hb_utf8tostr( oRow2:FieldGet( oRow2:FieldPos( "radn_ime" ) ) ) ) )
            xml_node( "r_imerod", to_xml_encoding( hb_utf8tostr( oRow2:FieldGet( oRow2:FieldPos( "radn_imerod" ) ) ) ))
            xml_node( "k_id", to_xml_encoding( hb_utf8tostr( oRow2:FieldGet(oRow2:FieldPos("idkred") ) ) ) )
            xml_node( "k_naz", to_xml_encoding( hb_utf8tostr( oRow2:FieldGet( oRow2:FieldPos( "kred_naz" ) )) ) )
            xml_node( "osn", to_xml_encoding( hb_utf8tostr( oRow2:FieldGet( oRow2:FieldPos( "naosnovu" ) ) ) ) )
            xml_node( "rata_i", ALLTRIM( STR( oRow2:FieldGet( oRow2:FieldPos( "iznos_rate" ) ), 12, 2 ) ) )
            xml_node( "rata_uk", ALLTRIM( STR( oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_ukupno" )) , 12, 0 ) ) )
            xml_node( "rata_up", ALLTRIM( STR( oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_uplaceno" )), 12, 0 ) ) )
            xml_node( "kred_uk", ALLTRIM( STR( oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" )), 12, 2 ) ) )
            xml_node( "kred_up", ALLTRIM( STR( oRow2:FieldGet( oRow2:FieldPos( "kredit_uplaceno" ) ), 12, 2 ) ))
            xml_node( "ostatak", ALLTRIM( STR( oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" ) ) - ;
                                                oRow2:FieldGet( oRow:FieldPos( "kredit_uplaceno") ), 12, 2 ) ))

            // saberi nam iznose... moze trebati !
            _t_rata_iznos += oRow2:FieldGet( oRow2:FieldPos( "iznos_rate" ) )
            _t_rata_ukupno += oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_ukupno" ) )
            _t_rata_uplaceno += oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_uplaceno" ) )
            _t_kred_ukupno += oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" ) )
            _t_kred_uplaceno += oRow2:FieldGet( oRow2:FieldPos( "kredit_uplaceno" ) )
            _t_ostatak += oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" ) ) - ;
                            oRow2:FieldGet( oRow2:FieldPos( "kredit_uplaceno" ) )

        xml_subnode( "data", .t. )
               
        data:Skip()

    enddo

    // totali
    xml_node( "rata_i", ALLTRIM( STR( _t_rata_iznos, 12, 2 ) ) )
    xml_node( "rata_uk", ALLTRIM( STR( _t_rata_ukupno, 12, 2 ) ) )
    xml_node( "rata_up", ALLTRIM( STR( _t_rata_uplaceno, 12, 2 ) ) )
    xml_node( "kred_uk", ALLTRIM( STR( _t_kred_ukupno, 12, 2 ) ) )
    xml_node( "kred_up", ALLTRIM( STR( _t_kred_uplaceno, 12, 2 ) ) )
    xml_node( "ostatak", ALLTRIM( STR( _t_ostatak, 12, 2 ) ) )

    xml_subnode( "kred", .t. )

enddo

xml_subnode( "spec", .t. )

close_xml()

return


