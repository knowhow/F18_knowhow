/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
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


CLASS F18TableBrowse

    METHOD New()
    METHOD show()

    DATA browse_params
    DATA browse_return_value
    DATA browse_messages

    PROTECTED:

        METHOD field_list_from_array()

ENDCLASS



METHOD F18TableBrowse:New()
::browse_params := hb_hash()
::browse_return_value := NIL
::browse_messages := { "<c+N> Novi", "<F2>  Ispravka", "<ENT> Odabir", _to_str("<c-T> Briši"), "<c-P> Print", ;
                   "<F4>  Dupliciraj", _to_str("<c-F9> Briši SVE"), _to_str("<F> Traži"),;
                   "<a-R> Zamjena vrij.", "<F5> Refresh"}

return SELF



// -----------------------------------------------------------
// prikazi tabelu u box-u
// -----------------------------------------------------------
METHOD F18TableBrowse:show( return_value )
local _srv := pg_server()
local _c_qry, _o_qry
local _where := ""
local _brw

if ::browse_params["table_filter"] <> NIL .and. LEN( ::browse_params["table_filter"] ) > 0
    // imamo i where listu...
    // _where := "...."
endif

_c_qry := "SELECT " + ::field_list_from_array() + ;
        " FROM " + ::browse_params["table_name"] + ;
        _where + ;
        " ORDER BY " + ::browse_params["table_order_field"] ;

if ::browse_params["direct_sql"] <> NIL .and. !EMPTY( ::browse_params["direct_sql"] )
    _c_qry := ::browse_params["direct_sql"]
endif

_o_qry := _sql_query( _srv, _c_qry )

// broj zapisa tabele...
@ m_x + 0, m_y + 2 SAY "SQLBrowse [" + ::browse_params["table_name"] + "]" COLOR "I" 
@ m_x + 1, m_y + ::browse_params["form_width"] - 20 SAY "uk.zapisa: " + ALLTRIM( STR( table_count( ::browse_params["table_name"] ) ) )

_brw := TBrowseSQL():new( m_x + 2, m_y + 1, m_x + ::browse_params["form_height"], m_y + ::browse_params["form_width"], _srv, _o_qry, ::browse_params["table_name"], ::browse_params["table_browse_fields"], ::browse_params["codes_type"], ::browse_params["key_fields"], ::browse_params["table_order_field"] )
_brw:BrowseTable( .f., NIL )

// nesto mi treba kao return value ....
::browse_return_value := _brw:oCurRow:FieldGet( _brw:oCurRow:FieldPos( ::browse_params["table_browse_return_field"] ) )

return_value := ::browse_return_value

return



// -------------------------------------------------------
// vraca listu polja na osnovu matrice
// -------------------------------------------------------
METHOD F18TableBrowse:field_list_from_array()
local _ret := ""
local _i
local _arr := ::browse_params["table_browse_fields"]

if _arr == NIL
    _ret := "*"
    return _ret
endif

for _i := 1 to LEN( _arr )

    _ret += _arr[ _i, 3 ]

    if _i <> LEN( _arr )
        _ret += ","
    endif

next

return _ret





// test funkcija...
function test_sql_table_browse( return_value )
local _height := MAXROWS() - 15
local _width := MAXCOLS() - 15
local _a_columns := {}
local _a_filter := NIL
local oTBr := F18TableBrowse():New()

// dodaj vidljive kolone
//                  ISPIS, LEN, field_name, when, valid
//                   1    2    3       4          5          6
AADD( _a_columns, { "ID", 10, "id", {|| id }, {|| .t. }, {|| .t. } } )
AADD( _a_columns, { "NAZIV", 40, "naz" } )
AADD( _a_columns, { "JMJ", 3, "jmj" } )
AADD( _a_columns, { "TARIFA", 6, "idtarifa" } )
AADD( _a_columns, { "NC", 12, "nc" } )
AADD( _a_columns, { "VPC", 12, "vpc" } )

Box(, _height, _width, .t., oTBr:browse_messages )

oTBr:browse_params["table_name"] := "fmk.roba"
oTBr:browse_params["table_order_field"] := "id"
oTBr:browse_params["table_browse_return_field"] := "id"
oTBr:browse_params["key_fields"] := { "id" }
oTBr:browse_params["table_browse_fields"] := _a_columns
oTBr:browse_params["form_width"] := _width
oTBr:browse_params["form_height"] := _height
oTBr:browse_params["table_filter"] := NIL
oTBr:browse_params["direct_sql"] := NIL
oTBr:browse_params["codes_type"] := .t.
 
// prikazi sifrarnik
oTBr:show( @return_value )

BoxC()

return



