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

_my_xml := my_home() + "data.xml"
_template := "fin_kart_std.odt"

if otv_stavke == NIL
    otv_stavke := .f.
endif

// uslovi izvjestaja
if !_get_vars( @_rpt_vars )
    return
endif

// kreiraj izvjestaj
_rpt_data := _cre_rpt( _rpt_vars, otv_stavke )

if _cre_xml( _rpt_data, _rpt_vars )
    // printaj odt report
    if f18_odt_generate( _template, _my_xml )
	    // printaj odt
        f18_odt_print()
    endif
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

    @ m_x + _x, m_y + 2 SAY "Datum dokumenta od:" GET _datum_od
 	@ m_x + _x, col() + 2 SAY "do" GET _datum_do VALID _datum_od <= _datum_do
 	
    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Uslov za vrstu naloga (prazno-sve):" GET _idvn PICT "@!S20"
 	
    ++ _x	
 	@ m_x + _x, m_y + 2 SAY "Uslov za broj veze (prazno-svi):" GET _brdok PICT "@!S20"
	 
    ++ _x	
    @ m_x + _x, m_y + 2 SAY "Opcina (prazno-sve):" GET _opcina PICT "@!S20"
		
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

// setuj hash matricu koju cu poslije koristiti u izvjestaju
rpt_vars["brza"] := _brza
rpt_vars["konto"] := _konto
rpt_vars["partner"] := _partner
rpt_vars["brdok"] := _brdok
rpt_vars["idvn"] := _idvn
rpt_vars["datum_od"] := _datum_od
rpt_vars["datum_do"] := _datum_do
rpt_vars["opcina"] := _opcina

return .t.


// -----------------------------------------------------------------
// kreiraj izvjestaj iz sql-a
// -----------------------------------------------------------------
static function _cre_rpt( rpt_vars, otv_stavke )
local _brza, _konto, _partner, _brdok, _idvn
local _datum_od, _datum_do
local _qry, _table
local _server := pg_server()

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

_qry := "SELECT s.idvn, s.brnal, s.rbr, s.brdok, s.datdok, s.datval, s.opis, " + ;
        "( CASE WHEN s.d_p = '1' THEN s.iznosbhd ELSE 0 END ) AS duguje, " + ;
        "( CASE WHEN s.d_p = '2' THEN s.iznosbhd ELSE 0 END ) AS potrazuje " + ;
        "FROM fmk.fin_suban s " + ;
        "LEFT JOIN fmk.partn p ON s.idpartner = p.id " + ;
        "WHERE idfirma = " + _sql_quote( gfirma ) + ;
          " AND " + _sql_cond_parse( "s.idkonto", _konto ) + ;
          " AND " + _sql_cond_parse( "s.idpartner", _partner ) + ;
          " AND " + _sql_date_parse( "s.datdok", _datum_od, _datum_do )

// ostali uslovi

if !EMPTY( _brdok )
    _qry += " AND " + _sql_cond_parse( "s.brdok", _brdok )
endif

if !EMPTY( _idvn )
    _qry += " AND " + _sql_cond_parse( "s.idvn", _idvn )
endif

if !EMPTY( _opcina )
    _qry += " AND " + _sql_cond_parse( "p.idops", _opcina )
endif

_qry += " ORDER BY s.datdok"

_table := _sql_query( _server, _qry )
_table:Refresh()

return _table



// ------------------------------------------------------
// generisi stavke reporta u xml
// ------------------------------------------------------
static function _cre_xml( table, rpt_vars )
local _i, oRow
local PIC_VRIJEDNOST := PADL( ALLTRIM( RIGHT( PicDem, LEN_VRIJEDNOST)), LEN_VRIJEDNOST, "9" )
local _u_dug1 := 0
local _u_pot1 := 0
local _u_saldo1 := 0
local _val

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
xml_node( "date1", DTOC( rpt_vars["datum_od"] ) )
xml_node( "date2", DTOC( rpt_vars["datum_do"] ) )

xml_node( "kt_id", rpt_vars["konto"] )
xml_node( "pt_id", to_xml_encoding( rpt_vars["partner"] ) )

if rpt_vars["brza"] == "D"
    xml_node( "kt_naz", ;
        to_xml_encoding( ;
                _sql_get_value( "konto", "naz", { "id", ALLTRIM( rpt_vars["konto"] ) } ) ) ;
                       )
    xml_node( "pt_naz", ;
        to_xml_encoding( ;
                _sql_get_value( "partn", "naz", { "id", ALLTRIM( rpt_vars["partner"] ) } ) ) ;
                       )
else
    xml_node( "kt_naz", "" )
    xml_node( "pt_naz", "" )
endif

for _i := 1 to table:LastRec()

    oRow := table:GetRow( _i )

    xml_subnode( "row", .f. )
    
    // idvn
    _val := oRow:Fieldget( oRow:Fieldpos("idvn") )
    xml_node( "vn", _val )

    // brnal
    _val := oRow:Fieldget( oRow:Fieldpos("brnal") )
    xml_node( "broj", _val )
    
    // rbr
    _val := oRow:Fieldget( oRow:Fieldpos("rbr") )
    xml_node( "rbr", _val )

    // brdok
    _val := oRow:Fieldget( oRow:Fieldpos("brdok") )
    xml_node( "veza", to_xml_encoding( _val ) )

    // datdok
    _val := oRow:Fieldget( oRow:Fieldpos("datdok") )
    xml_node( "datum", DTOC( _val ) )

    // datval
    _val := oRow:Fieldget( oRow:Fieldpos("datval") )
    xml_node( "datval", DTOC( _val ) )

    // opis
    _val := oRow:Fieldget( oRow:Fieldpos("opis") )
    xml_node( "opis", to_xml_encoding( _val ) )

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

next

// upisi totale
xml_node("dug", show_number( _u_dug1, PIC_VRIJEDNOST ) )
xml_node("pot", show_number( _u_pot1, PIC_VRIJEDNOST ) )
xml_node("saldo", show_number( _u_saldo1, PIC_VRIJEDNOST ) )

xml_subnode( "kartica", .t. )

close_xml()

return .t.




