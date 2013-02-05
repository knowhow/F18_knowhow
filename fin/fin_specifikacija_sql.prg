/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"


static LEN_VRIJEDNOST := 12
static PIC_VRIJEDNOST := ""
static _template
static _my_xml


// ---------------------------------------------
// ---------------------------------------------
function fin_suban_specifikacija_sql()
local _rpt_data := {}
local _rpt_vars := hb_hash()
local _exported := .f.

_my_xml := my_home() + "data.xml"
_template := "fin_specif.odt"

// uslovi izvjestaja
if !_get_vars( @_rpt_vars )
    return
endif

// kreiraj izvjestaj
_rpt_data := _cre_rpt( _rpt_vars )

if _rpt_data == NIL
    Msgbeep( "Problem sa generisanjem izvjestaja !!!" )
    return
endif

// eksport kartice u dbf
if _rpt_vars["export_dbf"] == "D"
    if _export_dbf( _rpt_data, _rpt_vars )
        _exported := .t.
    endif
endif

if _cre_xml( _rpt_data, _rpt_vars )

    // printaj odt report
    if f18_odt_generate( _template, _my_xml )
	    // printaj odt
        f18_odt_print()
    endif

endif

if _exported 
    // otvori mi eksport dokument
    f18_open_mime_document( my_home() + "r_export.dbf" )
endif

return



// ------------------------------------------------------------------
// uslovi izvjestaja
// ------------------------------------------------------------------
static function _get_vars( rpt_vars )
local _konto := fetch_metric( "fin_spec_rpt_konto", my_user(), "" )
local _partner := fetch_metric( "fin_spec_rpt_partner", my_user(), "" )
local _brdok := fetch_metric( "fin_spec_rpt_broj_dokumenta", my_user(), PADR("", 200) )
local _idvn := fetch_metric( "fin_spec_rpt_broj_dokumenta", my_user(), PADR("", 200) )
local _datum_od := fetch_metric( "fin_spec_rpt_datum_od", my_user(), CTOD("") )
local _datum_do := fetch_metric( "fin_spec_rpt_datum_do", my_user(), CTOD("") )
local _opcina := fetch_metric( "fin_spec_rpt_opcina", my_user(), PADR("", 200) )
local _tip_val := fetch_metric( "fin_spec_rpt_tip_valute", my_user(), 1 )
local _export_dbf := fetch_metric( "fin_spec_rpt_export_dbf", my_user(), "N" )
local _sintetika := fetch_metric( "fin_spec_rpt_sintetika", my_user(), "N" )
local _nule := fetch_metric( "fin_spec_rpt_nule", my_user(), "N" )
local _rasclan := fetch_metric( "fin_spec_rpt_rasclaniti_rj", my_user(), "N" )
local _box_name := "SUBANALITICKA SPECIFIKACIJA"
local _box_x := 21
local _box_y := 65
local _x := 1

O_SIFK
O_SIFV
O_KONTO
O_PARTN

Box( "#" + _box_name, _box_x, _box_y )

	set cursor on

    @ m_x + _x, m_y + 2 SAY "Firma "
	?? gFirma, "-", ALLTRIM( gNFirma )

    ++ _x
    ++ _x

   	_konto := PADR( _konto, 200 )
   	_partner := PADR( _partner, 200 )

   	@ m_x + _x, m_y + 2 SAY "Konto   " GET _konto PICT "@!S50"

    ++ _x
   	@ m_x + _x, m_y + 2 SAY "Partner " GET _partner PICT "@!S50"
	
    ++ _x
    ++ _x
 	
    @ m_x + _x, m_y + 2 SAY "Izvjestaj za domacu/stranu valutu (1/2):" GET _tip_val PICT "9"
    
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Datum dokumenta od:" GET _datum_od
 	@ m_x + _x, col() + 2 SAY "do" GET _datum_do VALID _datum_od <= _datum_do
 	
    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Uslov za vrstu naloga (prazno-sve):" GET _idvn PICT "@!S20"
 	
    ++ _x	
 	@ m_x + _x, m_y + 2 SAY "Uslov za broj veze (prazno-svi):" GET _brdok PICT "@!S20"
	 
    ++ _x	
    @ m_x + _x, m_y + 2 SAY "Opcina (prazno-sve):" GET _opcina PICT "@!S20"

    ++ _x	
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Prikaz stavki sa stanjem 0 (D/N)?" GET _nule PICT "@!" VALID _nule $ "DN"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Prikaz sintetike (D/N)?" GET _sintetika PICT "@!" VALID _sintetika $ "DN"
    @ m_x + _x, col() + 1 SAY "Rasclaniti po RJ/FOND/FUNK (D/N)?" GET _rasclan PICT "@!" VALID _rasclan $ "DN"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Eksport izvjestaja u dbf (D/N)?" GET _export_dbf PICT "@!" VALID _export_dbf $ "DN"
	
	read
		
BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi parametre
set_metric( "fin_spec_rpt_konto", my_user(), _konto )
set_metric( "fin_spec_rpt_partner", my_user(), _partner )
set_metric( "fin_spec_rpt_broj_dokumenta", my_user(), _brdok )
set_metric( "fin_spec_rpt_broj_dokumenta", my_user(), _idvn )
set_metric( "fin_spec_rpt_datum_od", my_user(), _datum_od )
set_metric( "fin_spec_rpt_datum_do", my_user(), _datum_do )
set_metric( "fin_spec_rpt_tip_valute", my_user(), _tip_val )
set_metric( "fin_spec_rpt_export_dbf", my_user(), _export_dbf )
set_metric( "fin_spec_rpt_sintetika", my_user(), _sintetika )
set_metric( "fin_spec_rpt_nule", my_user(), _nule )
set_metric( "fin_spec_rpt_rasclaniti_rj", my_user(), _rasclan )

// setuj hash matricu koju cu poslije koristiti u izvjestaju
rpt_vars["konto"] := _konto
rpt_vars["partner"] := _partner
rpt_vars["brdok"] := _brdok
rpt_vars["idvn"] := _idvn
rpt_vars["datum_od"] := _datum_od
rpt_vars["datum_do"] := _datum_do
rpt_vars["opcina"] := _opcina
rpt_vars["valuta"] := _tip_val
rpt_vars["export_dbf"] := _export_dbf
rpt_vars["nule"] := _nule
rpt_vars["sintetika"] := _sintetika
rpt_vars["rasclaniti_rj"] := _rasclan

return .t.


// -----------------------------------------------------------------
// kreiraj izvjestaj iz sql-a
// -----------------------------------------------------------------
static function _cre_rpt( rpt_vars )
local _rasclan, _nule, _sintetika, _konto, _partner, _brdok, _idvn
local _datum_od, _datum_do, _tip_valute
local _qry, _table
local _server := pg_server()
local _fld_iznos 
local _rj_fond_funk := ""
local _where_cond := ""
local _order_cond := ""
local _group_cond := ""

// init varijable
_konto := rpt_vars["konto"]
_partner := rpt_vars["partner"]
_brdok := rpt_vars["brdok"]
_idvn := rpt_vars["idvn"]
_datum_od := rpt_vars["datum_od"]
_datum_do := rpt_vars["datum_do"]
_opcina := rpt_vars["opcina"]
_tip_valute := rpt_vars["valuta"]

// logicke varijable
_nule := rpt_vars["nule"] == "D"
_sintetika := rpt_vars["sintetika"] == "D"
_rasclan := rpt_vars["rasclaniti_rj"] == "D"

_fld_iznos := "sub.iznosbhd"

if _tip_valute == 2
    // strana valuta
    _fld_iznos := "sub.iznosdem"
endif

// rasclaniti po RJ/FOND/FUNK
// ========================================
if _rasclan
    _rj_fond_funk := " sub.idrj, sub.fond, sub.funk, "
endif

// WHERE cond...
// ========================================
_where_cond := "WHERE sub.idfirma = " + _sql_quote( gfirma )
_where_cond += " AND " + _sql_date_parse( "sub.datdok", _datum_od, _datum_do )
if !EMPTY( _konto )
    _where_cond += " AND " + _sql_cond_parse( "sub.idkonto", _konto )
endif
if !EMPTY( _partner )
    _where_cond += " AND " + _sql_cond_parse( "sub.idpartner", _partner )
endif
if !EMPTY( _brdok )
    _where_cond += " AND " + _sql_cond_parse( "sub.brdok", _brdok )
endif
if !EMPTY( _idvn )
    _where_cond += " AND " + _sql_cond_parse( "sub.idvn", _idvn )
endif
if !EMPTY( _opcina )
    _where_cond += " AND " + _sql_cond_parse( "part.idops", _opcina )
endif


// GROUP cond
// ========================================
_group_cond := " GROUP BY sub.idkonto, kto.naz, sub.idpartner, part.naz"

