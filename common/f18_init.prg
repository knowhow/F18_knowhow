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


THREAD STATIC s_lAlreadyRunStartup := .F. // startup funkcija vec pokrenuta

STATIC s_psqlServer_log := .F. // logiranje na server

STATIC s_cF18HomeRoot := NIL // za sve threadove identican cHomeRootDir
STATIC s_cF18HomeBackup := NIL // svi threadovi ista backup lokacija

STATIC s_cF18CurrentDirectory := NIL

THREAD STATIC s_cF18Home := NIL // svaki thread ima svoj my home ovisno o tekucoj bazi

STATIC s_cRunOnStartParam


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
STATIC s_cFontName  := "Courier"
STATIC s_nFontSize  := 20
STATIC s_nFontWidth := 10

#endif

#endif

#ifdef F18_DEBUG
STATIC __log_level := F18_DEFAULT_LOG_LEVEL_DEBUG
#else
STATIC __log_level := F18_DEFAULT_LOG_LEVEL
#endif




FUNCTION f18_error_block()

   ErrorBlock( {| objError, lShowreport, lQuit | GlobalErrorHandler( objError, lShowReport, lQuit ) } )

   RETURN .T.


FUNCTION f18_init_app_opts()

   LOCAL _opt := {}
   LOCAL _optexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, hb_UTF8ToStr( "1. vpn konekcija                         " ) )
   AAdd( _opcexe, {|| NIL } )
   AAdd( _opc, hb_UTF8ToStr( "2. rekonfiguriši server  " ) )
   AAdd( _opcexe, {|| NIL } )
   AAdd( _opc, hb_UTF8ToStr( "3. otvaranje nove firme  " ) )
   AAdd( _opcexe, {|| NIL } )


   f18_menu( "mn", .F., _izbor, _opc, _opcexe  )

   RETURN .T.



FUNCTION post_login()

   LOCAL cDatabase := my_database()

   init_parameters_cache()
   set_sql_search_path()
   server_log_enable()

   // ~/.F18/empty38/
   set_f18_home( cDatabase )
   info_bar( "init", "home baze: " + my_home() )
   hb_gtInfo( HB_GTI_WINTITLE, "[ " + my_server_params()[ "user" ] + " ][ " + cDatabase + " ]" )
   set_a_dbfs()
   set_global_vars_1()
   set_global_screen_vars( .F. )
   set_global_vars_2()
   IF !parametri_organizacije( .F. )
      MsgBeep( "post_login error - parametri organizacije !" )
      RETURN .F.
   ENDIF
   set_vars_za_specificne_slucajeve()

   thread_dbfs( hb_threadStart( @thread_create_dbfs() ) )
   // thread_dbfs( hb_threadStart( @f18_http_server() ) )

   thread_dbfs( hb_threadStart( @thread_f18_backup(), 1 ) ) // auto backup jedne organizacije

   IF !check_server_db_version()
      RETURN .F.
   ENDIF

   server_log_enable()
   set_init_fiscal_params()

   run_on_start()

   IF !set_parametre_f18_aplikacije( .T. )
      RETURN .F.
   ENDIF
   set_hot_keys()

   get_log_level_from_params()
   crtaj_naslovni_ekran()

   RETURN .T.


PROCEDURE post_login_cleanup()

   LOCAL cFiles
/*
   LOCAL aFileList, cLoc, aFile, cExt


   FOR EACH cExt IN { "txt", "pdf" }
      cLoc := my_home() + "F18_rpt_*." + cExt
      aFileList := hb_vfDirectory( cLoc )
      FOR EACH aFile IN aFileList
         FErase( my_home() + aFile[ 1 ] )
      NEXT

   NEXT
*/

   FOR EACH cFiles in { "F18_rpt_*.txt", "F18_rpt_*.pdf", "r_export_*.xlsx", "out_*.odt" }
      brisi_stare_fajlove( my_home(), cFiles, 1 )
   NEXT

   RETURN


FUNCTION thread_dbfs( pThreadID )

   IF pThreadID != nil
#ifdef F18_DEBUG_DEBUG
      ?E "thread_dbfs id", pThreadID
#endif
   ENDIF

   RETURN .T.




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
      ENDIF

      RETURN .T.
   ENDIF


   DO CASE

   CASE _pix_width >= 1440 .AND. _pix_height >= 900

#ifdef  __PLATFORM__DARWIN
      font_name( "Courier" )
      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 119 )
#else
      font_size( 24 )
      font_width( 12 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 119 )
#endif
      ?E _msg + "1"

   CASE _pix_width >= 1280 .AND. _pix_height >= 820

#ifdef  __PLATFORM__DARWIN

      font_size( 20 )
      font_width( 12 )
      maxrows( 33 - INFO_BAR_ROWS )
      maxcols( 110 )
      ?E _msg + "2longMac"
