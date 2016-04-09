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
   VAR update_app_f18_version
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
   METHOD update_app_get_versions()
   METHOD update_app_run_script()
   METHOD update_app_run_app_update()
   METHOD update_app_run_templates_update()
   METHOD update_app_unzip_templates()

   DATA _new_db_params
   DATA _update_params

ENDCLASS



METHOD F18Admin:New()

   ::update_db_result := {}
   ::create_db_result := {}

   IF ! ::relogin_as_admin( "postgres" )
      MsgBeep( "relogin psotgresql as admin neuspjesno " )
      RETURN .F.
   ENDIF

   RETURN self



METHOD F18Admin:update_app()

   LOCAL _ver_params := hb_Hash()
   LOCAL _upd_params := hb_Hash()
   LOCAL _upd_file := ""
   LOCAL _ok := .F.

   ::update_app_info_file := "UPDATE_INFO"
   ::update_app_script_file := "f18_upd.sh"

#ifdef __PLATFORM__WINDOWS
   ::update_app_script_file := "f18_upd.bat"
#endif

   IF !::f18_upd_download()
      MsgBeep( "Problem sa download-om skripti. Provjerite internet koneciju." )
      RETURN SELF
   ENDIF

   _ver_params := ::update_app_get_versions()

   IF _ver_params == NIL
      RETURN SELF
   ENDIF

   IF !::update_app_form( _ver_params )
      RETURN SELF
   ENDIF

   if ::update_app_templates
      ::update_app_run_templates_update( _ver_params )
   ENDIF

   if ::update_app_f18
      ::update_app_run_app_update( _ver_params )
   ENDIF

   RETURN SELF



METHOD F18Admin:update_app_run_templates_update( params )

   LOCAL _upd_file := "F18_template_#VER#.tar.bz2"
   LOCAL _dest := SLASH + "opt" + SLASH + "knowhowERP" + SLASH

#ifdef __PLATFORM__WINDOWS

   _dest := "c:" + SLASH + "knowhowERP" + SLASH
#endif

   if ::update_app_templates_version == "#LAST#"
      ::update_app_templates_version := params[ "templates" ]
   ENDIF

   _upd_file := StrTran( _upd_file, "#VER#", ::update_app_templates_version )

   IF !::wget_download( params[ "url" ], _upd_file, _dest + _upd_file, .T., .T. )
      RETURN SELF
   ENDIF

   ::update_app_unzip_templates( _dest, _dest, _upd_file )

   RETURN SELF



METHOD F18Admin:update_app_unzip_templates( destination_path, location_path, filename )

   LOCAL _cmd
   LOCAL _args := "-jxf"

   MsgO( "Vršim update template fajlova ..." )

#ifdef __PLATFORM__WINDOWS

   DirChange( destination_path )

   _cmd := "bunzip2 -f " + location_path + filename
   hb_run( _cmd )

   _cmd := "tar xvf " + StrTran( filename, ".bz2", "" )
   hb_run( _cmd )

#else

   _cmd := "tar -C " + location_path + " " + _args + " " + location_path + filename
   hb_run( _cmd )

#endif

   MsgC()

   RETURN SELF



METHOD F18Admin:update_app_run_app_update( params )

   LOCAL _upd_file := "F18_#OS#_#VER#.gz"

   if ::update_app_f18_version == "#LAST#"
      ::update_app_f18_version := params[ "f18" ]
   ENDIF

#ifdef __PLATFORM__LINUX
   _upd_file := StrTran( _upd_file, "#OS#", ::get_os_name() + "_i686" )
#else
   _upd_file := StrTran( _upd_file, "#OS#", ::get_os_name() )
#endif

   _upd_file := StrTran( _upd_file, "#VER#", ::update_app_f18_version )

   if ::update_app_f18_version == F18_VER
      MsgBeep( "Verzija aplikacije " + F18_VER + " je vec instalirana !" )
      RETURN SELF
   ENDIF

   IF !::wget_download( params[ "url" ], _upd_file, my_home_root() + _upd_file, .T., .T. )
      RETURN SELF
   ENDIF

   ::update_app_run_script( my_home_root() + _upd_file )

   RETURN SELF



