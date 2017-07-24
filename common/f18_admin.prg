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


CLASS F18Admin

   VAR update_app_f18
   VAR cUpdateF18Version
   VAR update_app_templates
   VAR update_app_templates_version
   VAR update_app_info_file
   VAR update_app_script_file

   METHOD new()

   METHOD update_db()
   DATA update_db_result

   METHOD create_new_pg_db()
   METHOD drop_pg_db()
   METHOD delete_db_data_all()

   METHOD razdvajanje_sezona()

   METHOD relogin_as()
   METHOD relogin_as_admin()

   METHOD update_app()

   METHOD get_os_name()

   METHOD wget_download()

   DATA create_db_result

   PROTECTED:

   METHOD update_db_download()
   METHOD update_db_all()
   METHOD update_db_company()
   METHOD update_db_command()
   METHOD create_new_pg_db_params()

   METHOD update_app_form()
   METHOD f18_upd_download()
   //METHOD update_app_get_versions()
   METHOD update_app_run_script()
   METHOD update_app_run_app_update()
   //METHOD update_app_run_templates_update()
   METHOD update_app_unzip_templates()

   DATA _new_db_params
   DATA _update_params

ENDCLASS



METHOD F18Admin:New()

   ::update_db_result := {}
   ::create_db_result := {}

   IF ! ::relogin_as_admin( "postgres" )
      MsgBeep( "relogin postgresql as admin neuspjesno " )
      RETURN .F.
   ENDIF

   RETURN self



METHOD F18Admin:update_app()

   LOCAL hF18UpdateParams := hb_Hash()
   //LOCAL _hF18UpdateParams := hb_Hash()
   LOCAL cUpdateFile := ""
   LOCAL lOk := .F.

   //::update_app_info_file := "UPDATE_INFO"
   ::update_app_script_file := "f18_upd.sh"

#ifdef __PLATFORM__WINDOWS
   ::update_app_script_file := "f18_upd.bat"
#endif

   IF !::f18_upd_download()
      MsgBeep( "Problem sa download-om skripti. Provjerite internet koneciju." )
      RETURN SELF
   ENDIF

   //hF18UpdateParams := ::update_app_get_versions()

   hF18UpdateParams[ "f18" ] := f18_available_version()
   hF18UpdateParams[ "url" ] := F18_DOWNLOAD_URL_BASE

   IF hF18UpdateParams == NIL
      RETURN SELF
   ENDIF

   IF !::update_app_form( hF18UpdateParams )
      RETURN SELF
   ENDIF

/*
   IF ::update_app_templates
      ::update_app_run_templates_update( hF18UpdateParams )
   ENDIF
*/

   IF ::update_app_f18
      ::update_app_run_app_update( hF18UpdateParams )
   ENDIF

   s_cDownloadVersion := NIL

   RETURN SELF


/*
METHOD F18Admin:update_app_run_templates_update( params )

   LOCAL cUpdateFile := "F18_template_#VER#.tar.bz2"
   LOCAL _dest := SLASH + "opt" + SLASH + "knowhowERP" + SLASH

#ifdef __PLATFORM__WINDOWS

   _dest := "c:" + SLASH + "knowhowERP" + SLASH
#endif

   IF ::update_app_templates_version == "#LAST#"
      ::update_app_templates_version := params[ "templates" ]
   ENDIF

   cUpdateFile := StrTran( cUpdateFile, "#VER#", ::update_app_templates_version )

   IF !::wget_download( params[ "url" ], cUpdateFile, _dest + cUpdateFile, .T., .T. )
      RETURN SELF
   ENDIF

   ::update_app_unzip_templates( _dest, _dest, cUpdateFile )

   RETURN SELF
*/


METHOD F18Admin:update_app_unzip_templates( destination_path, location_path, cFileName )

   LOCAL cCmd
   LOCAL _args := "-jxf"

   MsgO( "Vršim update template fajlova ..." )

#ifdef __PLATFORM__WINDOWS

   DirChange( destination_path )

   cCmd := "bunzip2 -f " + location_path + cFileName
   hb_run( cCmd )

   cCmd := "tar xvf " + StrTran( cFileName, ".bz2", "" )
   hb_run( cCmd )

#else

   cCmd := "tar -C " + location_path + " " + _args + " " + location_path + cFileName
   hb_run( cCmd )

#endif

   MsgC()

   RETURN SELF



METHOD F18Admin:update_app_run_app_update( hF18Params )

   LOCAL cUpdateFile := "F18_#OS#_#VER#.gz"

   IF ::cUpdateF18Version == "#LAST#"
      ::cUpdateF18Version := hF18Params[ "f18" ]
   ENDIF

#ifdef __PLATFORM__LINUX
   cUpdateFile := StrTran( cUpdateFile, "#OS#", ::get_os_name() + "_i686" )
#else
   cUpdateFile := StrTran( cUpdateFile, "#OS#", ::get_os_name() )
