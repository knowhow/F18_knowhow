/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"


STATIC _datum


FUNCTION datum_server( lSet )

   IF lSet == NIL
      lSet := .F.
   ENDIF

   IF lSet .OR. _datum == NIL
      _datum := datum_server_sql()
   ENDIF

   RETURN _datum



FUNCTION danasnji_datum()
   
   RETURN datum_server()



STATIC FUNCTION datum_server_sql()

   LOCAL _date
   LOCAL _pg_server := my_server()
   LOCAL _qry := "SELECT CURRENT_DATE;"
   LOCAL _res

   _res := _sql_query( _pg_server, _qry )

   IF ValType( _res ) <> "L"
      _date := _res:FieldGet( 1 )
   ELSE
      _date := NIL
   ENDIF

   RETURN _date


