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

#include "f18.ch"


/*
    cKontoUslov := "13201;13202;"
    parsiraj_sql( "mkonto", cKontoUslov, .F. )
*/
FUNCTION parsiraj_sql( cFieldName, cond, lNot )

   LOCAL _ret := ""
   LOCAL cond_arr := TOKTONIZ( cond, ";" )
   LOCAL _cond

   IF lNot == NIL
      lNot := .F.
   ENDIF

   FOR EACH _cond in cond_arr

      IF Empty( _cond )
         LOOP
      ENDIF

      _ret += "  OR " + cFieldName

      IF Len( cond_arr ) > 1
         IF lNot
            _ret += " NOT "
         ENDIF
         _ret += " LIKE " + sql_quote( AllTrim( _cond ) + "%" )
      ELSE
         IF lNot
            _ret += " <> "
         ELSE
            _ret += " = "
         ENDIF
         _ret += sql_quote( _cond )
      ENDIF

   NEXT

   _ret := Right( _ret, Len( _ret ) - 5 )

   IF " OR " $ _ret
      _ret := " ( " + _ret + " ) "
   ENDIF

   IF Empty( _ret )
      _ret := " TRUE "
   ENDIF

   RETURN _ret



FUNCTION parsiraj_sql_date_interval( cFieldName, date1, date2 )

   LOCAL _ret := ""

   // datdok BETWEEN '2012-02-01' AND '2012-05-01'

   // dva su datuma
   IF PCount() > 2

      IF date1 == NIL
         date1 := CToD( "" )
      ENDIF
      IF date2 == NIL
         date2 := CToD( "" )
      ENDIF

      // oba su prazna
      IF DToC( date1 ) == DToC( CToD( "" ) ) .AND. DToC( date2 ) == DToC( CToD( "" ) )
         _ret := "TRUE"
         // samo prvi je prazan
      ELSEIF DToC( date1 ) == DToC( CToD( "" ) )
         _ret := cFieldName + " <= " + sql_quote( date2 )
         // drugi je prazan
      ELSEIF DToC( date2 ) == DToC( CToD( "" ) )
         _ret := cFieldName + " >= " + sql_quote( date1 )
         // imamo dva regularna datuma
      ELSE
         // ako su razliciti datumi
         IF DToC( date1 ) <> DToC( date2 )
            _ret := cFieldName + " BETWEEN " + sql_quote( date1 ) + " AND " + sql_quote( date2 )
            // ako su identicni, samo nam jedan treba u LIKE klauzuli
         ELSE
            _ret := cFieldName + "::char(20) LIKE " + sql_quote( _sql_date_str( date1 ) + "%" )
         ENDIF
      ENDIF

   ELSEIF PCount() <= 1
      _ret := "TRUE"
      // samo jedan datumski uslov
   ELSE
      _ret := cFieldName + "::char(20) LIKE " + sql_quote( _sql_date_str( date1 ) + "%" )
   ENDIF

   RETURN "(" + _ret + ")"
