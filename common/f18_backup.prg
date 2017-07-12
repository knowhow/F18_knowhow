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

STATIC s_pGT, s_pMainGT

CLASS F18Backup

   METHOD New()

   METHOD do_backup()

   METHOD backup_organizacija()
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
   DATA nBackupType
   DATA last_backup
   DATA removable_drive
   DATA ping_time

ENDCLASS





FUNCTION f18_backup_data()

   hb_threadStart( @thread_f18_backup(), NIL )

   RETURN .T.


PROCEDURE thread_f18_backup( nBackupTipOrgIliSve )

   LOCAL oBackup
   LOCAL lAutoBackup := .T.

   DO WHILE !open_thread( "f18_backup" )
      ?E "ERROR open_thread f18_backup"
   ENDDO

   // MsgBeep( "start     ============" )
   // Alert("ok")
   hb_idleSleep( 0.5 )
   // info_bar( "b2", "b2 start")
   // hb_idleSleep( 10 )
   // MsgBeep( "-------------------------end" )
   // info_bar( "b2", "   b2 end")
   // hb_idleSleep( 3 )
   // IF .T.
   // close_thread( "f18_backup" )
   // RETURN
   // ENDIF

   IF nBackupTipOrgIliSve == NIL
      lAutoBackup := .F.
   ENDIF

   // init_parameters_cache()

   set_global_vars_0()

   oBackup := F18Backup():New()

   // IF is_terminal()
   s_pGT := hb_gtCreate( f18_gt_background() )
   s_pMainGT := hb_gtSelect( s_pGT )

/*
   ELSE
      s_pGT := hb_gtCreate( f18_gt() )
      s_pMainGT := hb_gtSelect( s_pGT )
      hb_gtReload( s_pGT )
      _set_color()
   ENDIF
*/

   IF !lAutoBackup
      oBackup:get_backup_type( nBackupTipOrgIliSve )
   ENDIF
   oBackup:get_backup_interval()
   oBackup:get_last_backup_date()

   // IF !start_now .AND.
   IF oBackup:backup_interval == 0 // nemam sta raditi ako ovaj interval ne postoji !
      hb_gtSelect( s_pMainGt )
      info_bar( "backup", "backup 0" )
      // hb_idleSleep( 0.5 )
      RETURN
   ENDIF

   IF ( Date() - oBackup:backup_interval ) <= oBackup:last_backup
      hb_gtSelect( s_pMainGt )
      info_bar( "backup", "backup <interval" )
      RETURN
   ENDIF

   IF oBackup:get_backup_type( nBackupTipOrgIliSve )
      oBackup:get_backup_path()
      oBackup:get_backup_interval()
      oBackup:do_backup( lAutoBackup ) // pokreni backup
   ENDIF

   // IF is_terminal()
   hb_gtSelect( s_pMainGt )
   // ENDIF

   info_bar( "backup", "backup END :)" )
   // hb_idleSleep( 0.5 )
   close_thread( "f18_backup" )
   // QUIT_1

   RETURN


METHOD F18Backup:New()

   ::backup_interval := 0
   ::last_backup := CToD( "" )
   ::removable_drive := ""
   ::ping_time := 0
   info_bar( "backup", "backup start" )

   RETURN SELF


METHOD F18Backup:backup_in_progress_info()

   LOCAL cTxt

   cTxt := "Operacija backup-a u toku. Pokusajte ponovo..."

   RETURN cTxt



METHOD F18Backup:do_backup( lAuto )

   LOCAL pMainGT

   IF lAuto == NIL
      lAuto := .T.
   ENDIF

   // da li je backup vec pokrenut ?
   IF ::locked( .T. )
      // IF !is_terminal() .AND.

      IF Pitanje(, "Napravi unlock backup operacije (D/N)?", "N" ) == "N"
         RETURN .F.
      ENDIF
   ELSE
      ::Lock() // zakljucaj opciju backup-a da je samo jedan korisnik radi
   ENDIF



   IF ::nBackupType == 1
      ::backup_organizacija()
   ELSE
      ::Backup_server()
   ENDIF


   IF lAuto
      ::set_last_backup_date()   // setuj datum kreiranja backup-a
   ENDIF

   ::unlock()  // otkljucaj nakon sto je backup napravljen

   RETURN .T.