#endif

   cUpdateFile := StrTran( cUpdateFile, "#VER#", ::cUpdateF18Version )

// IF ::cUpdateF18Version == f18_ver()
// MsgBeep( "Verzija aplikacije " + f18_ver() + " je vec instalirana !" )
// RETURN SELF
// ENDIF

   IF !::wget_download( hF18Params[ "url" ], cUpdateFile, my_home_root() + cUpdateFile, .T., .T. )
      RETURN SELF
   ENDIF

   ::update_app_run_script( my_home_root() + cUpdateFile )

   RETURN SELF



METHOD F18Admin:update_app_run_script( update_file )

   LOCAL cUrl := my_home_root() + ::update_app_script_file

#ifdef __PLATFORM__WINDOWS

   cUrl := 'start cmd /C ""' + cUrl
   cUrl += '" "' + update_file + '""'
#else
#ifdef __PLATFORM__LINUX
   cUrl := "bash " + cUrl
#endif
   cUrl += " " + update_file
#endif

#ifdef __PLATFORM__UNIX
   cUrl := cUrl + " &"
#endif

   Msg( "F18 ce se sada zatvoriti#Nakon update procesa ponovo otvorite F18", 4 )

   hb_run( cUrl )

   QUIT_1

   RETURN SELF




METHOD F18Admin:update_app_form( hF18UpdateParams )

   LOCAL lOk := .F.
   LOCAL nVerzijaMajor := 2
   LOCAL nVerzijaMinor := 3
   LOCAL nVerzijaPatch := Space( 10 )
   LOCAL _t_ver_prim := 1
   LOCAL _t_ver_sec := 5
   LOCAL _t_ver_third := Space( 10 )
   LOCAL nX := 1
   LOCAL _col_app, _col_temp, cLine
   LOCAL cUpdateF18, _upd_t, nPos
   LOCAL pRegex := hb_regexComp( "(\d+).(\d+).(\d+)" )
   LOCAL aMatch

   cUpdateF18 := "D"
   _upd_t := "N"
   _col_app := "W/G+"
   _col_temp := "W/G+"

   aMatch := hb_regex( pRegex, hF18UpdateParams[ "f18" ] )

   IF Len( aMatch ) > 0 // aMatch[1]="2.3.500" aMatch[2]="2", aMatch[3]="3", aMatch[4]="500"
      nVerzijaMajor := Val( aMatch[ 2 ] )
      nVerzijaMinor := Val( aMatch[ 3 ] )
      nVerzijaPatch := Val( aMatch[ 4 ] )
   ENDIF

   // IF f18_ver() < hF18UpdateParams[ "f18" ]
   _col_app := "W/R+"
   // ENDIF
   // IF f18_template_ver() < hF18UpdateParams[ "templates" ]
   _col_temp := "W/R+"
   // ENDIF

   Box(, 10, 65 )

   @ m_x + nX, m_y + 2 SAY PadR( "## UPDATE F18 APP ##", 64 ) COLOR f18_color_i()
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY cLine := ( Replicate( "-", 10 ) + " " + Replicate( "-", 20 ) + " " + Replicate( "-", 20 ) )
   ++nX
   @ m_x + nX, m_y + 2 SAY PadR( "[INFO]", 10 ) + "/" + PadC( "Trenutna", 20 ) + "/" + PadC( "Dostupna", 20 )
   ++nX
   @ m_x + nX, m_y + 2 SAY cLine
   ++nX
   @ m_x + nX, m_y + 2 SAY PadR( "F18", 10 ) + " " + PadC( f18_ver(), 20 )
   @ m_x + nX, Col() SAY " "
   @ m_x + nX, Col() SAY PadC( hF18UpdateParams[ "f18" ], 20 ) COLOR _col_app

/*
   ++nX
   @ m_x + nX, m_y + 2 SAY PadR( "template", 10 ) + " " + PadC( f18_template_ver(), 20 )
   @ m_x + nX, Col() SAY " "
   @ m_x + nX, Col() SAY PadC( hF18UpdateParams[ "templates" ], 20 ) COLOR _col_temp
*/

   ++nX

   @ m_x + nX, m_y + 2 SAY cLine

   ++nX
   ++nX
   nPos := nX

   @ m_x + nX, m_y + 2 SAY "       Update F18 ?" GET cUpdateF18 PICT "@!" VALID cUpdateF18 $ "DN"

   READ

   IF cUpdateF18 == "D"
      @ m_x + nX, m_y + 25 SAY "VERZIJA:" GET nVerzijaMajor PICT "999" VALID nVerzijaMajor > 0
      @ m_x + nX, Col() + 1 SAY "." GET nVerzijaMinor PICT "999" VALID nVerzijaMinor >= 0
      @ m_x + nX, Col() + 1 SAY "." GET nVerzijaPatch PICT "9999"
   ENDIF

