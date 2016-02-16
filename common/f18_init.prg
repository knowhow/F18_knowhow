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

STATIC s_mainThreadID
STATIC s_threadDbfsID


STATIC s_psqlServer := NIL
THREAD STATIC s_psqlServerDbfThread := NIL
STATIC s_psqlServer_params := NIL

// logiranje na server
STATIC s_psqlServer_log := .F.

STATIC __f18_home := NIL
STATIC __f18_home_root := NIL
STATIC __f18_home_backup := NIL

THREAD STATIC __log_handle := NIL

STATIC __test_mode := .F.
STATIC __no_sql_mode := .F.

STATIC __max_rows := 35
STATIC __max_cols := 120

#ifdef  __PLATFORM__WINDOWS
STATIC __font_name := "Lucida Console"
STATIC __font_size := 20
STATIC __font_width := 10
#else

#ifdef  __PLATFORM__LINUX
STATIC __font_name := "terminus"

STATIC __font_size  := 20
STATIC __font_width := 10

#else
STATIC __font_name  := "Monaco"
STATIC __font_size  := 30
STATIC __font_width := 15

#endif

#endif

#ifdef F18_DEBUG
STATIC __log_level := F18_DEFAULT_LOG_LEVEL_DEBUG
#else
STATIC __log_level := F18_DEFAULT_LOG_LEVEL
#endif


FUNCTION f18_init_app( arg_v )

   LOCAL oLogin

   init_harbour()

   PUBLIC gRj         := "N"
   PUBLIC gReadOnly   := .F.
   PUBLIC gSQL        := "N"
   PUBLIC gOModul     := NIL
   PUBLIC cDirPriv    := ""
   PUBLIC cDirRad     := ""
   PUBLIC cDirSif     := ""
   PUBLIC glBrojacPoKontima := .T.

   set_f18_home_root()
   set_global_vars_0()
   PtxtSekvence()

   f18_error_block()

   AltD()
   set_screen_dimensions()

   init_gui()

   IF no_sql_mode()
      set_f18_home( "f18_test" )
      RETURN .T.
   ENDIF

   f18_init_app_login( NIL, arg_v )

   RETURN .T.


FUNCTION f18_error_block()

   ErrorBlock( {| objError, lShowreport, lQuit | GlobalErrorHandler( objError, lShowReport, lQuit ) } )

   RETURN .T.

// -----------------------------------------------------
// inicijalne opcije kod pokretanja firme
// -----------------------------------------------------

FUNCTION f18_init_app_opts()

   // ovdje treba napraviti meni listu sa opcijama
   // vpn, rekonfiguracija, itd... neke administraitvne opcije
   // otvaranje nove firme...
   LOCAL _opt := {}
   LOCAL _optexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, hb_UTF8ToStr( "1. vpn konekcija                         " ) )
   AAdd( _opcexe, {|| NIL } )
   AAdd( _opc, hb_UTF8ToStr( "2. rekonfiguriši server  " ) )
   AAdd( _opcexe, {|| NIL } )
   AAdd( _opc, hb_UTF8ToStr( "3. otvaranje nove firme  " ) )
   AAdd( _opcexe, {|| NIL } )
   // itd...

   f18_menu( "mn", .F., _izbor, _opc, _opcexe  )

   RETURN .T.


// -----------------------------------------------------
// inicijalna login opcija
// -----------------------------------------------------
FUNCTION f18_init_app_login( force_connect, arg_v )

   LOCAL oLogin

   IF force_connect == NIL
      force_connect := .T.
   ENDIF

   _get_server_params_from_config()

   oLogin := F18Login():New()
   oLogin:main_db_login( @s_psqlServer_params, force_connect )
   __main_db_params := s_psqlServer_params

   IF oLogin:_main_db_connected

      // 1 konekcija je na postgres i to je ok
      // ako je vec neka druga...
      IF oLogin:_login_count > 1
         // ostvari opet konekciju na main_db postgres
         oLogin:disconnect()
         oLogin:main_db_login( @s_psqlServer_params, .T. )
      ENDIF

      // upisi parametre za sljedeci put...
      _write_server_params_to_config()

      DO WHILE .T.

         IF !oLogin:company_db_login( @s_psqlServer_params )
            QUIT
         ENDIF

         // upisi parametre tekuce firme... treba li nam ovo ??????
         _write_server_params_to_config()

         IF oLogin:_company_db_connected

            show_sacekaj()
            post_login()
            f18_app_parameters( .T. )
            set_hot_keys()
            get_log_level_from_params()
            module_menu( arg_v )

         ENDIF

      ENDDO

   ELSE

      QUIT // neko je rekao ESC
   ENDIF

   RETURN .T.


