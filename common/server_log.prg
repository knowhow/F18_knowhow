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

/* ------------------------------------------
  reset_semaphore_version( "konto")
  set version to -1
  -------------------------------------------
*/
FUNCTION server_log_write( msg, silent )

   LOCAL _ret
   LOCAL _result
   LOCAL _qry
   LOCAL _tbl
   LOCAL _user := f18_user()
   LOCAL _server := pg_server()

   IF silent == NIL
      silent := .F.
   ENDIF

   _tbl := F18_PSQL_SCHEMA + ".log"

   msg  := ProcName( 2 ) + "(" + AllTrim( Str( ProcLine( 2 ) ) ) + ") : " + msg
   _qry := "INSERT INTO " + _tbl + "(user_code, msg) VALUES(" +  sql_quote( _user ) + "," +  sql_quote( msg ) + ")"
   _ret := _sql_query_no_log( _server, _qry, silent )

   RETURN .T.



/*
  run query bez upisivanja u log
*/
STATIC FUNCTION _sql_query_no_log( srv, qry, silent )

   LOCAL _msg, _ret

   IF silent == NIL
      silent := .F.
   ENDIF

   _ret := srv:Query( qry )

   RETURN _ret