/*
   ++nX
   ++nX
   nPos := nX

   @ m_x + nX, m_y + 2 SAY "  Update template ?" GET _upd_t PICT "@!" VALID _upd_t $ "DN"
*/

   READ

/*
   IF _upd_t == "D"

      @ m_x + nX, m_y + 25 SAY "VERZIJA:" GET _t_ver_prim PICT "99" VALID _t_ver_prim > 0
      @ m_x + nX, Col() + 1 SAY "." GET _t_ver_sec PICT "99" VALID _t_ver_sec > 0
      @ m_x + nX, Col() + 1 SAY "." GET _t_ver_third PICT "@S10"

      READ

   ENDIF
*/

   BoxC()

   IF LastKey() == K_ESC
      RETURN lOk
   ENDIF

   ::update_app_f18 := ( cUpdateF18 == "D" ) // setuj postavke
   //::update_app_templates := ( _upd_t == "D" )

   IF ::update_app_f18
      IF !Empty( nVerzijaPatch )
         // zadana verzija
         ::cUpdateF18Version := AllTrim( Str( nVerzijaMajor ) ) + ;
            "." + ;
            AllTrim( Str( nVerzijaMinor ) ) + ;
            "." + ;
            AllTrim( Str( nVerzijaPatch ) )
      ELSE
         ::cUpdateF18Version := "#LAST#"
      ENDIF

      lOk := .T.

   ENDIF

/*
   IF ::update_app_templates  // sastavi mi verziju
      IF !Empty( _t_ver_third ) // zadana verzija
         ::update_app_templates_version := AllTrim( Str( _t_ver_prim ) ) + "." +  AllTrim( Str( _t_ver_sec ) ) + "." +  AllTrim( _t_ver_third )
      ELSE
         ::update_app_templates_version := "#LAST#"
      ENDIF
      lOk := .T.
   ENDIF
*/

   RETURN lOk




/*
METHOD F18Admin:update_app_get_versions()

   LOCAL _urls := hb_Hash()
   LOCAL _o_file, cTmp, _a_tmp
   //LOCAL _file := my_home_root() + ::update_app_info_file
   LOCAL _count := 0

   //_o_file := TFileRead():New( _file )
   //_o_file:Open()

   //IF _o_file:Error()
  //    MSGBEEP( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
  //    RETURN SELF
   //ENDIF

   cTmp := ""


   DO WHILE _o_file:MoreToRead() // prodji kroz svaku liniju i procitaj zapise
      cTmp := hb_StrToUTF8( _o_file:ReadLine() )
      _a_tmp := TokToNiz( cTmp, "=" )
      IF Len( _a_tmp ) > 1
         ++_count
         _urls[ AllTrim( Lower( _a_tmp[ 1 ] ) ) ] := AllTrim( _a_tmp[ 2 ] )
      ENDIF
   ENDDO

   _o_file:Close()

   IF _count == 0
      MsgBeep( "Nisam uspio nista procitati iz fajla sa verzijama !" )
      _urls := NIL
   ENDIF

   RETURN _urls

*/

METHOD F18Admin:f18_upd_download()

   LOCAL lOk := .F.
   LOCAL cPath := my_home_root()
   LOCAL cUrl
   LOCAL _script
   LOCAL hF18UpdateParams
   LOCAL _silent := .T.
   LOCAL _always_erase := .T.

/*
   info_bar( "upd", "download " +  ::update_app_info_file )

   MsgO( "preuzimanje podataka o aktuelnoj verziji ..." )
   cUrl := f18_download_url() + "/"
   IF !::wget_download( cUrl, ::update_app_info_file, cPath + ::update_app_info_file, _always_erase, _silent )
      MsgC()
      RETURN .F.
   ENDIF
*/

   info_bar( "upd", "download " +  ::update_app_script_file )
   cUrl := f18_download_url() + "/scripts/"
   IF !::wget_download( cUrl, ::update_app_script_file, cPath + ::update_app_script_file, _always_erase, _silent )
      MsgC()
      RETURN .F.
   ENDIF
   MsgC()

   RETURN .T.



METHOD F18Admin:get_os_name()

   LOCAL _os := "Ubuntu"

#ifdef __PLATFORM__WINDOWS

   _os := "Windows"
#endif

#ifdef __PLATFORM__DARWIN
   _os := "MacOSX"
#endif

   RETURN _os




METHOD F18Admin:wget_download( cUrl, cFileName, cLocalFileName, lEraseFile, silent, only_newer )

   LOCAL lOk := .F.
   LOCAL cCmd
   LOCAL nFileHandle, nLength

   // IF lEraseFile == NIL
   // lEraseFile := .F.
   // ENDIF

   // IF silent == NIL
   // silent := .F.
   // ENDIF

   // IF only_newer == NIL
   // only_newer := .F.
   // ENDIF

   // IF lEraseFile
   // FErase( cLocalFileName )
   // Sleep( 1 )
   // ENDIF

  cCmd := "wget "