STATIC FUNCTION show_sacekaj()

   LOCAL _x, _y
   LOCAL _txt

   _x := ( MAXROWS() / 2 ) - 12
   _y := MAXCOLS()

   CLEAR SCREEN

   _txt := PadC( ". . .  S A Č E K A J T E    T R E N U T A K  . . .", _y )
   @ _x, 2 SAY8 _txt

   _txt := PadC( ". . . . . . k o n e k c i j a    n a    b a z u   u   t o k u . . . . . . .", _y )
   @ _x + 1, 2 SAY8 _txt


   Set( _SET_EVENTMASK, INKEY_ALL )

   RETURN .T.




// prelazak iz sezone u sezonu
FUNCTION f18_old_session()

   LOCAL oLogin := F18Login():New()

   oLogin:company_db_relogin( @s_psqlServer_params )

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

   s_mainThreadID := hb_threadSelf()

   hb_cdpSelect( "SL852" )
   hb_SetTermCP( "SLISO" )

   SET DELETED ON

   SetCancel( .F. )

   Set( _SET_EVENTMASK, INKEY_ALL )
   MSetCursor( .T. )

   RETURN .T.



FUNCTION set_screen_dimensions()

   LOCAL _msg

   LOCAL _pix_width  := hb_gtInfo( HB_GTI_DESKTOPWIDTH )
   LOCAL _pix_height := hb_gtInfo( HB_GTI_DESKTOPHEIGHT )

   _msg := "screen res: " + AllTrim( to_str( _pix_width ) ) + " " + AllTrim( to_str( _pix_height ) ) + " varijanta: "


   IF _pix_width == NIL

      maxrows( 40 - INFO_PANEL_ROWS)
      maxcols( 150 )

      IF SetMode( MaxRow(), MaxCol() )
         log_write( "setovanje ekrana: setovan ekran po rezoluciji" )
      ELSE
         log_write( "setovanje ekrana: ne mogu setovati ekran po trazenoj rezoluciji !" )
         QUIT_1
      ENDIF

      RETURN .T.
   ENDIF

   DO CASE


   CASE _pix_width >= 1440 .AND. _pix_height >= 900

      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_PANEL_ROWS)
      maxcols( 119 )

      log_write( _msg + "1" )

   CASE _pix_width >= 1280 .AND. _pix_height >= 820

#ifdef  __PLATFORM__DARWIN
      // font_name("Ubuntu Mono")
      font_name( "ubuntu mono" )
      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_PANEL_ROWS )
      maxcols( 110 )
      log_write( _msg + "2longMac" )
#else

      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_PANEL_ROWS )
      maxcols( 105 )
      log_write( _msg + "2long" )
#endif


   CASE _pix_width >= 1280 .AND. _pix_height >= 800

      font_size( 22 )
      font_width( 11 )
      maxrows( 35 )
      maxcols( 115 )

      log_write( _msg + "2" )

   CASE  _pix_width >= 1024 .AND. _pix_height >= 768

      font_size( 20 )
      font_width( 10 )
      maxrows( 35 - INFO_PANEL_ROWS )
      maxcols( 100 )

      log_write( _msg + "3" )

   OTHERWISE

      font_size( 16 )
      font_width( 8 )

      maxrows( 35 - INFO_PANEL_ROWS)
      maxcols( 100 )

      log_write( _msg + "4" )

   ENDCASE

   _get_screen_resolution_from_config()

   hb_gtInfo( HB_GTI_FONTNAME, font_name() )

