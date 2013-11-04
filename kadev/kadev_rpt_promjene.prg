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

#include "fmk.ch"

static __template
static __xml_file

// -----------------------------------------------------
// izvjestaj po promjenama
// -----------------------------------------------------
function kadev_izvjestaj_promjene()
local _params

__template := "kadev_promjene.odt"
__xml_file := my_home() + "data.xml"

// parametri
if !_get_vars( @_params )
    return
endif

// pozovi izvjestaj
if _cre_xml( _params )
    // generisi i printaj dokument...
    if f18_odt_generate( __template, __xml_file )
        f18_odt_print()
    endif
endif

return



// -----------------------------------------------------
// -----------------------------------------------------
static function _get_vars( params )
local _ok := .f.
local _datum_od := fetch_metric( "kadev_rpt_prom_datum_od", my_user(), CTOD("") )
local _datum_do := fetch_metric( "kadev_rpt_prom_datum_do", my_user(), DATE() )
local _promjene := PADR( fetch_metric( "kadev_rpt_prom_promjene", my_user(), "P1;P2;" ), 200 )
local _rj := PADR( fetch_metric( "kadev_rpt_prom_rj", my_user(), "" ), 100 )
local _rmj := PADR( fetch_metric( "kadev_rpt_prom_rmj", my_user(), "" ), 100 )
local _strspr := PADR( fetch_metric( "kadev_rpt_prom_strspr", my_user(), "" ), 100 )
local _spol := " "

Box(, 10, 65 )

    @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _datum_od
    @ m_x + 1, col() + 1 SAY "do:" GET _datum_do
    
    @ m_x + 3, m_y + 2 SAY "PROMJENE:" GET _promjene VALID !EMPTY( _promjene ) PICT "@S40"

    @ m_x + 5, m_y + 2 SAY "Radne jedinice (prazno-sve):" GET _rj PICT "@S30"
    @ m_x + 6, m_y + 2 SAY "  Radna mjesta (prazno-sve):" GET _rmj PICT "@S30"
    @ m_x + 7, m_y + 2 SAY "Strucne spreme (prazno-sve):" GET _strspr PICT "@S30"

    @ m_x + 9, m_y + 2 SAY "Spol ( /M/Z):" GET _spol VALID _spol $ " MZ" PICT "@!"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

set_metric( "kadev_rpt_prom_datum_od", my_user(), _datum_od )
set_metric( "kadev_rpt_prom_datum_do", my_user(), _datum_do )
set_metric( "kadev_rpt_prom_promjene", my_user(), ALLTRIM( _promjene ) )
set_metric( "kadev_rpt_prom_rj", my_user(), ALLTRIM( _rj ) )
set_metric( "kadev_rpt_prom_rmj", my_user(), ALLTRIM( _rmj ) )
set_metric( "kadev_rpt_prom_strspr", my_user(), ALLTRIM( _strspr ) )

params := hb_hash()
params["datum_od"] := _datum_od
params["datum_do"] := _datum_do
params["promjene"] := _promjene
params["rj"] := _rj
params["rmj"] := _rmj
params["strspr"] := _strspr
params["spol"] := _spol

_ok := .t.

return _ok


// -----------------------------------------------------
// -----------------------------------------------------
static function _get_data( param )
local _data, _qry
local _where := ""

if !EMPTY( param["datum_od"] ) .or. !EMPTY( param["datum_do"] )
    _where += _sql_date_parse( "pr.datumod", param["datum_od"], param["datum_do"] )
endif

if !EMPTY( param["promjene"] )
    _where += " AND ( " + _sql_cond_parse( "pr.idpromj", param["promjene"] ) + " ) " 
endif

if !EMPTY( param["strspr"] )
    _where += " AND ( "  + _sql_cond_parse( "main.idstrspr", param["strspr"] ) + " ) " 
endif

if !EMPTY( param["rj"] )
    _where += " AND ( "  + _sql_cond_parse( "main.idrj", param["rj"] ) + " ) " 
endif

