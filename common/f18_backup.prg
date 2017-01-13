/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"
#include "f18_color.ch"

CLASS F18Backup

   METHOD New()

   METHOD Backup_now()

   METHOD Backup_company()
   METHOD Backup_server()

   METHOD backup_to_removable()

   METHOD backup_in_progress_info()

   METHOD get_backup_path()
   METHOD get_backup_interval()
   METHOD get_backup_type()
   METHOD get_backup_filename()
   METHOD get_last_backup_date()
   METHOD set_last_backup_date()
   METHOD get_removable_drive()
   METHOD get_windows_ping_time()

   METHOD Lock()
   METHOD UNLOCK()
   METHOD locked()

   DATA backup_path
   DATA backup_filename
   DATA backup_interval
   DATA backup_type
   DATA last_backup
   DATA removable_drive
   DATA ping_time

ENDCLASS


METHOD F18Backup:New()

   ::backup_interval := 0
   ::last_backup := CToD( "" )
   ::removable_drive := ""
   ::ping_time := 0

   RETURN SELF


METHOD F18Backup:backup_in_progress_info()

   LOCAL _txt

   _txt := "Operacija backup-a u toku. Pokusajte ponovo..."

   RETURN _txt



METHOD F18Backup:Backup_now( auto )

   IF auto == NIL
      auto := .T.
   ENDIF

   // da li je backup vec pokrenut ?
   if ::locked( .T. )
      IF Pitanje(, "Napravi unlock backup operacije (D/N)?", "N" ) == "D"
      ELSE
         RETURN .F.
      ENDIF
   ELSE
      // zakljucaj opciju backup-a da je samo jedan korisnik radi
      ::Lock()
   ENDIF

   if ::backup_type == 1
      ::Backup_company()
   ELSE
      ::Backup_server()
   ENDIF

   IF auto
      // setuj datum kreiranja backup-a
      ::set_last_backup_date()
   ENDIF

   // otkljucaj nakon sto je backup napravljen
   ::unlock()

   RETURN .T.


METHOD F18Backup:Backup_company()

   LOCAL _ok := .F.
   LOCAL _cmd := ""
   LOCAL _server_params := my_server_params()
   LOCAL _host := _server_params[ "host" ]
   LOCAL _port := _server_params[ "port" ]
   LOCAL _database := _server_params[ "database" ]
   LOCAL _admin_user := "admin"
   LOCAL _x := 7
   LOCAL _y := 2
   LOCAL nI, _backup_file
   LOCAL _color_ok := F18_COLOR_BACKUP_OK
   LOCAL _color_err := F18_COLOR_BACKUP_ERROR
   LOCAL _line := Replicate( "-", 70 )

   ::get_backup_filename()
   ::get_windows_ping_time()
   ::get_removable_drive()

   FErase( ::backup_path + ::backup_filename )
   Sleep( 1 )

#ifdef __PLATFORM__UNIX
   _cmd += "export pgusername=admin;export PGPASSWORD=boutpgmin;"
#endif

#ifdef __PLATFORM__WINDOWS
   _cmd += "set pgusername=admin&set PGPASSWORD=boutpgmin&"

   IF ::ping_time > 0
      _cmd += "ping -n " + AllTrim( Str( ::ping_time ) ) + " 8.8.8.8&"
   ENDIF

#endif

   _backup_file := ::backup_path + ::backup_filename