#ifndef __PLATFORM__DARWIN
   hb_gtInfo( HB_GTI_FONTWIDTH, font_width() )
#endif

   hb_gtInfo( HB_GTI_FONTSIZE, font_size() )

   IF SetMode( maxrows(), maxcols() )
      log_write( "setovanje ekrana: setovan ekran po rezoluciji" )
   ELSE
      log_write( "setovanje ekrana: ne mogu setovati ekran po trazenoj rezoluciji !" )
      QUIT_1
   ENDIF

   RETURN .T.

#ifdef TEST


FUNCTION _get_server_params_from_config()

   s_psqlServer_params := hb_Hash()
   s_psqlServer_params[ "port" ] := 5432
   s_psqlServer_params[ "database" ] := "f18_test"
   s_psqlServer_params[ "host" ] := "localhost"
   s_psqlServer_params[ "user" ] := "test1"
   s_psqlServer_params[ "schema" ] := "fmk"
   s_psqlServer_params[ "password" ] := s_psqlServer_params[ "user" ]
   s_psqlServer_params[ "postgres" ] := "postgres"

   RETURN .T.

#else

FUNCTION _get_server_params_from_config()

   LOCAL _key, _ini_params

   // ucitaj parametre iz inija, ako postoje ...
   _ini_params := hb_Hash()
   _ini_params[ "host" ] := nil
   _ini_params[ "database" ] := nil
   _ini_params[ "user" ] := nil
   _ini_params[ "schema" ] := nil
   _ini_params[ "port" ] := nil
   _ini_params[ "session" ] := nil

   IF !f18_ini_read( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), @_ini_params, .T. )
      MsgBeep( "problem ini read" )
   ENDIF

   // definisi parametre servera
   s_psqlServer_params := hb_Hash()

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

FUNCTION _write_server_params_to_config()

   LOCAL _key, _ini_params := hb_Hash()

   FOR EACH _key in { "host", "database", "user", "schema", "port", "session" }
      _ini_params[ _key ] := s_psqlServer_params[ _key ]
   NEXT

   IF !f18_ini_write( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), _ini_params, .T. )
      MsgBeep( "problem ini write" )
   ENDIF

   RETURN .T.


FUNCTION post_login( gVars )

   IF gVars == NIL
      gVars := .T.
   ENDIF

   server_log_enable()

   // ~/.F18/empty38/
   set_f18_home( my_server_params()[ "database" ] )
   log_write( "home baze: " + my_home() )

   hb_gtInfo( HB_GTI_WINTITLE, "[ " + my_server_params()[ "user" ] + " ][ " + my_server_params()[ "database" ] + " ]" )

   thread_dbfs( hb_threadStart( @thread_create_dbfs() ) )

   check_server_db_version()
   server_log_enable()

   set_init_fiscal_params()

   // brisanje loga nakon logiranja...
   f18_log_delete()
   run_on_startup()


   RETURN .T.


FUNCTION thread_dbfs( pThreadID )

   IF pThreadID != nil
      ?E "thread_dbfs id", pThreadID
      s_threadDbfsID := pThreadID
   ENDIF

   RETURN s_threadDbfsID


FUNCTION main_thread()

   RETURN s_mainThreadID

FUNCTION is_in_main_thread()

   RETURN hb_threadSelf() == main_thread()



PROCEDURE thread_create_dbfs()

   LOCAL _ver

   PRIVATE m_x, m_y, normal

   m_x := 0
   m_y := 0
   Normal := "B/W"
   Invert := "W/B"

   ErrorBlock( {| objError, lShowreport, lQuit | GlobalErrorHandler( objError, lShowReport, lQuit ) } )

   _ver := read_dbf_version_from_config()

   my_server()

   set_a_dbfs()
   cre_all_dbfs( _ver )

   kreiraj_pa_napuni_partn_idbr_pdvb ()

   // inicijaliziraj "dbf_key_fields" u __f18_dbf hash matrici
   set_a_dbfs_key_fields()

   write_dbf_version_to_config()

   my_server_close()

   RETURN



