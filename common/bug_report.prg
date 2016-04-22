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


FUNCTION GlobalErrorHandler( err_obj, lShowErrorReport, lQuitApp )

   LOCAL _i, _cmd
   LOCAL _out_file
   LOCAL _msg, cLogMsg := "BUG REPORT: "
   LOCAL lNotify := .F.
   LOCAL bErr
   LOCAL nI, cMsg

   IF err_obj:GenCode == 45 .AND. err_obj:SubCode == 1302
   /*
   Verzija programa: 1.7.770 13.03.2016 8.5.0

   SubSystem/severity    : BASE          2
   GenCod/SubCode/OsCode :         45       1302          0
   Opis                  : Object destructor failure
   ImeFajla              :
   Operacija             : Reference to freed block
   Argumenti             : _?_
   canRetry/canDefault   : .f. .f.

   CALL STACK:
   --- --------------------------------------------------------------------------------
   BUG REPORT: Verzija programa: 1.7.770 13.03.2016 8.5.0 ; SubSystem/severity    : BASE          2 ; GenCod/SubCode/OsCode :         45       1302          0 ; Opis                  : Object destructor failure ; ImeFajla              :  ; Operacija             : Reference to freed block ; Argumenti             : _?_ ; canRetry/canDefault   : .f. .f. ; CALL STACK:
      1 (b)F18_ERROR_BLOCK / 66
      2 INKEY / 0
      3 MY_DB_EDIT / 157
      4 FIN_KNJIZENJE_NALOGA / 123
      5 FIN_UNOS_NALOGA / 36
      6 (b)TFINMOD_PROGRAMSKI_MODUL_OSNOVNI_MENI / 51
      7 F18_MENU / 61
      8 TFINMOD:PROGRAMSKI_MODUL_OSNOVNI_MENI / 81
      9 TFINMOD:MMENU / 38
     10 TFINMOD:RUN / 126
   */

      bErr := ErrorBlock( {| oError | Break( oError ) } )

      LOG_CALL_STACK cLogMsg
      ?E "ERR Object destructor failure/Reference to freed block 45/1302", cLogMsg

      ErrorBlock( bErr )
      RETURN .T.
   ENDIF

   bErr := ErrorBlock( {| oError | Break( oError ) } )

   hb_default( @lQuitApp, .T. )
   hb_default( @lShowErrorReport, .T. )

   IF !lShowErrorReport
      lNotify := .T.
   ELSE
      Beep( 5 )
   ENDIF

   _out_file := my_home_root() + "error.txt"

   IF is_in_main_thread()
#ifdef F18_DEBUG
      Alert( err_obj:Description + " " + err_obj:operation )
      AltD() // err_obj:Description
#endif

      SET CONSOLE OFF
      SET PRINTER OFF
      SET DEVICE TO PRINTER
      SET PRINTER to ( _out_file )
      SET PRINTER ON
      P_12CPI

   ENDIF

   OutBug()
   OutBug( "F18 bug report (v6.0) :", Date(), Time() )
   OutBug( Replicate( "=", 84 ) )

   _msg := "Verzija programa: " + f18_ver( .F. )
   OutBug( _msg )

   cLogMsg += _msg
   OutBug()

   _msg := "SubSystem/severity    : " + err_obj:SubSystem + " " + to_str( err_obj:severity )
   OutBug( _msg )
   cLogMsg += " ; " + _msg

   _msg := "GenCod/SubCode/OsCode : " + to_str( err_obj:GenCode ) + " " + to_str( err_obj:SubCode ) + " " + to_str( err_obj:OsCode )
   OutBug( _msg )
   cLogMsg += " ; " + _msg

   _msg := "Opis                  : " + err_obj:description
   OutBug( _msg )
   cLogMsg += " ; " + _msg

   _msg := "ImeFajla              : " + err_obj:filename
   OutBug( _msg )
   cLogMsg += " ; " + _msg


   _msg := "Operacija             : " + err_obj:operation
   OutBug( _msg )
   cLogMsg += " ; " + _msg

   _msg := "Argumenti             : " + to_str( err_obj:args )
   OutBug( _msg )
   cLogMsg += " ; " + _msg

   _msg := "canRetry/canDefault   : " + to_str( err_obj:canRetry ) + " " + to_str( err_obj:canDefault )
   OutBug( _msg )
   cLogMsg += " ; " + _msg

   OutBug()
   _msg := "CALL STACK:"
   OutBug( _msg )
   cLogMsg += " ; " + _msg

   OutBug( "---", Replicate( "-", 80 ) )
   LOG_CALL_STACK cLogMsg
   OutBug( StrTran( cLogMsg, "//", hb_eol() ) )
   OutBug( "---", Replicate( "-", 80 ) )
   OutBug()


   IF hb_HHasKey( my_server_params(), "host" ) .AND. !no_sql_mode()
      server_connection_info()
      server_db_version_info()
      server_info()
   ENDIF

   IF Used()
      current_dbf_info()
   ELSE
      _msg := "USED() = false"
   ENDIF

   OutBug( _msg )
   cLogMsg += " ; " + _msg

   IF err_obj:cargo <> NIL

      OutBug( "== CARGO", Replicate( "=", 50 ) )
      FOR _i := 1 TO Len( err_obj:cargo )
         IF err_obj:cargo[ _i ] == "var"
            _msg :=  "* var " + to_str( err_obj:cargo[ ++_i ] )  + " : " + to_str( pp( err_obj:cargo[ ++_i ] ) )
            ? _msg
            cLogMsg += " ; " + _msg
         ENDIF
      NEXT
      OutBug( Replicate( "-", 60 ) )

   ENDIF

   OutBug( "== END OF BUG REPORT ==" )

   my_close_all_dbf()

   IF is_in_main_thread()
      SET DEVICE TO SCREEN
      SET PRINTER OFF
      SET PRINTER TO
      SET CONSOLE ON
      IF lShowErrorReport
         _cmd := "f18_editor " + _out_file
         f18_run( _cmd )
      ENDIF
      log_write( cLogMsg, 1 )