if !EMPTY( param["rmj"] )
    _where += " AND ( "  + _sql_cond_parse( "main.idrmj", param["rmj"] ) + " ) " 
endif

if !EMPTY( param["spol"] )
    _where += " AND main.pol = " + _sql_quote( param["spol"] )
endif

// sredi WHERE upit na kraju...
if !EMPTY( _where )
    _where := "WHERE " + _where
endif

_qry := "SELECT " 
_qry += "  pr.id AS jmbg, "
_qry += "  main.ime || ' (' || main.imerod || ') ' || main.prezime AS radnik, "
_qry += "  pr.idpromj AS idpromj , "
_qry += "  pr.datumod AS datum, "
_qry += "  main.idrj AS rj, "
_qry += "  rj.naz AS rj_naz, "
_qry += "  main.idrmj AS rmj, "
_qry += "  rmj.naz AS rmj_naz, "
_qry += "  main.idstrspr AS strspr, "
_qry += "  ss.naz AS strspr_naz "
_qry += "FROM fmk.kadev_1 pr "
_qry += "LEFT JOIN fmk.kadev_0 main ON pr.id = main.id "
_qry += "LEFT JOIN fmk.kadev_promj prom ON pr.idpromj = prom.id "
_qry += "LEFT JOIN fmk.kadev_rj rj ON main.idrj = rj.id "
_qry += "LEFT JOIN fmk.kadev_rmj rmj ON main.idrmj = rmj.id "
_qry += "LEFT JOIN fmk.strspr ss ON main.idstrspr = ss.id "
_qry += " " + _where + " "
_qry += "ORDER BY pr.id, pr.datumod" 

MsgO( "Formiram podatke izvjestaja ..." ) 
_data := _sql_query( my_server(), _qry )
MsgC()

if VALTYPE( _data ) == "L"
    return NIL
endif

_data:Refresh()
_data:GoTo(1)

return _data



// -----------------------------------------------------
// -----------------------------------------------------
static function _cre_xml( params )
local _data, oRow
local _ok := .f.
local _count := 0
local _tmp, _jmbg

// uzmi podatke za izvjestaj....
_data := _get_data( params )

if _data == NIL
    return _ok
endif

open_xml( __xml_file )
xml_head()

xml_subnode( "rpt", .f. )

// header ...
xml_node( "f_id", to_xml_encoding( gFirma ) )
xml_node( "f_naz", to_xml_encoding( gNFirma ) )

xml_node( "dat_od", DTOC( params["datum_od"] ) )
xml_node( "dat_do", DTOC( params["datum_do"] ) )
xml_node( "datum", DTOC( DATE() ) )
xml_node( "promjene", to_xml_encoding( params["promjene"] ) )
xml_node( "strspr", to_xml_encoding( params["strspr"] ) )

_tmp := "XXX"

do while !_data:EOF()

    oRow := _data:GetRow()
    
    _jmbg := oRow:FieldGet( oRow:FieldPos("jmbg") )

    xml_subnode( "item", .f. )

    if _jmbg <> _tmp
        xml_node( "no", ALLTRIM( STR( ++_count ) ) )
        xml_node( "jmbg", to_xml_encoding( _jmbg ) )
        xml_node( "radn", to_xml_encoding( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "radnik" ) ) ) ) )
    else
        xml_node( "no", "" )
        xml_node( "jmbg", "" )
        xml_node( "radn", "" )
    endif

    xml_node( "rj", to_xml_encoding( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "rj_naz" ) ) ) ) )
    xml_node( "strspr", to_xml_encoding( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "strspr_naz" ) ) ) ) )
    xml_node( "datum", DTOC( oRow:FieldGet( oRow:FieldPos( "datum" ) ) ) )
    xml_node( "rmj", to_xml_encoding( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "rmj_naz" ) ) ) ) )

    xml_subnode( "item", .t. )

    _tmp := _jmbg

    _ok := .t.
    _data:SKIP()

enddo

xml_subnode( "rpt", .t. )

close_xml()

return _ok




