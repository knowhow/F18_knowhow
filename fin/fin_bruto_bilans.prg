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



// -------------------------------------------------------
// bruto bilans - sql varijanta
// -------------------------------------------------------
function fin_bruto_bilans_sql( params )
local _data

if params == NIL
    // uslovi izvjestaja
    if !fin_bruto_bilans_get_vars( @params )
        return
    endif
endif

// napuni izvjestaj...
_data := _get_data( params )

if _data == NIL
    MsgBeep( "Nema podataka za prikaz !!!" )
    return
endif

// napuni tmp tabelu
_fill_local_tmp( _data, params )

// generisi xml report
_gen_xml( params )

// otvori dbf ako treba itd...

return



// --------------------------------------------------------
// generise xml fajl za prikaz 
// --------------------------------------------------------
static function _gen_xml( params )
local _xml := "data.xml"
local _sint_len := 3

O_R_EXP

open_xml( my_home() + _xml )

xml_subnode( "bb", .f. )

select r_export
set order to tag "1"
go top

do while !EOF()

    // ....

    skip

enddo


xml_subnode( "bb", .t. )

close_xml()

return



// puni lokalni dbf fajl sa rezultatima...
static function _fill_local_tmp( data, params )
local oRow 
local _id_konto, _id_partner, _k_naz, _p_naz

// napravi tmp 
_cre_tmp()

O_KONTO
O_PARTN
O_SIFK
O_SIFV
O_R_EXP

data:GoTo(1)

do while !data:EOF()

    oRow := data:getRow()

    _id_konto := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("idkonto") ) )
    _id_partner := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("idpartner") ) )

    _k_naz := ""
    if !EMPTY( _id_konto )
        select konto
        hseek _id_konto
        _k_naz := field->naz
    endif

    _p_naz := ""
    if !EMPTY( _id_partner )
        select partn
        hseek _id_partn
        _p_naz := field->naz
    endif

    select r_export
    append blank
 
    _rec := dbf_get_rec()

    _rec["idkonto"] := _id_konto
    _rec["idpartner"] := _id_partner
    _rec["konto"] := _k_naz
    _rec["partner"] := _p_naz
    _rec["ps_dug"] := oRow:FieldGet( oRow:FieldPos("ps_dug") )
    _rec["ps_pot"] := oRow:FieldGet( oRow:FieldPos("ps_pot") )
    _rec["tek_dug"] := oRow:FieldGet( oRow:FieldPos("tek_dug") )
    _rec["tek_pot"] := oRow:FieldGet( oRow:FieldPos("tek_pot") )
    _rec["sld_dug"] := _rec["tek_dug"]
    _rec["sld_pot"] := _rec["tek_pot"]

    data:skip()

enddo

close all

return


// ------------------------------------------------------------
// napravi tmp
// ------------------------------------------------------------
static function _cre_tmp()
local _dbf := {}

AADD( _dbf, { "idkonto", "C", 7, 0 } )
AADD( _dbf, { "idpartner", "C", 6, 0 } )
AADD( _dbf, { "konto", "C", 60, 0 } )
AADD( _dbf, { "partner", "C", 100, 0 } )
AADD( _dbf, { "ps_dug", "N", 18, 2 } )
AADD( _dbf, { "ps_pot", "N", 18, 2 } )
AADD( _dbf, { "tek_dug", "N", 18, 2 } )
AADD( _dbf, { "tek_pot", "N", 18, 2 } )
AADD( _dbf, { "sld_dug", "N", 18, 2 } )
AADD( _dbf, { "sld_pot", "N", 18, 2 } )

// napravi dbf
t_exp_create( _dbf )

// indeksi po potrebi ...
//
index on ( idkonto + idpartner ) TAG "1"
// index on

return




// -------------------------------------------------------
// parametri / uslovi izvjestaja
// -------------------------------------------------------
function fin_bruto_bilans_get_vars( params )
local _ok := .f.
local _val := 1
local _x := 1
local _valuta := 1
local _konto := PADR( fetch_metric( "fin_bb_konto", my_user(), "" ), 200 )
local _dat_od := fetch_metric( "fin_bb_dat_od", my_user(), CTOD("") )
local _dat_do := fetch_metric( "fin_bb_dat_do", my_user(), CTOD("") )
local _format := ALLTRIM( fetch_metric( "fin_bb_format", my_user(), "2" ) )
local _klase := fetch_metric( "fin_bb_klase", my_user(), "N" )
local _var := fetch_metric( "fin_bb_varijanta", my_user(), 1 )
local _saldo_nula := fetch_metric( "fin_bb_saldo_nula", my_user(), "D" )
local _id_rj := SPACE(6)
local _export_dbf := "N"
local _export_sk := "N"
local _prikaz := "1"

