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

MEMVAR GetList

THREAD STATIC s_psqlServer := NIL  // glavni thread
THREAD STATIC s_pgsqlServerPostgresDb := NIL
STATIC s_psqlServer_params := NIL  // parametri trebaju biti dostupni novim threadovima

THREAD STATIC s_psqlServerDbfThread := NIL // svaka thread konekcija zasebna
THREAD STATIC s_psqlServer_params_thread := NIL  // svaka thread konekcija ce zapamtiti svoje parametre

STATIC s_nSQLConnections := 0
STATIC s_aSQLConnections := {}
STATIC s_mtxMutex


FUNCTION sql_data_conn( oServer )

   LOCAL oError
   LOCAL nI, cMsg, cLogMsg := ""

   IF !is_in_main_thread()
      IF oServer <> NIL
         s_psqlServerDbfThread := oServer
      ENDIF
      RETURN s_psqlServerDbfThread
   ENDIF

   IF oServer <> NIL
      s_psqlServer := oServer
   ENDIF

   RETURN s_psqlServer





FUNCTION sql_postgres_conn( oServer )

   IF oServer <> NIL
      s_pgsqlServerPostgresDb := oServer
   ENDIF

   RETURN s_pgsqlServerPostgresDb




FUNCTION server_postgres_db_close()

   RETURN my_server_close( 0 )




FUNCTION my_server_close( nConnType )

   LOCAL oServer, pDb, nPos

   hb_default( @nConnType, 1 )

   IF nConnType == 1
      oServer := sql_data_conn()  // db organizacija
   ELSE
      oServer := sql_postgres_conn()
   ENDIF

   IF is_var_objekat_tpqserver( oServer )
      pDb := oServer:pDb
      IF HB_ISNIL( pDb )
         ?E "TPQSERVER pDb IS NIL", s_nSQLConnections
         RETURN .F.
      ENDIF
      IF hb_mutexLock( s_mtxMutex )
         s_nSQLConnections--
         nPos := AScan( s_aSQLConnections, {| item|  item[ 1 ] == oServer } )
         IF nPos > 0
#ifdef F18_DEBUG_SQL
            ?E "CCCCCCCCCCCCCCCCCLOSE TPQSERVER CLOSE CONNECTION port:", s_aSQLConnections[ nPos, 2 ]
#endif
            ADel( s_aSQLConnections, nPos )
            ASize( s_aSQLConnections, Len( s_aSQLConnections ) -1 )
         ENDIF
         hb_mutexUnlock( s_mtxMutex )
      ENDIF

      oServer:close()
      oServer := NIL

#ifdef F18_DEBUG_THREAD
      ?E Replicate( iif( is_in_main_thread(), "%", "t" ), 50 ), "TPQSERVER " + iif( is_in_main_thread(), "", "THREAD " ), "CLOSE", ;
         iif( nConnType == 0, "POSTGRES DB", "DATA DB" ), pDb, s_nSQLConnections
#endif


   ELSE
      ?E "ERROR: server is not TPQServer objekat ?!"
   ENDIF

   IF !is_in_main_thread()
      s_psqlServerDbfThread := NIL
   ENDIF

   RETURN .T.


FUNCTION my_database()

   LOCAL hParams := my_server_params()

   IF ValType( hParams ) == "H" .AND. hb_HHasKey( hParams, "database" )
      RETURN hParams[ "database" ]
   ENDIF

   RETURN "?undefined?"


FUNCTION my_server_logout( nConnType )

   RETURN my_server_close( nConnType )



FUNCTION num_sql_connections()
   RETURN Len( s_aSQLConnections )

PROCEDURE print_sql_connections()

   LOCAL aConnection

   IF hb_mutexLock( s_mtxMutex )
      ?E "SQL connections:"
      FOR EACH aConnection IN s_aSQLConnections
         IF ValType( aConnection ) == "A"
            ?E aConnection[ 1 ], aConnection[ 2 ]
         ELSE
            ?E ValType( aConnection )
         ENDIF
      NEXT
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN

/*
 set_get server_params
*/

FUNCTION my_server_params( hSqlParams )

   LOCAL  _key

   IF !is_in_main_thread()
      IF hSqlParams <> NIL
         FOR EACH _key in hSqlParams:Keys
            s_psqlServer_params_thread[ _key ] := hSqlParams[ _key ]
         NEXT
      ELSE
         IF HB_ISNIL( s_psqlServer_params_thread )
            s_psqlServer_params_thread := hb_HClone( s_psqlServer_params )
         ENDIF
      ENDIF
      RETURN s_psqlServer_params_thread // svaki thread treba zapamtiti svoje parametre
   ENDIF

   IF hSqlParams <> NIL
      FOR EACH _key in hSqlParams:Keys
         s_psqlServer_params[ _key ] := hSqlParams[ _key ]
      NEXT
   ENDIF

   RETURN s_psqlServer_params



FUNCTION my_server_login( hSqlParams, nConnType )

   LOCAL oServer
   LOCAL oQry, hParams

   IF hSqlParams == NIL
      hSqlParams := my_server_params()
   ENDIF

   IF !hb_HHasKey( hSqlParams, "host" )
      Alert( "my server login hSqlParams ERROR" + pp( hSqlParams ) )
      QUIT
   ENDIF

   IF nConnType == NIL
      nConnType := 1
   ENDIF


   IF nConnType == 0
      hSqlParams[ "database" ] := "postgres"
      hSqlParams[ "schema" ] := "public"
   ENDIF

   oServer := TPQServer():New( hSqlParams[ "host" ], ;
      hSqlParams[ "database" ], ;
      hSqlParams[ "user" ], ;
      hSqlParams[ "password" ], ;
      hSqlParams[ "port" ], ;
      hSqlParams[ "schema" ] )