METHOD F18Backup:backup_organizacija()

   LOCAL lOk := .F.
   LOCAL cCmd := ""
   LOCAL _server_params := my_server_params()
   LOCAL _host := _server_params[ "host" ]
   LOCAL _port := _server_params[ "port" ]
   LOCAL _database := _server_params[ "database" ]
   LOCAL _admin_user := "admin"
   LOCAL nX := 7
   LOCAL nY := 2
   LOCAL nI, _backup_file
   LOCAL _color_ok := F18_COLOR_BACKUP_OK
   LOCAL _color_err := F18_COLOR_BACKUP_ERROR
   LOCAL _line := Replicate( "-", 70 )

   ::get_backup_filename()
   ::get_windows_ping_time()
   ::get_removable_drive()

   IF is_windows()
      cCmd += "set pgusername=" + f18_user() + "&set PGPASSWORD=" + f18_password() + "&"
   ELSE
      cCmd += "export pgusername=" + f18_user() + ";export PGPASSWORD=" + f18_password() + ";"
   ENDIF

#ifdef __PLATFORM__WINDOWS

   IF ::ping_time > 0
      cCmd += "ping -n " + AllTrim( Str( ::ping_time ) ) + " 8.8.8.8&"
   ENDIF

#endif

   _backup_file := ::backup_path + ::backup_filename

