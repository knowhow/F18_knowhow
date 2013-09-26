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
    METHOD initialize()
    METHOD show()
    METHOD findRec()

    DATA pos_x
    DATA pos_y
    DATA browse_params
    DATA browse_return_value
    DATA browse_codes_commands
    DATA current_row
    DATA select_all_query
    DATA select_filtered_query

    PROTECTED:

        METHOD box_desc_text_print()
        METHOD select_all_rec()
        METHOD select_filtered()
        METHOD table_order_by()
        METHOD field_list_from_array()

ENDCLASS



METHOD F18TableBrowse:New()

// incijalizacija browse parametara
// setuj default vrijednosti...
::browse_params := hb_hash()
::initialize()

// koordinate ispisa naziva
::pos_x := NIL
::pos_y := NIL

// ostalo
::browse_return_value := NIL
::browse_codes_commands := ::browse_params["codes_commands"]

return SELF



// -----------------------------------------------------------
// inicijalizacija hash matrice
// -----------------------------------------------------------
METHOD F18TableBrowse:initialize()

::browse_params["table_name"] := ""
::browse_params["table_order_field"] := "id"
::browse_params["table_browse_return_field"] := "id"
::browse_params["key_fields"] := { "id" }
::browse_params["table_browse_fields"] := NIL
::browse_params["form_width"] := NIL
::browse_params["form_height"] := NIL
::browse_params["table_filter"] := NIL
::browse_params["direct_sql"] := NIL
::browse_params["codes_type"] := .t.
::browse_params["read_sifv"] := .f.
::browse_params["user_functions"] := NIL
::browse_params["header_text"] := ""
::browse_params["footer_text"] := ""
::browse_params["restricted_keys"] := NIL
::browse_params["invert_row_block"] := NIL
::browse_params["codes_commands"] := ;
        { "<c+N> Novi", "<F2>  Ispravka", "<ENT> Odabir", ;
        _to_str("<c-T> Briši"), "<c-P> Print", ;
        "<F4>  Dupliciraj", _to_str("<c-F9> Briši SVE"), ;
        _to_str("<F> Traži"), "<a-R> Zamjena vrij.", "<F5> Refresh" }

return




// -----------------------------------------------------------
// pronadji zapis u tabeli
// -----------------------------------------------------------
METHOD F18TableBrowse:findRec( find_value )
return





// ---------------------------------------------------------
// vraca ORDER BY strukturu po trazenom polju
// ---------------------------------------------------------
METHOD F18TableBrowse:table_order_by( order_field )
local _order
_order := " ORDER BY " + order_field
return _order




// -----------------------------------------------------------
// select svih podataka baze
// -----------------------------------------------------------
METHOD F18TableBrowse:select_all_rec()
local _qry, _i

_qry := "SELECT " + ::field_list_from_array() 
_qry += " FROM " + ::browse_params["table_name"] 

// ima li dodatnih where uslova ?
if ::browse_params["table_filter"] <> NIL .and. LEN( ::browse_params["table_filter"] ) > 0
    _qry += " WHERE " 
    for _i := 1 to LEN( ::browse_params["table_filter"] )
        _qry += " " + ::browse_params["table_filter"][ _i ] + " "
        if _i < LEN( ::browse_params["table_filter"] )
            _qry += " OR "
        endif
    next
endif

_qry += ::table_order_by( ::browse_params["table_order_field"] )

// imamo li direktni upit ? ako imamo onda cemo koristiti taj !
if ::browse_params["direct_sql"] <> NIL .and. !EMPTY( ::browse_params["direct_sql"] )
    _qry := ::browse_params["direct_sql"]
endif

::select_all_query := _qry

return Self




// -----------------------------------------------------------
// select sa where klauzulom
// -----------------------------------------------------------
METHOD F18TableBrowse:select_filtered( search_value )
local _qry 
local _where := ""
local _order_field := ::browse_params["table_order_field"]

if !EMPTY( search_value )

    if RIGHT( ALLTRIM( search_value ), 2 ) == ".."
        // pretraga po nazivu
        search_value := ALLTRIM( STRTRAN( search_value, "..", "" ) )
        _where += ::browse_params["key_fields"][2] + " LIKE " + _sql_quote( search_value + "%" )        
        _order_field := ::browse_params["key_fields"][2]

    elseif RIGHT( ALLTRIM( search_value ), 1 ) == "."
        // pretraga po sifri
        search_value := ALLTRIM( STRTRAN( search_value, ".", "" ) )
        _where += ::browse_params["key_fields"][1] + " LIKE " + _sql_quote( search_value + "%" )        
    else
        // klasicna pretraga po iskljucivoj sifri
        _where += ::browse_params["key_fields"][1] + " = " + _sql_quote( search_value )        
    endif

endif

// ima li dodatnih where uslova ?
if ::browse_params["table_filter"] <> NIL .and. LEN( ::browse_params["table_filter"] ) > 0

    if !EMPTY( _where )
        _where += " AND "
    endif

    for _i := 1 to LEN( ::browse_params["table_filter"] )
        _where += " " + ::browse_params["table_filter"][ _i ] + " "
        if _i < LEN( ::browse_params["table_filter"] )
            _where += " OR "
        endif
    next

endif

_qry := "SELECT " + ::field_list_from_array() 
_qry += " FROM " + ::browse_params["table_name"] 
_qry += " WHERE " + _where

_qry += ::table_order_by( _order_field )

// imamo li direktni upit ? ako imamo onda cemo koristiti taj !
if ::browse_params["direct_sql"] <> NIL .and. !EMPTY( ::browse_params["direct_sql"] )
    _qry := ::browse_params["direct_sql"]