#ifdef F18_DEBUG_SQL
   ?E Replicate( iif( is_in_main_thread(), "m", "." ), 60 ), "TPQSERVER NEW", iif( is_in_main_thread(), "", "THREAD" ), hSqlParams[ "database" ], oServer:pDb, s_nSQLConnections
#endif

   IF  !oServer:NetErr() .AND. Empty( oServer:ErrorMsg() )

      IF nConnType == 0
         sql_postgres_conn( oServer )
      ELSE
         sql_data_conn( oServer ) // konekcija za organizaciju
         // info_bar( "login", "server connection ok: " + hSqlParams[ "user" ] + " / " + iif ( nConnType == 1, hSqlParams[ "database" ], "postgres" ) + " / verzija aplikacije: " + F18_VER, 1 )
      ENDIF

      hParams := hb_Hash()
      hParams[ "server" ] := oServer
      oQry := run_sql_query( "SELECT current_user, inet_client_port()", hParams )
#ifdef F18_DEBUG_SQL
      ??E "user:", oQry:FieldGet( 1 ), " client port", oQry:FieldGet( 2 )
#endif
      IF hb_mutexLock( s_mtxMutex )
         s_nSQLConnections++
         AAdd( s_aSQLConnections, { oServer,  oQry:FieldGet( 1 ), oQry:FieldGet( 2 ) } )
         hb_mutexUnlock( s_mtxMutex )
      ENDIF


      RETURN .T.

   ELSE

      error_bar( "login", "error server connection: " + oServer:ErrorMsg() )
      RETURN .F.
   ENDIF

   RETURN .T.



FUNCTION f18_login_loop( lAutoConnect, arg_v )

   LOCAL oLogin

   IF lAutoConnect == NIL
      lAutoConnect := .T.
   ENDIF

   oLogin := F18Login():New()

   DO WHILE .T.

      oLogin:postgres_db_login( lAutoConnect )

      IF !oLogin:lPostgresDbSpojena
         QUIT_1
      ELSE
         lAutoConnect := .T.
      ENDIF

      IF !oLogin:login_odabir_organizacije()

         IF LastKey() == K_ESC
            RETURN .F.
         ENDIF
/*          TODO: 2 x ESC ulkoniti
            info_bar( "info", "<ESC> za izlaz iz aplikacije" )
            oLogin:disconnect( 0 )
            oLogin:disconnect( 1 )
            print_sql_connections()

            Inkey( 0 )
            IF LastKey() == K_ESC // 2 x ESC

               ?E "num sql connections:", num_sql_connections()
               ?E
               RETURN .F.
            ENDIF

         ENDIF
*/
      ELSE
         IF oLogin:lOrganizacijaSpojena
            show_sacekaj()
            oLogin:disconnect( 0 )
            program_module_menu( arg_v )
            oLogin:disconnect( 1 )
         ENDIF
      ENDIF

   ENDDO

   RETURN .T.



STATIC FUNCTION show_sacekaj()

   LOCAL _x, _y
   LOCAL _txt

   _x := ( MAXROWS() / 2 ) -12
   _y := MAXCOLS()

   CLEAR SCREEN

   // _txt := PadC( ". . .  S A Č E K A J T E    T R E N U T A K  . . .", _y )
   // @ _x, 2 SAY8 _txt

   // _txt := PadC( ". . . . . . k o n e k c i j a    n a    b a z u   u   t o k u . . . . . . .", _y )
   // @ _x + 1, 2 SAY8 _txt


   naslovni_ekran_splash_screen( "F18", F18_VER )

   RETURN .T.



FUNCTION f18_promjena_sezone()

   LOCAL oLogin := F18Login():New()

   oLogin:promjena_sezone()

   RETURN .T.




FUNCTION init_harbour()

   rddSetDefault( RDDENGINE )
   Set( _SET_AUTOPEN, .F.  )

   SET CENTURY OFF
   // epoha je u stvari 1999, 2000 itd
   SET EPOCH TO 1960
   SET DATE TO GERMAN


   f18_init_threads()


   hb_cdpSelect( "SL852" )
   hb_SetTermCP( "SLISO" )

   SET DELETED ON

   SetCancel( .F. )

   Set( _SET_EVENTMASK, INKEY_ALL )
   MSetCursor( .T. )

   SET DATE GERMAN
   SET SCOREBOARD OFF
   SET CONFIRM ON
   SET WRAP ON
   SET ESCAPE ON
   SET SOFTSEEK ON

   SetColor( F18_COLOR_NORMAL )

   Set( _SET_IDLEREPEAT, .F. )
   hb_idleAdd( {|| on_idle_dbf_refresh() } )
   // hb_idleAdd( {|| idle_eval() } ) - izaziva erore

   RETURN .T.







FUNCTION my_server_search_path( path )

   LOCAL _key := "search_path"

   IF path == nil
      IF !hb_HHasKey( s_psqlServer_params, _key )
         s_psqlServer_params[ _key ] := F18_PSQL_SCHEMA + ", public"
      ENDIF
   ELSE
      s_psqlServer_params[ _key ] := path
   ENDIF

   RETURN s_psqlServer_params[ _key ]


FUNCTION f18_user()
   RETURN s_psqlServer_params[ "user" ]


FUNCTION f18_database()
   RETURN s_psqlServer_params[ "database" ]


FUNCTION f18_curr_session()
   RETURN s_psqlServer_params[ "session" ]


FUNCTION my_user()
   RETURN f18_user()



INIT PROCEDURE init_my_sql_server()

   s_mtxMutex := hb_mutexCreate()
   s_psqlServer_params := hb_Hash()

   RETURN