// #ifdef __PLATFORM__WINDOWS
   cCmd += " -q  --tries=4 --timeout=4  --no-cache --no-check-certificate "
// #endif

   cCmd += cUrl + cFileName // http://test.com/FILE

   cCmd += " -O "

   IF f18_run( cCmd + " " + file_path_quote( cLocalFileName ) ) != 0
      MsgBeep( "Error: " + cCmd  + "?!" )
      RETURN .F.
   ENDIF
   // Sleep( 1 )

   IF !File( cLocalFileName )
      error_bar( "upd", "Fajl " + cLocalFileName + " nije download-ovan !" )
      RETURN .F.
   ENDIF

   nFileHandle := FOpen( cLocalFileName ) // provjeri velicinu fajla

   IF nFileHandle >= 0
      nLength := FSeek( nFileHandle, 0, FS_END )
      FSeek( nFileHandle, 0 )
      FClose( nFileHandle )
      IF nLength <= 0
         error_bar( "upd", "Fajl " + cLocalFileName + " download ERROR!" )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN .T.





METHOD F18Admin:update_db()

   LOCAL lOk := .F.
   LOCAL nX := 1
   LOCAL _version := Space( 50 )
   LOCAL _db_list := {}
   LOCAL _server := my_server_params()
   LOCAL cDatabase := ""
   LOCAL _upd_empty := "N"
   PRIVATE GetList := {}

   cDatabase := Space( 50 )

   Box(, 10, 70 )

   @ m_x + nX, m_y + 2 SAY "**** upgrade db-a / unesite verziju ..."
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "     verzija db-a (npr. 4.6.1):" GET _version PICT "@S30" VALID !Empty( _version )
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "naziv baze / prazno update-sve:" GET cDatabase PICT "@S30"
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "Update template [empty] baza (D/N) ?" GET _upd_empty VALID _upd_empty $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN lOk
   ENDIF

   // snimi parametre
   ::_update_params := hb_Hash()
   ::_update_params[ "version" ] := AllTrim( _version )
   ::_update_params[ "database" ] := AllTrim( cDatabase )
   ::_update_params[ "host" ] := _server[ "host" ]
   ::_update_params[ "port" ] := _server[ "port" ]
   ::_update_params[ "file" ] := "?"
   ::_update_params[ "updade_empty" ] := _upd_empty

   IF !Empty( cDatabase )
      AAdd( _db_list, { AllTrim( cDatabase ) } )
   ELSE
      _db_list := my_login():database_array()
   ENDIF

   IF _upd_empty == "D"   // dodaj i empty template tabele u update shemu

      AAdd( _db_list, { "empty" } )
      AAdd( _db_list, { "empty_sezona" } )
   ENDIF

   IF !::update_db_download()    // download fajla sa interneta
      RETURN lOk
   ENDIF

   IF ! ::update_db_all( _db_list )
      RETURN lOk
   ENDIF


   lOk := .T.

   RETURN lOk



METHOD F18Admin:update_db_download()

   LOCAL lOk := .F.
   LOCAL _ver := ::_update_params[ "version" ]
   LOCAL cCmd := ""
   LOCAL cPath := my_home_root()
   LOCAL _file := "f18_db_migrate_package_" + AllTrim( _ver ) + ".gz"
   LOCAL cUrl := "http://download.bring.out.ba/"

   IF File( AllTrim( cPath ) + AllTrim( _file ) )

      IF Pitanje(, "Izbrisati postojeći download fajl ?", "N" ) == "D"
         FErase( AllTrim( cPath ) + AllTrim( _file ) )
         Sleep( 1 )
      ELSE
         ::_update_params[ "file" ] := AllTrim( cPath ) + AllTrim( _file )
         RETURN .T.
      ENDIF

   ENDIF


   IF ::wget_download( cUrl, _file, cPath + _file )  // download fajla
      ::_update_params[ "file" ] := AllTrim( cPath ) + AllTrim( _file )
      lOk := .T.
   ENDIF

   RETURN lOk



METHOD F18Admin:update_db_all( arr )

   LOCAL nI
   LOCAL lOk := .F.

   FOR nI := 1 TO Len( arr )
      IF ! ::update_db_company( AllTrim( arr[ nI, 1 ] ) )
         RETURN lOk
      ENDIF
   NEXT

   lOk := .T.

   RETURN lOk


METHOD F18Admin:update_db_command( cDatabase )

   LOCAL cCmd := ""
   LOCAL _file := ::_update_params[ "file" ]

#ifdef __PLATFORM__DARWIN

   cCmd += "open "
#endif

#ifdef __PLATFORM__WINDOWS
   cCmd += "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#else
   cCmd += SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#endif

   cCmd += "knowhowERP_package_updater"

#ifdef __PLATFORM__WINDOWS
   cCmd += ".exe"
#endif

