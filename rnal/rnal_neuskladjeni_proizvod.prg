/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"
#include "hbclass.ch"
#include "hbcompat.ch"
#include "common.ch"


CLASS RNALDamageDocument

    METHOD New()
    METHOD get_damage_data()
    METHOD get_damage_items()
    METHOD has_damage_data()
    METHOD generate_rnal_document()

    DATA damage_items
    DATA damage_data
    DATA doc_no

    PROTECTED:

        METHOD open_tables()
        METHOD get_damage_items_cond()
        METHOD get_damage_items_qtty()
        METHOD get_rnal_header_data()
        METHOD get_rnal_items_data()
        METHOD get_rnal_opers_data()

ENDCLASS



// ---------------------------------------
METHOD RNALDamageDocument:New()
::damage_data := NIL
::damage_items := NIL
::doc_no := NIL
return SELF


// vraca podatke o ostecenju za nalog broj
METHOD RNALDamageDocument:get_damage_data()
local _ok := .f.
local _qry, _table
local _server := pg_server()
local _log_type := "21"

_qry := "SELECT " + ;
        "  lit.doc_no, " + ;
        "  lit.doc_log_no, " + ;
        "  lit.doc_lit_no, " + ;
        "  lit.doc_lit_ac, " + ;
        "  lit.art_id, " + ;
        "  lit.char_1, " + ;
        "  lit.num_1, " + ;
        "  lit.num_2, " + ;
        "  lit.int_1, " + ;
        "  lit.int_2, " + ;
        "  dlog.doc_log_da, " + ;
        "  dlog.doc_log_ti " + ;
        "FROM fmk.rnal_doc_lit lit " + ;
        "LEFT JOIN fmk.rnal_doc_log dlog ON lit.doc_no = dlog.doc_no " + ;
        "   AND dlog.doc_log_no = lit.doc_log_no " + ;
        "WHERE dlog.doc_log_ty = " + _sql_quote( _log_type ) + ;
        "   AND dlog.doc_no = " + ALLTRIM( STR( ::doc_no ) ) + " " + ;
        "ORDER BY lit.doc_no, lit.doc_log_no, lit.doc_lit_no"

MsgO( "formiranje sql upita u toku ..." )

_table := _sql_query( _server, _qry )

MsgC()

if _table == NIL
    return NIL
endif

_table:Refresh()

::damage_data := _table

return


// ------------------------------------------------------
// daj mi stavke koje su sporne sa naloga
// ------------------------------------------------------
METHOD RNALDamageDocument:get_damage_items()
local oRow
local _item, _scan

::damage_items := {}
::damage_data:GoTo(1)

do while !::damage_data:EOF() 

    oRow := ::damage_data:GetRow()

    _item := oRow:FieldGet( oRow:FieldPos( "int_1" ) )
    _scan := ASCAN( ::damage_items, { | var | var[1] == _item } )

    if _scan == 0
        AADD( ::damage_items, { _item } )
    endif

    ::damage_data:skip()

enddo

::damage_data:GoTo(1)

return 

// -------------------------------------------------------------
// vrati mi uslov za sql izraz na osnovu ovoga
// -------------------------------------------------------------
METHOD RNALDamageDocument:get_damage_items_cond( field_name )
local _cond := ""
local _i

if ::damage_items == NIL .or. LEN( ::damage_items ) == 0
    return _cond
endif

_cond := " AND " +  field_name + " IN ( "

for _i := 1 to LEN( ::damage_items )
    _cond += ALLTRIM( STR( ::damage_items[ _i, 1 ] ) )
    if _i < LEN( ::damage_items )
        _cond += ", "
    endif
next

_cond += " ) "

return _cond


// -------------------------------------------------------------
// vraca podatke o ostecenju za nalog broj
// -------------------------------------------------------------
METHOD RNALDamageDocument:has_damage_data()
local _res
local _where

_where := "WHERE doc_log_ty = " + _sql_quote( _log_type ) + ;
        "   AND doc_no = " + ALLTRIM( STR( ::doc_no ) );

_res := table_count( "fmk.rnal_doc_log", _where )

return _res


// ------------------------------------------------------
// vraca header podatke dokumenta
// ------------------------------------------------------
METHOD RNALDamageDocument:get_rnal_header_data()
local _qry, _table
local _server := pg_server()

_qry := "SELECT * FROM fmk.rnal_docs ORDER BY doc_no"

_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table


// ------------------------------------------------------
// vraca item podatke dokumenta
// ------------------------------------------------------
METHOD RNALDamageDocument:get_rnal_items_data()
local _qry, _table
local _server := pg_server()
local _items_cond := ::get_damage_items_cond( "doc_it_no" )
local _i

_qry := "SELECT * FROM fmk.rnal_doc_it WHERE doc_no = " + ALLTRIM( STR( ::doc_no ) ) + _items_cond + ;
        " ORDER BY doc_no, doc_it_no "
        
_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table


// ------------------------------------------------------
// vraca oper podatke dokumenta
// ------------------------------------------------------
METHOD RNALDamageDocument:get_rnal_opers_data()
local _qry, _table
local _server := pg_server()
local _items_cond := ::get_damage_items_cond( "doc_it_no" )

_qry := "SELECT * FROM fmk.rnal_doc_ops WHERE doc_no = " + ALLTRIM( STR( ::doc_no ) ) + _items_cond + ;
        " ORDER BY doc_no, doc_it_no, doc_op_no"

_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table



