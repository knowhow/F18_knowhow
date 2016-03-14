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

STATIC s_psqlServer := NIL
STATIC s_pgsqlServerMainDb := NIL

THREAD STATIC s_psqlServerDbfThread := NIL // svaka thread konekcija zasebna

STATIC s_psqlServer_params := NIL
THREAD STATIC s_psqlServer_params_thread := NIL  // svaka thread konekcija ce zapamtiti svoje parametre

FUNCTION pg_server( server )

   LOCAL oError
   LOCAL nI, cMsg, cLogMsg := ""

   IF !is_in_main_thread()

      IF s_psqlServerDbfThread  == NIL

         BEGIN SEQUENCE WITH {| err | Break( err ) }
            s_psqlServer_params_thread := hb_HClone( s_psqlServer_params )
            s_psqlServerDbfThread := TPQServer():New( s_psqlServer_params[ "host" ], ;
               s_psqlServer_params_thread[ "database" ], ;
               s_psqlServer_params_thread[ "user" ], ;
               s_psqlServer_params_thread[ "password" ], ;
               s_psqlServer_params_thread[ "port" ], ;
               s_psqlServer_params_thread[ "schema" ] )

         RECOVER USING oError

            LOG_CALL_STACK cLogMsg
            ?E "thread psql login error:", cLogMsg, oError:description
            QUIT_1
         END SEQUENCE

      ENDIF
      RETURN s_psqlServerDbfThread

   ENDIF

   IF server <> NIL
      s_psqlServer := server
   ENDIF

   RETURN s_psqlServer


FUNCTION my_server( oServer )

   RETURN pg_server( oServer )




FUNCTION server_main_db( oServer )

   IF oServer <> NIL
      s_pgsqlServerMainDb := oServer
   ENDIF

   RETURN s_pgsqlServerMainDb




FUNCTION server_main_db_close()

   LOCAL oServer := server_main_db()

   IF is_var_objekat_tpqserver( oServer )
      oServer:close()
   ENDIF

   RETURN .T.






FUNCTION my_server_close()

   LOCAL oServer := my_server()

   IF is_var_objekat_tpqserver( oServer )
      oServer:close()
   ENDIF

   IF !is_in_main_thread()
      s_psqlServerDbfThread := NIL
   ENDIF

   RETURN .T.



FUNCTION my_server_logout()

   RETURN my_server_close()



/*
 set_get server_params
*/

FUNCTION my_server_params( params )

   LOCAL  _key

   IF !is_in_main_thread()
      RETURN s_psqlServer_params_thread // svaki thread treba zapamtiti svoje parametre
   ENDIF

   IF params <> nil
      FOR EACH _key in params:Keys
         s_psqlServer_params[ _key ] := params[ _key ]
      NEXT
   ENDIF

   RETURN s_psqlServer_params



FUNCTION my_server_login( params, conn_type )

   LOCAL _key, _server

   IF params == NIL
      params := s_psqlServer_params
   ENDIF

   IF conn_type == NIL
      conn_type := 1
   ENDIF

   FOR EACH _key in params:Keys
      IF params[ _key ] == NIL
         IF conn_type == 1
            error_bar( "init", "my_server_login error server params key: " + _key )
         ENDIF
         RETURN .F.
      ENDIF
   NEXT

   _server := TPQServer():New( params[ "host" ], ;
      iif( conn_type == 1, params[ "database" ], "postgres" ), ;
      params[ "user" ], ;
      params[ "password" ], ;
      params[ "port" ], ;
      iif( conn_type == 1, params[ "schema" ], "public" ) )


   IF  !_server:NetErr() .AND. Empty( _server:ErrorMsg() )

      IF conn_type == 0
         server_main_db( _server )
      ELSE
         my_server( _server ) // konekcija za organizaciju
         info_bar( "login", "server connection ok: " + params[ "user" ] + " / " + iif ( conn_type == 1, params[ "database" ], "postgres" ) + " / verzija aplikacije: " + F18_VER, 1 )
      ENDIF

      RETURN .T.

   ELSE

      IF conn_type == 1
         error_bar( "login", "error server connection: " + _server:ErrorMsg() )
      ENDIF

      RETURN .F.

   ENDIF

   RETURN .T.