#ifndef F18_DEBUG
      send_email( err_obj, lNotify )
#endif
   ENDIF

   IF lQuitApp
      QUIT_1
   ENDIF

   ErrorBlock( bErr )

   RETURN .T.



FUNCTION OutBug( ... )

   IF is_in_main_thread()
      QOut( ... )
   ELSE
      OutErr( ..., hb_eol() )
   ENDIF

   RETURN .T.

STATIC FUNCTION server_info()

   LOCAL _key
   LOCAL _server_vars := { "server_version", "TimeZone" }
   LOCAL _sys_info

   OutBug()
   OutBug( "/---------- BEGIN PostgreSQL vars --------/" )
   OutBug()
   FOR EACH _key in _server_vars
      OutBug( PadR( _key, 25 ) + ":",  server_show( _key ) )
   NEXT
   OutBug()

   OutBug( "/----------  END PostgreSQL vars --------/" )
   OutBug()
   _sys_info := server_sys_info()

   IF _sys_info != NIL
      OutBug()
      OutBug( "/-------- BEGIN PostgreSQL sys info --------/" )
      FOR EACH _key in _sys_info:Keys
         OutBug( PadR( _key, 25 ) + ":",  _sys_info[ _key ] )
      NEXT
      OutBug()
      OutBug( "/-------  END PostgreSQL sys info --------/" )
      OutBug()
   ENDIF

   RETURN .T.



STATIC FUNCTION server_connection_info()

   LOCAL hParams := my_server_params()

   IF !hb_HHasKey( hParams, "host" )
      RETURN .F.
   ENDIF

   OutBug()
   OutBug( "/----- SERVER connection info: ---------- /" )
   OutBug()
   OutBug( "host/database/port/schema :", my_server_params()[ "host" ] + " / " + my_server_params()[ "database" ] + " / " +  AllTrim( Str( my_server_params()[ "port" ], 0 ) ) + " / " +  my_server_params()[ "schema" ] )
   OutBug( "                     user :", my_server_params()[ "user" ] )
   OutBug()

   RETURN .T.



STATIC FUNCTION server_db_version_info()

   LOCAL _server_db_num, _server_db_str, _f18_required_server_str, _f18_required_server_num

   _f18_required_server_num := get_version_num( SERVER_DB_VER_MAJOR, SERVER_DB_VER_MINOR, SERVER_DB_VER_PATCH )

   _server_db_num := server_db_version()

   _f18_required_server_str := get_version_str( _f18_required_server_num )
   _server_db_str := get_version_str( _server_db_num )

   OutBug( "F18 client required server db >=     :", _f18_required_server_str, "/", AllTrim( Str( _f18_required_server_num, 0 ) ) )
   OutBug( "Actual knowhow ERP server db version :", _server_db_str, "/", AllTrim( Str( _server_db_num, 0 ) ) )

   RETURN .T.