if _rasclan
    _group_cond += ", sub.idrj, sub.fond, sub.funk "
endif

// ORDER cond...
// ========================================
_order_cond := " ORDER BY sub.idkonto, kto.naz, sub.idpartner, part.naz"

if _rasclan
    _order_cond += ", sub.idrj, sub.fond, sub.funk "
endif

// glavni select
// ========================================
_qry := "SELECT " + ;
        " sub.idkonto as konto_id, " + ;
        " kto.naz as konto_naz, " + ; 
        " sub.idpartner as partner_id, " + ;
        " part.naz as partner_naz, " + ;
        _rj_fond_funk + ;
        " SUM( CASE WHEN sub.d_p = '1' THEN " + _fld_iznos + " ELSE 0 END ) AS duguje, " + ;
        " SUM( CASE WHEN sub.d_p = '2' THEN " + _fld_iznos + " ELSE 0 END ) AS potrazuje " + ;
        "FROM fmk.fin_suban sub " + ;
        "LEFT JOIN fmk.partn part ON sub.idpartner = part.id " + ;
        "LEFT JOIN fmk.konto kto ON sub.idkonto = kto.id "
// where
_qry += _where_cond
// group by
_qry += _group_cond
// order
_qry += _order_cond

_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table



// -----------------------------------------------------------
// eksport kartice u dbf 
// -----------------------------------------------------------
static function _export_dbf( table, rpt_vars )
local oRow, _struct
local _rasclan := rpt_vars["rasclaniti_rj"] == "D"
local _nule := rpt_vars["nule"] == "D"
local _rec

if table:LastRec() == 0
    return .f.
endif

// daj mi dbf strukturu kartice
_struct := fin_specifikacija_dbf_struct()
// kreiraj r_export tabelu sa strukturom
t_exp_create( _struct )

O_R_EXP

for _i := 1 to table:LastRec()

    oRow := table:GetRow( _i )

    select r_export
    append blank

    _rec := dbf_get_rec()

    _rec["id_konto"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("konto_id") ) )
    _rec["id_partn"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("partner_id") ) )

    if !EMPTY ( hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("partner_id") ) ) )
        _rec["naziv"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("partn_naz") ) )
    else
        _rec["naziv"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("konto_naz") ) )
    endif

    // rasclaniti... po RJ/FOND/FUNK
    if _rasclan
        _rec["rj"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("idrj") ) )
        _rec["fond"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("fond") ) )
        _rec["funk"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("funk") ) )
    endif

    _rec["duguje"] := oRow:Fieldget( oRow:Fieldpos("duguje") )
    _rec["potrazuje"] := oRow:Fieldget( oRow:Fieldpos("potrazuje") )
    _rec["saldo"] := _rec["duguje"] - _rec["potrazuje"]

    // nule ne prikazuj
    if ROUND( _rec["saldo"], 2 ) == 0 .and. !_nule
        loop
    endif

    dbf_update_rec( _rec )

next

select r_export
use
 
return .t.


// --------------------------------------------------------
// vraca polja export tabele
// --------------------------------------------------------
function fin_specifikacija_dbf_struct()
local aDbf := {}

AADD( aDbf, { "id_konto", "C", 7, 0 }  )
AADD( aDbf, { "id_partn", "C", 6, 0 }  )
AADD( aDbf, { "rj", "C", 6, 0 }  )
AADD( aDbf, { "fond", "C", 6, 0 }  )
AADD( aDbf, { "funk", "C", 6, 0 }  )
AADD( aDbf, { "naziv", "C", 200, 0 }  )
AADD( aDbf, { "duguje", "N", 15, 5 }  )
AADD( aDbf, { "potrazuje", "N", 15, 5 }  )
AADD( aDbf, { "saldo", "N", 15, 5 }  )

return aDbf



// ------------------------------------------------------
// generisi stavke reporta u xml
// ------------------------------------------------------
static function _cre_xml( table, rpt_vars )
local _i, oRow, oItem
local PIC_VRIJEDNOST := PADL( ALLTRIM( RIGHT( PicDem, LEN_VRIJEDNOST)), LEN_VRIJEDNOST, "9" )
local _dug := 0
local _pot := 0
local _saldo := 0
local _u_dug1 := 0
local _u_dug2 := 0
local _u_pot1 := 0
local _u_pot2 := 0
local _u_saldo1 := 0
local _u_saldo2 := 0
local _u_sint_dug := 0
local _u_sint_pot := 0
local _u_sint_saldo := 0
local _val, _sint_kto
local _id_konto, _id_partner
local _sintetika := rpt_vars["sintetika"] == "D"
local _nule := rpt_vars["nule"] == "D"
local _rasclan := rpt_vars["rasclaniti_rj"] == "D"

