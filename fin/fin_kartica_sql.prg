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
function fin_suban_kartica_sql( otv_stavke )
local _rpt_data := {}
local _rpt_vars := hb_hash()
local _exported := .f.

_my_xml := my_home() + "data.xml"
_template := "fin_kart_brza.odt"

if otv_stavke == NIL
    otv_stavke := .f.
endif

// uslovi izvjestaja
if !_get_vars( @_rpt_vars )
    return
endif

// kreiraj izvjestaj
_rpt_data := _cre_rpt( _rpt_vars, otv_stavke )

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

    // ovdje koristi drugi template fajl...
    // sa prelomom stranice    
    if _rpt_vars["brza"] == "N"
        _template := "fin_kart_svi.odt"
    endif

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
local _brza := fetch_metric( "fin_kart_brza", my_user(), "D" )
local _konto := fetch_metric( "fin_kart_konto", my_user(), "" )
local _partner := fetch_metric( "fin_kart_partner", my_user(), "" )
local _brdok := fetch_metric( "fin_kart_broj_dokumenta", my_user(), PADR("", 200) )
local _idvn := fetch_metric( "fin_kart_broj_dokumenta", my_user(), PADR("", 200) )
local _datum_od := fetch_metric( "fin_kart_datum_od", my_user(), CTOD("") )
local _datum_do := fetch_metric( "fin_kart_datum_do", my_user(), CTOD("") )
local _opcina := fetch_metric( "fin_kart_opcina", my_user(), PADR("", 200) )
local _tip_val := fetch_metric( "fin_kart_tip_valute", my_user(), 1 )
local _export_dbf := fetch_metric( "fin_kart_export_dbf", my_user(), "N" )
local _box_name := "SUBANALITICKA KARTICA"
local _box_x := 21
local _box_y := 65
local _x := 1

O_SIFK
O_SIFV
O_KONTO
O_PARTN

Box( "#" + _box_name, _box_x, _box_y )

	set cursor on

    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Brza kartica (D/N)" GET _brza PICT "@!" VALID _brza $ "DN"

 	read

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Firma "
	?? gFirma, "-", ALLTRIM( gNFirma )

    ++ _x
    ++ _x

	if _brza = "D"
   			
        _konto := PADR( _konto, 7 )
   		_partner := PADR( _partner, LEN( partn->id ) )

  		@ m_x + _x, m_y + 2 SAY "Konto   " GET _konto VALID P_KontoFin( @_konto )
   		++ _x
        @ m_x + _x, m_y + 2 SAY "Partner " GET _partner VALID EMPTY(_partner) .or. RTRIM( _partner ) == ";" .or. P_Firma( @_partner) PICT "@!"
 	
    else

   		_konto := PADR( _konto, 200 )
   		_partner := PADR( _partner, 200 )

   		@ m_x + _x, m_y + 2 SAY "Konto   " GET _konto PICT "@!S50"
        ++ _x
   		@ m_x + _x, m_y + 2 SAY "Partner " GET _partner PICT "@!S50"

 	endif
	
    ++ _x
    ++ _x
 	
    @ m_x + _x, m_y + 2 SAY "Kartica za domacu/stranu valutu (1/2):" GET _tip_val PICT "9"
    
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
    @ m_x + _x, m_y + 2 SAY "Eksport kartice u dbf (D/N)?" GET _export_dbf PICT "@!" VALID _export_dbf $ "DN"
	
	read
		
BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi parametre
set_metric( "fin_kart_brza", my_user(), _brza )
set_metric( "fin_kart_konto", my_user(), _konto )
set_metric( "fin_kart_partner", my_user(), _partner )
set_metric( "fin_kart_broj_dokumenta", my_user(), _brdok )
set_metric( "fin_kart_broj_dokumenta", my_user(), _idvn )
set_metric( "fin_kart_datum_od", my_user(), _datum_od )
set_metric( "fin_kart_datum_do", my_user(), _datum_do )
set_metric( "fin_kart_tip_valute", my_user(), _tip_val )
set_metric( "fin_kart_export_dbf", my_user(), _export_dbf )

// setuj hash matricu koju cu poslije koristiti u izvjestaju
rpt_vars["brza"] := _brza
rpt_vars["konto"] := _konto
rpt_vars["partner"] := _partner
rpt_vars["brdok"] := _brdok
rpt_vars["idvn"] := _idvn
rpt_vars["datum_od"] := _datum_od
rpt_vars["datum_do"] := _datum_do
rpt_vars["opcina"] := _opcina
rpt_vars["valuta"] := _tip_val
rpt_vars["export_dbf"] := _export_dbf

return .t.


// -----------------------------------------------------------------
// kreiraj izvjestaj iz sql-a
// -----------------------------------------------------------------
static function _cre_rpt( rpt_vars, otv_stavke )
local _brza, _konto, _partner, _brdok, _idvn
local _datum_od, _datum_do, _tip_valute
local _qry, _table
local _server := pg_server()
local _fld_iznos 