// -----------------------------------------------------
// generisanje novog dokumenta...
// -----------------------------------------------------
METHOD RNALDamageDocument:generate_rnal_document()
local _ok := .f.
local _rec
local _header_tbl, _items_tbl, _opers_tbl
local _damage_doc_no := 0
local oRow

// otvori mi sve tabele potrebne za rad !
::open_tables()

if _docs->( RECCOUNT() ) <> 0
    MsgBeep( "Priprema nije prazna !!!" )
    return _ok
endif 

// daj mi podatke header-a
_header_tbl := ::get_rnal_header_data()
_header_tbl:GoTo(1)

// daj mi podatke stavki
_items_tbl := ::get_rnal_items_data()
_items_tbl:GoTo(1)

// daj mi podatke operacija
_opers_tbl := ::get_rnal_opers_data()
_opers_tbl:GoTo(1)

// 1) ubaci podatke header-a

oRow := _header_tbl:GetRow()

select _docs
append blank

_rec := dbf_get_rec()

_rec["doc_no"] := _damage_doc_no
_rec["doc_date"] := DATE()
_rec["doc_dvr_da"] := DATE() + 2
_rec["doc_dvr_ti"] := PADR( PADR( TIME(), 5 ), 8 )
_rec["doc_ship_p"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_ship_p" ) ) )
_rec["doc_priori"] := oRow:FieldGet( oRow:FieldPos( "doc_priori" ) )
_rec["doc_pay_id"] := oRow:FieldGet( oRow:FieldPos( "doc_pay_id" ) )
_rec["doc_paid"] := oRow:FieldGet( oRow:FieldPos( "doc_paid" ) )
_rec["doc_pay_de"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_pay_de" ) ) )
_rec["doc_status"] := 10
_rec["doc_sh_des"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_sh_des" ) ) )
_rec["doc_desc"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_desc" ) ) )
_rec["operater_i"] := GetUserID( f18_user() )
_rec["cust_id"] := oRow:FieldGet( oRow:FieldPos( "cust_id" ) )
_rec["cont_add_d"] := oRow:FieldGet( oRow:FieldPos( "cont_add_d" ) )
_rec["cont_id"] := oRow:FieldGet( oRow:FieldPos( "cont_id" ) )
_rec["obj_id"] := oRow:FieldGet( oRow:FieldPos( "obj_id" ) )

dbf_update_rec( _rec )


// 2) ubaci podatke u items...

do while !_items_tbl:EOF()
    
    oRow := _items_tbl:GetRow()

    _item := oRow:FieldGet( oRow:FieldPos( "doc_it_no" ) )

    select _doc_it
    append blank

    _rec := dbf_get_rec()

    _rec["doc_no"] := _damage_doc_no
    _rec["doc_it_no"] := inc_docit( _damage_doc_no )
    _rec["doc_it_typ"] := oRow:FieldGet( oRow:FieldPos( "doc_it_typ" ) )
    _rec["it_lab_pos"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "it_lab_pos" ) ) )
    _rec["doc_it_alt"] := oRow:FieldGet( oRow:FieldPos( "doc_it_alt" ) )
    _rec["doc_it_des"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_it_des" ) ) )
    _rec["doc_acity"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_acity" ) ) )
    _rec["doc_it_sch"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_it_sch" ) ) )
    _rec["art_id"] := oRow:FieldGet( oRow:FieldPos( "art_id" ) )
    _rec["doc_it_wid"] := oRow:FieldGet( oRow:FieldPos( "doc_it_wid" ) )
    _rec["doc_it_w2"] := oRow:FieldGet( oRow:FieldPos( "doc_it_w2" ) )
    _rec["doc_it_hei"] := oRow:FieldGet( oRow:FieldPos( "doc_it_hei" ) )
    _rec["doc_it_h2"] := oRow:FieldGet( oRow:FieldPos( "doc_it_h2" ) )

    // broj komada ostecenog stakla
    _rec["doc_it_qtt"] := ::get_damage_items_qtty( _item ) 

    dbf_update_rec( _rec )

    _items_tbl:Skip()

enddo



// 3) ubaci podatke u operacije
//select _doc_ops


_ok := .t.

return _ok


// -----------------------------------------------------
// koliko je osteceno stakala za stavku
// -----------------------------------------------------
METHOD RNALDamageDocument:get_damage_items_qtty( item_no )
local _qtty := 0
local _item, oRow

::damage_data:GoTo(1)

do while !::damage_data:EOF()

    oRow := ::damage_data:GetRow()
    _item := oRow:FieldGet( oRow:FieldPos( "int_1" ) )

    if _item == item_no
        _qtty := oRow:FieldGet( oRow:FieldPos( "num_2" ) )
        exit
    endif

    ::damage_data:Skip()

enddo

::damage_data:GoTo(1)

return _qtty





// -----------------------------------------------------
// otvaranje potrebnih tabela
// -----------------------------------------------------
METHOD RNALDamageDocument:open_tables()
o_tables( .t. )
return



// ---------------------------------------------
// generisi neuskladjeni nalog
// ---------------------------------------------
function rnal_damage_doc_generate( doc_no )
local oDamage := RNALDamageDocument():New()

// setuj broj dokumenta za koji cemo ovo sve raditi
oDamage:doc_no := doc_no
// daj mi podatke loma za ovaj nalog
oDamage:get_damage_data()
// daj mi matricu stavki koje su sporne sa naloga
oDamage:get_damage_items()

// ima li podataka ?
if oDamage:damage_data == NIL
    MsgBeep( "Ovaj dokument nema evidencije loma !" )
    return
endif

oDamage:generate_rnal_document()

return



