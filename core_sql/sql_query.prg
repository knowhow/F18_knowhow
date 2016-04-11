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

STATIC s_mtxMutex
STATIC s_aTransactions := {}

FUNCTION set_sql_search_path()

   LOCAL _path := my_server_search_path()

   LOCAL _qry := "SET search_path TO " + _path + ";"
   LOCAL _result

   _result := run_sql_query( _qry )

   IF sql_error_in_query( _result, "SET" )
      RETURN .F.
#ifdef F18_DEBUG_SQL
   ELSE
      ?E "set_sql_search path ok"
#endif
   ENDIF

   RETURN .T.



FUNCTION _sql_query( oServer, cQuery )

   LOCAL hParams := hb_Hash()

   hParams[ "retry" ] := 2
   hParams[ "server" ] := oServer

   RETURN run_sql_query( cQuery, hParams )



FUNCTION postgres_sql_query( cQuery )

   LOCAL hParams := hb_Hash()

   hParams[ "server" ] := sql_postgres_conn()

   RETURN run_sql_query( cQuery, hParams )


FUNCTION run_sql_query( cQry, hParams )

   LOCAL nI, oQuery, cLogMsg, cMsg
   LOCAL _msg
   LOCAL cTip
   LOCAL nPos
   LOCAL nRetry := 2
   LOCAL oServer := sql_data_conn()
   LOCAL cTransactionName := "BEGIN"
   LOCAL lLog := .T.

   IF hParams != NIL

      IF ValType( hParams ) != "H"
         Alert( "run sql query param 2 nije hash !?" )
         AltD()
         QUIT
      ENDIF

      IF hb_HHasKey( hParams, "retry" )
         nRetry := hParams[ "retry" ]
      ENDIF

      IF hb_HHasKey( hParams, "server" )
         oServer :=  hParams[ "server" ]
      ENDIF

      IF hb_HHasKey( hParams, "tran_name" )
         cTransactionName :=  hParams[ "tran_name" ]
      ENDIF

      IF hb_HHasKey( hParams, "log" )
         lLog :=  hParams[ "log" ]
      ENDIF
   ENDIF


   IF !is_in_main_thread()
      IF !is_var_objekat_tpqserver( oServer ) .OR. oServer:pDB == NIL
         // delegiraj izvrsenje u main thread-u
         idle_add_for_eval( cQry, {|| run_sql_query( cQry ) } )
         RETURN idle_get_eval( cQry )
      ENDIF
   ENDIF


   IF ! is_var_objekat_tpqserver( oServer )
      ?E "run_sql_query server not defined !"
      RETURN NIL
   ENDIF

   IF Left( cQry, 5 ) == "BEGIN"
      IF hb_mutexLock( s_mtxMutex )

         nPos := AScan( s_aTransactions, {| aItem | ValType( aItem ) == "A" ;
            .AND. aItem[ 2 ] == sql_data_conn():pDB .AND. aItem[ 3 ] == hb_threadSelf() .AND. aItem[ 4 ] == cTransactionName } )

         IF nPos > 0
            cLogMsg := "SQL transactions ERR: "
            LOG_CALL_STACK cLogMsg
            ?E cLogMsg
            IF is_in_main_thread()
               AltD()
               Alert( "SQL transactions error !" )
            ENDIF
            hb_mutexUnlock( s_mtxMutex )
            print_transactions()
            RETURN NIL
         ENDIF

         AAdd( s_aTransactions, { Time(), sql_data_conn():pDB, hb_threadSelf(), cTransactionName } )
         hb_mutexUnlock( s_mtxMutex )
      ENDIF
   ENDIF

   IF Left( cQry, 6 ) == "COMMIT" .OR. Left( cQry, 8 ) == "ROLLBACK"
      IF hb_mutexLock( s_mtxMutex )
         nPos := AScan( s_aTransactions, {| aTran | ValType( aTran ) == "A" .AND. ;
            aTran[ 2 ] == sql_data_conn():pDB .AND. aTran[ 3 ] == hb_threadSelf() .AND. aTran[ 4 ] == cTransactionName } )

         IF nPos > 0
            ADel( s_aTransactions, nPos )
            ASize( s_aTransactions, Len( s_aTransactions ) - 1 )
         ENDIF
         hb_mutexUnlock( s_mtxMutex )

      ENDIF

   ENDIF

   IF Left( Upper( cQry ), 6 ) == "SELECT"
      cTip := "SELECT"
   ELSE
      cTip := "INSERT" // insert ili update nije bitno
   ENDIF

   IF ValType( cQry ) != "C"
      _msg := "qry ne valja VALTYPE(qry) =" + ValType( cQry )
      IF lLog
         log_write( _msg, 2 )
      ENDIF
      MsgBeep( _msg )
      quit_1
   ENDIF


   FOR nI := 1 TO nRetry

      IF nI > 1
         error_bar( "sql",  cQry + " pokušaj: " + AllTrim( Str( nI ) ) )
      ENDIF

      BEGIN SEQUENCE WITH {| err| Break( err ) }

         oQuery := oServer:Query( cQry + ";" )

      RECOVER

         hb_idleSleep( 1 )

      END SEQUENCE


      IF sql_error_in_query( oQuery, cTip, oServer )

         ?E "SQL ERROR QUERY: ", cQry
         IF is_var_objekat_tpqserver( sql_data_conn() )
            ?E "pDb:", sql_data_conn():pDb
         ENDIF
         print_transactions()
         print_threads( cQry )
         error_bar( "sql", cQry )
         IF nI == nRetry
            RETURN oQuery
         ENDIF

      ELSE
         nI := nRetry + 1
      ENDIF

   NEXT

   RETURN oQuery