#ifdef __PLATFORM__DARWIN
   cCmd += ".app"
#endif

#ifndef __PLATFORM__DARWIN
   IF !File( cCmd )
      MsgBeep( "Fajl " + cCmd  + " ne postoji !" )
      RETURN NIL
   ENDIF
#endif

   cCmd += " -databaseURL=//" + AllTrim( ::_update_params[ "host" ] )

   cCmd += ":"

   cCmd += AllTrim( Str( ::_update_params[ "port" ] ) )

   cCmd += "/" + AllTrim( cDatabase )

   cCmd += " -username=admin"

   cCmd += " -passwd=boutpgmin"

#ifdef __PLATFORM__WINDOWS
   cCmd += " -file=" + '"' + ::_update_params[ "file" ] + '"'
#else
   cCmd += " -file=" + ::_update_params[ "file" ]
#endif

   cCmd += " -autorun"

   RETURN cCmd




METHOD F18Admin:update_db_company( cOrganizacija )

   LOCAL aListaSezona := {}
   LOCAL nI
   LOCAL cDatabase
   LOCAL cCmd
   LOCAL lOk := .F.

   IF AllTrim( cOrganizacija ) $ "#empty#empty_sezona#"

      AAdd( aListaSezona, { "empty" } ) // ovo su template tabele
   ELSE

      IF Left( cOrganizacija, 1 ) == "!"

         cOrganizacija := Right( AllTrim( cOrganizacija ), Len( AllTrim( cOrganizacija ) ) - 1 )

         AAdd( aListaSezona, { "empty" } ) // rucno zadan naziv baze, ne gledati sezone

      ELSEIF !( "_" $ cOrganizacija )


         aListaSezona := my_login():get_database_sessions( cOrganizacija ) // nema sezone, uzeti sa servera

      ELSE

         IF SubStr( cOrganizacija, Len( cOrganizacija ) - 3, 1 ) $ "1#2"

            AAdd( aListaSezona, { Right( AllTrim( cOrganizacija ), 4 ) } ) // vec postoji zadana sezona, samo je dodati u matricu
            cOrganizacija := PadR( AllTrim( cOrganizacija ), Len( AllTrim( cOrganizacija ) ) - 5  )
         ELSE
            aListaSezona := my_login():get_database_sessions( cOrganizacija )
         ENDIF

      ENDIF

   ENDIF

   FOR nI := 1 TO Len( aListaSezona )


      IF aListaSezona[ nI, 1 ] == "empty" // ako je ovaj marker uzmi cisto ono sto je navedeno

         cDatabase := AllTrim( cOrganizacija ) // ovo je za empty template tabele
      ELSE
         cDatabase := AllTrim( cOrganizacija ) + "_" + AllTrim( aListaSezona[ nI, 1 ] )
      ENDIF

      cCmd := ::update_db_command( cDatabase )

      IF cCmd == NIL
         RETURN lOk
      ENDIF

      MsgO( "Vršim update baze " + cDatabase )

      lOk := hb_run( cCmd )
      AAdd( ::update_db_result, { cOrganizacija, cDatabase, cCmd, lOk } ) // ubaci u matricu rezultat

      MsgC()

   NEXT

   lOk := .T.

   RETURN lOk




METHOD F18Admin:razdvajanje_sezona()

   LOCAL _params
   LOCAL _dbs := {}
   LOCAL nI
   LOCAL hDbServerParams, cTekuciUser, cTekucaPassword, cTekucaDb
   LOCAL cQuery
   LOCAL nFromSezona, nToSezona
   LOCAL cDatabaseFrom, cDatabaseTo
   LOCAL _db := Space( 100 )
   LOCAL cDeletePostojecaDbDN := "N"
   LOCAL _count := 0
   LOCAL aRezultati := {}
   LOCAL oRow
   LOCAL lConfirmEnter

#ifndef F18_DEBUG

   IF !spec_funkcije_sifra( "ADMIN" )
      MsgBeep( "Opcija zaštićena šifrom !" )
      RETURN .F.
   ENDIF
