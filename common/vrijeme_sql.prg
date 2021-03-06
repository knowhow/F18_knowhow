/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning suite,
 * Copyright (c) 1994-2018 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


STATIC _datum


/*
   Opis: vraća tekući datum sa servera

   Usage:
      danasnji_datum() => vraća vrijednost statičke varijable _datum

*/
FUNCTION danasnji_datum()
   RETURN datum_server()



/*
   Opis: vraća/setuje statičku varijablu _datum

   Usage:
      datum_server() => vraća vrijednost statičke varijable _datum
      datum_server(.T.) => iščitava vrijednost sa sql servera i setuje statičku varijablu _datum

*/
FUNCTION datum_server( lSet )

   IF lSet == NIL
      lSet := .F.
   ENDIF

   IF lSet .OR. _datum == NIL
      _datum := datum_server_sql()
   ENDIF

   RETURN _datum



STATIC FUNCTION datum_server_sql()

   LOCAL _qry := "SELECT CURRENT_DATE;"
   LOCAL _res

   _res := run_sql_query( _qry )

   IF sql_error_in_query( _res )
      RETURN Date()
   ENDIF

   RETURN  _res:FieldGet( 1 )
