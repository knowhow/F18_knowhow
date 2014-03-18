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


CLASS F18_REPORT

    DATA pict_kolicina
    DATA pict_cijena
    DATA pict_iznos

    DATA zagl_arr
    DATA zagl_delimiter

    METHOD New()
    METHOD get_company()
    METHOD show_company()
    METHOD get_zaglavlje()

    PROTECTED:

        METHOD set_picture_codes()

ENDCLASS




// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD F18_REPORT:New()
::zagl_delimiter := " "
::set_picture_codes()
return SELF




// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD F18_REPORT:set_picture_codes( _set, params )

if _set == NIL
    _set := .f.
endif

if _set 
    set_metric( "f18_global_pict_code_qtty", NIL, params["pict_qtty"] )
    set_metric( "f18_global_pict_code_amount", NIL, params["pict_amount"] )
    set_metric( "f18_global_pict_code_price", NIL, params["pict_price"] )
endif

::pict_kolicina := fetch_metric( "f18_global_pict_code_qtty", NIL, "9999999.99" )
::pict_iznos := fetch_metric( "f18_global_pict_code_amount", NIL, "9999999.99" )
::pict_cijena := fetch_metric( "f18_global_pict_code_price", NIL, "999999.999" )

return SELF




// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD F18_REPORT:get_company( id_firma )
local _data, oRow
local _comp

_comp := ALLTRIM( gTS ) + ": "

if gNW == "D"
    _comp += gFirma + " - " + ALLTRIM( gNFirma )
else
    if id_firma == NIL
        id_firma := gFirma
    endif
    _data := _select_all_from_table( "fmk.partn", { "naz", "naz2" }, { "id = " + _sql_quote( id_firma ) } )
    oRow := _data:GetRow(1)
    _comp += id_firma + " " + ;
        hb_utf8tostr( ALLTRIM( oRow:FieldGet( oRow:FieldPos( "naz" ) ) ) ) + " " + ;
        hb_utf8tostr( ALLTRIM( oRow:FieldGet( oRow:FieldPos( "naz2" ) ) ) )
endif

return _comp



// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD F18_REPORT:show_company( id_firma )
local _comp := ::get_company( id_firma )

P_10CPI
B_ON

? _comp

B_OFF
?

return SELF





METHOD F18_REPORT:get_zaglavlje( item )
local _line := ""
local _i, _empty_fill

for _i := 1 to LEN( ::zagl_arr )

	if item == 0
		_line += REPLICATE( "-", ::zagl_arr[ _i, 1 ] )
	elseif item == 1
		_empty_fill := ::zagl_arr[ _i, 1 ] - LEN( ::zagl_arr[ _i, 2 ] )
		_line += ::zagl_arr[ _i, 2 ] + SPACE( _empty_fill )	
	elseif item == 2
		_empty_fill := ::zagl_arr[ _i, 1 ] - LEN( ::zagl_arr[ _i, 3 ] )
		_line += ::zagl_arr[ _i, 3 ] + SPACE( _empty_fill )	
	elseif item == 3
		_empty_fill := ::zagl_arr[ _i, 1 ] - LEN( ::zagl_arr[ _i, 4 ] )
		_line += ::zagl_arr[ _i, 4 ] + SPACE( _empty_fill )	
	endif
		
	if _i <> LEN( ::zagl_arr )
		if item == 0
			_line += " "
		else
			_line += ::zagl_delimiter
		endif
	endif

next

return _line




