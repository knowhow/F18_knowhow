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

#include "fmk.ch"
#include "f18_ver.ch"

FUNCTION server_db_version()

   LOCAL _qry
   LOCAL _ret
   LOCAL _server := pg_server()

   _qry := "SELECT u2.knowhow_package_version('fmk')"

   _ret := _sql_query( _server, _qry )

   IF ValType( _ret ) == "L"
      RETURN -1
   ENDIF

   RETURN _ret:FieldGet( 1 )



FUNCTION check_server_db_version()

   LOCAL _server_db_num, _server_db_str, _f18_required_server_str, _f18_required_server_num
   LOCAL _msg

   _f18_required_server_num := get_version_num( SERVER_DB_VER_MAJOR, SERVER_DB_VER_MINOR, SERVER_DB_VER_PATCH )

   _server_db_num := server_db_version()

   IF ( _f18_required_server_num > _server_db_num )

      _f18_required_server_str := get_version_str( _f18_required_server_num )
      _server_db_str := get_version_str( _server_db_num )

      _msg := "F18 klijent trazi verziju " + _f18_required_server_str + " server db je verzije: " + _server_db_str

      log_write( _msg, 3 )

      MsgBeep( _msg )

      OutMsg( 1, _msg + hb_osNewLine() )
      //QUIT_1
   ENDIF

   RETURN .T.
