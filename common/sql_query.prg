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

   LOCAL _server := my_server()
   LOCAL _path := my_server_search_path()

   LOCAL _qry := "SET search_path TO " + _path + ";"
   LOCAL _result

   _result := _server:Query( _qry )

   IF sql_error_in_query( _result )
      ?E "ERR?! :" + _qry
      RETURN .F.
   ELSE
      log_write( "set_sql_search path ok", 9 )
   ENDIF

   RETURN _result



FUNCTION _sql_query( oServer, cQuery, silent )

   RETURN run_sql_query( cQuery, 10 )


FUNCTION run_sql_query( qry, retry )

   LOCAL _i, _qry_obj, lMsg := .F.
   LOCAL _server := my_server()
   LOCAL _msg

   IF retry == NIL
      retry := 10
   ENDIF

   IF ValType( qry ) != "C"
      _msg := "qry ne valja VALTYPE(qry) =" + ValType( qry )
      log_write( _msg, 2 )
      MsgBeep( _msg )
      quit_1
   ENDIF


   FOR _i := 1 TO retry

      IF _i > 1
         MsgO( "Pokušavam izvršiti SQL upit: " + qry + " pokušaj: " + AllTrim( Str( _i ) ) )
         lMsg := .T.
      ENDIF

      BEGIN SEQUENCE WITH {| err| Break( err ) }

         _qry_obj := _server:Query( qry + ";" )

      RECOVER

         hb_idleSleep( 1 )

      END SEQUENCE

      IF sql_error_in_query( _qry_obj )

         ?E "SQL ERROR: ", qry
         error_bar( "sql", qry )
         IF _i == retry
            MsgC()
            RETURN .F.
         ENDIF

      ELSE
         _i := retry + 1
      ENDIF

      iif( lMsg, MsgC(), NIL )

   NEXT

   RETURN _qry_obj



FUNCTION is_var_objekat_tpquery( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQServer" )

FUNCTION is_var_objekat_tpquery( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQquery" )

FUNCTION is_var_objekat_tipa( xVar, cClassName )

   IF ValType( xVar ) == "O" .AND. Upper( xVar:ClassName() ) == Upper( cClassName )
      RETURN .T.
   ENDIF

   RETURN .F.


FUNCTION sql_error_in_query( oQry )

   IF !is_var_objekat_tpquery( oQry )
      RETURN .T.
   ENDIF

   RETURN  ( oQry:NetErr() ) .AND. !Empty( oQry:ErrorMsg() )



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