endif

::select_filtered_query := _qry

return Self


// ----------------------------------------------------------
// ispis pomocnog teksta na box-u
// ----------------------------------------------------------
METHOD F18TableBrowse:box_desc_text_print()

// tip browse-a i naziv tabele
@ m_x + 0, m_y + 2 SAY "SQLBrowse [" + ::browse_params["table_name"] + "]" COLOR "I" 

// header
if !EMPTY( ::browse_params["header_text"] )
    @ m_x + 2, m_y + 2 SAY ALLTRIM( ::browse_params["header_text"] )
endif

// footer
if !EMPTY( ::browse_params["footer_text"] )
    @ m_x + ::browse_params["form_height"], m_y + 2 SAY ALLTRIM( ::browse_params["footer_text"] )
endif

// broj zapisa
@ m_x + 1, m_y + ::browse_params["form_width"] - 20 SAY "broj zapisa: " + ALLTRIM( STR( table_count( ::browse_params["table_name"] ) ) )

return Self




// -----------------------------------------------------------
// prikazi tabelu u box-u
// -----------------------------------------------------------
METHOD F18TableBrowse:show( return_value, pos_x, pos_y )
local _srv := pg_server()
local _data
local _qry
local _brw
local _found
local _value
local _ret := 0
local _x_pos, _y_pos

// setuj koordinate ispisa...
if pos_x <> NIL
    ::pos_x := pos_x
endif

if pos_y <> NIL
    ::pos_y := pos_y
endif

// postojeca pozicija
_x_pos := m_x
_y_pos := m_y

// 1) postavi mi querije...

// SELECT ( bez WHERE ) 
::select_all_rec()
_qry := ::select_all_query

// SELECT ( sa WHERE ) 
// ovo samo za tip - sifrarnik
if !EMPTY( return_value ) .and. ::browse_params["codes_type"]
    ::select_filtered( @return_value )
    _qry := ::select_filtered_query
endif

// 2) postavi upit
_data := _sql_query( _srv, _qry )

// 3) provjeri rezultat
if VALTYPE( _data ) == "L"
    MsgBeep( "Postoji problem sa upitom !" )
    _ret := -1
    return _ret
endif

// 4) refresh podataka i pozicioniranje na prvi zapis
_data:Refresh()
_data:GoTo(1)

// 5) ako su sifrarnici u pitanju provjeri da li treba raditi browse kompletan 
//    ili si pronasao zapis...
if ::browse_params["codes_type"]

    // pronasao sam samo jedan zapis
    if _data:LastRec() == 1 

        oRow := _data:GetRow(1)
        _value := oRow:FieldGet( oRow:FieldPos( ::browse_params["key_fields"][1] ) )

        if _value == return_value
            // pronasao sam taj zapis... nemam sta traziti to je to
            // ne moram raditi browse...
            return_value := _value
            return _ret
        endif

    elseif _data:LastRec() == 0

        // napravi upit za listu kompletnog sifrarnika....
        _qry := ::select_all_query
        _data := _sql_query( _srv, _qry )
        _data:Refresh()
        _data:GoTo(1)

    endif

endif

// 6) ispis dodatni/pomocni tekst na sifrarniku...
::box_desc_text_print()

// 7) idemo na pregled tabele
_brw := TBrowseSQL():new( m_x + 2, m_y + 1, m_x + ::browse_params["form_height"], m_y + ::browse_params["form_width"], _srv, _data, ::browse_params )
_brw:BrowseTable( .f., NIL, @return_value, @::current_row )

_ret := 1

return _ret






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



// ---------------------------------------------------------
// test funkcija sifrarnika robe u uslovima i GET listi
// ---------------------------------------------------------
function test_get_box_table_browse()
local _id_roba := SPACE(10)
local _test := SPACE(20)
private GetList := {}


Box(, 6, 70 )

    @ m_x + 1, m_y + 2 SAY "TEST RADA SQL TABLE BROWSE ....."
    @ m_x + 3, m_y + 2 SAY "IDROBA (prazno-sve):" GET _id_roba ;
                        VALID EMPTY( _id_roba ) .or. test_sql_table_browse( @_id_roba )

    @ m_x + 4, m_y + 2 SAY "TEST" GET _test 

    read

BoxC()

if LastKey( ) == K_ESC
    return
endif

return





// ---------------------------------------------------------
// test funkcija... kao P_ROBA()
// ---------------------------------------------------------
function test_sql_table_browse( return_value, kord_x, kord_y )
local _ok := .t.
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

Box(, _height, _width, .t., oTBr:browse_codes_commands )

oTBr:browse_params["table_name"] := "fmk.roba"
oTBr:browse_params["table_order_field"] := "id"
oTBr:browse_params["table_browse_return_field"] := "id"
oTBr:browse_params["key_fields"] := { "id", "naz" }
oTBr:browse_params["table_browse_fields"] := _a_columns
oTBr:browse_params["form_width"] := _width
oTBr:browse_params["form_height"] := _height
oTBr:browse_params["table_filter"] := NIL
oTBr:browse_params["direct_sql"] := NIL
oTBr:browse_params["codes_type"] := .t.
//oTBr:browse_params["user_functions"] := {|| _key_handler( oTBr:current_row ) }
oTBr:browse_params["read_sifv"] := .t.
 
// prikazi sifrarnik
oTBr:show( @return_value, kord_x, kord_y )

BoxC()

return _ok


static function _key_handler( curr_row )

do case

    case Ch == K_CTRL_K

        MsgBeep( curr_row:FieldGet(1) )

        return DE_CONT

endcase

return DE_CONT


