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

STATIC s_psqlServer := NIL
THREAD STATIC s_psqlServerDbfThread := NIL // svaka thread konekcija zasebna
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
STATIC s_cFontName := "Lucida Console"
STATIC s_nFontSize := 20
STATIC s_nFontWidth := 10
#else

#ifdef  __PLATFORM__LINUX
STATIC s_cFontName := "terminus"

STATIC s_nFontSize  := 20
STATIC s_nFontWidth := 10

#else
STATIC s_cFontName  := "Monaco"
STATIC s_nFontSize  := 30
STATIC s_nFontWidth := 15

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
   init_parameters_cache()

   set_f18_home_root()
   set_global_vars_0()
   f18_error_block()
   set_screen_dimensions()


   IF no_sql_mode()
      set_f18_home( "f18_test" )
      RETURN .T.
   ENDIF

   f18_login( NIL, arg_v )

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
FUNCTION f18_login( force_connect, arg_v )

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


      _write_server_params_to_config() // upisi parametre za sljedeci put...

      DO WHILE .T.

         IF !oLogin:company_db_login( @s_psqlServer_params )
            QUIT
         ENDIF

         _write_server_params_to_config() // upisi parametre tekuce firme...

         IF oLogin:_company_db_connected

            show_sacekaj()
            post_login()
            program_module_menu( arg_v )

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

   naslovni_ekran_splash_screen( "F18", F18_VER )

   RETURN .T.




// prelazak iz sezone u sezonu
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

   s_mainThreadID := hb_threadSelf()

   hb_cdpSelect( "SL852" )
   hb_SetTermCP( "SLISO" )

   SET DELETED ON

   SetCancel( .F. )

   Set( _SET_EVENTMASK, INKEY_ALL )
   MSetCursor( .T. )

   // SET MESSAGE TO 24 CENTER
   SET DATE GERMAN
   SET SCOREBOARD OFF
   SET CONFIRM ON
   SET WRAP ON
   SET ESCAPE ON
   SET SOFTSEEK ON

   RETURN .T.



FUNCTION set_screen_dimensions()

   LOCAL _msg

   LOCAL _pix_width  := hb_gtInfo( HB_GTI_DESKTOPWIDTH )
   LOCAL _pix_height := hb_gtInfo( HB_GTI_DESKTOPHEIGHT )

   _msg := "screen res: " + AllTrim( to_str( _pix_width ) ) + " " + AllTrim( to_str( _pix_height ) ) + " varijanta: "


   IF _pix_width == NIL

      maxrows( 40 - INFO_BAR_ROWS )
      maxcols( 150 )

      IF SetMode( maxrows() + INFO_BAR_ROWS,  maxcols() )
         ?E "setovanje ekrana: setovan ekran po rezoluciji"
      ELSE
         ?E "setovanje ekrana: ne mogu setovati ekran po trazenoj rezoluciji !"
         QUIT_1
      ENDIF

      RETURN .T.
   ENDIF

   DO CASE


   CASE _pix_width >= 1440 .AND. _pix_height >= 900

      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 119 )

      ?E _msg + "1"

   CASE _pix_width >= 1280 .AND. _pix_height >= 820

#ifdef  __PLATFORM__DARWIN

      font_name( "Ubuntu Mono" )
      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 110 )
      ?E _msg + "2longMac"
#else

      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 105 )
      ?E _msg + "2long"