FUNCTION is_in_main_thread_sql_transaction()

   IF !is_in_main_thread()
      RETURN .F.
   ENDIF

   IF hb_mutexLock( s_mtxMutex )

      nPos := AScan( s_aTransactions, {| aItem | ValType( aItem ) == "A" ;
         .AND. aItem[ 2 ] == sql_data_conn():pDB .AND. aItem[ 3 ] == main_thread() } )

      hb_mutexUnlock( s_mtxMutex )
      IF nPos > 0
         RETURN .T.
      ENDIF



   ENDIF

   RETURN .T.

PROCEDURE print_transactions()

   LOCAL aTransaction

   ?E "SQL transactions:"
   FOR EACH aTransaction IN s_aTransactions
      IF ValType( aTransaction ) == "A"
         ?E aTransaction[ 1 ], "pDB:", aTransaction[ 2 ], "thread id:", aTransaction[ 3 ], aTransaction[ 4 ]
      ELSE
         ?E ValType( aTransaction ),  aTransaction
      ENDIF
   NEXT

   RETURN

FUNCTION is_var_objekat_tpqserver( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQServer" )

FUNCTION is_var_objekat_tpqquery( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQquery" )

FUNCTION is_var_objekat_tipa( xVar, cClassName )

   IF ValType( xVar ) == "O" .AND. Upper( xVar:ClassName() ) == Upper( cClassName )
      RETURN .T.
   ENDIF

   RETURN .F.



FUNCTION sql_error_in_query( oQry, cTip, oServer )

   LOCAL cLogMsg := "", cMsg, nI
   LOCAL cQuery

   hb_default( @oServer, sql_data_conn() )

   IF cTip == NIL
      cQuery := oQry:cQuery
      IF Left( Upper( cQuery ), 6 ) == "SELECT"
         cTip := "SELECT"
      ELSE
         cTip := "UPDATE" // insert ili update nije bitno
      ENDIF
   ENDIF


   IF is_var_objekat_tpqquery( oQry ) .AND. !Empty( oQry:ErrorMsg() )
      LOG_CALL_STACK cLogMsg
      ?E oQry:ErrorMsg(), cLogMsg
      error_bar( "sql", oQry:ErrorMsg() )
      RETURN .T.
   ENDIF

   IF cTip == "SELECT" .AND. !is_var_objekat_tpqquery( oQry )
      RETURN .T.
   ENDIF

   IF cTip $ "SET#INSERT#UPDATE#DELETE#DROP#CREATE#GRANT#"
      IF is_var_objekat_tpqserver( oServer ) .AND. !Empty( oServer:ErrorMsg() )
         LOG_CALL_STACK cLogMsg
         ?E oServer:ErrorMsg(), cLogMsg
         RETURN .T.
      ELSE
         RETURN .F. // sve ok
      ENDIF
   ENDIF

   RETURN  ( oQry:NetErr() )



FUNCTION sql_query_no_records( ret )

   RETURN sql_query_bez_zapisa( ret )



FUNCTION sql_query_bez_zapisa( ret )

   LOCAL cMsg, cLogMsg, nI

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
      cLogMsg := "sql_query ? ret valtype: " + ValType( ret )
      LOG_CALL_STACK cLogMsg
      QUIT_1
   END SWITCH

   RETURN .F.


INIT PROCEDURE init_sql_qry()

   s_mtxMutex := hb_mutexCreate()

   RETURN