METHOD F18Admin:update_app_run_script( update_file )

   LOCAL _url := my_home_root() + ::update_app_script_file

#ifdef __PLATFORM__WINDOWS

   _url := 'start cmd /C ""' + _url
   _url += '" "' + update_file + '""'
#else
#ifdef __PLATFORM__LINUX
   _url := "bash " + _url
#endif
   _url += " " + update_file
#endif

#ifdef __PLATFORM__UNIX
   _url := _url + " &"
#endif

   Msg( "F18 ce se sada zatvoriti#Nakon update procesa ponovo otvorite F18", 4 )

   hb_run( _url )

   QUIT_1

   RETURN SELF




METHOD F18Admin:update_app_form( upd_params )

   LOCAL _ok := .F.
   LOCAL _f_ver_prim := 1
   LOCAL _f_ver_sec := 7
   LOCAL _f_ver_third := Space( 10 )
   LOCAL _t_ver_prim := 1
   LOCAL _t_ver_sec := 5
   LOCAL _t_ver_third := Space( 10 )
   LOCAL _x := 1
   LOCAL _col_app, _col_temp, _line
   LOCAL _upd_f, _upd_t, _pos

   _upd_f := "D"
   _upd_t := "N"
   _col_app := "W/G+"
   _col_temp := "W/G+"

   IF F18_VER < upd_params[ "f18" ]
      _col_app := "W/R+"
   ENDIF
   IF F18_TEMPLATE_VER < upd_params[ "templates" ]
      _col_temp := "W/R+"
   ENDIF

   Box(, 14, 65 )

   @ m_x + _x, m_y + 2 SAY PadR( "## UPDATE F18 APP ##", 64 ) COLOR F18_COLOR_I

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY _line := ( Replicate( "-", 10 ) + " " + Replicate( "-", 20 ) + " " + Replicate( "-", 20 ) )

   ++ _x
   @ m_x + _x, m_y + 2 SAY PadR( "[INFO]", 10 ) + "/" + PadC( "Trenutna", 20 ) + "/" + PadC( "Dostupna", 20 )

   ++ _x
   @ m_x + _x, m_y + 2 SAY _line

   ++ _x
   @ m_x + _x, m_y + 2 SAY PadR( "F18", 10 ) + " " + PadC( F18_VER, 20 )
   @ m_x + _x, Col() SAY " "
   @ m_x + _x, Col() SAY PadC( upd_params[ "f18" ], 20 ) COLOR _col_app

   ++ _x
   @ m_x + _x, m_y + 2 SAY PadR( "template", 10 ) + " " + PadC( F18_TEMPLATE_VER, 20 )
   @ m_x + _x, Col() SAY " "
   @ m_x + _x, Col() SAY PadC( upd_params[ "templates" ], 20 ) COLOR _col_temp

   ++ _x

   @ m_x + _x, m_y + 2 SAY _line

   ++ _x
   ++ _x
   _pos := _x

   @ m_x + _x, m_y + 2 SAY "       Update F18 ?" GET _upd_f PICT "@!" VALID _upd_f $ "DN"

   READ

   IF _upd_f == "D"
      @ m_x + _x, m_y + 25 SAY "VERZIJA:" GET _f_ver_prim PICT "99" VALID _f_ver_prim > 0
      @ m_x + _x, Col() + 1 SAY "." GET _f_ver_sec PICT "99" VALID _f_ver_sec > 0
      @ m_x + _x, Col() + 1 SAY "." GET _f_ver_third PICT "@S10"

   ENDIF

   ++ _x
   ++ _x
   _pos := _x

   @ m_x + _x, m_y + 2 SAY "  Update template ?" GET _upd_t PICT "@!" VALID _upd_t $ "DN"

   READ

   IF _upd_t == "D"

      @ m_x + _x, m_y + 25 SAY "VERZIJA:" GET _t_ver_prim PICT "99" VALID _t_ver_prim > 0
      @ m_x + _x, Col() + 1 SAY "." GET _t_ver_sec PICT "99" VALID _t_ver_sec > 0
      @ m_x + _x, Col() + 1 SAY "." GET _t_ver_third PICT "@S10"

      READ

   ENDIF

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   // setuj postavke...
   ::update_app_f18 := ( _upd_f == "D" )
   ::update_app_templates := ( _upd_t == "D" )

   if ::update_app_f18
      // sastavi mi verziju
      IF !Empty( _f_ver_third )
         // zadana verzija
         ::update_app_f18_version := AllTrim( Str( _f_ver_prim ) ) + ;
            "." + ;
            AllTrim( Str( _f_ver_sec ) ) + ;
            "." + ;
            AllTrim( _f_ver_third )
      ELSE
         ::update_app_f18_version := "#LAST#"
      ENDIF

      _ok := .T.

   ENDIF

   if ::update_app_templates
      // sastavi mi verziju
      IF !Empty( _t_ver_third )
         // zadana verzija
         ::update_app_templates_version := AllTrim( Str( _t_ver_prim ) ) + ;
            "." + ;
            AllTrim( Str( _t_ver_sec ) ) + ;
            "." + ;
            AllTrim( _t_ver_third )
      ELSE
         ::update_app_templates_version := "#LAST#"
      ENDIF

      _ok := .T.

   ENDIF

   RETURN _ok





