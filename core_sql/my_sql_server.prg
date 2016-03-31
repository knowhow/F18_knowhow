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


FUNCTION my_server( oServer )

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





FUNCTION server_postgres_db( oServer )

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
      oServer := my_server()  // db organizacija
   ELSE
      oServer := server_postgres_db()
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
            ?E "CCCCCCCCCCCCCCCCCLOSE TPQSERVER CLOSE CONNECTION port:", s_aSQLConnections[ nPos, 2 ]
            ADel( s_aSQLConnections, nPos )
            ASize( s_aSQLConnections, Len( s_aSQLConnections ) - 1 )
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



FUNCTION my_server_logout( nConnType )

   RETURN my_server_close( nConnType )



FUNCTION num_sql_connections()
   RETURN Len( s_aSQLConnections )

PROCEDURE print_sql_connections()

   LOCAL aConnection

   ?E "SQL connections:"
   FOR EACH aConnection IN s_aSQLConnections
      IF ValType( aConnection ) == "A"
         ?E aConnection[ 1 ], aConnection[ 2 ]
      ELSE
         ?E ValType( aConnection )
      ENDIF
   NEXT

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
      altd()
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


#ifdef F18_DEBUG_THREAD
   ?E Replicate( iif( is_in_main_thread(), "m", "." ), 60 ), "TPQSERVER NEW", iif( is_in_main_thread(), "", "THREAD" ), hSqlParams[ "database" ], oServer:pDb, s_nSQLConnections
#endif

   IF  !oServer:NetErr() .AND. Empty( oServer:ErrorMsg() )

      IF nConnType == 0
         server_postgres_db( oServer )
      ELSE
         my_server( oServer ) // konekcija za organizaciju
         info_bar( "login", "server connection ok: " + hSqlParams[ "user" ] + " / " + iif ( nConnType == 1, hSqlParams[ "database" ], "postgres" ) + " / verzija aplikacije: " + F18_VER, 1 )
      ENDIF

      hParams := hb_Hash()
      hParams[ "server" ] := oServer
      oQry := run_sql_query( "SELECT inet_client_port()", hParams )
      ??E " client port", oQry:FieldGet( 1 )

      IF hb_mutexLock( s_mtxMutex )
         s_nSQLConnections++
         AAdd( s_aSQLConnections, { oServer,  oQry:FieldGet( 1 ) } )
         hb_mutexUnlock( s_mtxMutex )
      ENDIF


      RETURN .T.

   ELSE

      error_bar( "login", "error server connection: " + oServer:ErrorMsg() )
      RETURN .F.
   ENDIF

   RETURN .T.



FUNCTION f18_login_loop( force_connect, arg_v )

   LOCAL oLogin

   IF force_connect == NIL
      force_connect := .T.
   ENDIF

   oLogin := F18Login():New()

   DO WHILE .T.

      oLogin:postgres_db_login( force_connect )

      IF !oLogin:lPostgresDbSpojena
         QUIT_1
      ENDIF
      IF !oLogin:login_odabir_organizacije( @s_psqlServer_params )
         IF LastKey() == K_ESC
            info_bar( "info", "<ESC> za izlaz iz aplikacije" )
            AltD()
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
      ELSE
         write_last_login_params_to_ini_conf() // upisi parametre tekuce firme...
         IF oLogin:lOrganizacijaSpojena
            show_sacekaj()
            program_module_menu( arg_v )
            oLogin:disconnect( 1 )
         ENDIF
      ENDIF

   ENDDO

   RETURN .T.



STATIC FUNCTION f18_form_login( hSqlParams )

   IF hSqlParams == NIL
      hSqlParams := s_psqlServer_params
   ENDIF

   DO WHILE .T.

      IF !_login_screen( @server_params )
         f18_no_login_quit()
         RETURN .F.
      ENDIF

      IF my_server_login( hSqlParams )
         info_bar( "init", "form login succesfull: " + hSqlParams[ "host" ] + " / " + hSqlParams[ "database" ] + " / " + hSqlParams[ "user" ] + " / " + Str( my_server_params()[ "port" ] )  + " / " + hSqlParams[ "schema" ] + " / verzija programa: " + F18_VER )
         EXIT
      ELSE
         Beep( 4 )
      ENDIF

   ENDDO

   RETURN .T.


