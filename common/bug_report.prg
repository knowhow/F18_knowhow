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

   LOCAL _i, _err_code
   LOCAL _out_file
   LOCAL _msg, _log_msg := "BUG REPORT: "
   LOCAL lNotify := .F.

   hb_default( @lQuitApp, .T. )
   hb_default( @lShowErrorReport, .T. )

   IF !lShowErrorReport
      lNotify := .T.
   ENDIF

   _err_code := err_obj:genCode

   BEEP( 5 )
   _out_file := my_home_root() + "error.txt"

   PTxtSekvence()

   SET CONSOLE OFF
   SET PRINTER OFF
   SET DEVICE TO PRINTER
   SET PRINTER to ( _out_file )
   SET PRINTER ON

   P_12CPI

   ? Replicate( "=", 84 )
   ? "F18 bug report (v3.2) :", Date(), Time()
   ? Replicate( "=", 84 )

   _msg := "Verzija programa: " + F18_VER + " " + F18_VER_DATE + " " + FMK_LIB_VER
   ? _msg

   _log_msg += _msg

   ?

   _msg := "SubSystem/severity    : " + err_obj:SubSystem + " " + to_str( err_obj:severity )
   ? _msg
   _log_msg += " ; " + _msg

   _msg := "GenCod/SubCode/OsCode : " + to_str( err_obj:GenCode ) + " " + to_str( err_obj:SubCode ) + " " + to_str( err_obj:OsCode )
   ? _msg
   _log_msg += " ; " + _msg

   _msg := "Opis                  : " + err_obj:description
   ? _msg
   _log_msg += " ; " + _msg

   _msg := "ImeFajla              : " + err_obj:filename
   ? _msg
   _log_msg += " ; " + _msg


   _msg := "Operacija             : " + err_obj:operation
   ? _msg
   _log_msg += " ; " + _msg

   _msg := "Argumenti             : " + to_str( err_obj:args )
   ? _msg
   _log_msg += " ; " + _msg

   _msg := "canRetry/canDefault   : " + to_str( err_obj:canRetry ) + " " + to_str( err_obj:canDefault )
   ? _msg
   _log_msg += " ; " + _msg

   ?
   _msg := "CALL STACK:"
   ? _msg
   _log_msg += " ; " + _msg

   ? "---", Replicate( "-", 80 )
   FOR _i := 1 TO 30
      IF !Empty( ProcName( _i ) )
         _msg := Str( _i, 3 ) + " " + ProcName( _i ) + " / " + AllTrim( Str( ProcLine( _i ), 6 ) )
         ? _msg
         _log_msg += " ; " + _msg
      ENDIF
   NEXT
   ? "---", Replicate( "-", 80 )
   ?

   IF ! no_sql_mode()
      server_connection_info()
      server_db_version_info()
      server_info()
   ENDIF

   IF Used()
      current_dbf_info()
   ELSE
      _msg := "USED() = false"
   ENDIF

   ? _msg
   _log_msg += " ; " + _msg


   IF err_obj:cargo <> NIL

      ? "== CARGO", Replicate( "=", 50 )
      FOR _i := 1 TO Len( err_obj:cargo )
         IF err_obj:cargo[ _i ] == "var"
            _msg :=  "* var " + to_str( err_obj:cargo[ ++_i ] )  + " : " + to_str( pp( err_obj:cargo[ ++_i ] ) )
            ? _msg
            _log_msg += " ; " + _msg
         ENDIF
      NEXT
      ? Replicate( "-", 60 )

   ENDIF

   ? "== END OF BUG REPORT =="

   SET DEVICE TO SCREEN
   SET PRINTER OFF
   SET PRINTER TO
   SET CONSOLE ON

   my_close_all_dbf()

   log_write( _log_msg, 1 )

   IF lShowErrorReport
      _cmd := "f18_editor " + _out_file
      f18_run( _cmd )
   ENDIF

   send_email( err_obj, lNotify )

   IF lQuitApp
      QUIT_1
   ENDIF

   RETURN



STATIC FUNCTION server_info()

   LOCAL _key
   LOCAL _server_vars := { "server_version", "TimeZone" }
   LOCAL _sys_info

   ?
   ? "/---------- BEGIN PostgreSQL vars --------/"
   ?
   FOR EACH _key in _server_vars
      ? PadR( _key, 25 ) + ":",  server_show( _key )
   NEXT
   ?

   ? "/----------  END PostgreSQL vars --------/"
   ?
   _sys_info := server_sys_info()

   IF _sys_info != NIL
      ?
      ? "/-------- BEGIN PostgreSQL sys info --------/"
      FOR EACH _key in _sys_info:Keys
         ? PadR( _key, 25 ) + ":",  _sys_info[ _key ]
      NEXT
      ?
      ? "/-------  END PostgreSQL sys info --------/"
      ?
   ENDIF

   RETURN .T.



