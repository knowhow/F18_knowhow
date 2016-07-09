/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

FUNCTION usex( cTable )
   RETURN my_use( cTable )


// --------------------------------------------------
// kreira direktorij ako ne postoji
// --------------------------------------------------
FUNCTION f18_create_dir( cLocation )

   LOCAL _len
   LOCAL _loc
   LOCAL _create

   _loc := cLocation + "*.*"

   _loc := file_path_quote( cLocation + "*.*" )

   _len := ADir( _loc )

   IF _len == 0

      _create := DirMake( cLocation )

      IF _create <> 0
         log_write( "f18_create_dir, problem sa kreiranjem direktorija: " + cLocation, 5 )
      ENDIF

   ENDIF

   RETURN .T.



FUNCTION f18_help()

   ? "F18 parametri"
   ? "parametri"
   ? "-h hostname (default: localhost)"
   ? "-y port (default: 5432)"
   ? "-u user (default: root)"
   ? "-p password (default no password)"
   ? "-d name of database to use"
   ? "-e schema (default: public)"
   ? "-t fmk tables path"
   ? ""

   RETURN .T.

/*
 setup ulazne parametre F18
*/

FUNCTION set_f18_params()

   LOCAL _i := 1


   cParams := "" // setuj ulazne parametre

   DO WHILE _i <= PCount()


      cTok := hb_PValue( _i++ ) // ucitaj parametar


      DO CASE

      CASE cTok == "--no-sql"
         no_sql_mode( .T. )

      CASE cTok == "--test"
         test_mode( .T. )

      CASE cTok == "--help"
         f18_help()
         QUIT_1

      CASE cTok == "--dbf-prefix"   // prefix privatni dbf

          dbf_prefix( hb_PValue( _i++ ) )


      CASE cTok == "-h"
         cHostName := hb_PValue( _i++ )
         cParams += Space( 1 ) + "hostname=" + cHostName

      CASE cTok == "-y"
         nPort := Val( hb_PValue( _i++ ) )
         cParams += Space( 1 ) + "port=" + AllTrim( Str( nPort ) )

      CASE cTok == "-d"
         cDataBase := hb_PValue( _i++ )
         cParams += Space( 1 ) + "database=" + cDatabase

      CASE cTok == "-u"
         cUser := hb_PValue( _i++ )
         cParams += Space( 1 ) + "user=" + cUser

      CASE cTok == "-p"
         cPassWord := hb_PValue( _i++ )
         cParams += Space( 1 ) + "password=" + cPassword

      CASE cTok == "-t"
         cDBFDataPath := hb_PValue( _i++ )
         cParams += Space( 1 ) + "dbf data path=" + cDBFDataPath

      CASE cTok == "-e"
         cSchema := hb_PValue( _i++ )
         cParams += Space( 1 ) + "schema=" + cSchema
      ENDCASE



   ENDDO

   RETURN .T.



FUNCTION pp( x )

   LOCAL _key, _i
   LOCAL _tmp
   LOCAL _type

   _tmp := ""

   _type := ValType( x )

   IF _type == "H"
      _tmp += "(hash): "
      FOR EACH _key in x:Keys
         _tmp +=  pp( _key ) + " / " + pp( x[ _key ] ) + " ; "
      NEXT
      RETURN _tmp
   ENDIF

   IF _type  == "A"
      _tmp += "(array): "
      FOR _i := 1 TO Len( x )
         _tmp +=  AllTrim( pp( _i ) ) + " / " + pp( x[ _i ] ) + " ; "
      NEXT
      RETURN _tmp
   ENDIF

   IF _type $ "CLDNM"
      RETURN hb_ValToStr( x )
   ENDIF

   RETURN "?" + _type + "?"



// --------------------------------------
// aktiviranje vpn podrske
// --------------------------------------
FUNCTION vpn_support( set_params )

   LOCAL _conn_name := PadR( "bringout podrska", 50 )
   LOCAL _status := 0
   LOCAL _ok

#ifdef __PLATFORM__WINDOWS

   MsgBeep( "Opcija nije omogucena !" )

   RETURN
#endif

IF set_params == NIL
set_params := .T.
ENDIF

IF set_params
_conn_name := fetch_metric( "vpn_support_conn_name", my_user(), _conn_name )
_status := fetch_metric( "vpn_support_last_status", my_user(), _status )
ELSE
_status := 1
ENDIF

IF set_params

IF _status == 0
_status := 1
ELSE
_status := 0
ENDIF

Box(, 2, 65 )
@ m_x + 1, m_y + 2 SAY "Konekcija:" GET _conn_name PICT "@S50" VALID !Empty( _conn_name )
@ m_x + 2, m_y + 2 SAY "[1] aktivirati [0] prekinuti" GET _status PICT "9"
READ
BoxC()

IF LastKey() == K_ESC
RETURN
ENDIF

ENDIF

IF set_params
set_metric( "vpn_support_conn_name", my_user(), _conn_name )
ENDIF

// startaj vpn konekciju
_ok := _vpn_start_stop( _status, _conn_name )

// ako je sve ok snimi parametar u bazu
IF _ok == 0 .AND. set_params
set_metric( "vpn_support_last_status", my_user(), _status )
ENDIF

   RETURN



// ------------------------------------------------
// stopira ili starta vpn konekciju
// status : 0 - off, 1 - on
// ------------------------------------------------
STATIC FUNCTION _vpn_start_stop( status, conn_name )

   LOCAL _cmd
   LOCAL _err
   LOCAL _up_dn := "up"

   IF status == 0
      _up_dn := "down"
   ENDIF

   _cmd := 'nmcli con ' + _up_dn + ' id "' + AllTrim( conn_name ) + '"'

   _err := f18_run( _cmd )

   IF _err <> 0
      MsgBeep( "Problem sa vpn konekcijom:#" + AllTrim( conn_name ) + " !???" )
      RETURN _err
   ENDIF

   RETURN _err




FUNCTION f18_copy_to_desktop( file_path, file_name, output_file )

   LOCAL _desktop_path

   create_f18_dokumenti_on_desktop( @_desktop_path )

   IF output_file == NIL
      output_file := ""
   ENDIF

   IF Empty( output_file )
      output_file := file_name
   ENDIF

   FileCopy( file_path + file_name, _desktop_path + output_file )

   RETURN




FUNCTION create_f18_dokumenti_on_desktop( desktop_path )

   LOCAL _home_path
   LOCAL _desk_path := ""
   LOCAL _desk_folder := "F18_dokumenti"
   LOCAL _cre

#ifdef __PLATFORM__WINDOWS

   _home_path := hb_DirSepAdd( GetEnv( "USERPROFILE" ) )
   _desk_path := _home_path + "Desktop" + SLASH
#else
   _home_path := hb_DirSepAdd( GetEnv( "HOME" ) )
   _desk_path := _home_path + "Desktop" + SLASH
   IF DirChange( _desk_path ) != 0
      _desk_path := _home_path + "Radna površ" + SLASH
   ENDIF
#endif

   desktop_path := _desk_path + _desk_folder + SLASH

   IF DirChange( '"' + desktop_path + '"' ) != 0
      _cre := MakeDir( desktop_path )
   ENDIF

   DirChange( my_home() )

   RETURN .T.