STATIC FUNCTION _login_screen( hSqlParams )

   LOCAL cHostname, cDatabase, cUser, cPassword, nPort, cSchema, cSession
   LOCAL lSuccess := .T.
   LOCAL nX := 5
   LOCAL nLeft := 7
   LOCAL cConfigureServer := "N"

   cHostName := hSqlParams[ "host" ]
   cDatabase := hSqlParams[ "database" ]
   cUser := hSqlParams[ "user" ]
   cSchema := hSqlParams[ "schema" ]
   nPort := hSqlParams[ "port" ]
   cSession := hSqlParams[ "session" ]
   cPassword := ""

   IF ( cHostName == nil ) .OR. ( nPort == nil )
      cConfigureServer := "D"
   ENDIF

   IF cSession == NIL
      cSession := AllTrim( Str( Year( Date() ) ) )
   ENDIF

   IF cHostName == NIL
      cHostName := "localhost"
   ENDIF

   IF nPort == nil
      nPort := 5432
   ENDIF

   IF cSchema == nil
      cSchema := F18_PSQL_SCHEMA
   ENDIF

   IF cDatabase == nil
      cDatabase := "f18_test"
   ENDIF

   IF cUser == nil
      cUser := "test1"
   ENDIF

   cSchema   := PadR( cSchema, 40 )
   cDatabase := PadR( cDatabase, 100 )
   cHostName := PadR( cHostName, 100 )
   cUser     := PadR( cUser, 100 )
   cPassword := PadR( cPassword, 100 )

   CLEAR SCREEN

   @ 5, 5, 18, 77 BOX B_DOUBLE_SINGLE

   ++ nX
   @ nX, nLeft SAY PadC( "***** Unesite podatke za pristup *****", 60 )

   nX += 2
   @ nX, nLeft SAY PadL( "Konfigurisati server ?:", 21 ) GET cConfigureServer VALID cConfigureServer $ "DN" PICT "@!"
   ++ nX

   READ

   IF cConfigureServer == "D"
      ++ nX
      @ nX, nLeft SAY PadL( "Server:", 8 ) GET cHostname PICT "@S20"
      @ nX, 37 SAY "Port:" GET nPort PICT "9999"
      @ nX, 48 SAY "Shema:" GET cSchema PICT "@S15"
   ELSE
      ++ nX
   ENDIF

   ++ nX
   ++ nX
   @ nX, nLeft SAY PadL( "Baza:", 15 ) GET cDatabase PICT "@S30"
   @ nX, 55 SAY "Sezona:" GET cSession

   ++ nX
   ++ nX
   @ nX, nLeft SAY PadL( "KORISNIK:", 15 ) GET cUser PICT "@S30"

   ++ nX
   ++ nX
   @ nX, nLeft SAY PadL( "LOZINKA:", 15 ) GET cPassword PICT "@S30" COLOR F18_COLOR_PASSWORD

   READ

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   cHostName := AllTrim( cHostname )
   cUser     := AllTrim( cUser )


   IF Empty( cPassword )  // korisnici user=password se jednostavno logiraju
      cPassword := cUser
   ELSE
      cPassword := AllTrim( cPassword )
   ENDIF
   cDatabase := AllTrim( cDatabase )
   cSchema   := AllTrim( cSchema )

   hSqlParams[ "host" ]      := cHostName
   hSqlParams[ "database" ]  := cDatabase
   hSqlParams[ "user" ]      := cUser
   hSqlParams[ "schema" ]    := cSchema
   hSqlParams[ "port" ]      := nPort
   hSqlParams[ "password" ]  := cPassword
   hSqlParams[ "session" ]  := cSession

   RETURN lSuccess


STATIC FUNCTION f18_no_login_quit()

   ?E "direct login: " + ;
      my_server_params()[ "host" ] + " / " + ;
      my_server_params()[ "database" ] + " / " + ;
      my_server_params()[ "user" ] + " / " +  ;
      Str( my_server_params()[ "port" ] )  + " / " + ;
      my_server_params()[ "schema" ]

   MsgBeep( "Neuspješna prijava na server." )

   log_close()

   QUIT_1

   RETURN .T.


STATIC FUNCTION show_sacekaj()

   LOCAL _x, _y
   LOCAL _txt

   _x := ( MAXROWS() / 2 ) - 12
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
   hb_idleAdd( {|| idle_eval() } )

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

   RETURN .T.





FUNCTION write_last_login_params_to_ini_conf()

   LOCAL _key, _ini_params := hb_Hash()

   FOR EACH _key in { "host", "database", "user", "schema", "port", "session" }
      _ini_params[ _key ] := s_psqlServer_params[ _key ]
   NEXT

   IF !f18_ini_config_write( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), _ini_params, .T. )
      MsgBeep( "problem ini write" )
   ENDIF

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
