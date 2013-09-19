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
local _template := "fin_bbl.odt"

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

if params["export_dbf"] == "D"
    f18_open_mime_document( my_home() + "r_export.dbf" )
    return
endif

// generisi xml report
if _gen_xml( params )
    // printaj odt report
    if f18_odt_generate( _template )
	    // printaj odt
        f18_odt_print()
    endif
endif

return



// --------------------------------------------------------
// generise xml fajl za prikaz 
// --------------------------------------------------------
static function _gen_xml( params )
local _xml := "data.xml"
local _sint_len := 3
local _a_klase := {}
local _klasa, _i
local _u_ps_dug := 0
local _u_ps_pot := 0
local _u_tek_dug := 0
local _u_tek_pot := 0
local _u_sld_dug := 0
local _u_sld_pot := 0
local _t_ps_dug := 0
local _t_ps_pot := 0
local _t_tek_dug := 0
local _t_tek_pot := 0
local _t_sld_dug := 0
local _t_sld_pot := 0
local _tt_ps_dug := 0
local _tt_ps_pot := 0
local _tt_tek_dug := 0
local _tt_tek_pot := 0
local _tt_sld_dug := 0
local _tt_sld_pot := 0
local _ok := .f.
local _count

O_KONTO
O_R_EXP

open_xml( my_home() + _xml )

xml_subnode( "rpt", .f. )

xml_subnode( "bilans", .f. )

// header podaci
xml_node( "firma", to_xml_encoding( gFirma ) )
xml_node( "naz", to_xml_encoding( gNFirma ) )
xml_node( "datum", DTOC( DATE() ) )
xml_node( "datum_od", DTOC( params["datum_od"] ) )
xml_node( "datum_do", DTOC( params["datum_do"] ) )

if !EMPTY( params["konto"] )
    xml_node( "konto", to_xml_encoding( params["konto"] ) ) 
else
    xml_node( "konto", to_xml_encoding( "- sva konta -" ) ) 
endif

select r_export
set order to tag "1"
go top

_count := 0

do while !EOF()

    _klasa := LEFT( field->idkonto, 1 )

    xml_subnode( "klasa", .f. )

    xml_node( "id", to_xml_encoding( _klasa ) )
    
    select konto
    hseek _klasa
    xml_node( "naz", to_xml_encoding( ALLTRIM( field->naz ) ) )

    select r_export

    _t_ps_dug := _t_ps_pot := _t_tek_dug := _t_tek_pot := _t_sld_dug := _t_sld_pot := 0
    
    do while !EOF() .and. LEFT( field->idkonto, 1 ) == _klasa

        _sint := LEFT( field->idkonto, 3 )

        xml_subnode( "sint", .f. )

        xml_node( "id", to_xml_encoding( _sint ) )
        
        select konto
        hseek _sint
        xml_node( "naz", to_xml_encoding( ALLTRIM( field->naz ) ) )

        select r_export

        _u_ps_dug := _u_ps_pot := _u_tek_dug := _u_tek_pot := _u_sld_dug := _u_sld_pot := 0

        do while !EOF() .and. LEFT( field->idkonto, 3 ) == _sint 
        
            xml_subnode( "item", .f. )
        
            xml_node( "rb", ALLTRIM( STR( ++ _count ) ) )
            xml_node( "kto", to_xml_encoding( field->idkonto ) )
            xml_node( "part", to_xml_encoding( field->idpartner ) )
           
            if !EMPTY( field->partner ) 
                xml_node( "naz", to_xml_encoding( field->partner ) )
            else
                xml_node( "naz", to_xml_encoding( field->konto ) )
            endif

            // iznosi ...
            xml_node( "ps_dug", ALLTRIM( STR( field->ps_dug, 12, 2 ) ) )
            xml_node( "ps_pot", ALLTRIM( STR( field->ps_pot, 12, 2 ) ) )

            xml_node( "tek_dug", ALLTRIM( STR( field->tek_dug, 12, 2 ) ) )
            xml_node( "tek_pot", ALLTRIM( STR( field->tek_pot, 12, 2 ) ) )

            xml_node( "sld_dug", ALLTRIM( STR( field->sld_dug, 12, 2 ) ) )
            xml_node( "sld_pot", ALLTRIM( STR( field->sld_pot, 12, 2 ) ) )

            // totali sintetički...
            _u_ps_dug += field->ps_dug
            _u_ps_pot += field->ps_pot
            _u_tek_dug += field->tek_dug
            _u_tek_pot += field->tek_pot
            _u_sld_dug += field->sld_dug
            _u_sld_pot += field->sld_pot

            // totali po klasama
            _t_ps_dug += field->ps_dug
            _t_ps_pot += field->ps_pot
            _t_tek_dug += field->tek_dug
            _t_tek_pot += field->tek_pot
            _t_sld_dug += field->sld_dug
            _t_sld_pot += field->sld_pot

            // total ukupno
            _tt_ps_dug += field->ps_dug
            _tt_ps_pot += field->ps_pot
            _tt_tek_dug += field->tek_dug
            _tt_tek_pot += field->tek_pot
            _tt_sld_dug += field->sld_dug
            _tt_sld_pot += field->sld_pot

            // dodaj u matricu sa klasama, takodjer totale...
            _scan := ASCAN( _a_klase, { |var| var[1] == LEFT( _sint, 1 ) } )

            if _scan == 0
                // dodaj novu stavku u matricu...
                AADD( _a_klase, { LEFT( _sint, 1 ), ;
                                    field->ps_dug, ;
                                    field->ps_pot, ;
                                    field->tek_dug, ;
                                    field->tek_pot, ;
                                    field->sld_dug, ;
                                    field->sld_pot } )
            else

                // dodaj na postojeci iznos...

                _a_klase[ _scan, 2 ] := _a_klase[ _scan, 2 ] + field->ps_dug
                _a_klase[ _scan, 3 ] := _a_klase[ _scan, 3 ] + field->ps_pot
                _a_klase[ _scan, 4 ] := _a_klase[ _scan, 4 ] + field->tek_dug
                _a_klase[ _scan, 5 ] := _a_klase[ _scan, 5 ] + field->tek_pot
                _a_klase[ _scan, 6 ] := _a_klase[ _scan, 6 ] + field->sld_dug
                _a_klase[ _scan, 7 ] := _a_klase[ _scan, 7 ] + field->sld_pot

            endif

            xml_subnode( "item", .t. )
            
            skip

        enddo
   
        // upisi totale sintetike 
        // ....
        xml_node( "ps_dug", ALLTRIM( STR( _u_ps_dug, 12, 2 ) ) ) 
        xml_node( "ps_pot", ALLTRIM( STR( _u_ps_pot, 12, 2 ) ) ) 
        xml_node( "tek_dug", ALLTRIM( STR( _u_tek_dug, 12, 2 ) ) ) 
        xml_node( "tek_pot", ALLTRIM( STR( _u_tek_pot, 12, 2 ) ) ) 
        xml_node( "sld_dug", ALLTRIM( STR( _u_sld_dug, 12, 2 ) ) ) 
        xml_node( "sld_pot", ALLTRIM( STR( _u_sld_pot, 12, 2 ) ) ) 

        xml_subnode( "sint", .t. )

    enddo

    // uspisi totale klase
    xml_node( "ps_dug", ALLTRIM( STR( _t_ps_dug, 12, 2 ) ) ) 
    xml_node( "ps_pot", ALLTRIM( STR( _t_ps_pot, 12, 2 ) ) ) 
    xml_node( "tek_dug", ALLTRIM( STR( _t_tek_dug, 12, 2 ) ) ) 
    xml_node( "tek_pot", ALLTRIM( STR( _t_tek_pot, 12, 2 ) ) ) 
    xml_node( "sld_dug", ALLTRIM( STR( _t_sld_dug, 12, 2 ) ) ) 
    xml_node( "sld_pot", ALLTRIM( STR( _t_sld_pot, 12, 2 ) ) ) 

    xml_subnode( "klasa", .t. )