#ifdef __PLATFORM__WINDOWS
   _backup_file := StrTran( _backup_file, "\", "//" )
#endif

   _cmd += "pg_dump"
   _cmd += " -h " + AllTrim( _host )
   _cmd += " -p " + AllTrim( Str( _port ) )
   _cmd += " -U " + AllTrim( _admin_user )
   _cmd += " -w "
   _cmd += " -F c "
   _cmd += " -b "
   _cmd += ' -f "' + _backup_file + '"'
   _cmd += ' "' + _database + '"'

   @ _x, _y SAY8 "Obavještenje: nakon pokretanja procedure backup-a slobodno se prebacite"
   ++_x
   @ _x, _y SAY "              na prozor aplikacije i nastavite raditi."
   ++ _x
   @ _x, _y SAY _line
   ++ _x
   @ _x, _y SAY "Backup podataka u toku...."
   ++ _x
   @ _x, _y SAY _line
   ++ _x
   @ _x, _y SAY "   Lokacija backup-a: " + ::backup_path
   ++ _x
   @ _x, _y SAY "Naziv fajla backup-a: " + ::backup_filename

   ++ _x
   ++ _x
   @ _x, _y SAY8 "očekujem rezulat operacije... "

#ifdef __PLATFORM__WINDOWS
   f18_run( _cmd )
#else
   hb_run( _cmd )
#endif

   IF File( ::backup_path + ::backup_filename )
      @ _x, Col() + 1 SAY "OK" COLOR _color_ok
      _ok := .T.
   ELSE
      @ _x, Col() + 1 SAY "ERROR !" COLOR _color_err
   ENDIF

   IF _ok

      log_write( "backup company kreiran uspjesno: " + ::backup_path + ::backup_filename, 6 )

      IF !Empty( ::removable_drive )
         ++ _x
         @ _x, _y SAY "Prebacujem backup na udaljenu lokaciju ... "

         IF ::backup_to_removable()
            @ _x, Col() SAY "OK" COLOR _color_ok
         ELSE
            @ _x, Col() SAY "ERROR" COLOR _color_err
         ENDIF
      ENDIF

   ENDIF

   ++ _x

   FOR nI := 10 TO 1 STEP -1
      @ _x, _y SAY "... izlazim za " + PadL( AllTrim( Str( nI ) ), 2 ) + " sekundi"
      Sleep( 1 )
   NEXT

   RETURN _ok


METHOD F18Backup:Backup_server()

   LOCAL _ok := .F.
   LOCAL _cmd := ""
   LOCAL _server_params := my_server_params()
   LOCAL _host := _server_params[ "host" ]
   LOCAL _port := _server_params[ "port" ]
   LOCAL _database := _server_params[ "database" ]
   LOCAL _admin_user := "admin"
   LOCAL _x := 7
   LOCAL _y := 2
   LOCAL nI, _backup_file
   LOCAL _line := Replicate( "-", 70 )
   LOCAL _color_ok := "W+/B+"
   LOCAL _color_err := "W+/R+"

   ::get_backup_filename()
   ::get_windows_ping_time()
   ::get_removable_drive()

   FErase( ::backup_path + ::backup_filename )
   Sleep( 1 )

#ifdef __PLATFORM__UNIX
   _cmd += "export pgusername=admin;export PGPASSWORD=boutpgmin;"
#endif

#ifdef __PLATFORM__WINDOWS
   _cmd += "set pgusername=admin&set PGPASSWORD=boutpgmin&"

   IF ::ping_time > 0
      // dodaj ping na komandu za backup radi ENV varijabli
      _cmd += "ping -n " + AllTrim( Str( ::ping_time ) ) + " 8.8.8.8&"
   ENDIF

#endif

   _backup_file := ::backup_path + ::backup_filename

#ifdef __PLATFORM__WINDOWS
   _backup_file := StrTran( _backup_file, "\", "//" )
#endif

   _cmd += "pg_dumpall"
   _cmd += " -h " + AllTrim( _host )
   _cmd += " -p " + AllTrim( Str( _port ) )
   _cmd += " -U " + AllTrim( _admin_user )
   _cmd += " -w "
   _cmd += ' -f "' + _backup_file + '"'

   @ _x, _y SAY8 "Obavještenje: nakon pokretanja procedure backup-a slobodno se prebacite"
   ++_x
   @ _x, _y SAY8 "              na prozor aplikacije i nastavite raditi."
   ++ _x
   @ _x, _y SAY _line
   ++ _x
   @ _x, _y SAY8 "Backup podataka u toku...."
   ++ _x
   @ _x, _y SAY Replicate( "=", 70 )
   ++ _x
   @ _x, _y SAY "   Lokacija backup-a: " + ::backup_path
   ++ _x
   @ _x, _y SAY "Naziv fajla backup-a: " + ::backup_filename
   ++ _x
   ++ _x
   @ _x, _y SAY8 "očekujem rezulat operacije... "

#ifdef __PLATFORM__WINDOWS
   f18_run( _cmd )
#else
   hb_run( _cmd )
#endif

   IF File( ::backup_path + ::backup_filename )
      @ _x, Col() + 1 SAY "OK" COLOR _color_ok
      _ok := .T.
   ELSE
      @ _x, Col() + 1 SAY "ERROR !" COLOR _color_err
   ENDIF

   IF _ok

      log_write( "backup kreiran uspjesno: " + ::backup_path + ::backup_filename, 6 )

      IF !Empty( ::removable_drive )
         ++ _x
         @ _x, _y SAY "Prebacujem backup na udaljenu lokaciju ... "

         IF ::backup_to_removable()
            @ _x, Col() SAY "OK" COLOR _color_ok
         ELSE
            @ _x, Col() SAY "ERROR" COLOR _color_err
         ENDIF

      ENDIF
   ENDIF

   ++ _x

   FOR nI := 10 TO 1 STEP -1
      @ _x, _y SAY "... izlazim za " + PadL( AllTrim( Str( nI ) ), 2 ) + " sekundi"
      Sleep( 1 )
   NEXT

   RETURN _ok


METHOD F18Backup:backup_to_removable()

   LOCAL _ok := .F.
   LOCAL _res

   IF Empty( ::removable_drive )
      RETURN _ok
   ENDIF

   _res := FileCopy( ::backup_path + ::backup_filename, ::removable_drive + ::backup_filename )
   Sleep( 1 )

   IF !File( ::removable_drive + ::backup_filename )
   ELSE
      log_write( "backup to removable drive ok", 6 )
      _ok := .T.
   ENDIF

   RETURN _ok


METHOD F18Backup:get_windows_ping_time()

   ::ping_time := fetch_metric( "backup_windows_ping_time", my_user(), 0 )

   RETURN .T.


METHOD F18Backup:get_removable_drive()

   ::removable_drive := fetch_metric( "backup_removable_drive", my_user(), "" )

   RETURN .T.

METHOD F18Backup:get_backup_path()

   LOCAL _path
   LOCAL _database

   if ::backup_type == 0
      set_f18_home_backup()
      ::backup_path := my_home_backup()
   ELSE
      _database := my_server_params()[ "database" ]
      set_f18_home_backup( _database )
      ::backup_path := my_home_backup()
   ENDIF

   RETURN .T.


METHOD F18Backup:get_backup_filename()

   LOCAL _name
   LOCAL _tmp
   LOCAL _server_params := my_server_params()
   LOCAL nI

   _tmp := "server"

   if ::backup_type == 1
      _tmp := AllTrim( _server_params[ "database" ] )
   ENDIF

   FOR nI := 1 TO 99

      _name := _tmp + "_" + DToC( Date() ) + "_" + PadL( AllTrim( Str( nI ) ), 2, "0" ) + ".backup"

      IF !File( ::backup_path + _name )
         EXIT
      ENDIF

   NEXT

   ::backup_filename := _name

   RETURN _name


METHOD F18Backup:get_backup_interval()

   LOCAL _param := "backup_company_interval"

   if ::backup_type == 0
      _param := "backup_server_interval"
   ENDIF

   ::backup_interval := fetch_metric( _param, my_user(), 0 )

   RETURN .T.


METHOD F18Backup:get_backup_type( backup_type )

   LOCAL _type := 1
   LOCAL _x := 1
   LOCAL _y := 2
   LOCAL _s_line := Replicate( "-", 60 )
   LOCAL _d_line := Replicate( "=", 60 )

   IF backup_type == NIL

      @ _x, _y SAY "*** BACKUP procedura *** " + DToC( Date() )

      ++ _x
      @ _x, _y SAY _d_line

      ++ _x
      @ _x, _y SAY "Dostupne opcije:"

      ++ _x
      @ _x, _y SAY8 "   1 - backup tekuće firme"

      ++ _x
      @ _x, _y SAY "   0 - backup kompletnog servera"

      ++ _x
      @ _x, _y SAY8 "Vaš odabir:" GET _type VALID _type >= 0 PICT "9"

      ++ _x
      @ _x, _y SAY _s_line

      READ

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF

   ELSE
      _type := backup_type
   ENDIF

   ::backup_type := _type

   RETURN .T.


// ---------------------------------------------------------
// backup locking system
// ---------------------------------------------------------
METHOD F18Backup:Lock()

   set_metric( "f18_my_backup_lock_status", my_user(), 1 )

   RETURN .T.


METHOD F18Backup:unlock()

   set_metric( "f18_my_backup_lock_status", my_user(), 0 )

   RETURN .T.


METHOD F18Backup:locked( info )

   LOCAL _ret := .F.
   LOCAL _lock := fetch_metric( "f18_my_backup_lock_status", my_user(), 0 )

   IF info == NIL
      info := .F.
   ENDIF

   IF _lock > 0

      IF info
         MsgBeep( "Operacija backup-a vec pokrenuta !#Prekidam operaciju !" )
      ENDIF

      _ret := .T.

   ENDIF

   RETURN _ret


// ---------------------------------------------------------
// set/get backup date
// ---------------------------------------------------------
METHOD F18Backup:set_last_backup_date()

   LOCAL _type := "company"

   if ::backup_type == 0
      _type := "server"
   ENDIF

   set_metric( "f18_backup_date_" + _type, my_user(), Date() )

   RETURN .T.


METHOD F18Backup:get_last_backup_date()

   LOCAL _type := "company"

   if ::backup_type == 0
      _type := "server"
   ENDIF

   ::last_backup := fetch_metric( "f18_backup_date_" + _type, my_user(), CToD( "" ) )

   RETURN

// ------------------------------------------------
// poziv backupa podataka sa menija...
// ------------------------------------------------
FUNCTION f18_backup_data()

   hb_threadStart( @thread_f18_backup(), NIL )

   RETURN .T.

// ------------------------------------------------
// poziv backupa podataka automatski...
// jednostavno napravimo pozive
//
// f18_auto_backup_data(0)
// f18_auto_backup_data(1)
//
// ------------------------------------------------
FUNCTION f18_auto_backup_data( backup_type_def, start_now )

   LOCAL oBackup
   LOCAL _curr_date := Date()
   LOCAL _last_backup

   IF backup_type_def == NIL
      backup_type_def := 1
   ENDIF

   IF start_now == NIL
      start_now := .F.
   ENDIF

   oBackup := F18Backup():New()
   oBackup:get_backup_type( backup_type_def )
   oBackup:get_backup_interval()
   oBackup:get_last_backup_date()

   // nemam sta raditi ako ovaj interval ne postoji !
   IF !start_now .AND. oBackup:backup_interval == 0
      RETURN .F.
   ENDIF

   // uslov za backup nije zadovoljen...
   IF ( !start_now .AND. ( _curr_date - oBackup:backup_interval ) > oBackup:last_backup ) .OR. start_now
      hb_threadStart( @thread_f18_backup(), backup_type_def )
   ENDIF

   RETURN .T.


PROCEDURE thread_f18_backup( type_def )

   LOCAL oBackup
   LOCAL auto_backup := .T.

   init_parameters_cache()
   set_global_vars_0()

   _w := hb_gtCreate( f18_gt() )


   IF type_def == NIL
      auto_backup := .F.
   ENDIF

   hb_gtSelect( _w )
   hb_gtReload( _w )




   // podesi boje...
   _set_color()

   oBackup := F18Backup():New()

   IF oBackup:get_backup_type( type_def )

      oBackup:get_backup_path()
      oBackup:get_backup_interval()
      oBackup:Backup_now( auto_backup ) // pokreni backup

      QUIT_1

   ENDIF

   RETURN .T.


STATIC FUNCTION _set_color()

   LOCAL _color := F18_COLOR_BACKUP

   SetColor( _color )
   CLEAR SCREEN

   RETURN .T.
