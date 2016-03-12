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

#include "f18.ch"



CLASS ReportCommon

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





METHOD ReportCommon:New()

   ::zagl_delimiter := " "
   ::set_picture_codes()

   RETURN SELF




// -----------------------------------------------------------
// -----------------------------------------------------------
METHOD ReportCommon:set_picture_codes( _set, params )

   IF _set == NIL
      _set := .F.
   ENDIF

   IF _set
      set_metric( "f18_global_pict_code_qtty", NIL, params[ "pict_qtty" ] )
      set_metric( "f18_global_pict_code_amount", NIL, params[ "pict_amount" ] )
      set_metric( "f18_global_pict_code_price", NIL, params[ "pict_price" ] )
   ENDIF

   ::pict_kolicina := fetch_metric( "f18_global_pict_code_qtty", NIL, "9999999.99" )
   ::pict_iznos := fetch_metric( "f18_global_pict_code_amount", NIL, "9999999.99" )
   ::pict_cijena := fetch_metric( "f18_global_pict_code_price", NIL, "999999.999" )

   RETURN SELF





METHOD ReportCommon:get_company( id_firma )

   LOCAL _data, oRow
   LOCAL _comp

   _comp := AllTrim( gTS ) + ": "

   IF gNW == "D"
      _comp += gFirma + " - " + AllTrim( gNFirma )
   ELSE
      IF id_firma == NIL
         id_firma := gFirma
      ENDIF
      _data := select_all_records_from_table( F18_PSQL_SCHEMA_DOT + "partn", { "naz", "naz2" }, { "id = " + sql_quote( id_firma ) } )
      oRow := _data:GetRow( 1 )
      _comp += id_firma + " " + ;
         hb_UTF8ToStr( AllTrim( oRow:FieldGet( oRow:FieldPos( "naz" ) ) ) ) + " " + ;
         hb_UTF8ToStr( AllTrim( oRow:FieldGet( oRow:FieldPos( "naz2" ) ) ) )
   ENDIF

   RETURN _comp




METHOD ReportCommon:show_company( id_firma )

   LOCAL _comp := ::get_company( id_firma )

   P_10CPI
   B_ON

   ? _comp

   B_OFF
   ?

   RETURN SELF





METHOD ReportCommon:get_zaglavlje( item )

   LOCAL _line := ""
   LOCAL _i, _empty_fill

   FOR _i := 1 TO Len( ::zagl_arr )

      IF item == 0
         _line += Replicate( "-", ::zagl_arr[ _i, 1 ] )
      ELSEIF item == 1
         _empty_fill := ::zagl_arr[ _i, 1 ] - Len( ::zagl_arr[ _i, 2 ] )
         _line += ::zagl_arr[ _i, 2 ] + Space( _empty_fill )
      ELSEIF item == 2
         _empty_fill := ::zagl_arr[ _i, 1 ] - Len( ::zagl_arr[ _i, 3 ] )
         _line += ::zagl_arr[ _i, 3 ] + Space( _empty_fill )
      ELSEIF item == 3
         _empty_fill := ::zagl_arr[ _i, 1 ] - Len( ::zagl_arr[ _i, 4 ] )
         _line += ::zagl_arr[ _i, 4 ] + Space( _empty_fill )
      ENDIF

      IF _i <> Len( ::zagl_arr )
         IF item == 0
            _line += " "
         ELSE
            _line += ::zagl_delimiter
         ENDIF
      ENDIF

   NEXT

   RETURN _line
