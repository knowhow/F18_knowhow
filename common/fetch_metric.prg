/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

THREAD STATIC s_hParametri := NIL



FUNCTION fetch_metric( sect, user, default_value )

   LOCAL _temp_qry
   LOCAL _table
   LOCAL _server := pg_server()
   LOCAL _ret := ""
   LOCAL xRet

   IF default_value == NIL
      default_value := ""
   ENDIF

   IF user != NIL
      IF user == "<>"
         sect += "/" + f18_user()
      ELSE
         sect += "/" + user
      ENDIF
   ENDIF


   IF hb_HHasKey( s_hParametri, sect ) .AND. !parametar_dinamican( sect )
      ?E "fetch param cache hit: ", sect
      RETURN s_hParametri[ sect ]
   ENDIF

   _temp_qry := "SELECT fetchmetrictext(" + sql_quote( sect )  + ")"

   _table := _sql_query( _server, _temp_qry )

   IF sql_error_in_query( _table )
      RETURN default_value
   ENDIF

   IF sql_query_bez_zapisa( _table )
      RETURN default_value
   ENDIF

   _ret := _table:FieldGet( 1 )

   IF _ret == "!!notfound!!"
      xRet := default_value
   ELSE

      xRet := str_to_val( _ret, default_value )
      s_hParametri[ sect ] :=  xRet
   ENDIF

   RETURN xRet


FUNCTION parametar_dinamican( cSection )

   IF "auto_plu_" $ cSection
       RETURN .T.
   ENDIF

   IF "_doc_no" $ cSection
       RETURN .T.
   ENDIF

   IF "_brojac_" $ cSection  // brojaci se moraju uvijek citati sa servera
      RETURN .T.
   ENDIF
   IF "_counter_" $ cSection
      RETURN .T.
   ENDIF

   IF Left( cSection, 5 ) == "fakt/"  // fakt brojaci
      RETURN .T.
   ENDIF

   RETURN .F.

// --------------------------------------------------------------
// setuj parametre u metric tabelu
// --------------------------------------------------------------

FUNCTION set_metric( sect, user, value )

   LOCAL _table
   LOCAL _temp_qry
   LOCAL _server := pg_server()
   LOCAL _val

   IF user != NIL
      IF user == "<>"
         sect += "/" + f18_user()
      ELSE
         sect += "/" + user
      ENDIF
   ENDIF

   SET CENTURY ON
   _val := hb_ValToStr( value )
   SET CENTURY OFF

   _temp_qry := "SELECT fmk.setmetric(" + sql_quote( sect ) + "," + sql_quote( _val ) +  ")"
   _table := _sql_query( _server, _temp_qry )
   IF _table == NIL
      MsgBeep( "problem sa:" + _temp_qry )
      RETURN .F.
   ENDIF

   s_hParametri[ sect ] := value

   RETURN _table:FieldGet( _table:FieldPos( "setmetric" ) )



STATIC FUNCTION str_to_val( str_val, default_value )

   LOCAL _val_type := ValType( default_value )

   DO CASE
   CASE _val_type == "C"
      RETURN hb_UTF8ToStr( str_val )
   CASE _val_type == "N"
      RETURN Val( str_val )
   CASE _val_type == "D"
      RETURN CToD( str_val )
   CASE _val_type == "L"
      IF Lower( str_val ) == ".t."
         RETURN .T.
      ELSE
         RETURN .F.
      ENDIF
   END CASE

   RETURN NIL


// ----------------------------------------------------------
// set/get globalne parametre F18
// ----------------------------------------------------------
FUNCTION get_set_global_param( param_name, value, def_value )

   LOCAL _ret

   IF value == NIL
      _ret := fetch_metric( param_name, NIL, def_value )
   ELSE
      set_metric( param_name, NIL, value )
      _ret := value
   ENDIF

   RETURN _ret


// ----------------------------------------------------------
// set/get user parametre F18
// ----------------------------------------------------------
FUNCTION get_set_user_param( param_name, value, def_value )

   LOCAL _ret

   IF value == NIL
      _ret := fetch_metric( param_name, my_user(), def_value )
   ELSE
      set_metric( param_name, my_user(), value )
      _ret := value
   ENDIF

   RETURN _ret




FUNCTION init_parameters_cache()

   s_hParametri := hb_Hash()

   RETURN .T.


FUNCTION params_in_cache()

   LOCAL cKey, nCnt := 0

   FOR EACH cKey IN s_hParametri:Keys
      nCnt ++
   NEXT

   RETURN nCnt
