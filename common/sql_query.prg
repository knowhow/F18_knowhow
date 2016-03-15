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


FUNCTION set_sql_search_path()

   LOCAL _path := my_server_search_path()

   LOCAL _qry := "SET search_path TO " + _path + ";"
   LOCAL _result

   _result := run_sql_query( _qry )

   IF sql_error_in_query( _result, "SET" )
      RETURN .F.
   ELSE
      ?E "set_sql_search path ok"
   ENDIF

   RETURN _result



FUNCTION _sql_query( oServer, cQuery, silent )

   RETURN run_sql_query( cQuery, 10, oServer )


FUNCTION run_sql_query( qry, retry, oServer )

   LOCAL _i, _qry_obj, lMsg := .F.
   LOCAL _server
   LOCAL _msg
   LOCAL cTip

   IF retry == NIL
      retry := 10
   ENDIF

   IF oServer == NIL
      _server := my_server()
   ELSE
      _server := oServer
   ENDIF

   IF Left( Upper( qry ), 6 ) == "SELECT"
      cTip := "SELECT"
   ELSE
      cTip := "INSERT" // insert ili update nije bitno
   ENDIF

   IF ValType( qry ) != "C"
      _msg := "qry ne valja VALTYPE(qry) =" + ValType( qry )
      log_write( _msg, 2 )
      MsgBeep( _msg )
      quit_1
   ENDIF


   FOR _i := 1 TO retry

      IF _i > 1
         error_bar( "sql",  qry + " pokušaj: " + AllTrim( Str( _i ) ) )
         lMsg := .T.
      ENDIF

      BEGIN SEQUENCE WITH {| err| Break( err ) }

         _qry_obj := _server:Query( qry + ";" )

      RECOVER

         hb_idleSleep( 1 )

      END SEQUENCE


      IF sql_error_in_query( _qry_obj, cTip )

         ?E "SQL ERROR QUERY: ", qry
         error_bar( "sql", qry )
         IF _i == retry
            RETURN .F.
         ENDIF

      ELSE
         _i := retry + 1
      ENDIF

      iif( lMsg, MsgC(), NIL )

   NEXT

   RETURN _qry_obj


FUNCTION is_var_objekat_tpqserver( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQServer" )

FUNCTION is_var_objekat_tpqquery( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQquery" )

FUNCTION is_var_objekat_tipa( xVar, cClassName )

   IF ValType( xVar ) == "O" .AND. Upper( xVar:ClassName() ) == Upper( cClassName )
      RETURN .T.
   ENDIF

   RETURN .F.



FUNCTION sql_error_in_query( oQry, cTip )

   LOCAL cLogMsg := "", cMsg, nI

   hb_default( @cTip, "SELECT" )

   IF cTip == "SELECT" .AND. !is_var_objekat_tpqquery( oQry )
      RETURN .T.
   ENDIF

   IF cTip $ "SET#INSERT#UPDATE"
      IF !Empty( my_server():ErrorMsg() )
         LOG_CALL_STACK cLogMsg
         ?E my_server():ErrorMsg(), cLogMsg
         RETURN .T.
      ELSE
         RETURN .F. // sve ok
      ENDIF
   ENDIF

   IF !Empty( oQry:ErrorMsg() )
      LOG_CALL_STACK cLogMsg
      ?E oQry:ErrorMsg(), cLogMsg
      RETURN .T.
   ENDIF

   RETURN  ( oQry:NetErr() )



FUNCTION sql_query_no_records( ret )

   RETURN sql_query_bez_zapisa( ret )



FUNCTION sql_query_bez_zapisa( ret )

   SWITCH ValType( ret )
   CASE "L"
      RETURN .T.
   CASE "O"
      // TPQQuery nema nijednog zapisa
      IF ret:lEof .AND. ret:lBof
         RETURN .T.
      ENDIF
      EXIT
   OTHERWISE
      MsgBeep( "sql_query ? ret valtype: " + ValType( ret ) )
      QUIT_1
   END SWITCH

   RETURN .F.
