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


FUNCTION run_sql_query( qry, retry )

   LOCAL _i, _qry_obj

   LOCAL _server := my_server()

   IF retry == NIL
      retry := 1
   ENDIF

   IF ValType( qry ) != "C"
      _msg := "qry ne valja VALTYPE(qry) =" + ValType( qry )
      log_write( _msg, 2 )
      MsgBeep( _msg )
      quit_1
   ENDIF

   log_write( "QRY OK: run_sql_query: " + qry, 9 )

   FOR _i := 1 TO retry

      BEGIN SEQUENCE WITH {| err| Break( err ) }
         _qry_obj := _server:Query( qry + ";" )
      RECOVER
         log_write( "ERROR: run_sql_query(), slijedi timeout od 0.5 sec", 2 )
         my_server_logout()
         hb_idleSleep( 0.5 )
         IF my_server_login()
            _server := my_server()
         ENDIF
      END SEQUENCE

      IF _qry_obj:NetErr() .AND. !Empty( _qry_obj:ErrorMsg() )

         log_write( "run_sql_query(), ajoj: " + _qry_obj:ErrorMsg(), 2 )
         log_write( "run_sql_query(), error na sljedecem upitu: " + qry, 2 )

         my_server_logout()
         hb_idleSleep( 0.5 )

         IF my_server_login()
            _server := my_server()
         ENDIF

         IF _i == retry
            MsgBeep( "neuspjesno nakon " + ALLTRIM( to_str( retry ) ) + " pokusaja !?" )
            Alert( qry )
            QUIT_1
         ENDIF
      ELSE
         _i := retry + 1
      ENDIF
   NEXT

   RETURN _qry_obj



FUNCTION _sql_query( oServer, cQuery, silent )

   LOCAL oQuery, cMsg

   IF silent == NIL
      silent := .F.
   ENDIF

#ifdef NODE
   log_write( cQuery, 1 )
#endif

   oQuery := oServer:Query( cQuery + ";" )

   IF oQuery:lError

      cMsg := oQuery:cError

      IF !Empty( cMsg )
         log_write( "ERROR: _sql_query: " + cQuery + "err msg:" + cMsg, 1, silent )

         IF !silent
            Alert( cQuery + " : " + cMsg )
         ENDIF
      ENDIF

      RETURN .F.

   ELSE

      log_write( "QRY OK: _sql_query: " + cQuery, 9, silent )

   ENDIF

   RETURN oQuery



FUNCTION is_var_objekat_tpquery( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQuery" )



FUNCTION is_var_objekat_tipa( xVar, cClassName )

   IF ValType( xVar ) == "O" .AND. xVar:ClassName() != cClassName
      RETURN .T.
   ENDIF

   RETURN .F.