FUNCTION f18_login( force_connect, arg_v )

   LOCAL oLogin

   IF force_connect == NIL
      force_connect := .T.
   ENDIF

   _get_server_params_from_config()

   oLogin := F18Login():New()
   oLogin:main_db_login( @s_psqlServer_params, force_connect )

   IF oLogin:lMainDbSpojena


      DO WHILE .T.

         IF !oLogin:login_odabir_organizacije( @s_psqlServer_params )
            QUIT_1
         ENDIF

         write_last_login_params_to_ini_conf() // upisi parametre tekuce firme...

         IF oLogin:lOrganizacijaSpojena

            show_sacekaj()
            program_module_menu( arg_v )

         ENDIF

      ENDDO

   ELSE

      QUIT_1 // neko je rekao ESC
   ENDIF

   RETURN .T.



STATIC FUNCTION f18_form_login( server_params )

   IF server_params == NIL
      server_params := s_psqlServer_params
   ENDIF

   DO WHILE .T.

      IF !_login_screen( @server_params )
         f18_no_login_quit()
         RETURN .F.
      ENDIF

      IF my_server_login( server_params )
         info_bar( "init", "form login succesfull: " + server_params[ "host" ] + " / " + server_params[ "database" ] + " / " + server_params[ "user" ] + " / " + Str( my_server_params()[ "port" ] )  + " / " + server_params[ "schema" ] + " / verzija programa: " + F18_VER )
         EXIT
      ELSE
         Beep( 4 )
      ENDIF

   ENDDO

   RETURN .T.


STATIC FUNCTION _login_screen( server_params )

   LOCAL cHostname, cDatabase, cUser, cPassword, nPort, cSchema, cSession
   LOCAL lSuccess := .T.
   LOCAL nX := 5
   LOCAL nLeft := 7
   LOCAL cConfigureServer := "N"

   cHostName := server_params[ "host" ]
   cDatabase := server_params[ "database" ]
   cUser := server_params[ "user" ]
   cSchema := server_params[ "schema" ]
   nPort := server_params[ "port" ]
   cSession := server_params[ "session" ]
   cPassword := ""

   IF ( cHostName == nil ) .OR. ( nPort == nil )
      cConfigureServer := "D"
   ENDIF

   IF cSession == NIL
      cSession := AllTrim( Str( Year( Date() ) ) )
   ENDIF

   IF cHostName == nil
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
   @ nX, nLeft SAY PadC( "***** Unestite podatke za pristup *****", 60 )

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

   server_params[ "host" ]      := cHostName
   server_params[ "database" ]  := cDatabase
   server_params[ "user" ]      := cUser
   server_params[ "schema" ]    := cSchema
   server_params[ "port" ]      := nPort
   server_params[ "password" ]  := cPassword
   server_params[ "session" ]  := cSession

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

   oLogin:promjena_sezone( @s_psqlServer_params )

   RETURN .T.



// -------------------------------
// init harbour postavke
// -------------------------------
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

   RETURN .T.





#ifdef TEST


FUNCTION _get_server_params_from_config()

   s_psqlServer_params := hb_Hash()
   s_psqlServer_params[ "port" ] := 5432
   s_psqlServer_params[ "database" ] := "f18_test"
   s_psqlServer_params[ "host" ] := "localhost"
   s_psqlServer_params[ "user" ] := "test1"
   s_psqlServer_params[ "schema" ] := F18_PSQL_SCHEMA
   s_psqlServer_params[ "password" ] := s_psqlServer_params[ "user" ]
   s_psqlServer_params[ "postgres" ] := "postgres"

   RETURN .T.

#else

FUNCTION _get_server_params_from_config()

   LOCAL _key, _ini_params

   _ini_params := hb_Hash()
   _ini_params[ "host" ] := nil
   _ini_params[ "database" ] := nil
   _ini_params[ "user" ] := nil
   _ini_params[ "schema" ] := nil
   _ini_params[ "port" ] := nil
   _ini_params[ "session" ] := nil

   IF !f18_ini_config_read( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), @_ini_params, .T. )
      MsgBeep( "problem ini read" )
   ENDIF

   s_psqlServer_params := hb_Hash() // definisi parametre servera

   // preuzmi iz ini-ja
   FOR EACH _key in _ini_params:Keys
      s_psqlServer_params[ _key ] := _ini_params[ _key ]
   NEXT

   // port je numeric
   IF ValType( s_psqlServer_params[ "port" ] ) == "C"
      s_psqlServer_params[ "port" ] := Val( s_psqlServer_params[ "port" ] )
   ENDIF
   s_psqlServer_params[ "password" ] := s_psqlServer_params[ "user" ]
   s_psqlServer_params[ "postgres" ] := "postgres"

   RETURN .T.
#endif

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
