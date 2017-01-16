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
THREAD STATIC s_lError := .F.


FUNCTION fetch_metric( cSection, cUser, default_value )

   LOCAL cQuery
   LOCAL oQuery
   LOCAL cRet := ""
   LOCAL xRet

   IF default_value == NIL
      default_value := ""
   ENDIF

   IF cUser != NIL
      IF cUser == "<>"
         cSection += "/" + f18_user()
      ELSE
         cSection += "/" + cUser
      ENDIF
   ENDIF


   IF hb_HHasKey( s_hParametri, cSection ) .AND. !parametar_dinamican( cSection )
#ifdef F18_DEBUG_PARAMS
      ?E "fetch param cache hit: ", cSection
#endif
      RETURN s_hParametri[ cSection ]
   ENDIF

   cQuery := "SELECT " + F18_PSQL_SCHEMA + ".fetchmetrictext(" + sql_quote( cSection )  + ")"

   oQuery := run_sql_query( cQuery )

   IF sql_error_in_query( oQuery, "SELECT" )
      s_lError := .T.
      RETURN default_value
   ELSE
      s_lError := .F.
   ENDIF


   IF sql_query_bez_zapisa( oQuery )
      RETURN default_value
   ENDIF

   cRet := oQuery:FieldGet( 1 )

   IF cRet == "!!notfound!!"
      xRet := default_value
   ELSE

      xRet := str_to_val( cRet, default_value )
      s_hParametri[ cSection ] :=  xRet
   ENDIF

   RETURN xRet


FUNCTION fetch_metric_error()
   RETURN s_lError



FUNCTION parametar_dinamican( cSectionIn )

   IF "auto_plu_" $ cSectionIn
      RETURN .T.
   ENDIF

   IF "_doc_no" $ cSectionIn
      RETURN .T.
   ENDIF

   IF "_brojac_" $ cSectionIn  // brojaci se moraju uvijek citati sa servera
      RETURN .T.
   ENDIF
   IF "_counter_" $ cSectionIn
      RETURN .T.
   ENDIF

   IF Left( cSectionIn, 5 ) == "fakt/"  // fakt brojaci
      RETURN .T.
   ENDIF

   RETURN .F.


FUNCTION set_metric( cSection, cUser, xValue )

   LOCAL oQry
   LOCAL cQuery
   LOCAL _val

   IF cUser != NIL
      IF cUser == "<>"
         cSection += "/" + f18_user()
      ELSE
         cSection += "/" + cUser
      ENDIF
   ENDIF

   SET CENTURY ON
   _val := hb_ValToStr( xValue )
   SET CENTURY OFF

   cQuery := "SELECT " + F18_PSQL_SCHEMA + ".setmetric(" + sql_quote( cSection ) + "," + sql_quote( _val ) +  ")"
   oQry := run_sql_query( cQuery )
   IF sql_error_in_query( oQry, "SELECT" )
      RETURN .F.
   ENDIF

   s_hParametri[ cSection ] := xValue

   RETURN .T.



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
FUNCTION get_set_global_param( cParamName, xValue, def_value )

   LOCAL cRet

   IF xValue == NIL
      cRet := fetch_metric( cParamName, NIL, def_value )
   ELSE
      set_metric( cParamName, NIL, xValue )
      cRet := xValue
   ENDIF

   RETURN cRet


// ----------------------------------------------------------
// set/get user parametre F18
// ----------------------------------------------------------
FUNCTION get_set_user_param( cParamName, xValue, def_value )

   LOCAL cRet

   IF xValue == NIL
      cRet := fetch_metric( cParamName, my_user(), def_value )
   ELSE
      set_metric( cParamName, my_user(), xValue )
      cRet := xValue
   ENDIF

   RETURN cRet




FUNCTION init_parameters_cache()

   s_hParametri := hb_Hash()
   organizacija_params_init()

   RETURN .T.


FUNCTION params_in_cache()

   LOCAL cKey, nCnt := 0

   FOR EACH cKey IN s_hParametri:Keys
      nCnt ++
   NEXT

   RETURN nCnt