// -----------------------------------------------------------
// vraca informaciju o nivou logiranja aplikcije
// -----------------------------------------------------------
STATIC FUNCTION get_log_level_from_params()

#ifdef F18_DEBUG

   log_level( fetch_metric( "log_level", NIL, F18_DEFAULT_LOG_LEVEL_DEBUG ) )
#else
   log_level( fetch_metric( "log_level", NIL, F18_DEFAULT_LOG_LEVEL ) )
#endif

   RETURN .T.


// ------------------------------------------------------------
// vraca informacije iz inija vezane za screen rezoluciju
// ------------------------------------------------------------
STATIC FUNCTION _get_screen_resolution_from_config()

   LOCAL _var_name

   LOCAL _ini_params := hb_Hash()

   _ini_params[ "max_rows" ] := nil
   _ini_params[ "max_cols" ] := nil
   _ini_params[ "font_name" ] := nil
   _ini_params[ "font_width" ] := nil
   _ini_params[ "font_size" ] := nil

   IF !f18_ini_read( F18_SCREEN_INI_SECTION, @_ini_params, .T. )
      MsgBeep( "screen resolution: problem sa ini read" )
      RETURN .F.
   ENDIF

   // setuj varijable iz inija
   IF _ini_params[ "max_rows" ] != nil
      __max_rows := Val( _ini_params[ "max_rows" ] )
   ENDIF

   IF _ini_params[ "max_cols" ] != nil
      __max_cols := Val( _ini_params[ "max_cols" ] )
   ENDIF

   IF _ini_params[ "font_name" ] != nil
      __font_name := _ini_params[ "font_name" ]
   ENDIF

   _var_name := "font_width"
   IF _ini_params[ _var_name ] != nil
      __font_width := Val( _ini_params[ _var_name ] )
   ENDIF

   _var_name := "font_size"
   IF _ini_params[ _var_name ] != nil
      __font_size := Val( _ini_params[ _var_name ] )
   ENDIF

   RETURN .T.

/*
 vraca maksimalni broj redova, kolona
*/

FUNCTION maxrows( x )

   IF ValType( x ) == "N"
      __max_rows := x
   ENDIF

   RETURN __max_rows


FUNCTION maxcols( x )

   IF ValType( x ) == "N"
      __max_cols := x
   ENDIF

   RETURN __max_cols

FUNCTION font_name( x )

   IF ValType( x ) == "C"
      __font_name := x
   ENDIF

   RETURN __font_name

FUNCTION font_width( x )

   IF ValType( x ) == "N"

#ifdef __PLATFORM__DARWIN

      IF  x != 100
         __font_width := x
      ELSE
         __font_width := font_size()
      ENDIF
#else
      __font_width := x
#endif

   ENDIF

   RETURN __font_width


FUNCTION font_size( x )

   IF ValType( x ) == "N"
      __font_size := x
   ENDIF

   RETURN __font_size


FUNCTION log_level( x )

   IF ValType( x ) == "N"
      __log_level := x
   ENDIF

   RETURN __log_level


STATIC FUNCTION f18_form_login( server_params )

   LOCAL _ret
   LOCAL _server

   IF server_params == NIL
      server_params := s_psqlServer_params
   ENDIF

   DO WHILE .T.

      IF !_login_screen( @server_params )
         f18_no_login_quit()
         RETURN .F.
      ENDIF

      IF my_server_login( server_params )
         log_write( "form login succesfull: " + server_params[ "host" ] + " / " + server_params[ "database" ] + " / " + server_params[ "user" ] + " / " + Str( my_server_params()[ "port" ] )  + " / " + server_params[ "schema" ] + " / verzija programa: " + F18_VER )
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
      cSchema := "fmk"
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
   @ nX, nLeft SAY PadL( "LOZINKA:", 15 ) GET cPassword PICT "@S30" COLOR "BG/BG"

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