#endif


   CASE _pix_width >= 1280 .AND. _pix_height >= 800

      font_size( 22 )
      font_width( 11 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 115 )
      ?E _msg + "2"

   CASE  _pix_width >= 1024 .AND. _pix_height >= 768

      font_size( 20 )
      font_width( 10 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 100 )

      ?E _msg + "3"

   OTHERWISE

      font_size( 16 )
      font_width( 8 )

      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 100 )

      ?E "init",  _msg + "4"

   ENDCASE


   get_screen_resolution_from_config()

   ?E " set font_name: ", hb_gtInfo( HB_GTI_FONTNAME, font_name() )
   ?E " set font_size: ", hb_gtInfo( HB_GTI_FONTSIZE, font_size() )
   ?E " set font_width: ", hb_gtInfo( HB_GTI_FONTWIDTH, font_width() )
   ?E " set font_weight: ", hb_gtInfo( HB_GTI_FONTWEIGHT, HB_GTI_FONTW_BOLD )

   ?E " get font_name: ", hb_gtInfo( HB_GTI_FONTNAME )
   ?E " get font_size: ", hb_gtInfo( HB_GTI_FONTSIZE )
   ?E " get font_width: ", hb_gtInfo( HB_GTI_FONTWIDTH )
   ?E " get font_weight: ", hb_gtInfo( HB_GTI_FONTWEIGHT )

   // Alert( hb_ValToStr( hb_gtInfo( HB_GTI_DESKTOPROWS ) ) + " / " + hb_ValToStr( hb_gtInfo( HB_GTI_DESKTOPCOLS ) ) )
   //hb_gtInfo( HB_GTI_ISFULLSCREEN, .T. )
   hb_gtInfo( HB_GTI_ALTENTER, .T. )


   IF SetMode( maxrows() + INFO_BAR_ROWS,  maxcols() )
      ?E "setovanje ekrana: setovan ekran po rezoluciji"
   ELSE

      // pGt := hb_gtCreate( f18_gt() )
      // hb_gtSelect( pGt )

      ?E "setovanje ekrana: ne mogu setovati ekran po trazenoj rezoluciji !"
      RETURN .F.
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

   IF !f18_ini_config_write( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), _ini_params, .T. )
      MsgBeep( "problem ini write" )
   ENDIF

   RETURN .T.


FUNCTION post_login( gVars )

   IF gVars == NIL
      gVars := .T.
   ENDIF

   init_parameters_cache()

   set_global_vars_0()
   set_global_screen_vars( .F. )
   set_global_vars_2()
   parametri_organizacije( .F. )
   set_vars_za_specificne_slucajeve()

   server_log_enable()

   // ~/.F18/empty38/
   set_f18_home( my_server_params()[ "database" ] )
   info_bar( "init", "home baze: " + my_home() )

   hb_gtInfo( HB_GTI_WINTITLE, "[ " + my_server_params()[ "user" ] + " ][ " + my_server_params()[ "database" ] + " ]" )

   thread_dbfs( hb_threadStart( @thread_create_dbfs() ) )
   info_bar( "init", "thread_create_dbfs - end" )

   check_server_db_version()
   server_log_enable()

   set_init_fiscal_params()

   run_on_startup()

   set_parametre_f18_aplikacije( .T. )
   set_hot_keys()

   say_database_info()
   get_log_level_from_params()

   RETURN .T.


FUNCTION thread_dbfs( pThreadID )

   IF pThreadID != nil
#ifdef F18_DEBUG
      ?E "thread_dbfs id", pThreadID
#endif
   ENDIF

   RETURN .T.


FUNCTION main_thread()

   RETURN s_mainThreadID


FUNCTION is_in_main_thread()

   RETURN hb_threadSelf() == main_thread()



PROCEDURE thread_create_dbfs()

   LOCAL _ver

   init_parameters_cache()

   ErrorBlock( {| objError, lShowreport, lQuit | GlobalErrorHandler( objError, lShowReport, lQuit ) } )

   _ver := read_dbf_version_from_config()

   my_server()
   set_a_dbfs()
   cre_all_dbfs( _ver )

   kreiraj_pa_napuni_partn_idbr_pdvb ()

   set_a_dbfs_key_fields() // inicijaliziraj "dbf_key_fields" u __f18_dbf hash matrici
   write_dbf_version_to_ini_conf()

   f18_log_delete() // brisanje loga nakon logiranja...

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




STATIC FUNCTION get_screen_resolution_from_config()

   LOCAL _var_name

   LOCAL _ini_params := hb_Hash()

   _ini_params[ "max_rows" ] := nil
   _ini_params[ "max_cols" ] := nil
   _ini_params[ "font_name" ] := nil
   _ini_params[ "font_width" ] := nil
   _ini_params[ "font_size" ] := nil

   IF !f18_ini_config_read( F18_SCREEN_INI_SECTION, @_ini_params, .T. )
      ?E "screen resolution: problem sa ini read"
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
      s_cFontName := _ini_params[ "font_name" ]
   ENDIF

   _var_name := "font_width"
   IF _ini_params[ _var_name ] != nil
      s_nFontWidth := Val( _ini_params[ _var_name ] )
   ENDIF

   _var_name := "font_size"
   IF _ini_params[ _var_name ] != nil
      s_nFontSize := Val( _ini_params[ _var_name ] )
   ENDIF

   RETURN .T.