if otv_stavke == NIL
    otv_stavke := .f.
endif

// init varijable
_brza := rpt_vars["brza"]
_konto := rpt_vars["konto"]
_partner := rpt_vars["partner"]
_brdok := rpt_vars["brdok"]
_idvn := rpt_vars["idvn"]
_datum_od := rpt_vars["datum_od"]
_datum_do := rpt_vars["datum_do"]
_opcina := rpt_vars["opcina"]
_tip_valute := rpt_vars["valuta"]

_fld_iznos := "s.iznosbhd"

if _tip_valute == 2
    // strana valuta
    _fld_iznos := "s.iznosdem"
endif

_qry := "SELECT s.idkonto, k.naz as konto_naz, s.idpartner, p.naz as partn_naz, s.idvn, s.brnal, s.rbr, s.brdok, s.datdok, s.datval, s.opis, " + ;
        "( CASE WHEN s.d_p = '1' THEN " + _fld_iznos + " ELSE 0 END ) AS duguje, " + ;
        "( CASE WHEN s.d_p = '2' THEN " + _fld_iznos + " ELSE 0 END ) AS potrazuje " + ;
        "FROM fmk.fin_suban s " + ;
        "LEFT JOIN fmk.partn p ON s.idpartner = p.id " + ;
        "LEFT JOIN fmk.konto k ON s.idkonto = k.id " + ;
        "WHERE idfirma = " + _sql_quote( gfirma )

// datumi
_qry += " AND " + _sql_date_parse( "s.datdok", _datum_od, _datum_do )

if _brza == "D"
    
    // kod brze kartice je bitno da su konta zadana, kao i partner

    // konto
    _qry += " AND " + _sql_cond_parse( "s.idkonto", _konto )
    _qry += " AND " + _sql_cond_parse( "s.idpartner", _partner )
 
else

    // ako nije brza slobodno provjeri sta je prazno a sta ne !!!

    if !EMPTY( _konto )
        // konto
        _qry += " AND " + _sql_cond_parse( "s.idkonto", _konto )
    endif

    if !EMPTY( _partner )
        // partner
        _qry += " AND " + _sql_cond_parse( "s.idpartner", _partner )
    endif

endif

if !EMPTY( _brdok )
    _qry += " AND " + _sql_cond_parse( "s.brdok", _brdok )
endif

if !EMPTY( _idvn )
    _qry += " AND " + _sql_cond_parse( "s.idvn", _idvn )
endif

if !EMPTY( _opcina )
    _qry += " AND " + _sql_cond_parse( "p.idops", _opcina )
endif

_qry += " ORDER BY s.idkonto, s.idpartner, s.datdok, s.brnal"

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
local _rec

if table:LastRec() == 0
    return .f.
endif

// daj mi dbf strukturu kartice
_struct := fin_kartica_dbf_struct()
// kreiraj r_export tabelu sa strukturom
t_exp_create( _struct )

O_R_EXP

for _i := 1 to table:LastRec()

    oRow := table:GetRow( _i )

    select r_export
    append blank

    _rec := dbf_get_rec()

    _rec["id_konto"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("idkonto") ) )
    _rec["naz_konto"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("konto_naz") ) )
    _rec["id_partn"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("idpartner") ) )
    _rec["naz_partn"] := hb_utf8tostr( oRow:FieldGet( oRow:Fieldpos("partn_naz") ) )
    _rec["vrsta_nal"] := hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("idvn") ) )
    _rec["broj_nal"] := oRow:Fieldget( oRow:Fieldpos("brnal") )
    _rec["nal_rbr"] := oRow:Fieldget( oRow:Fieldpos("rbr") )
    _rec["broj_veze"] := hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("brdok") ) )
    _rec["dat_nal"] := oRow:Fieldget( oRow:Fieldpos("datdok") )
    _rec["dat_val"] := oRow:Fieldget( oRow:Fieldpos("datval") )
    _rec["opis_nal"] := hb_utf8tostr( oRow:Fieldget( oRow:Fieldpos("opis") ) )
    _rec["duguje"] := oRow:Fieldget( oRow:Fieldpos("duguje") )
    _rec["potrazuje"] := oRow:Fieldget( oRow:Fieldpos("potrazuje") )
    _rec["saldo"] := oRow:Fieldget( oRow:Fieldpos("saldo") )

    dbf_update_rec( _rec )

next

select r_export
use
 
return .t.


// --------------------------------------------------------
// vraca polja export tabele
// --------------------------------------------------------
function fin_kartica_dbf_struct()
local aDbf := {}