FUNCTION pg_server( server )

   LOCAL oError

   // LOCAL nI, cMsg, cLogMsg := ""


   IF !is_in_main_thread()

      IF s_psqlServerDbfThread  == NIL

         // LOG_CALL_STACK cLogMsg
         BEGIN SEQUENCE WITH {| err | Break( err ) }

            s_psqlServerDbfThread := TPQServer():New( s_psqlServer_params[ "host" ], ;
               s_psqlServer_params[ "database" ], ;
               s_psqlServer_params[ "user" ], ;
               s_psqlServer_params[ "password" ], ;
               s_psqlServer_params[ "port" ], ;
               s_psqlServer_params[ "schema" ] )

            // ?E "thread psql login OK ", cLogMsg
         RECOVER USING oError

            ?E "thread psql login error:", oError:description
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


FUNCTION my_server_close()

   my_server():close()
   IF !is_in_main_thread()
      s_psqlServerDbfThread := NIL
   ENDIF

   RETURN .T.

/*
 set_get server_params
*/

FUNCTION my_server_params( params )

   LOCAL  _key

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
            log_write( "error server params key: " + _key )
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

   IF !( _server:NetErr() .AND. !Empty( _server:ErrorMsg() ) )

      my_server( _server )

      IF conn_type == 1
         set_sql_search_path()
         log_write( "server connection ok: " + params[ "user" ] + " / " + if ( conn_type == 1, params[ "database" ], "postgres" ) + " / verzija aplikacije: " + F18_VER, 1 )
      ENDIF

      RETURN .T.

   ELSE

      IF conn_type == 1
         log_write( "error server connection: " + _server:ErrorMsg() )
      ENDIF

      RETURN .F.

   ENDIF

   RETURN .T.


FUNCTION my_server_logout()

   IF ValType( s_psqlServer ) == "O"
      s_psqlServer:Close()
   ENDIF

   RETURN s_psqlServer


FUNCTION my_server_search_path( path )

   LOCAL _key := "search_path"

   IF path == nil
      IF !hb_HHasKey( s_psqlServer_params, _key )
         s_psqlServer_params[ _key ] := "fmk, public, u2"
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



FUNCTION my_home( home )

   IF home != NIL
      __f18_home := home
   ENDIF

   RETURN __f18_home



FUNCTION _path_quote( path )

   IF ( At( path, " " ) != 0 ) .AND. ( At( PATH, '"' ) == 0 )
      RETURN  '"' + path + '"'
   ENDIF

   RETURN PATH



FUNCTION my_home_root( home_root )

   IF home_root != NIL
      __f18_home_root := home_root
   ENDIF

   RETURN __f18_home_root


FUNCTION set_f18_home_root()

   LOCAL home

#ifdef __PLATFORM__WINDOWS

   home := hb_DirSepAdd( GetEnv( "USERPROFILE" ) )
#else
   home := hb_DirSepAdd( GetEnv( "HOME" ) )
#endif

   home := hb_DirSepAdd( home + ".f18" )

   f18_create_dir( home )

   my_home_root( home )

   RETURN .T.


FUNCTION my_home_backup( home_backup )

   IF home_backup != NIL
      __f18_home_backup := home_backup
   ENDIF

   RETURN __f18_home_backup




FUNCTION set_f18_home_backup( database )

   LOCAL _home := hb_DirSepAdd( my_home_root() + "backup" )

   f18_create_dir( _home )

   IF database <> NIL
      _home := hb_DirSepAdd( _home + database )
      f18_create_dir( _home )
   ENDIF

   my_home_backup( _home )

   RETURN .T.




// ---------------------------
// ~/.F18/bringout1
// ~/.F18/rg1
// ~/.F18/test
// ---------------------------
FUNCTION set_f18_home( database )

   LOCAL _home

   IF database <> nil
      _home := hb_DirSepAdd( my_home_root() + database )
      f18_create_dir( _home )
   ENDIF

   my_home( _home )

   RETURN .T.