/*
 vraca maksimalni broj redova, kolona
*/

FUNCTION maxrows( x )

/*
   IF ValType( x ) == "N"
      __max_rows := x
   ENDIF
   RETURN __max_rows

*/
   RETURN  hb_gtInfo( HB_GTI_DESKTOPROWS ) - INFO_BAR_ROWS



FUNCTION maxcols( x )

  /*
   IF ValType( x ) == "N"
      __max_cols := x
   ENDIF
      RETURN __max_cols
  */

   RETURN hb_gtInfo( HB_GTI_DESKTOPCOLS )




FUNCTION font_name( x )

   IF ValType( x ) == "C"
      s_cFontName := x
   ENDIF
   ?E " s_font_name:", s_cFontName

   RETURN s_cFontName

FUNCTION font_width( x )

   IF ValType( x ) == "N"
      s_nFontWidth := x
   ENDIF

   ?E " s_font_width:", s_nFontWidth

   RETURN s_nFontWidth


FUNCTION font_size( x )

   IF ValType( x ) == "N"
      s_nFontSize := x
   ENDIF

   ?E " s_font_size:", s_nFontSize

   RETURN s_nFontSize


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
   LOCAL nI, cMsg, cLogMsg := ""

   IF !is_in_main_thread()

      IF s_psqlServerDbfThread  == NIL

         BEGIN SEQUENCE WITH {| err | Break( err ) }

            s_psqlServerDbfThread := TPQServer():New( s_psqlServer_params[ "host" ], ;
               s_psqlServer_params[ "database" ], ;
               s_psqlServer_params[ "user" ], ;
               s_psqlServer_params[ "password" ], ;
               s_psqlServer_params[ "port" ], ;
               s_psqlServer_params[ "schema" ] )

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

   IF !( _server:NetErr() .AND. !Empty( _server:ErrorMsg() ) )

      my_server( _server )

      IF conn_type == 1
         set_sql_search_path()
         info_bar( "login", "server connection ok: " + params[ "user" ] + " / " + if ( conn_type == 1, params[ "database" ], "postgres" ) + " / verzija aplikacije: " + F18_VER, 1 )
      ENDIF

      RETURN .T.

   ELSE

      IF conn_type == 1
         error_bar( "login", "error server connection: " + _server:ErrorMsg() )
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

   info_bar( "init", "setting up hot keys" )
   SetKey( K_SH_F1, {|| Calc() } )
   SetKey( K_SH_F6, {|| f18_promjena_sezone() } )
   info_bar( "init", "setting up hot keys - end" )

   RETURN .T.


FUNCTION run_on_startup()

   LOCAL _ini, _fakt_doks, cRun, oModul

   info_bar( "init", "run_on_start" )

   _ini := hb_Hash()
   _ini[ "run" ] := ""
   _ini[ "modul" ] := "FIN"

   f18_ini_config_read( "startup" + iif( test_mode(), "_test", "" ), @_ini, .F. )

   cRun := _ini[ "run" ]

   SWITCH _ini[ "modul" ]
   CASE "FIN"
      oModul := TFinMod():new( NIL, "FIN", F18_VER, F18_VER_DATE, my_user(), "dummy" )
      EXIT
   CASE "KALK"
      oModul := TKalkMod():new( NIL, "KALK", F18_VER, F18_VER_DATE, my_user(), "dummy" )
      EXIT
   CASE "FAKT"
      oModul := TFaktMod():new( NIL, "FAKT", F18_VER, F18_VER_DATE, my_user(), "dummy" )
      EXIT

   ENDSWITCH

   goModul := oModul
   gModul := oModul:cName

   SWITCH ( cRun )
   CASE "fakt_pretvori_otpremnice_u_racun"
      _fakt_doks := FaktDokumenti():New()
      _fakt_doks:pretvori_otpremnice_u_racun()

   OTHERWISE
      IF !Empty( cRun )
         &cRun
      ENDIF
   END

   info_bar( "init", "run_on_start_end" )

   RETURN .T.