#else

      font_size( 24 )
      font_width( 12 )
      maxrows( 33 - INFO_BAR_ROWS )
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

      font_size( 22 )
      font_width( 11 )
      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 100 )

      ?E _msg + "3"

   OTHERWISE

      font_size( 22 )
      font_width( 11 )

      maxrows( 35 - INFO_BAR_ROWS )
      maxcols( 100 )

      ?E "init",  _msg + "4"

   ENDCASE



   get_screen_resolution_from_config()

   ?E " set font_name: ", hb_gtInfo( HB_GTI_FONTNAME, font_name() )

#if defined( __PLATFORM__LINUX ) .OR. defined( __PLATFORM__DARWIN )
   ?E " set font_weight: ", hb_gtInfo( HB_GTI_FONTWEIGHT, HB_GTI_FONTW_BOLD )
#endif

   // #if  defined( __PLATFORM__WINDOWS ) .OR. defined( __PLATFORM__LINUX )
   ?E " set font_width: ", hb_gtInfo( HB_GTI_FONTWIDTH, font_width() )
   // #endif
   ?E " set font_size: ", hb_gtInfo( HB_GTI_FONTSIZE, font_size() )



   // Alert( hb_ValToStr( hb_gtInfo( HB_GTI_DESKTOPROWS ) ) + " / " + hb_ValToStr( hb_gtInfo( HB_GTI_DESKTOPCOLS ) ) )
   // hb_gtInfo( HB_GTI_ISFULLSCREEN, .T. )

   // hb_gtInfo( HB_GTI_RESIZEMODE, HB_GTI_RESIZEMODE_ROWS )


   IF SetMode( maxrows( hb_gtInfo( HB_GTI_DESKTOPROWS ) - 2 - INFO_BAR_ROWS ) + INFO_BAR_ROWS,  ;
         maxcols( hb_gtInfo( HB_GTI_DESKTOPCOLS ) - 5 ) )

      // IF SetMode( maxrows() + INFO_BAR_ROWS,  maxcols() )
      ?E "setovanje ekrana: setovan ekran po rezoluciji", maxrows(), maxcols()
   ELSE
      // linux nece od prve!?
      SetMode( maxrows( hb_gtInfo( HB_GTI_DESKTOPROWS ) - 2 - INFO_BAR_ROWS ) + INFO_BAR_ROWS,  ;
         maxcols( hb_gtInfo( HB_GTI_DESKTOPCOLS ) - 5 ) )
      ?E " set font_width/2: ", hb_gtInfo( HB_GTI_FONTWIDTH, font_width() )
      ?E "setovanje ekrana/2 "
   ENDIF


   ?E " get font_name: ", hb_gtInfo( HB_GTI_FONTNAME )
   ?E " get font_size: ", hb_gtInfo( HB_GTI_FONTSIZE )
   ?E " get font_width: ", hb_gtInfo( HB_GTI_FONTWIDTH )
   ?E " get font_weight: ", hb_gtInfo( HB_GTI_FONTWEIGHT )

   // hb_gtInfo( HB_GTI_ALTENTER, .T. )

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

   IF ValType( x ) == "N"
      __max_rows := x
   ENDIF

   RETURN  Max( hb_gtInfo( HB_GTI_VIEWMAXHEIGHT ) - INFO_BAR_ROWS, __max_rows )



FUNCTION maxcols( x )

   IF ValType( x ) == "N"
      __max_cols := x
   ENDIF

   RETURN Max( hb_gtInfo( HB_GTI_VIEWMAXWIDTH ), __max_cols )



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




FUNCTION my_home( cHome )

   IF cHome != NIL
      s_cF18Home := cHome
   ENDIF

   RETURN s_cF18Home



FUNCTION file_path_quote( cPath )

   // f18_run / run_invisible.vbs podesava shortpath, quotes sada smetaju
   IF ( At( " ", cPath ) != 0 ) .AND. ( At( '"', cPath ) == 0 )
      RETURN  '"' + cPath + '"'
   ENDIF

   RETURN cPath



FUNCTION my_home_root( cHomeRootDir )

   IF cHomeRootDir != NIL
      s_cF18HomeRoot := cHomeRootDir
   ENDIF

   IF HB_ISNIL( s_cF18HomeRoot )
      set_f18_home_root()
   ENDIF

   RETURN s_cF18HomeRoot


FUNCTION set_f18_current_directory()

   s_cF18CurrentDirectory := iif( is_windows(), hb_CurDrive() + ":" + SLASH, "/" ) + CurDir()

   ?E "current directory:", s_cF18CurrentDirectory

   RETURN s_cF18CurrentDirectory


FUNCTION f18_current_directory()

   RETURN s_cF18CurrentDirectory


FUNCTION set_f18_home_root()

   LOCAL cHome

#ifdef __PLATFORM__WINDOWS

   cHome := hb_DirSepAdd( GetEnv( "USERPROFILE" ) )