enddo

// ukupni total
xml_node( "ps_dug", ALLTRIM( STR( _tt_ps_dug, 12, 2 ) ) ) 
xml_node( "ps_pot", ALLTRIM( STR( _tt_ps_pot, 12, 2 ) ) ) 
xml_node( "tek_dug", ALLTRIM( STR( _tt_tek_dug, 12, 2 ) ) ) 
xml_node( "tek_pot", ALLTRIM( STR( _tt_tek_pot, 12, 2 ) ) ) 
xml_node( "sld_dug", ALLTRIM( STR( _tt_sld_dug, 12, 2 ) ) ) 
xml_node( "sld_pot", ALLTRIM( STR( _tt_sld_pot, 12, 2 ) ) ) 

// totali po klasama...
xml_subnode( "total", .f. )

for _i := 1 to LEN( _a_klase )

    xml_subnode( "item", .f. )

    xml_node( "klasa", to_xml_encoding( _a_klase[ _i, 1 ] ) )
    xml_node( "ps_dug", ALLTRIM( STR( _a_klase[ _i, 2 ], 12, 2 ) ) )
    xml_node( "ps_pot", ALLTRIM( STR( _a_klase[ _i, 3 ], 12, 2 ) ) )
    xml_node( "tek_dug", ALLTRIM( STR( _a_klase[ _i, 4 ], 12, 2 ) ) )
    xml_node( "tek_pot", ALLTRIM( STR( _a_klase[ _i, 5 ], 12, 2 ) ) )
    xml_node( "sld_dug", ALLTRIM( STR( _a_klase[ _i, 6 ], 12, 2 ) ) )
    xml_node( "sld_pot", ALLTRIM( STR( _a_klase[ _i, 7 ], 12, 2 ) ) )

    xml_subnode( "item", .t. )

next

xml_subnode( "total", .t. )

xml_subnode( "bilans", .t. )

xml_subnode( "rpt", .t. )

close_xml()

close all

_ok := .t.
return _ok



// puni lokalni dbf fajl sa rezultatima...
static function _fill_local_tmp( data, params )
local oRow 
local _id_konto, _id_partner, _k_naz, _p_naz
local _rec

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
        hseek _id_partner
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

    // sredi kolonu saldo...
    _rec["sld_dug"] := _rec["tek_dug"] - _rec["tek_pot"]

    if _rec["sld_dug"] >= 0
        _rec["sld_pot"] := 0
    else
        _rec["sld_pot"] := - _rec["sld_dug"]
        _rec["sld_dug"] := 0
    endif

    // update na kraju...
    dbf_update_rec( _rec )

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

O_R_EXP

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
local _id_rj := param["id_rj"]

// valuta 1 = domaca
if param["valuta"] == 2
    _iznos := "iznosdem"
endif

_where := "WHERE sub.idfirma = " + _filter_quote( gFirma )
_where += " AND " + _sql_date_parse( "sub.datdok", _dat_od, _dat_do )

if !EMPTY( _konto )
    _where += " AND " + _sql_cond_parse( "sub.idkonto", _konto + " " )
endif

if !EMPTY( _id_rj )
    _where += " AND sub.idrj = " + _sql_quote( _id_rj ) 
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