#endif

   stop_refresh_operations()

   nFromSezona := Year( Date() ) - 1
   nToSezona := Year( Date() )

   SET CURSOR ON
   lConfirmEnter := Set( _SET_CONFIRM, .T. )


   Box(, 7, 60 )
   @ m_x + 1, m_y + 2 SAY8 "Otvaranje baze za novu sezonu ***" COLOR f18_color_i()
   @ m_x + 3, m_y + 2 SAY8 "Vrši se prenos sa godine:" GET nFromSezona PICT "9999"
   @ m_x + 3, Col() + 1 SAY8 "na godinu:" GET nToSezona PICT "9999" VALID ( nToSezona > nFromSezona .AND. nToSezona - nFromSezona == 1 )
   @ m_x + 5, m_y + 2 SAY8 "Baza (prazno-sve):" GET _db PICT "@S30"
   @ m_x + 6, m_y + 2 SAY8 "Ako baza postoji, pobriši je ? (D/N)" GET cDeletePostojecaDbDN VALID cDeletePostojecaDbDN $ "DN" PICT "@!"
   READ
   BoxC()

   Set( _SET_CONFIRM, lConfirmEnter )

   IF LastKey() == K_ESC
      start_refresh_operations()
      RETURN .F.
   ENDIF

   IF Pitanje(, "Konekcije svih korisnika na bazu biti prekinute! Nastaviti?", " " ) == "N"
      start_refresh_operations()
      RETURN .F.
   ENDIF

   pg_terminate_all_data_db_connections()

   hDbServerParams := my_server_params()
   cTekuciUser := hDbServerParams[ "user" ]
   cTekucaPassword := hDbServerParams[ "password" ]
   cTekucaDb := hDbServerParams[ "database" ]


   IF !::relogin_as_admin()
      Alert( "login kao admin neuspjesan !?" )
      start_refresh_operations()
      RETURN .F.
   ENDIF

   cQuery := "SELECT datname FROM pg_database "

   IF Empty( _db )
      cQuery += "WHERE datname LIKE '%_" + AllTrim( Str( nFromSezona ) ) + "' "
   ELSE
      cQuery += "WHERE datname = " + sql_quote( AllTrim( _db ) + "_" + AllTrim( Str( nFromSezona ) ) )
   ENDIF
   cQuery += "ORDER BY datname;"


   _dbs := postgres_sql_query( cQuery )
   _dbs:GoTo( 1 )

   // treba da imamo listu baza,  uzmemo sa select-om sve sto ima npr. 2013, i onda cemo provrtiti te baze i napraviti 2014
   Box(, 3, 65 )

   DO WHILE !_dbs:Eof()

      oRow := _dbs:GetRow()

      // test_2013
      cDatabaseFrom := AllTrim( oRow:FieldGet( 1 ) )
      // test_2014
      cDatabaseTo := StrTran( cDatabaseFrom, "_" + AllTrim( Str( nFromSezona ) ), "_" + AllTrim( Str( nToSezona ) ) )

      @ m_x + 1, m_y + 2 SAY Space( 60 )
      @ m_x + 1, m_y + 2 SAY "Kreiranje baze: " +  cDatabaseFrom + " > " + cDatabaseTo


      _params := hb_Hash()
      _params[ "db_type" ] := 1 // init parametri za razdvajanje, pocetno stanje je 1
      _params[ "cDatabaseName" ] := cDatabaseTo
      _params[ "db_template" ] := cDatabaseFrom
      _params[ "db_drop" ] := cDeletePostojecaDbDN
      _params[ "db_comment" ] := ""

      IF ! ::create_new_pg_db( _params )
         AAdd( aRezultati, { cDatabaseTo, cDatabaseFrom, "ERR" } )
         error_bar( "nova_sezona", cDatabaseFrom + " -> " + cDatabaseTo )
      ELSE
         ++_count
      ENDIF

      _dbs:Skip()

   ENDDO

   BoxC()

   ::relogin_as( cTekuciUser, cTekucaPassword, cTekucaDb )

   IF Len( aRezultati ) > 0
      MsgBeep( "Postoje greške kod otvaranja sezone !" )
   ENDIF

   IF _count > 0
      MsgBeep( "Uspješno kreirano " + AllTrim( Str( _count ) ) + " baza" )
   ENDIF

   start_refresh_operations()

   RETURN .T.




