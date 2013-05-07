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

#include "fmk.ch"

function usex(cTable)
return my_use(cTable)


// --------------------------------------------------
// kreira direktorij ako ne postoji
// --------------------------------------------------
function f18_create_dir( location )
local _len
local _loc
local _create

_loc := location + "*.*"

_loc := _path_quote( location + "*.*" )

_len := ADIR( _loc )

if _len == 0

	_create := DIRMAKE( location )

	if _create <> 0
		log_write("f18_create_dir(), problem sa kreiranjem direktorija: " + location, 5 )
	endif	

endif

return

// -------------------------
// -------------------------
function f18_ime_dbf(alias)
local _pos, _a_dbf_rec

alias := FILEBASE(alias)

_a_dbf_rec := get_a_dbf_rec(alias, .t.)

alias := my_home() + _a_dbf_rec["table"] + "." + DBFEXT

return alias


// ---------------------------------------
// ---------------------------------------
function f18_help()
   
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

RETURN

/* --------------------------
 setup ulazne parametre F18
 -------------------------- */

function set_f18_params()
local _i := 1

// setuj ulazne parametre
cParams := ""

DO WHILE _i <= PCount()

    // ucitaj parametar
    cTok := hb_PValue( _i++ )
     
    
    DO CASE

      CASE cTok == "--no-sql"
	       no_sql_mode(.t.)

      CASE cTok == "--test"
           test_mode(.t.)
           
      CASE cTok == "--help"
          f18_help()
          QUIT

      CASE cTok == "-h"
         cHostName := hb_PValue( _i++ )
         cParams += SPACE(1) + "hostname=" + cHostName

      CASE cTok == "-y"
         nPort := Val( hb_PValue( _i++ ) )
         cParams += SPACE(1) + "port=" + ALLTRIM(STR(nPort))

      CASE cTok == "-d"
         cDataBase := hb_PValue( _i++ )
         cParams += SPACE(1) + "database=" + cDatabase

      CASE cTok == "-u"
         cUser := hb_PValue( _i++ )
         cParams += SPACE(1) + "user=" + cUser

      CASE cTok == "-p"
         cPassWord := hb_PValue( _i++ )
         cParams += SPACE(1) + "password=" + cPassword

      CASE cTok == "-t"
         cDBFDataPath := hb_PValue( _i++ )
         cParams += SPACE(1) + "dbf data path=" + cDBFDataPath

      CASE cTok == "-e"
         cSchema := hb_PValue( _i++ )
         cParams += SPACE(1) + "schema=" + cSchema
    ENDCASE

ENDDO

return

// --------------------------------------------------------------
// --------------------------------------------------------------
function pp(x)
local _key, _i
local _tmp
local _type

_tmp := ""

_type := VALTYPE(x)

if _type == "H"
  _tmp += "(hash): "
  FOR EACH _key in x:Keys
      _tmp +=  pp(_key) + " / " + pp(x[_key]) + " ; "
  NEXT
  return _tmp
endif

if _type  == "A"
  _tmp += "(array): "
  FOR _i := 1 to LEN(x)
      _tmp +=  ALLTRIM(pp(_i)) + " / " + pp(x[_i]) + " ; "
  NEXT
  return _tmp
endif

if _type $ "CLDN"
   return hb_ValToStr(x)
endif

return "?" + _type + "?"



// --------------------------------------
// aktiviranje vpn podrske 
// --------------------------------------
function vpn_support( set_params )
local _conn_name := PADR( "bringout podrska", 50 )
local _status := 0
local _ok

#ifdef __PLATFORM__WINDOWS 
    msgbeep("Opcija nije omogucena !")
    return
#endif

if set_params == NIL
    set_params := .t.
endif

if set_params
    _conn_name := fetch_metric( "vpn_support_conn_name", my_user(), _conn_name )
    _status := fetch_metric( "vpn_support_last_status", my_user(), _status )
else
    _status := 1
endif

if set_params

    if _status == 0
	    _status := 1
    else
	    _status := 0
    endif

    Box(, 2, 65 )
        @ m_x + 1, m_y + 2 SAY "Konekcija:" GET _conn_name PICT "@S50" VALID !EMPTY( _conn_name )
        @ m_x + 2, m_y + 2 SAY "[1] aktivirati [0] prekinuti" GET _status PICT "9"
        read
    BoxC()

    if LastKey() == K_ESC
        return
    endif

endif

if set_params
    set_metric( "vpn_support_conn_name", my_user(), _conn_name )
endif

// startaj vpn konekciju
_ok := _vpn_start_stop( _status, _conn_name )

// ako je sve ok snimi parametar u bazu
if _ok == 0 .and. set_params
	set_metric( "vpn_support_last_status", my_user(), _status )
endif

return



// ------------------------------------------------
// stopira ili starta vpn konekciju
// status : 0 - off, 1 - on
// ------------------------------------------------
static function _vpn_start_stop( status, conn_name )
local _cmd
local _err
local _up_dn := "up"

if status == 0
	_up_dn := "down"
endif

_cmd := 'nmcli con ' + _up_dn + ' id "' + ALLTRIM( conn_name ) + '"' 

_err := f18_run( _cmd )

if _err <> 0
    msgbeep( "Problem sa vpn konekcijom:#" + ALLTRIM( conn_name ) + " !???" )
    return _err
endif

return _err



// --------------------------------------------------
// kopiraj fajl na desktop
// --------------------------------------------------
function f18_copy_to_desktop( file_path, file_name, output_file )
local _desktop_path := ""
local _desktop_folder := "F18_dokumenti"
local _cre

if output_file == NIL
    output_file := ""
endif

#ifdef __PLATFORM__WINDOWS
    _desktop_path := hb_DirSepAdd( GetEnv( "USERPROFILE" ) ) + "Desktop" + SLASH
#else
    _desktop_path := hb_DirSepAdd( GetEnv( "HOME" ) ) + "Desktop" + SLASH
#endif

if DirChange( _desktop_path + _desktop_folder + SLASH ) != 0
    _cre := MakeDir( _desktop_path + _desktop_folder + SLASH )
endif

DirChange( my_home() )

if EMPTY( output_file )
    output_file := file_name
endif

FileCopy( file_path + file_name, _desktop_path + _desktop_folder + SLASH + output_file )

return


