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


FUNCTION server_show( var )

   LOCAL _qry
   LOCAL _ret

   _qry := "SHOW " + var

   _ret := run_sql_query( _qry, 1 )

   IF !is_var_objekat_tpqquery( _ret )
      RETURN -1
   ENDIF

   IF _ret:Eof()
      RETURN -1
   ENDIF

   RETURN _ret:FieldGet( 1 )


FUNCTION server_sys_info( var )

   LOCAL _qry
   LOCAL _ret_sql
   LOCAL _server := pg_server()
   LOCAL _ret := hb_Hash()

   _qry := "select inet_client_addr(), inet_client_port(),  inet_server_addr(), inet_server_port(), user"

   log_write( _qry, 9 )
   _ret_sql := _sql_query( _server, _qry )

   IF sql_query_bez_zapisa( _ret_sql )
      RETURN NIL
   ENDIF

   _ret[ "client_addr" ] := _ret_sql:FieldGet( 1 )
   _ret[ "client_port" ] := _ret_sql:FieldGet( 2 )
   _ret[ "server_addr" ] := _ret_sql:FieldGet( 3 )
   _ret[ "server_port" ] := _ret_sql:FieldGet( 4 )
   _ret[ "user" ]        := _ret_sql:FieldGet( 5 )

   RETURN _ret