METHOD F18Admin:create_new_pg_db( hDb )

   LOCAL cDatabaseName, cDatabaseTemplate, lDbDrop, nDatabaseType, cDatabaseComment
   LOCAL cQuery
   LOCAL oQuery, aRezultati
   LOCAL _db_params, cTekuciUser, cTekucaPassword, cTekucaDb

   // 1) hF18Params read
   // ===============================================================
   IF hDb == NIL

      IF !spec_funkcije_sifra( "ADMIN" )
         MsgBeep( "Opcija zasticena !" )
         RETURN .F.
      ENDIF

      hDb := hb_Hash()

      IF !::create_new_pg_db_params( @hDb ) // CREATE DATABASE name OWNER admin TEMPLATE templ;
         RETURN .F.
      ENDIF

   ENDIF

   cDatabaseName := hDb[ "database_name" ]
   cDatabaseTemplate := hDb[ "db_template" ]
   lDbDrop := hDb[ "db_drop" ] == "D"
   nDatabaseType := hDb[ "db_type" ]
   cDatabaseComment := hDb[ "db_comment" ]

   IF Empty( cDatabaseTemplate ) .OR. Left( cDatabaseTemplate, 5 ) == "empty"
      nDatabaseType := 0 // ovo ce biti prazna baza uvijek
   ENDIF

   IF ! ::relogin_as_admin( "postgres" )
      RETURN .F.
   ENDIF

   IF lDbDrop
      IF !::drop_pg_db( cDatabaseName )
         RETURN .F.
      ENDIF
   ELSE

      cQuery := "SELECT COUNT(*) FROM pg_database "
      cQuery += "WHERE datname = " + sql_quote( cDatabaseName )
      oQuery := postgres_sql_query( cQuery )
      IF oQuery:GetRow( 1 ):FieldGet( 1 ) > 0
         error_bar( "nova_sezona", "baza " + cDatabaseName + " vec postoji" )
         RETURN .F. // baza vec postoji
      ENDIF
   ENDIF

   cQuery := "CREATE DATABASE " + cDatabaseName + " OWNER admin"
   IF !Empty( cDatabaseTemplate )
      cQuery += " TEMPLATE " + cDatabaseTemplate
   ENDIF
   cQuery += ";"

   info_bar( "nova_sezona", "db create: " + cDatabaseName  )
   oQuery := postgres_sql_query( cQuery )
   IF sql_error_in_query( oQuery, "CREATE", sql_postgres_conn() )
      RETURN .F.
   ENDIF

   cQuery := "GRANT ALL ON DATABASE " + cDatabaseName + " TO admin;"
   cQuery += "GRANT ALL ON DATABASE " + cDatabaseName + " TO xtrole WITH GRANT OPTION;"

   info_bar( "nova_sezona", "grant admin, xtrole: " + cDatabaseName )
   oQuery := postgres_sql_query( cQuery )
   IF sql_error_in_query( oQuery, "GRANT", sql_postgres_conn() )
      RETURN .F.
   ENDIF

   IF !Empty( cDatabaseComment )
      cQuery := "COMMENT ON DATABASE " + cDatabaseName + " IS " + sql_quote( hb_StrToUTF8( cDatabaseComment ) ) + ";"
      info_bar( "nova_sezona", "Postavljam opis baze..." )
      run_sql_query( cQuery )
   ENDIF

   IF nDatabaseType > 0
      info_bar( "nova_sezona", "brisanje podataka " + cDatabaseName )
      ::delete_db_data_all( cDatabaseName, nDatabaseType )
   ENDIF

   RETURN .T.



METHOD F18Admin:relogin_as_admin( cDatabase )

   LOCAL hSqlParams := my_server_params()
   LOCAL nConnType := 1

   hb_default( @cDatabase, "postgres" )

   IF cDatabase == "postgres"
      nConnType := 0
   ENDIF

   my_server_logout( nConnType )

   hSqlParams[ "user" ] := "admin"
   hSqlParams[ "password" ] := "boutpgmin"
   hSqlParams[ "database" ] := cDatabase

   IF my_server_login( hSqlParams, nConnType )
      set_sql_search_path()
      RETURN .T.
   ENDIF

   RETURN .F.


METHOD F18Admin:relogin_as( cUser, cPwd, cDatabase )

   LOCAL hSqlParams := my_server_params()
   LOCAL nConnType := 1

   IF cDatabase == "postgres"
      nConnType := 0
   ENDIF

   my_server_logout( nConnType )

   hSqlParams[ "user" ] := cUser
   hSqlParams[ "password" ] := cPwd

   IF cDatabase <> NIL
      hSqlParams[ "database" ] := cDatabase
   ENDIF

   RETURN my_server_login( hSqlParams, nConnType )


