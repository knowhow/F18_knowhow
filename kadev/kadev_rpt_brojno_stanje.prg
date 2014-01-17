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
function kadev_izvjestaj_br_stanje()
local _params

__template := "kadev_br_stanje.odt"
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
local _datum_od := CTOD("")
local _datum_do := DATE()
local _promjene := PADR( fetch_metric( "kadev_rpt_br_promjene", my_user(), "P1;P2;" ), 200 )
local _rj := PADR( fetch_metric( "kadev_rpt_br_rj", my_user(), "" ), 100 )
local _rmj := PADR( fetch_metric( "kadev_rpt_br_rmj", my_user(), "" ), 100 )
local _spol := " "

SET CENTURY ON

Box(, 8, 65 )

    @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _datum_od
    @ m_x + 1, col() + 1 SAY "do:" GET _datum_do
    
    @ m_x + 3, m_y + 2 SAY "Radne jedinice (prazno-sve):" GET _rj PICT "@S30"
    @ m_x + 4, m_y + 2 SAY "  Radna mjesta (prazno-sve):" GET _rmj PICT "@S30"

    @ m_x + 7, m_y + 2 SAY "Spol ( /M/Z):" GET _spol VALID _spol $ " MZ" PICT "@!"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

set_metric( "kadev_rpt_br_rj", my_user(), ALLTRIM( _rj ) )
set_metric( "kadev_rpt_br_rmj", my_user(), ALLTRIM( _rmj ) )

params := hb_hash()
params["datum_od"] := _datum_od
params["datum_do"] := _datum_do
params["rj"] := _rj
params["rmj"] := _rmj
params["spol"] := _spol

_ok := .t.

return _ok


// -----------------------------------------------------
// -----------------------------------------------------
static function _get_data( param )
local _data, _qry
local _where := ""

_where := " main.status = 'A' "

if !EMPTY( param["datum_od"] ) .or. !EMPTY( param["datum_do"] )
    _where += " AND ( " + _sql_date_parse( "pr.datumod", param["datum_od"], param["datum_do"] ) + " ) " 
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

_qry := "WITH tmp AS ( "
_qry += " SELECT " 
_qry += "  main.id AS jmbg, "
_qry += "  main.idrj AS idrj, "
_qry += "  main.idstrspr AS idstrspr "
_qry += "FROM fmk.kadev_1 pr "
_qry += "LEFT JOIN fmk.kadev_0 main ON pr.id = main.id "
_qry += "LEFT JOIN fmk.kadev_promj prom ON pr.idpromj = prom.id "
_qry += " " + _where + " "
_qry += "GROUP BY main.id, main.idrj, main.idstrspr "
_qry += "ORDER BY main.id " 
_qry += " ) "
_qry += " SELECT "
_qry += "  idrj, "
_qry += "  rj.naz, "
_qry += "  SUM( CASE WHEN idstrspr = '1' THEN 1 END ) AS s_1, "
_qry += "  SUM( CASE WHEN idstrspr = '2' THEN 1 END ) AS s_2, "
_qry += "  SUM( CASE WHEN idstrspr = '3' THEN 1 END ) AS s_3, "
_qry += "  SUM( CASE WHEN idstrspr = '4' THEN 1 END ) AS s_4, "
_qry += "  SUM( CASE WHEN idstrspr = '5' THEN 1 END ) AS s_5, "
_qry += "  SUM( CASE WHEN idstrspr = '6' THEN 1 END ) AS s_6, "
_qry += "  SUM( CASE WHEN idstrspr = '7' THEN 1 END ) AS s_7, "
_qry += "  SUM( CASE WHEN idstrspr = '8' THEN 1 END ) AS s_8, "
_qry += "  SUM( CASE WHEN idstrspr = '9' THEN 1 END ) AS s_9, "
_qry += "  SUM( CASE WHEN idstrspr = '000' THEN 1 END ) AS s_o "
_qry += " FROM tmp "
_qry += " LEFT JOIN fmk.kadev_rj rj ON tmp.idrj = rj.id "
_qry += " GROUP BY idrj, rj.naz "
_qry += " ORDER BY idrj "

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
local _total := 0
local _sprema := 0
local _sp_1 := _sp_2 := _sp_3 := _sp_4 := _sp_5 := _sp_6 := _sp_7 := _sp_8 := _sp_9 := _sp_o := 0

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

do while !_data:EOF()

    _total := 0

    oRow := _data:GetRow()
    
    xml_subnode( "item", .f. )

    xml_node( "no", ALLTRIM( STR( ++_count ) ) )
    xml_node( "idrj", to_xml_encoding( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "idrj" ) ) ) ) )
    xml_node( "rj", to_xml_encoding( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) ) ) )
    
    // spreme
    _sprema := oRow:FieldGet( oRow:FieldPos( "s_1" ) )
    xml_node( "s_1", ALLTRIM( STR( _sprema ) ) )
    _sp_1 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_2" ) )
    xml_node( "s_2", ALLTRIM( STR( _sprema ) ) )
    _sp_2 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_3" ) )
    xml_node( "s_3", ALLTRIM( STR( _sprema ) ) )
    _sp_3 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_4" ) )
    xml_node( "s_4", ALLTRIM( STR( _sprema ) ) )
    _sp_4 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_5" ) )
    xml_node( "s_5", ALLTRIM( STR( _sprema ) ) )
    _sp_5 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_6" ) )
    xml_node( "s_6", ALLTRIM( STR( _sprema ) ) )
    _sp_6 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_7" ) )
    xml_node( "s_7", ALLTRIM( STR( _sprema ) ) )
    _sp_7 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_8" ) )
    xml_node( "s_8", ALLTRIM( STR( _sprema ) ) )
    _sp_8 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_9" ) )
    xml_node( "s_9", ALLTRIM( STR( _sprema ) ) )
    _sp_9 += _sprema
    _total += _sprema

    _sprema := oRow:FieldGet( oRow:FieldPos( "s_o" ) )
    xml_node( "s_o", ALLTRIM( STR( _sprema ) ) )
    _sp_o += _sprema
    _total += _sprema

    xml_node( "tot", ALLTRIM( STR( _total ) ) )

    xml_subnode( "item", .t. )

    _ok := .t.
    _data:SKIP()

enddo

xml_node( "s_1", ALLTRIM( STR( _sp_1 ) ) )
xml_node( "s_2", ALLTRIM( STR( _sp_2 ) ) )
xml_node( "s_3", ALLTRIM( STR( _sp_3 ) ) )
xml_node( "s_4", ALLTRIM( STR( _sp_4 ) ) )
xml_node( "s_5", ALLTRIM( STR( _sp_5 ) ) )
xml_node( "s_6", ALLTRIM( STR( _sp_6 ) ) )
xml_node( "s_7", ALLTRIM( STR( _sp_7 ) ) )
xml_node( "s_8", ALLTRIM( STR( _sp_8 ) ) )
xml_node( "s_9", ALLTRIM( STR( _sp_9 ) ) )
xml_node( "s_o", ALLTRIM( STR( _sp_o ) ) )
xml_node( "tot", ALLTRIM( STR( _sp_1 + _sp_2 + _sp_3 + _sp_4 + _sp_5 + _sp_6 + _sp_7 + _sp_8 + _sp_9 + _sp_o ) ) )

xml_subnode( "rpt", .t. )

close_xml()

return _ok