#else
   cHome := hb_DirSepAdd( GetEnv( "HOME" ) )
#endif

   cHome := hb_DirSepAdd( cHome + ".f18" )

   f18_create_dir( cHome )

   my_home_root( cHome )

   RETURN .T.


FUNCTION my_home_backup( cF18HomeBackup )

   IF cF18HomeBackup != NIL
      s_cF18HomeBackup := cF18HomeBackup
   ENDIF

   RETURN s_cF18HomeBackup




FUNCTION set_f18_home_backup( cDatabase )

   LOCAL cHomeDir := hb_DirSepAdd( my_home_root() + "backup" )

   f18_create_dir( cHomeDir )

   IF cDatabase <> NIL
      cHomeDir := hb_DirSepAdd( cHomeDir + cDatabase )
      f18_create_dir( cHomeDir )
   ENDIF

   my_home_backup( cHomeDir )

   RETURN .T.




// ---------------------------
// ~/.F18/bringout1
// ~/.F18/rg1
// ~/.F18/test
// ---------------------------
FUNCTION set_f18_home( cDatabase )

   LOCAL cHomeDir

   IF cDatabase <> NIL
      cHomeDir := hb_DirSepAdd( my_home_root() + cDatabase )
      f18_create_dir( cHomeDir )
   ENDIF

   my_home( cHomeDir )

   RETURN .T.



FUNCTION dummy_error_handler()
   RETURN {| err | Break( err ) }


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





FUNCTION log_write( cMsg, nLevel, lSilent )

   LOCAL _msg_time

   IF nLevel == NIL
      // uzmi defaultni
      nLevel := log_level()
   ENDIF

   IF lSilent == NIL
      lSilent := .F.
   ENDIF

   // treba li logirati ?
   IF nLevel > log_level()
      RETURN .T.
   ENDIF

   _msg_time := DToC( Date() )
   _msg_time += ", "
   _msg_time += PadR( Time(), 8 )
   _msg_time += ": "

   // time ide samo u fajl, ne na server
   // ovdje ima neki problem #30139 iskljucujem dok ne skontamo
   // baca mi ove poruke u outf.txt
   // FWRITE( __log_handle, _msg_time + cMsg + hb_eol() )

   IF server_log()
      server_log_write( cMsg, lSilent )
   ENDIF

   ?E _msg_time, cMsg

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
      error_bar( "log", "Cannot create log file: " + F18_LOG_FILE )
      RETURN .F.
   ENDIF

   RETURN .T.


FUNCTION log_close()

   FClose( __log_handle )

   RETURN .T.



FUNCTION log_handle( handle )

   IF handle != NIL
      __log_handle := handle
   ENDIF

   RETURN __log_handle



FUNCTION set_hot_keys()

   info_bar( "init", "setting up hot keys" )
   SetKey( K_SH_F1, {|| f18_kalkulator() } )
   SetKey( K_SH_F6, {|| f18_promjena_sezone() } )
   info_bar( "init", "setting up hot keys - end" )

   RETURN .T.



FUNCTION run_on_start_param( cParam )

   IF cParam != NIL
      s_cRunOnStartParam := cParam
   ENDIF

   RETURN s_cRunOnStartParam


FUNCTION run_on_start()

   LOCAL _ini, _fakt_doks, cRun, oModul
   LOCAL cModul

   IF s_lAlreadyRunStartup
      RETURN .F.
   ENDIF

   s_lAlreadyRunStartup := .T.

   // _ini := hb_Hash()
   // _ini[ "run" ] := ""
   // _ini[ "modul" ] := "FIN"

   IF run_on_start_param() == NIL
      RETURN .F.
   ENDIF
   // f18_ini_config_read( "startup" + iif( test_mode(), "_test", "" ), @_ini, .F. )

   // cRun := _ini[ "run" ]
   cRun := run_on_start_param()

   IF Empty( cRun )
      RETURN .F.
   ENDIF

   info_bar( "init", "run_on_start" )

   IF Left( cRun, 5 ) == "kalk_"
      cModul := "KALK"
   ELSEIF Left( cRun, 5 ) == "fakt_"
      cModul := "FAKT"
   ELSEIF Left( cRun, 4 ) == "fin_"
      cModul := "FIN"
   ENDIF

   SWITCH cModul
   CASE "FIN"
      oModul := TFinMod():new( NIL, "FIN", f18_ver(), f18_ver_date(), my_user(), "dummy" )
      EXIT
   CASE "KALK"
      oModul := TKalkMod():new( NIL, "KALK", f18_ver(), f18_ver_date(), my_user(), "dummy" )
      EXIT
   CASE "FAKT"
      oModul := TFaktMod():new( NIL, "FAKT", f18_ver(), f18_ver_date(), my_user(), "dummy" )
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