FUNCTION dummy_error_handler()
   RETURN {| err| Break( err ) }


FUNCTION test_mode( tm )

   IF tm != nil
      __test_mode := tm
   ENDIF

   RETURN __test_mode


FUNCTION no_sql_mode( val )

   IF val != nil
      __no_sql_mode := val
   ENDIF

   RETURN __no_sql_mode



STATIC FUNCTION f18_no_login_quit()

   log_write( "direct login: " + ;
      my_server_params()[ "host" ] + " / " + ;
      my_server_params()[ "database" ] + " / " + ;
      my_server_params()[ "user" ] + " / " +  ;
      Str( my_server_params()[ "port" ] )  + " / " + ;
      my_server_params()[ "schema" ] )

   MsgBeep( "Neuspješna prijava na server." )

   log_close()

   QUIT_1

   RETURN .T.


FUNCTION relogin()

   LOCAL oBackup := F18Backup():New()
   LOCAL _ret := .F.

   IF oBackup:locked()
      MsgBeep( oBackup:backup_in_progress_info() )
      RETURN _ret
   ENDIF

   server_log_disable()
   my_server_logout()

   _get_server_params_from_config()

   IF f18_form_login()
      post_login()
   ENDIF

   _write_server_params_to_config()
   _ret := .T.

   RETURN _ret



FUNCTION log_write( msg, level, silent )

   LOCAL _msg_time

   IF level == NIL
      // uzmi defaultni
      level := log_level()
   ENDIF

   IF silent == NIL
      silent := .F.
   ENDIF

   // treba li logirati ?
   IF level > log_level()
      RETURN .T.
   ENDIF

   _msg_time := DToC( Date() )
   _msg_time += ", "
   _msg_time += PadR( Time(), 8 )
   _msg_time += ": "

   // time ide samo u fajl, ne na server
   // ovdje ima neki problem #30139 iskljucujem dok ne skontamo
   // baca mi ove poruke u outf.txt
   // FWRITE( __log_handle, _msg_time + msg + hb_eol() )

   IF server_log()
      server_log_write( msg, silent )
   ENDIF

   ?E _msg_time, msg

   RETURN .T.


FUNCTION server_log()
   RETURN s_psqlServer_log


FUNCTION server_log_disable()

   s_psqlServer_log := .F.

   RETURN .T.

FUNCTION server_log_enable()

   s_psqlServer_log := .T.

   RETURN .T.



FUNCTION log_create()

   IF ( __log_handle := FCreate( F18_LOG_FILE ) ) == -1
      Alert( "Cannot create log file: " + F18_LOG_FILE )

      QUIT_1
   ENDIF

   RETURN


FUNCTION log_close()

   FClose( __log_handle )

   RETURN .T.



FUNCTION log_handle( handle )

   IF handle != NIL
      __log_handle := handle
   ENDIF

   RETURN __log_handle


FUNCTION view_log()

   LOCAL _cmd

   _out_file := my_home() + "F18.log.txt"

   FileCopy( F18_LOG_FILE, _out_file )
   _cmd := "f18_editor " + _out_file
   f18_run( _cmd )

   RETURN .T.


FUNCTION set_hot_keys()

   SetKey( K_SH_F1, {|| Calc() } )
   SetKey( K_SH_F6, {|| f18_old_session() } )

   RETURN .T.

// ---------------------------------------------
// pokreni odredjenu funkciju odmah na pocetku
// ---------------------------------------------
FUNCTION run_on_startup()

   LOCAL _ini, _fakt_doks

   _ini := hb_Hash()
   _ini[ "run" ] := ""

   f18_ini_read( "run" + iif( test_mode(), "_test", "" ), @_ini, .F. )

   SWITCH ( _ini[ "run" ] )
   CASE "fakt_pretvori_otpremnice_u_racun"
      _fakt_doks := FaktDokumenti():New()
      _fakt_doks:pretvori_otpremnice_u_racun()

   END

   RETURN .T.