STATIC FUNCTION current_dbf_info()

   LOCAL _struct, _i

   OutBug( "Trenutno radno podrucje:", Alias(), ", record:", RecNo(), "/", RecCount() )

   _struct := dbStruct()

   OutBug( Replicate( "-", 60 ) )
   OutBug( "Record content:" )
   OutBug( Replicate( "-", 60 ) )
   FOR _i := 1 TO Len( _struct )
      OutBug( Str( _i, 3 ), PadR( _struct[ _i, 1 ], 15 ), _struct[ _i, 2 ], _struct[ _i, 3 ], _struct[ _i, 4 ], Eval( FieldBlock( _struct[ _i, 1 ] ) ) )
   NEXT
   OutBug( Replicate( "-", 60 ) )

   RETURN .T.




FUNCTION RaiseError( cErrMsg )

   LOCAL oErr

   oErr := ErrorNew()
   oErr:severity    := ES_ERROR
   oErr:genCode     := EG_OPEN
   oErr:subSystem   := "F18"
   oErr:SubCode     := 1000
   oErr:Description := cErrMsg

   Eval( ErrorBlock(), oErr )

   RETURN .T.




STATIC FUNCTION send_email( err_obj, lNotify )

   LOCAL _mail_params
   LOCAL _body, _subject
   LOCAL _attachment
   LOCAL _answ := fetch_metric( "bug_report_email", my_user(), "A" )
   LOCAL cDatabase
   LOCAL _attach

   IF lNotify == NIL
      lNotify := .F.
   ENDIF

   DO CASE
   CASE _answ $ "D#N#A"
      IF _answ $ "DN"
         IF Pitanje(, "Poslati poruku greške email-om podrški bring.out-a (D/N) ?", _answ ) == "N"
            RETURN .F.
         ENDIF
      ENDIF
   OTHERWISE
      RETURN .F.
   ENDCASE

   // BUG F18 1.7.21, rg_2013/bjasko, 02.04.04, 15:00:07, variable does not exist
   IF lNotify
      _subject := "NOTIFY F18 "
   ELSE
      _subject := "BUG F18 "
   ENDIF

   IF hb_HHasKey( my_server_params(), "database" )
      cDatabase := my_server_params()[ "database" ]
   ELSE
      cDatabase := "DBNOTDEFINED"
   ENDIF

   _subject += F18_VER
   _subject += ", " + cDatabase + "/" + AllTrim( f18_user() )
   _subject += ", " + DToC( Date() ) + " " + PadR( Time(), 8 )

   IF err_obj != NIL
      _subject += ", " + AllTrim( err_obj:description ) + "/" + AllTrim( err_obj:operation )
   ENDIF

   _body := "U prilogu zip fajl sa sadržajem trenutne greške i log fajlom servera"

   _mail_params := email_hash_za_podrska_bring_out( _subject, _body )

   _attachment := send_email_attachment()

   IF ValType( _attachment ) == "L"
      RETURN .F.
   ENDIF

   _attach := { _attachment }

   info_bar( "err-sync", "Slanje greške podršci bring.out ..." )

   f18_email_send( _mail_params, _attach )


   FErase( _attachment )

   RETURN .T.



STATIC FUNCTION send_email_attachment()

   LOCAL _a_files := {}
   LOCAL _path := my_home_root()
   LOCAL _server := my_server_params()
   LOCAL _filename, _err
   LOCAL _log_file, _log_params
   LOCAL _error_file := "error.txt"

   _filename := AllTrim( _server[ "database" ] )
   _filename += "_" + AllTrim( f18_user() )
   _filename += "_" + DToS( Date() )
   _filename += "_" + StrTran( Time(), ":", "" )
   _filename += ".zip"

   _log_params := hb_Hash()
   _log_params[ "date_from" ] := Date()
   _log_params[ "date_to" ] := Date()
   _log_params[ "limit" ] := 1000
   _log_params[ "conds_true" ] := ""
   _log_params[ "conds_false" ] := ""
   _log_params[ "doc_oper" ] := "N"
   _log_file := f18_view_log( _log_params )

   AAdd( _a_files, _error_file )
   AAdd( _a_files, _log_file )

   DirChange( _path )

   _err := zip_files( _path, _filename, _a_files )

   DirChange( my_home() )

   IF _err <> 0
      RETURN .F.
   ENDIF

   RETURN ( _path + _filename )




FUNCTION notify_podrska( cErrorMsg )

   LOCAL oErr

   oErr := ErrorNew()
   oErr:severity := ES_ERROR
   oErr:genCode := EG_OPEN
   oErr:subSystem := "F18"
   oErr:subCode := 1000
   oErr:Description := cErrorMsg

   Eval( ErrorBlock(), oErr, .F., .F. )

   RETURN .T.