Box(, 17, 70 )

    @ m_x + _x, m_y + 2 SAY "SUBANALITICKI BRUTO BILANS"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Firma "
    ?? gFirma, "-", ALLTRIM( gNFirma )

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Konto:" GET _konto PICT "@!S50"
        
    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Od datuma:" GET _dat_od
 	@ m_x + _x, col() + 1 SAY "do" GET _dat_do

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Format izvjestaja (1) A3 (2) A4 portret (3) A4 landscape:" GET _format PICT "@!"

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Varijanta TXT/ODT (1/2):" GET _var PICT "9"

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Klase unutar glavnog izvjestaja (D/N) ?" GET _klase VALID _klase $ "DN" PICT "@!"

    ++ _x

 	@ m_x + _x, m_y + 2 SAY "Prikaz stavki sa saldom 0 (D/N) ?" GET _saldo_nula VALID _saldo_nula $ "DN" PICT "@!"

 	if gRJ == "D"
        ++ _x
        _id_rj := "999999"
   		@ m_x + _x, m_y + 2 SAY "Radna jedinica ( 999999-sve ): " GET _id_rj
 	endif
 	
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Export izvjestaja u dbf (D/N) ?" GET _export_dbf VALID _export_dbf $ "DN" PICT "@!"

    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Export skraceni bruto bilans (D/N) ?" GET _export_sk VALID _export_sk $ "DN" PICT "@!"

    ++ _x	
 	@ m_x + _x, m_y + 2 SAY "Prikaz suban (1) / suban + anal (2) / anal (3)" GET _prikaz VALID _prikaz $ "123" PICT "@!"
	
    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// snimi parametre
set_metric( "fin_bb_konto", my_user(), ALLTRIM( _konto ) )
set_metric( "fin_bb_dat_od", my_user(), _dat_od )
set_metric( "fin_bb_dat_do", my_user(), _dat_do )
set_metric( "fin_bb_format", my_user(), ALLTRIM( _format ) )
set_metric( "fin_bb_klase", my_user(), _klase )
set_metric( "fin_bb_saldo_nula", my_user(), _saldo_nula )
set_metric( "fin_bb_varijanta", my_user(), _var )

_ok := .t.

params := hb_hash()
params["valuta"] := _valuta
params["id_rj"] := _id_rj
params["export_dbf"] := _export_dbf
params["export_sk"] := _export_sk
params["datum_od"] := _dat_od
params["datum_do"] := _dat_do
params["konto"] := ALLTRIM( _konto )
params["prikaz"] := _prikaz
params["format"] := ALLTRIM( _format )
params["klase"] := _klase
params["saldo_nula"] := _saldo_nula
params["varijanta"] := _var

return _ok




// --------------------------------------------------------
// vraca podatke sa sql servera
// --------------------------------------------------------
static function _get_data( param )
local _qry, _where
local _iznos := "iznosbhd"
local _server := pg_server()
local _table
local _konto := param["konto"]
local _dat_od := param["datum_od"]
local _dat_do := param["datum_do"]

// valuta 1 = domaca
if param["valuta"] == 2
    _iznos := "iznosdem"
endif

_where := "WHERE sub.idfirma = " + _filter_quote( gFirma )
_where += " AND " + _sql_date_parse( "sub.datdok", _dat_od, _dat_do )

if !EMPTY( _konto )
    _where += " AND " + _sql_cond_parse( "sub.idkonto", _konto )
endif

_qry := "SELECT " + ;
        "sub.idkonto, " + ;
        "sub.idpartner, " + ;
        "SUM( CASE WHEN sub.d_p = '1' AND sub.idvn = '00' THEN sub." + _iznos + " ELSE 0 END ) as ps_dug, " + ;
        "SUM( CASE WHEN sub.d_p = '2' AND sub.idvn = '00' THEN sub." + _iznos + " ELSE 0 END ) as ps_pot, " + ;
        "SUM( CASE WHEN sub.d_p = '1' THEN sub." + _iznos + " ELSE 0 END ) as tek_dug, " + ;
        "SUM( CASE WHEN sub.d_p = '2' THEN sub." + _iznos + " ELSE 0 END ) as tek_pot " + ;
        "FROM fmk.fin_suban sub " + ; 
        _where + " " + ;
        "GROUP BY sub.idkonto, sub.idpartner " + ;
        "ORDER BY sub.idkonto, sub.idpartner "

MsgO( "formiranje sql upita u toku ..." )

_table := _sql_query( _server, _qry )

MsgC()

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table