AADD( aDbf, { "id_konto", "C", 7, 0 }  )
AADD( aDbf, { "naz_konto", "C", 100, 0 }  )
AADD( aDbf, { "id_partn", "C", 6, 0 }  )
AADD( aDbf, { "naz_partn", "C", 50, 0 }  )
AADD( aDbf, { "vrsta_nal", "C", 2, 0 }  )
AADD( aDbf, { "broj_nal", "C", 8, 0 }  )
AADD( aDbf, { "nal_rbr", "C", 4, 0 }  )
AADD( aDbf, { "broj_veze", "C", 10, 0 }  )
AADD( aDbf, { "dat_nal", "D", 8, 0 }  )
AADD( aDbf, { "dat_val", "D", 8, 0 }  )
AADD( aDbf, { "opis_nal", "C", 100, 0 }  )
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
local _u_dug1 := 0
local _u_dug2 := 0
local _u_pot1 := 0
local _u_pot2 := 0
local _u_saldo1 := 0
local _u_saldo2 := 0
local _val
local _id_konto, _id_partner

if table:LastRec() == 0
    return .f.
endif

open_xml( _my_xml )

xml_head()

xml_subnode( "kartica", .f. )

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

do while !table:EOF()

    oItem := table:GetRow()

    // provjeri mi konto + partner
    _id_konto := oItem:Fieldget( oItem:Fieldpos("idkonto") )
    _id_partner := oItem:Fieldget( oItem:Fieldpos("idpartner") )

    // dodaj novi subnode....
    xml_subnode( "kartica_item", .f. )

    // idkonto
    xml_node( "konto", to_xml_encoding( hb_utf8tostr( _id_konto ) ) )
    
    // naziv konta 
    if !EMPTY( _id_konto )
        _naz_konto := _sql_get_value( "konto", "naz", { "id", ALLTRIM( _id_konto ) } )
    else
        _naz_konto := ""
    endif

    xml_node( "konto_naz", to_xml_encoding( hb_utf8tostr( _naz_konto ) ) )

    // partner 
    xml_node( "partner", to_xml_encoding( hb_utf8tostr( _id_partner ) ) )

    // naziv partnera
    if !EMPTY( _id_partner )
        _naz_partner := _sql_get_value( "partn", "naz", { "id", ALLTRIM( _id_partner ) } )
    else
        _naz_partner := ""
    endif

    xml_node( "partner_naz", to_xml_encoding( hb_utf8tostr( _naz_partner ) ) )

    _u_pot1 := 0
    _u_dug1 := 0
    _u_saldo1 := 0

    do while !table:EOF() .and. table:FieldGet( table:FieldPos( "idkonto" ) ) == _id_konto ;
                .and. table:FieldGet( table:FieldPos( "idpartner" ) ) == _id_partner

        oRow := table:GetRow()

        // sada subnode unutara kartica_item
        xml_subnode( "row", .f. )
    
        // idvn
        _val := oRow:Fieldget( oRow:Fieldpos("idvn") )
        xml_node( "vn", to_xml_encoding( hb_utf8tostr( _val ) ) )

        // brnal
        _val := oRow:Fieldget( oRow:Fieldpos("brnal") )
        xml_node( "broj", _val )
    
        // rbr
        _val := oRow:Fieldget( oRow:Fieldpos("rbr") )
        xml_node( "rbr", _val )

        // brdok
        _val := oRow:Fieldget( oRow:Fieldpos("brdok") )
        xml_node( "veza", to_xml_encoding( hb_utf8tostr( _val ) ) )
    
        // datdok
        _val := oRow:Fieldget( oRow:Fieldpos("datdok") )
        xml_node( "datum", DTOC( _val ) )

        // datval
        _val := oRow:Fieldget( oRow:Fieldpos("datval") )
        xml_node( "datval", DTOC( _val ) )

        // opis
        _val := oRow:Fieldget( oRow:Fieldpos("opis") )
        xml_node( "opis", to_xml_encoding( hb_utf8tostr( _val ) ) )

        // duguje
        _val := oRow:Fieldget( oRow:Fieldpos("duguje") )
        xml_node("dug", show_number( _val, PIC_VRIJEDNOST ) )
        _u_dug1 += _val

        // potrazuje
        _val := oRow:Fieldget( oRow:Fieldpos("potrazuje") )
        xml_node("pot", show_number( _val, PIC_VRIJEDNOST ) )
        _u_pot1 += _val

        // saldo
        _val := oRow:Fieldget( oRow:Fieldpos("duguje") ) - oRow:Fieldget( oRow:Fieldpos("potrazuje") )
        _u_saldo1 += _val
        xml_node("saldo", show_number( _u_saldo1, PIC_VRIJEDNOST ) )

        xml_subnode( "row", .t. )

        table:Skip()

    enddo

    // dodaj totale
    xml_node( "dug", show_number( _u_dug1, PIC_VRIJEDNOST ) )
    xml_node( "pot", show_number( _u_pot1, PIC_VRIJEDNOST ) )
    xml_node( "saldo", show_number( _u_saldo1, PIC_VRIJEDNOST ) )

    // zatvori item subnode
    xml_subnode( "kartica_item", .t. )

enddo

xml_subnode( "kartica", .t. )

close_xml()

return .t.