#ifdef __PLATFORM__WINDOWS
   _backup_file := StrTran( _backup_file, "\", "//" )
#endif

   cCmd += "pg_dump"
   cCmd += " -h " + AllTrim( _host )
   cCmd += " -p " + AllTrim( Str( _port ) )
   cCmd += " -U " + AllTrim( _admin_user )
   cCmd += " -w "
   cCmd += " -F c "
   cCmd += " -b "
   cCmd += ' -f "' + _backup_file + '"'
   cCmd += ' "' + _database + '"'

   FErase( ::backup_path + ::backup_filename )

   // IF is_terminal()
   info_bar( "back", "backup u toku .. " + Right( ::backup_path + ::backup_filename, 60 ) )

/*
   ELSE

      Sleep( 1 )
      @ nX, nY SAY8 "Obavještenje: nakon pokretanja procedure backup-a slobodno se prebacite"
      ++nX
      @ nX, nY SAY "              na prozor aplikacije i nastavite raditi."
      ++nX
      @ nX, nY SAY _line
      ++nX
      @ nX, nY SAY "Backup podataka u toku...."
      ++nX
      @ nX, nY SAY _line
      ++nX
      @ nX, nY SAY "   Lokacija backup-a: " + ::backup_path
      ++nX
      @ nX, nY SAY "Naziv fajla backup-a: " + ::backup_filename

      ++nX
      ++nX
      @ nX, nY SAY8 "očekujem rezulat operacije... "

   ENDIF
*/

   hb_run_in_background_gt( cCmd )

// IF is_terminal()

   IF File( ::backup_path + ::backup_filename )
      info_bar( "backup", ::backup_path + ::backup_filename + " OK" )

      IF !Empty( ::removable_drive )
         IF ::backup_to_removable()
            info_bar( "backup", "prenos na " + ::removable_drive + " OK" )
         ELSE
            error_bar( "backup", "prenos na " + ::removable_drive + " ERR" )
         ENDIF
      ENDIF
   ELSE
      info_bar( "backup", ::backup_path + ::backup_filename + " ERROR" )
   ENDIF

/*
   ELSE // gui - prikaz informacija u prozoru

      IF File( ::backup_path + ::backup_filename )
         @ nX, Col() + 1 SAY "OK" COLOR _color_ok
         lOk := .T.
      ELSE
         @ nX, Col() + 1 SAY "ERROR !" COLOR _color_err
      ENDIF

      IF lOk

         log_write( "backup company kreiran uspjesno: " + ::backup_path + ::backup_filename, 6 )

         IF !Empty( ::removable_drive )
            ++nX
            @ nX, nY SAY "Prebacujem backup na udaljenu lokaciju ... "

            IF ::backup_to_removable()
               @ nX, Col() SAY "OK" COLOR _color_ok
            ELSE
               @ nX, Col() SAY "ERROR" COLOR _color_err
            ENDIF
         ENDIF

      ENDIF

      ++nX

      FOR nI := 10 TO 1 STEP -1
         @ nX, nY SAY "... izlazim za " + PadL( AllTrim( Str( nI ) ), 2 ) + " sekundi"
         Sleep( 1 )
      NEXT

   ENDIF
*/

   RETURN lOk


METHOD F18Backup:Backup_server()

   LOCAL lOk := .F.
   LOCAL cCmd := ""
   LOCAL _server_params := my_server_params()
   LOCAL _host := _server_params[ "host" ]
   LOCAL _port := _server_params[ "port" ]
   LOCAL _database := _server_params[ "database" ]
   LOCAL _admin_user := "admin"
   LOCAL nX := 7
   LOCAL nY := 2
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
   cCmd += "export pgusername=admin;export PGPASSWORD=boutpgmin;"
#endif

#ifdef __PLATFORM__WINDOWS
   cCmd += "set pgusername=admin&set PGPASSWORD=boutpgmin&"

   IF ::ping_time > 0
      // dodaj ping na komandu za backup radi ENV varijabli
      cCmd += "ping -n " + AllTrim( Str( ::ping_time ) ) + " 8.8.8.8&"
   ENDIF

#endif

   _backup_file := ::backup_path + ::backup_filename

#ifdef __PLATFORM__WINDOWS
   _backup_file := StrTran( _backup_file, "\", "//" )
#endif

   cCmd += "pg_dumpall"
   cCmd += " -h " + AllTrim( _host )
   cCmd += " -p " + AllTrim( Str( _port ) )
   cCmd += " -U " + AllTrim( _admin_user )
   cCmd += " -w "
   cCmd += ' -f "' + _backup_file + '"'

/*
   IF !is_terminal()
      @ nX, nY SAY8 "Obavještenje: nakon pokretanja procedure backup-a slobodno se prebacite"
      ++nX
      @ nX, nY SAY8 "              na prozor aplikacije i nastavite raditi."
      ++nX
      @ nX, nY SAY _line
      ++nX
      @ nX, nY SAY8 "Backup podataka u toku...."
      ++nX
      @ nX, nY SAY Replicate( "=", 70 )
      ++nX
      @ nX, nY SAY "   Lokacija backup-a: " + ::backup_path
      ++nX
      @ nX, nY SAY "Naziv fajla backup-a: " + ::backup_filename
      ++nX
      ++nX
      @ nX, nY SAY8 "očekujem rezulat operacije... "
   ENDIF
*/

   hb_run_in_background_gt( cCmd )

// IF is_terminal()

   IF File( ::backup_path + ::backup_filename )
      info_bar( "backup", ::backup_path + ::backup_filename + " OK" )

      IF !Empty( ::removable_drive )
         IF ::backup_to_removable()
            info_bar( "backup", "prenos na " + ::removable_drive + " OK" )
         ELSE
            error_bar( "backup", "prenos na " + ::removable_drive + " ERR" )
         ENDIF
      ENDIF
   ELSE
      info_bar( "backup", ::backup_path + ::backup_filename + " ERROR" )
   ENDIF

/*
   ELSE
      IF File( ::backup_path + ::backup_filename )
         @ nX, Col() + 1 SAY "OK" COLOR _color_ok
         lOk := .T.
      ELSE
         @ nX, Col() + 1 SAY "ERROR !" COLOR _color_err
      ENDIF

      IF lOk
         log_write( "backup kreiran uspjesno: " + ::backup_path + ::backup_filename, 6 )

         IF !Empty( ::removable_drive )
            ++nX
            @ nX, nY SAY "Prebacujem backup na udaljenu lokaciju ... "

            IF ::backup_to_removable()
               @ nX, Col() SAY "OK" COLOR _color_ok
            ELSE
               @ nX, Col() SAY "ERROR" COLOR _color_err
            ENDIF

         ENDIF
      ENDIF

      ++nX

      FOR nI := 10 TO 1 STEP -1
         @ nX, nY SAY "... izlazim za " + PadL( AllTrim( Str( nI ) ), 2 ) + " sekundi"
         Sleep( 1 )
      NEXT

   ENDIF
*/

   RETURN lOk


METHOD F18Backup:backup_to_removable()

   LOCAL lOk := .F.
   LOCAL _res

   IF Empty( ::removable_drive )
      RETURN lOk
   ENDIF

   _res := FileCopy( ::backup_path + ::backup_filename, ::removable_drive + ::backup_filename )
   Sleep( 1 )

   IF !File( ::removable_drive + ::backup_filename )
   ELSE
      log_write( "backup to removable drive ok", 6 )
      lOk := .T.
   ENDIF

   RETURN lOk


METHOD F18Backup:get_windows_ping_time()

   ::ping_time := fetch_metric( "backup_windows_ping_time", my_user(), 0 )

   RETURN .T.


METHOD F18Backup:get_removable_drive()

   ::removable_drive := fetch_metric( "backup_removable_drive", my_user(), "" )

   RETURN .T.

METHOD F18Backup:get_backup_path()

   LOCAL _path
   LOCAL _database

   IF ::nBackupType == 0
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

   IF ::nBackupType == 1
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

   IF ::nBackupType == 0
      _param := "backup_server_interval"
   ENDIF

   ::backup_interval := fetch_metric( _param, my_user(), 0 )

   RETURN .T.


METHOD F18Backup:get_backup_type( nBackupType )

   LOCAL _type := 1
   LOCAL nX := 1
   LOCAL nY := 2
   LOCAL _s_line := Replicate( "-", 60 )
   LOCAL _d_line := Replicate( "=", 60 )

   IF nBackupType == NIL

      @ nX, nY SAY "*** BACKUP procedura *** " + DToC( Date() )

      ++nX
      @ nX, nY SAY _d_line
      ++nX
      @ nX, nY SAY "Dostupne opcije:"
      ++nX
      @ nX, nY SAY8 "   1 - backup tekuće firme"
      ++nX
      @ nX, nY SAY "   0 - backup kompletnog servera"
      ++nX
      @ nX, nY SAY8 "Vaš odabir:" GET _type VALID _type >= 0 PICT "9"

      ++nX
      @ nX, nY SAY _s_line

      READ

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF

   ELSE
      _type := nBackupType
   ENDIF

   ::nBackupType := _type

   RETURN .T.


METHOD F18Backup:Lock()

   set_metric( "f18_backup_lock_status", my_user(), 1 )

   RETURN .T.


METHOD F18Backup:unlock()

   set_metric( "f18_backup_lock_status", my_user(), 0 )

   RETURN .T.


METHOD F18Backup:locked( lInfo )

   LOCAL lRet := .F.
   LOCAL _lock := fetch_metric( "f18_backup_lock_status", my_user(), 0 )

   IF lInfo == NIL
      lInfo := .F.
   ENDIF

   IF _lock > 0

      IF lInfo
         MsgBeep( "Operacija backup-a vec pokrenuta !#Prekidam operaciju !" )
      ENDIF

      lRet := .T.

   ENDIF

   RETURN lRet



METHOD F18Backup:set_last_backup_date()

   LOCAL _type := "company"

   IF ::nBackupType == 0
      _type := "server"
   ENDIF

   ?E "set", "f18_backup_date_" + _type, my_user(), Date()
   ?E set_metric( "f18_backup_date_" + _type, my_user(), Date() )

   RETURN .T.


METHOD F18Backup:get_last_backup_date()

   LOCAL _type := "company"

   IF ::nBackupType == 0
      _type := "server"
   ENDIF

   ::last_backup := fetch_metric( "f18_backup_date_" + _type, my_user(), CToD( "" ) )
   ?E "get ", "f18_backup_date_" + _type, my_user(), ::last_backup

   RETURN .T.



FUNCTION f18_gt_background()
   RETURN "NUL"

STATIC FUNCTION hb_run_in_background_gt( cCmd )

   LOCAL nRet

   IF is_terminal()
      hb_gtSelect( s_pGT )
   ENDIF

   nRet := hb_run( cCmd )
   ?E "RET=", nRet, cCmd

   IF is_terminal()
      hb_gtSelect( s_pMainGT )
   ENDIF

   RETURN nRet


STATIC FUNCTION _set_color()

   LOCAL _color := F18_COLOR_BACKUP

   SetColor( _color )
   CLEAR SCREEN

   RETURN .T.