METHOD F18Admin:drop_pg_db( cDatabaseName )

   LOCAL cQry, oQry
   LOCAL hDbServerParams

   IF cDatabaseName == NIL

      IF !spec_funkcije_sifra( "ADMIN" )
         MsgBeep( "Opcija zasticena !" )
         RETURN .F.
      ENDIF

      // treba mi db name ?
      cDatabaseName := Space( 30 )

      Box(, 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Naziv baze:" GET cDatabaseName VALID !Empty( cDatabaseName )
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF

      cDatabaseName := AllTrim( cDatabaseName )

      IF Pitanje(, "100% sigurni da zelite izbrisati bazu '" + cDatabaseName + "' ?", "N" ) == "N"
         RETURN .F.
      ENDIF

   ENDIF

   IF ! ::relogin_as_admin( "postgres" )
      RETURN .F.
   ENDIF

   cQry := "DROP DATABASE IF EXISTS " + cDatabaseName + ";"

   oQry := postgres_sql_query( cQry )

   IF sql_error_in_query( oQry, "DROP", sql_postgres_conn() )
      error_bar( "drop_db", "drop db: " + cDatabaseName )
      RETURN .F.
   ENDIF

   RETURN .T.


METHOD F18Admin:delete_db_data_all( cDatabaseName, data_type )

   LOCAL _ret
   LOCAL cQuery
   LOCAL _pg_srv

   IF cDatabaseName == NIL
      ?E "Opcija delete_db_data_all zahtjeva naziv baze ..."
      RETURN .F.
   ENDIF

   // data_type
   // 1 - pocetno stanje
   // 2 - brisi sve podatke
   IF data_type == NIL
      data_type := 1
   ENDIF


   IF !::relogin_as_admin( AllTrim( cDatabaseName ) )
      RETURN .F.
   ENDIF


   // bitne tabele za reset podataka baze
   cQuery := ""
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "kalk_kalk;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "kalk_doks;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "kalk_doks2;"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "pos_doks;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "pos_pos;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "pos_dokspf;"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_fakt_atributi;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_doks;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_doks2;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_fakt;"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_suban;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_anal;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_sint;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_nalog;"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_suban;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_anal;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_sint;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_nalog;"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_docs;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_it;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_it2;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_ops;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_log;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_lit;"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "epdv_kuf;"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "epdv_kif;"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'fin/%';"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'kalk/%';"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'fakt/%';"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'pos/%';"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'epdv/%';"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'rnal_doc_no';"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE '%auto_plu%';"
   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE '%lock%';"

   cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "log;"

   // ako je potrebno brisati sve onda dodaj i sljedece...
   IF data_type > 1

      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "os_os;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "os_promj;"

      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "sii_sii;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "sii_promj;"

      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_ld;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_radkr;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_radn;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_pk_data;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_pk_radn;"

      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "roba;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "partn;"
      cQuery += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "sifv;"

   ENDIF

   info_bar( "nova_sezona", "brisanje podataka " + cDatabaseName )
   _ret := run_sql_query( cQuery )
   IF sql_error_in_query( _ret, "DELETE" )
      RETURN .F.
   ENDIF

   RETURN .T.



// -------------------------------------------------------------------
// kreiranje baze, parametri
// -------------------------------------------------------------------
METHOD F18Admin:create_new_pg_db_params( params )

   LOCAL lOk := .F.
   LOCAL nX := 1
   LOCAL cDatabaseName := Space( 50 )
   LOCAL cDatabaseTemplate := Space( 50 )
   LOCAL _db_year := AllTrim( Str( Year( Date() ) ) )
   LOCAL cDatabaseComment := Space( 100 )
   LOCAL lDbDrop := "N"
   LOCAL nDatabaseType := 1
   LOCAL _db_str

   Box(, 12, 70 )

   @ m_x + nX, m_y + 2 SAY "*** KREIRANJE NOVE BAZE PODATAKA ***"

   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "Naziv nove baze:" GET cDatabaseName VALID _new_db_valid( cDatabaseName ) PICT "@S30"
   @ m_x + nX, Col() + 1 SAY "godina:" GET _db_year PICT "@S4" VALID !Empty( _db_year )

   ++nX
   @ m_x + nX, m_y + 2 SAY "Opis baze (*):" GET cDatabaseComment PICT "@S50"

   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "Koristiti kao uzorak postojeću bazu (*):"

   ++nX
   @ m_x + nX, m_y + 2 SAY "Naziv:" GET cDatabaseTemplate PICT "@S40"

   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "Brisi bazu ako vec postoji ! (D/N)" GET lDbDrop VALID lDbDrop $ "DN" PICT "@!"

   ++nX
   @ m_x + nX, m_y + 2 SAY "Pražnjenje podataka (1) pocetno stanje (2) sve" GET nDatabaseType PICT "9"

   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "*** opcije markirane kao (*) nisu obavezne"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN lOk
   ENDIF

   // formiranje strina naziva baze...
   _db_str := AllTrim( cDatabaseName ) + "_" + AllTrim( _db_year )


   // template empty
   IF Empty( cDatabaseTemplate )
      cDatabaseTemplate := "empty"
   ENDIF

   // - zaista nema template !
   IF AllTrim( cDatabaseTemplate ) == "!"
      cDatabaseTemplate := ""
   ENDIF

   params[ "cDatabaseName" ] := AllTrim( _db_str )
   params[ "db_template" ] := AllTrim( cDatabaseTemplate )
   params[ "db_drop" ] := lDbDrop
   params[ "db_type" ] := nDatabaseType
   params[ "db_comment" ] := AllTrim( cDatabaseComment )

   lOk := .T.

   RETURN lOk




// ----------------------------------------------------------
// dodavanje nove baze - validator
// ----------------------------------------------------------
STATIC FUNCTION _new_db_valid( cDatabaseName )

   LOCAL lOk := .F.

   IF Empty( cDatabaseName )
      MsgBeep( "Naziv baze ne može biti prazno !" )
      RETURN lOk
   ENDIF

   IF ( "-" $ cDatabaseName .OR. ;
         "?" $ cDatabaseName .OR. ;
         ":" $ cDatabaseName .OR. ;
         "," $ cDatabaseName .OR. ;
         "." $ cDatabaseName )

      MsgBeep( "Naziv baze ne moze sadržavati znakove .:- itd... !" )
      RETURN lOk

   ENDIF

   lOk := .T.

   RETURN lOk