STATIC FUNCTION server_connection_info()

   ?
   ? "/----- SERVER connection info: ---------- /"
   ?
   ? "host/database/port/schema :", my_server_params()[ "host" ] + " / " + my_server_params()[ "database" ] + " / " +  AllTrim( Str( my_server_params()[ "port" ], 0 ) ) + " / " +  my_server_params()[ "schema" ]
   ? "                     user :", my_server_params()[ "user" ]
   ?

   RETURN .T.



STATIC FUNCTION server_db_version_info()

   LOCAL _server_db_num, _server_db_str, _f18_required_server_str, _f18_required_server_num

   _f18_required_server_num := get_version_num( SERVER_DB_VER_MAJOR, SERVER_DB_VER_MINOR, SERVER_DB_VER_PATCH )

   _server_db_num := server_db_version()

   _f18_required_server_str := get_version_str( _f18_required_server_num )
   _server_db_str := get_version_str( _server_db_num )

   ? "F18 client required server db >=     :", _f18_required_server_str, "/", AllTrim( Str( _f18_required_server_num, 0 ) )
   ? "Actual knowhow ERP server db version :", _server_db_str, "/", AllTrim( Str( _server_db_num, 0 ) )

   RETURN .T.




STATIC FUNCTION current_dbf_info()

   LOCAL _struct, _i

   ? "Trenutno radno podrucje:", Alias(),", record:", RecNo(), "/", RecCount()

   _struct := dbStruct()

   ? Replicate( "-", 60 )
   ? "Record content:"
   ? Replicate( "-", 60 )
   FOR _i := 1 TO Len( _struct )
      ? Str( _i, 3 ), PadR( _struct[ _i, 1 ], 15 ), _struct[ _i, 2 ], _struct[ _i, 3 ], _struct[ _i, 4 ], Eval( FieldBlock( _struct[ _i, 1 ] ) )
   NEXT
   ? Replicate( "-", 60 )

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

   _subject += F18_VER
   _subject += ", " + my_server_params()["database"] + "/" + ALLTRIM( f18_user() )
   _subject += ", " + DTOC( DATE() ) + " " + PADR( TIME(), 8 )

   IF err_obj != NIL
         _subject += ", " + ALLTRIM( err_obj:description ) + "/" + ALLTRIM( err_obj:operation )
   ENDIF

   _body := "U prilogu zip fajl sa sadržajem trenutne greške i log fajlom servera"

   _mail_params := email_hash_za_podrska_bring_out( _subject, _body )

   _attachment := send_email_attachment()

   if VALTYPE( _attachment ) == "L"
         RETURN .F.
   endif

   _attach := { _attachment }

   MsgO( "Šaljem izvještaj greške podršci bring.out ..." )

   f18_email_send( _mail_params, _attach )

   MsgC()

   FERASE( _attachment )

   RETURN .T.



STATIC FUNCTION send_email_attachment()

   LOCAL _a_files := {}
   LOCAL _path := my_home_root()
   LOCAL _server := my_server_params()
   LOCAL _filename, _err
   LOCAL _log_file, _log_params
   LOCAL _error_file := "error.txt"

   _filename := ALLTRIM( _server["database"] )
   _filename += "_" + ALLTRIM( f18_user() )
   _filename += "_" + DTOS( DATE() )
   _filename += "_" + STRTRAN( TIME(), ":", "" )
   _filename += ".zip"

   _log_params := hb_hash()
   _log_params["date_from"] := DATE()
   _log_params["date_to"] := DATE()
   _log_params["limit"] := 1000
   _log_params["conds_true"] := ""
   _log_params["conds_false"] := ""
   _log_params["doc_oper"] := "N"
   _log_file := f18_view_log( _log_params )

   AADD( _a_files, _error_file )
   AADD( _a_files, _log_file )

   DirChange( _path )

   _err := zip_files( _path, _filename, _a_files )

   DirChange( my_home() )

   if _err <> 0
        RETURN .F.
   endif

   RETURN ( _path + _filename )




FUNCTION notify_podrska( cErrorMsg )

   LOCAL oErr

   oErr := ErrorNew()
   oErr:severity := ES_ERROR
   oErr:genCode := EG_OPEN
   oErr:subSystem := "F18"
   oErr:subCode := 1000
   oErr:Description := cErrorMsg

   EVAL( ErrorBlock(), oErr, .F., .F. )

   RETURN .T.
