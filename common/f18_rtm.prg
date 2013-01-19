/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

static _f18_delphi_exe := "f18_delphirb.exe"
static _f18_label_exe := "f18_labeliranje.exe"


// ------------------------------------------------------------
// stampa rtm reporta kroz delphirb
//
// - rtm_file - naziv rtm fajla
// - table_name - naziv tabele koju otvara
// - table_index - naziv indeksa koji otvara tabelu
// - test_mode .t. ili .f., default .f. - testni rezim komande
// ------------------------------------------------------------
function f18_rtm_print( rtm_file, table_name, table_index, test_mode, rtm_mode )
local _cmd
local _ok := .f.
local _delphi_exe := "delphirb.exe"
local _label_exe := "labeliranje.exe"
local _util_path
local _error

#ifdef __PLATFORM__UNIX
	_f18_delphi_exe := "delphirb"
	_f18_label_exe := "labeliranje"
#endif

// provjera uslova

if ( rtm_file == NIL )
    MsgBeep( "Nije zadat rtm fajl !!!" )
    return _ok
endif 

if ( table_name == NIL )
    table_name := ""
endif

if ( table_index == NIL )
    table_index := ""
endif

if ( test_mode == NIL )
    test_mode := .f.
endif

if ( rtm_mode == NIL )
    rtm_mode := "drb"
endif

// provjeri treba li kopirati delphirb.exe ?
if !copy_delphirb_exe( rtm_mode )
    // sigurno ima neka greska... pa izadji
    return _ok
endif

// provjeri treba li kopirati template fajl
if !copy_rtm_template( rtm_file )
    // sigurno postoji opet neka greska...
    return _ok
endif

// ovdje treba kod za filovanje datoteke IZLAZ.DBF
if Pitanje(, "Stampati delphirb report ?", "D" ) == "N"
    // ne zelimo stampati report...
    return _ok
endif

// idemo na slaganje komande za report

_cmd := ""

#ifdef __PLATFORM__UNIX
	_cmd += SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#endif

if rtm_mode == "drb"
    _cmd += _f18_delphi_exe
else
    _cmd += _f18_label_exe
endif

_cmd += " "
_cmd += rtm_file
_cmd += " "
    
#ifdef __PLATFORM__WINDOWS
    _cmd += "." + SLASH
#else
    _cmd += my_home()
#endif
    
if !EMPTY( table_name )

    // dodaj i naziv tabele i index na komandu
    _cmd += " "
    _cmd += table_name
    _cmd += " "
    _cmd += table_index

endif

#ifdef __PLATFORM__UNIX
	_cmd += " "
	_cmd += "&"
#endif

#ifdef __PLATFORM__WINDOWS
    if test_mode
        _cmd += " & pause"
    endif
#endif
 
// pozicioniraj se na home direktorij tokom izvrsenja
DirChange( my_home() )

log_write( "delphirb/label print, cmd: " + _cmd, 7 )

_error := f18_run( _cmd )
    
if _error <> 0
    MsgBeep("Postoji problem sa stampom#Greska: " + ALLTRIM(STR( _error )) )
    return _ok
endif

// sve je ok
_ok := .t.

return _ok



// --------------------------------------------------
// kopira delphirb.exe u home/f18_delphirb.exe
// --------------------------------------------------
static function copy_delphirb_exe( mode )
local _ok := .t.
local _util_path
local _drb := "delphirb.exe"
local _lab := "labeliranje.exe"
local _exe, _tmp

if mode == NIL
    mode := "drb"
endif

if mode == "drb"
    _exe := _f18_delphi_exe
    _tmp := _drb
else
    _exe := _f18_label_exe
    _tmp := _lab
endif

// util path...
#ifdef __PLATFORM__WINDOWS
    _util_path := "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#else
    _util_path := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
	return _ok
#endif

// kopiraj delphirb u home path
if !FILE( my_home() + _exe )
    if !FILE( _util_path + _tmp )
        MsgBeep( "Fajl " + _util_path + _tmp + " ne postoji !????" )
        _ok := .f.
        return _ok
    else
        FILECOPY( _util_path + _tmp, my_home() + _exe )
    endif
endif

return _ok


// ---------------------------------------------------------
// kopiranje template fajla u home direktorij
//
// napomena: template = "nalplac", bez ekstenzije
// ---------------------------------------------------------
static function copy_rtm_template( template )
local _ret := .f.
local _rtm_ext := ".rtm"
local _a_source, _a_template
local _src_size, _src_date, _src_time
local _temp_size, _temp_date, _temp_time
local _copy := .f.


if !FILE( my_home() + template + _rtm_ext )
	_copy := .t.
else
	
	// fajl postoji na lokaciji
	// ispitaj velicinu, datum vrijeme...
	_a_source := DIRECTORY( my_home() + template + _rtm_ext )
	_a_template := DIRECTORY( F18_TEMPLATE_LOCATION + template + _rtm_ext ) 	

	// datum, vrijeme, velicina
	_src_size := ALLTRIM( STR( _a_source[1, 2] ) )
	_src_date := DTOS( _a_source[1, 3] )
	_src_time := _a_source[1, 4]

	_temp_size := ALLTRIM( STR( _a_template[1, 2] ) )
	_temp_date := DTOS( _a_template[1, 3] )
	_temp_time := _a_template[1, 4]

	// treba ga kopirati
	if _temp_date + _temp_time > _src_date + _src_time
		_copy := .t.
	endif

endif

// treba ga kopirati
if _copy

    if !FILE( F18_TEMPLATE_LOCATION + template + _rtm_ext )
        MsgBeep( "Fajl " + F18_TEMPLATE_LOCATION + template + _rtm_ext + " ne postoji !????" )
        return _ret
    else
        FILECOPY( F18_TEMPLATE_LOCATION + template + _rtm_ext, my_home() + template + _rtm_ext )
    endif

endif

_ret := .t.

return _ret