METHOD F18Admin:update_app_get_versions()

   LOCAL _urls := hb_Hash()
   LOCAL _o_file, _tmp, _a_tmp
   LOCAL _file := my_home_root() + ::update_app_info_file
   LOCAL _count := 0

   _o_file := TFileRead():New( _file )
   _o_file:Open()

   IF _o_file:Error()
      MSGBEEP( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
      RETURN SELF
   ENDIF

   _tmp := ""

   // prodji kroz svaku liniju i procitaj zapise
   DO WHILE _o_file:MoreToRead()
      _tmp := hb_StrToUTF8( _o_file:ReadLine() )
      _a_tmp := TokToNiz( _tmp, "=" )
      IF Len( _a_tmp ) > 1
         ++ _count
         _urls[ AllTrim( Lower( _a_tmp[ 1 ] ) ) ] := AllTrim( _a_tmp[ 2 ] )
      ENDIF
   ENDDO

   _o_file:Close()

   IF _count == 0
      MsgBeep( "Nisam uspio nista procitati iz fajla sa verzijama !" )
      _urls := NIL
   ENDIF

   RETURN _urls



METHOD F18Admin:f18_upd_download()

   LOCAL _ok := .F.
   LOCAL _path := my_home_root()
   LOCAL _url
   LOCAL _script
   LOCAL _ver_params
   LOCAL _silent := .T.
   LOCAL _always_erase := .T.

   info_bar( "upd", "download " +  ::update_app_info_file )

   _url := "https://raw.github.com/knowhow/F18_knowhow/master/"
   IF !::wget_download( _url, ::update_app_info_file, _path + ::update_app_info_file, _always_erase, _silent )
      RETURN .F.
   ENDIF

   info_bar( "upd", "download " +  ::update_app_script_file )
   _url := "https://raw.github.com/knowhow/F18_knowhow/master/scripts/"
   IF !::wget_download( _url, ::update_app_script_file, _path + ::update_app_script_file, _always_erase, _silent )
      RETURN .F.
   ENDIF

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




METHOD F18Admin:wget_download( url, filename, location, erase_file, silent, only_newer )

   LOCAL _ok := .F.
   LOCAL _cmd := ""
   LOCAL _h, _lenght

   IF erase_file == NIL
      erase_file := .F.
   ENDIF

   IF silent == NIL
      silent := .F.
   ENDIF

   IF only_newer == NIL
      only_newer := .F.
   ENDIF

   IF erase_file
      FErase( location )
      Sleep( 1 )
   ENDIF

   _cmd += "wget "

#ifdef __PLATFORM__WINDOWS
   _cmd += " --no-check-certificate "
#endif

   _cmd += url + filename

   _cmd += " -O "

#ifdef __PLATFORM__WINDOWS
   _cmd += '"' + location + '"'
#else
   _cmd += location
#endif

   hb_run( _cmd )

   Sleep( 1 )

   IF !File( location )
      // nema fajle
      error_bar( "upd", "Fajl " + location + " nije download-ovan !" )
      RETURN .F.
   ENDIF

   // provjeri velicinu fajla...
   _h := FOpen( location )

   IF _h >= 0
      _length := FSeek( _h, 0, FS_END )
      FSeek( _h, 0 )
      FClose( _h )
      IF _length <= 0
         error_bar( "upd", "Fajl " + location + " download ERROR!" )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN .T.





METHOD F18Admin:update_db()

   LOCAL _ok := .F.
   LOCAL _x := 1
   LOCAL _version := Space( 50 )
   LOCAL _db_list := {}
   LOCAL _server := my_server_params()
   LOCAL _database := ""
   LOCAL _upd_empty := "N"
   PRIVATE GetList := {}

   _database := Space( 50 )

   Box(, 10, 70 )

   @ m_x + _x, m_y + 2 SAY "**** upgrade db-a / unesite verziju ..."
   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "     verzija db-a (npr. 4.6.1):" GET _version PICT "@S30" VALID !Empty( _version )
   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "naziv baze / prazno update-sve:" GET _database PICT "@S30"
   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Update template [empty] baza (D/N) ?" GET _upd_empty VALID _upd_empty $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   // snimi parametre...
   ::_update_params := hb_Hash()
   ::_update_params[ "version" ] := AllTrim( _version )
   ::_update_params[ "database" ] := AllTrim( _database )
   ::_update_params[ "host" ] := _server[ "host" ]
   ::_update_params[ "port" ] := _server[ "port" ]
   ::_update_params[ "file" ] := "?"
   ::_update_params[ "updade_empty" ] := _upd_empty

   IF !Empty( _database )
      AAdd( _db_list, { AllTrim( _database ) } )
   ELSE
      _db_list := F18Login():New():database_array()
   ENDIF

   IF _upd_empty == "D"
      // dodaj i empty template tabele u update shemu...
      AAdd( _db_list, { "empty" } )
      AAdd( _db_list, { "empty_sezona" } )
   ENDIF

   // download fajla sa interneta...
   IF !::update_db_download()
      RETURN _ok
   ENDIF

   IF ! ::update_db_all( _db_list )
      RETURN _ok
   ENDIF

   IF Len( ::update_db_result ) > 0
      // imamo i rezultate...

   ENDIF

   _ok := .T.

   RETURN _ok



METHOD F18Admin:update_db_download()

   LOCAL _ok := .F.
   LOCAL _ver := ::_update_params[ "version" ]
   LOCAL _cmd := ""
   LOCAL _path := my_home_root()
   LOCAL _file := "f18_db_migrate_package_" + AllTrim( _ver ) + ".gz"
   LOCAL _url := "http://download.bring.out.ba/"

   IF File( AllTrim( _path ) + AllTrim( _file ) )

      IF Pitanje(, "Izbrisati postojeći download fajl ?", "N" ) == "D"
         FErase( AllTrim( _path ) + AllTrim( _file ) )
         Sleep( 1 )
      ELSE
         ::_update_params[ "file" ] := AllTrim( _path ) + AllTrim( _file )
         RETURN .T.
      ENDIF

   ENDIF

   // download fajla
   if ::wget_download( _url, _file, _path + _file )
      ::_update_params[ "file" ] := AllTrim( _path ) + AllTrim( _file )
      _ok := .T.
   ENDIF

   RETURN _ok



METHOD F18Admin:update_db_all( arr )

   LOCAL _i
   LOCAL _ok := .F.

   FOR _i := 1 TO Len( arr )
      IF ! ::update_db_company( AllTrim( arr[ _i, 1 ] ) )
         RETURN _ok
      ENDIF
   NEXT

   _ok := .T.

   RETURN _ok


METHOD F18Admin:update_db_command( database )

   LOCAL _cmd := ""
   LOCAL _file := ::_update_params[ "file" ]

#ifdef __PLATFORM__DARWIN

   _cmd += "open "
#endif

#ifdef __PLATFORM__WINDOWS
   _cmd += "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#else
   _cmd += SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#endif

   _cmd += "knowhowERP_package_updater"

#ifdef __PLATFORM__WINDOWS
   _cmd += ".exe"
#endif

#ifdef __PLATFORM__DARWIN
   _cmd += ".app"
#endif

#ifndef __PLATFORM__DARWIN
   IF !File( _cmd )
      MsgBeep( "Fajl " + _cmd  + " ne postoji !" )
      RETURN NIL
   ENDIF
#endif

   _cmd += " -databaseURL=//" + AllTrim( ::_update_params[ "host" ] )

   _cmd += ":"

   _cmd += AllTrim( Str( ::_update_params[ "port" ] ) )

   _cmd += "/" + AllTrim( database )

   _cmd += " -username=admin"

   _cmd += " -passwd=boutpgmin"

#ifdef __PLATFORM__WINDOWS
   _cmd += " -file=" + '"' + ::_update_params[ "file" ] + '"'
#else
   _cmd += " -file=" + ::_update_params[ "file" ]
#endif

   _cmd += " -autorun"

   RETURN _cmd




METHOD F18Admin:update_db_company( company )

   LOCAL _sess_list := {}
   LOCAL _i
   LOCAL _database
   LOCAL _cmd
   LOCAL _ok := .F.

   IF AllTrim( company ) $ "#empty#empty_sezona#"
      // ovo su template tabele...
      AAdd( _sess_list, { "empty" } )
   ELSE

      IF Left( company, 1 ) == "!"

         company := Right( AllTrim( company ), Len( AllTrim( company ) ) - 1 )
         // rucno zadat naziv baze, ne gledaj sezone...
         AAdd( _sess_list, { "empty" } )

      ELSEIF ! ( "_" $ company )

         // nema sezone, uzmi sa servera...
         _sess_list := F18Login():New():get_database_sessions( company )

      ELSE

         IF SubStr( company, Len( company ) - 3, 1 ) $ "1#2"
            // vec postoji zadana sezona...
            // samo je dodaj u matricu...
            AAdd( _sess_list, { Right( AllTrim( company ), 4 ) } )
            company := PadR( AllTrim( company ), Len( AllTrim( company ) ) - 5  )
         ELSE
            _sess_list := F18Login():New():get_database_sessions( company )
         ENDIF

      ENDIF

   ENDIF

   FOR _i := 1 TO Len( _sess_list )

      // ako je ovaj marker uzmi cisto ono sto je navedeno...
      IF _sess_list[ _i, 1 ] == "empty"
         // ovo je za empty template tabele..
         _database := AllTrim( company )
      ELSE
         _database := AllTrim( company ) + "_" + AllTrim( _sess_list[ _i, 1 ] )
      ENDIF

      _cmd := ::update_db_command( _database )

      IF _cmd == NIL
         RETURN _ok
      ENDIF

      MsgO( "Vršim update baze " + _database )

      _ok := hb_run( _cmd )
      // ubaci u matricu rezultat...
      AAdd( ::update_db_result, { company, _database, _cmd, _ok } )

      MsgC()

   NEXT

   _ok := .T.

   RETURN _ok




METHOD F18Admin:razdvajanje_sezona()

   LOCAL _params
   LOCAL _dbs := {}
   LOCAL _i
   LOCAL _my_params, _t_user, _t_pwd, _t_database
   LOCAL _qry
   LOCAL _from_sess, _to_sess
   LOCAL _db_from, _db_to
   LOCAL _db := Space( 100 )
   LOCAL _db_delete := "N"
   LOCAL _count := 0
   LOCAL aRezultati := {}
   LOCAL oRow

#ifndef F18_DEBUG

   IF !spec_funkcije_sifra( "ADMIN" )
      MsgBeep( "Opcija zasticena !" )
      RETURN .F.
   ENDIF
#endif
   // pg_terminate_all_data_db_connections()

   _from_sess := Year( Date() ) - 1
   _to_sess := Year( Date() )

   SET CURSOR ON
   SET CONFIRM ON

   Box(, 7, 60 )
   @ m_x + 1, m_y + 2 SAY8 "Otvaranje baze za novu sezonu ***" COLOR F18_COLOR_I
   @ m_x + 3, m_y + 2 SAY8 "Vrsi se prenos sa godine:" GET _from_sess PICT "9999"
   @ m_x + 3, Col() + 1 SAY8 "na godinu:" GET _to_sess PICT "9999" VALID ( _to_sess > _from_sess .AND. _to_sess - _from_sess == 1 )
   @ m_x + 5, m_y + 2 SAY8 "Baza (prazno-sve):" GET _db PICT "@S30"
   @ m_x + 6, m_y + 2 SAY8 "Ako baza postoji, pobriši je ? (D/N)" GET _db_delete VALID _db_delete $ "DN" PICT "@!"
   READ
   BoxC()

   SET CONFIRM OFF

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   _my_params := my_server_params()
   _t_user := _my_params[ "user" ]
   _t_pwd := _my_params[ "password" ]
   _t_database := _my_params[ "database" ]


   IF !::relogin_as_admin()
      Alert( "login kao admin neuspjesan !?" )
      RETURN .F.
   ENDIF

   _qry := "SELECT datname FROM pg_database "

   IF Empty( _db )
      _qry += "WHERE datname LIKE '%_" + AllTrim( Str( _from_sess ) ) + "' "
   ELSE
      _qry += "WHERE datname = " + sql_quote( AllTrim( _db ) + "_" + AllTrim( Str( _from_sess ) ) )
   ENDIF
   _qry += "ORDER BY datname;"


   _dbs := postgres_sql_query( _qry )
   _dbs:GoTo( 1 )

   // treba da imamo listu baza...
   // uzemomo sa select-om sve sto ima 2013 recimo
   // i onda cemo provrtiti te baze i napraviti 2014
   Box(, 3, 65 )

   DO WHILE !_dbs:Eof()

      oRow := _dbs:GetRow()

      // test_2013
      _db_from := AllTrim( oRow:FieldGet( 1 ) )
      // test_2014
      _db_to := StrTran( _db_from, "_" + AllTrim( Str( _from_sess ) ), "_" + AllTrim( Str( _to_sess ) ) )

      @ m_x + 1, m_y + 2 SAY Space( 60 )
      @ m_x + 1, m_y + 2 SAY "Kreiranje baze: " +  _db_from + " > " + _db_to

      // init parametri za razdvajanje...
      // pocetno stanje je 1
      _params := hb_Hash()
      _params[ "db_type" ] := 1
      _params[ "db_name" ] := _db_to
      _params[ "db_template" ] := _db_from
      _params[ "db_drop" ] := _db_delete
      _params[ "db_comment" ] := ""

      IF ! ::create_new_pg_db( _params )
         AAdd( aRezultati, { _db_to, _db_from, "ERR" } )
         error_bar( "nova_sezona", _db_from + " -> " + _db_to )
      ELSE
         ++ _count
      ENDIF

      _dbs:Skip()

   ENDDO

   BoxC()


   ::relogin_as( _t_user, _t_pwd, _t_database )


   IF Len( aRezultati ) > 0
      MsgBeep( "Postoje greške kod otvaranja sezone !" )
   ENDIF

   IF _count > 0
      MsgBeep( "Uspješno kreirano " + AllTrim( Str( _count ) ) + " baza" )
   ENDIF

   RETURN .T.




METHOD F18Admin:create_new_pg_db( params )

   LOCAL _db_name, _db_template, _db_drop, _db_type, _db_comment
   LOCAL _qry
   LOCAL oQuery, aRezultati
   LOCAL _db_params, _t_user, _t_pwd, _t_database

   // 1) params read
   // ===============================================================
   IF params == NIL

      IF !spec_funkcije_sifra( "ADMIN" )
         MsgBeep( "Opcija zasticena !" )
         RETURN .F.
      ENDIF

      params := hb_Hash()

      // CREATE DATABASE name OWNER admin TEMPLATE templ;
      IF !::create_new_pg_db_params( @params )
         RETURN .F.
      ENDIF

   ENDIF

   // uzmi parametre koje ces koristiti dalje...
   _db_name := params[ "db_name" ]
   _db_template := params[ "db_template" ]
   _db_drop := params[ "db_drop" ] == "D"
   _db_type := params[ "db_type" ]
   _db_comment := params[ "db_comment" ]

   IF Empty( _db_template ) .OR. Left( _db_template, 5 ) == "empty"
      // ovo ce biti prazna baza uvijek...
      _db_type := 0
   ENDIF

   IF ! ::relogin_as_admin( "postgres" )
      RETURN .F.
   ENDIF

   IF _db_drop
      IF !::drop_pg_db( _db_name )
         RETURN .F.
      ENDIF
   ELSE

      _qry := "SELECT COUNT(*) FROM pg_database "
      _qry += "WHERE datname = " + sql_quote( _db_name )
      oQuery := postgres_sql_query( _qry )
      IF oQuery:GetRow( 1 ):FieldGet( 1 ) > 0
         error_bar( "nova_sezona", "baza " + _db_name + " vec postoji" )
         RETURN .F. // baza vec postoji
      ENDIF
   ENDIF

   _qry := "CREATE DATABASE " + _db_name + " OWNER admin"
   IF !Empty( _db_template )
      _qry += " TEMPLATE " + _db_template
   ENDIF
   _qry += ";"

   info_bar( "nova_sezona", "db create: " + _db_name  )
   oQuery := postgres_sql_query( _qry )
   IF sql_error_in_query( oQuery, "CREATE", sql_postgres_conn() )
      RETURN .F.
   ENDIF


   _qry := "GRANT ALL ON DATABASE " + _db_name + " TO admin;"
   _qry += "GRANT ALL ON DATABASE " + _db_name + " TO xtrole WITH GRANT OPTION;"

   info_bar( "nova_sezona", "grant admin, xtrole: " + _db_name )
   oQuery := postgres_sql_query( _qry )
   IF sql_error_in_query( oQuery, "GRANT", sql_postgres_conn() )
      RETURN .F.
   ENDIF

   IF !Empty( _db_comment )
      _qry := "COMMENT ON DATABASE " + _db_name + " IS " + sql_quote( hb_StrToUTF8( _db_comment ) ) + ";"
      info_bar( "nova_sezona", "Postavljam opis baze..." )
      run_sql_query( _qry )
   ENDIF


   IF _db_type > 0
      info_bar( "nova_sezona", "brisanje podataka " + _db_name )
      ::delete_db_data_all( _db_name, _db_type )
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


METHOD F18Admin:drop_pg_db( db_name )

   LOCAL cQry, oQry
   LOCAL _my_params

   IF db_name == NIL

      IF !spec_funkcije_sifra( "ADMIN" )
         MsgBeep( "Opcija zasticena !" )
         RETURN .F.
      ENDIF

      // treba mi db name ?
      db_name := Space( 30 )

      Box(, 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Naziv baze:" GET db_name VALID !Empty( db_name )
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF

      db_name := AllTrim( db_name )

      IF Pitanje(, "100% sigurni da zelite izbrisati bazu '" + db_name + "' ?", "N" ) == "N"
         RETURN .F.
      ENDIF

   ENDIF

   IF ! ::relogin_as_admin( "postgres" )
      RETURN .F.
   ENDIF

   cQry := "DROP DATABASE IF EXISTS " + db_name + ";"

   oQry := postgres_sql_query( cQry )

   IF sql_error_in_query( oQry, "DROP", sql_postgres_conn() )
      error_bar( "drop_db", "drop db: " + db_name )
      RETURN .F.
   ENDIF

   RETURN .T.


METHOD F18Admin:delete_db_data_all( db_name, data_type )

   LOCAL _ret
   LOCAL _qry
   LOCAL _pg_srv

   IF db_name == NIL
      ?E "Opcija delete_db_data_all zahtjeva naziv baze ..."
      RETURN .F.
   ENDIF

   // data_type
   // 1 - pocetno stanje
   // 2 - brisi sve podatke
   IF data_type == NIL
      data_type := 1
   ENDIF

   AltD()
   IF !::relogin_as_admin( AllTrim( db_name ) )
      RETURN .F.
   ENDIF


   // bitne tabele za reset podataka baze
   _qry := ""
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "kalk_kalk;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "kalk_doks;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "kalk_doks2;"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "pos_doks;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "pos_pos;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "pos_dokspf;"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_fakt_atributi;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_doks;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_doks2;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fakt_fakt;"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_suban;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_anal;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_sint;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "fin_nalog;"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_suban;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_anal;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_sint;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "mat_nalog;"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_docs;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_it;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_it2;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_ops;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_log;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_lit;"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "epdv_kuf;"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "epdv_kif;"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'fin/%';"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'kalk/%';"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'fakt/%';"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'pos/%';"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'epdv/%';"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE 'rnal_doc_no';"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE '%auto_plu%';"
   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "metric WHERE metric_name LIKE '%lock%';"

   _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "log;"

   // ako je potrebno brisati sve onda dodaj i sljedece...
   IF data_type > 1

      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "os_os;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "os_promj;"

      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "sii_sii;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "sii_promj;"

      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_ld;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_radkr;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_radn;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_pk_data;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "ld_pk_radn;"

      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "roba;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "partn;"
      _qry += "DELETE FROM " + F18_PSQL_SCHEMA_DOT + "sifv;"

   ENDIF

   info_bar( "nova_sezona", "brisanje podataka " + db_name )
   _ret := run_sql_query( _qry )
   IF sql_error_in_query( _ret, "DELETE" )
      RETURN .F.
   ENDIF

   RETURN .T.



// -------------------------------------------------------------------
// kreiranje baze, parametri
// -------------------------------------------------------------------
METHOD F18Admin:create_new_pg_db_params( params )

   LOCAL _ok := .F.
   LOCAL _x := 1
   LOCAL _db_name := Space( 50 )
   LOCAL _db_template := Space( 50 )
   LOCAL _db_year := AllTrim( Str( Year( Date() ) ) )
   LOCAL _db_comment := Space( 100 )
   LOCAL _db_drop := "N"
   LOCAL _db_type := 1
   LOCAL _db_str

   Box(, 12, 70 )

   @ m_x + _x, m_y + 2 SAY "*** KREIRANJE NOVE BAZE PODATAKA ***"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Naziv nove baze:" GET _db_name VALID _new_db_valid( _db_name ) PICT "@S30"
   @ m_x + _x, Col() + 1 SAY "godina:" GET _db_year PICT "@S4" VALID !Empty( _db_year )

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Opis baze (*):" GET _db_comment PICT "@S50"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Koristiti kao uzorak postojeću bazu (*):"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Naziv:" GET _db_template PICT "@S40"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Brisi bazu ako vec postoji ! (D/N)" GET _db_drop VALID _db_drop $ "DN" PICT "@!"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Pražnjenje podataka (1) pocetno stanje (2) sve" GET _db_type PICT "9"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "*** opcije markirane kao (*) nisu obavezne"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   // formiranje strina naziva baze...
   _db_str := AllTrim( _db_name ) + "_" + AllTrim( _db_year )


   // template empty
   IF Empty( _db_template )
      _db_template := "empty"
   ENDIF

   // - zaista nema template !
   IF AllTrim( _db_template ) == "!"
      _db_template := ""
   ENDIF

   params[ "db_name" ] := AllTrim( _db_str )
   params[ "db_template" ] := AllTrim( _db_template )
   params[ "db_drop" ] := _db_drop
   params[ "db_type" ] := _db_type
   params[ "db_comment" ] := AllTrim( _db_comment )

   _ok := .T.

   RETURN _ok




// ----------------------------------------------------------
// dodavanje nove baze - validator
// ----------------------------------------------------------
STATIC FUNCTION _new_db_valid( db_name )

   LOCAL _ok := .F.

   IF Empty( db_name )
      MsgBeep( "Naziv baze ne može biti prazno !" )
      RETURN _ok
   ENDIF

   IF ( "-" $ db_name .OR. ;
         "?" $ db_name .OR. ;
         ":" $ db_name .OR. ;
         "," $ db_name .OR. ;
         "." $ db_name )

      MsgBeep( "Naziv baze ne moze sadržavati znakove .:- itd... !" )
      RETURN _ok

   ENDIF

   _ok := .T.

   RETURN _ok