if table:LastRec() == 0
    return .f.
endif

open_xml( _my_xml )

xml_head()

xml_subnode( "specif", .f. )

// neki osnovni podaci
xml_node( "f_id", gFirma )
xml_node( "f_naz", to_xml_encoding( gNFirma ) )
xml_node( "f_mj", to_xml_encoding( gMjStr ) )

xml_node( "datum", DTOC( DATE() ) )
xml_node( "datum_od", DTOC( rpt_vars["datum_od"] ) )
xml_node( "datum_do", DTOC( rpt_vars["datum_do"] ) )

// valuta
if rpt_vars["valuta"] == 1
    xml_node( "val", "KM" )
else
    xml_node( "val", "EUR" )
endif

_u_pot1 := 0
_u_dug1 := 0
_u_saldo1 := 0

_sint_kto := "X"

do while !table:EOF()

    oItem := table:GetRow()

    _id_konto := oItem:Fieldget( oItem:Fieldpos("konto_id") )
    _naz_konto := oItem:Fieldget( oItem:Fieldpos("konto_naz") )
    
    _id_partner := oItem:Fieldget( oItem:Fieldpos("partner_id") )
    _naz_partner := oItem:Fieldget( oItem:Fieldpos("partner_naz") )

    // sinteticki konto...
    _sint_kto := PADR( _id_konto, 3 )

    // rasclaniti po RJ
    if _rasclan    
        _rj := oItem:Fieldget( oItem:Fieldpos("idrj") )
        _fond := oItem:Fieldget( oItem:Fieldpos("fond") )
        _funk := oItem:Fieldget( oItem:Fieldpos("funk") )
    endif

    // iznosi...
    _dug := oItem:Fieldget( oItem:Fieldpos("duguje") )
    _pot := oItem:Fieldget( oItem:Fieldpos("potrazuje") )
    _saldo := oItem:Fieldget( oItem:Fieldpos("duguje") ) - oItem:Fieldget( oItem:Fieldpos("potrazuje") )

    // preskakanje iznosa 0
    if ROUND( _saldo, 2 ) == 0 .and. !_nule
        table:Skip()
        loop
    endif 
    
    // dodaj novi subnode....
    xml_subnode( "specif_item", .f. )

    // idkonto
    xml_node( "konto", to_xml_encoding( hb_utf8tostr( _id_konto ) ) )    
    // partner 
    xml_node( "partner", to_xml_encoding( hb_utf8tostr( _id_partner ) ) )

    if !EMPTY( _id_partner )
        // naziv partnera
        xml_node( "naziv", to_xml_encoding( hb_utf8tostr( _naz_partner ) ) )
    else
        // naziv konta 
        xml_node( "naziv", to_xml_encoding( hb_utf8tostr( _naz_konto ) ) )
    endif

    // rasclaniti po RJ/FOND/FUNK
    if _rasclan
        xml_node( "rj", to_xml_encoding( hb_utf8tostr( _rj ) ) )
        xml_node( "fond", to_xml_encoding( hb_utf8tostr( _fond ) ) )
        xml_node( "funk", to_xml_encoding( hb_utf8tostr( _funk ) ) )
    endif

    // duguje
    xml_node("dug", show_number( _dug, PIC_VRIJEDNOST ) )
    _u_dug1 += _dug

    // potrazuje
    xml_node("pot", show_number( _pot, PIC_VRIJEDNOST ) )
    _u_pot1 += _pot

    // saldo
    xml_node("saldo", show_number( _saldo, PIC_VRIJEDNOST ) )
    _u_saldo1 += _saldo

    // zatvori item subnode
    xml_subnode( "specif_item", .t. )

    table:Skip()

enddo

// dodaj totale
xml_node( "dug", show_number( _u_dug1, PIC_VRIJEDNOST ) )
xml_node( "pot", show_number( _u_pot1, PIC_VRIJEDNOST ) )
xml_node( "saldo", show_number( _u_saldo1, PIC_VRIJEDNOST ) )

xml_subnode( "specif", .t. )

close_xml()

return .t.




