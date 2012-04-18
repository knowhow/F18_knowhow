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

#include "fmk.ch"

static __output_odt
static __output_name := "out.odt"
static __xml_file
static __xml_name := "data.xml"


// -------------------------------------------------------------------
// generisanje odt reporta putem jodreports
//
// - template - naziv template fajla (npr. f_01.odt)
// - xml_file - putanja + naziv fajla (npr. c:/data.xml)
// - output_file - putanja + naziv fajla (npr. c:/out.odt)
// - test_mode - testiranje opcije, samo za windows
//
// -------------------------------------------------------------------
function f18_odt_generate( template, xml_file, output_file, test_mode )
local _ok := .f.
local _template
local _screen
local _cmd, _java_start, _jod_bin
local _error

// xml fajl
if ( xml_file == NIL )
    __xml_file := my_home() + __xml_name
else
    __xml_file := xml_file
endif

// output fajl
if ( output_file == NIL )
    __output_odt := my_home() + __output_name
else
    __output_odt := output_file
endif

// testni rezim
if ( test_mode == NIL )
    test_mode := .f.
endif

// kopiranje template fajla...
if !FILE( my_home() + template )
    if FILE( F18_TEMPLATE_LOCATION + template )
        FileCopy( F18_TEMPLATE_LOCATION + template, my_home() + template )
    else
        log_write( "ODT report gen: " + F18_TEMPLATE_LOCATION + template + " ne postoji." )
        MsgBeep( "Fajl " + F18_TEMPLATE_LOCATION + template + " ne postoji !???" )
        return _ok
    endif
endif

// prije generisanja pobrisi prošli izlazni fajl...
FERASE( __output_odt )
log_write( "ODT report gen: pobrisao fajl " + __output_odt )

// ovo ce nam biti template lokcija
_template := my_home() + template

// uzmi sada parametre...
_java_start := ALLTRIM( fetch_metric( "java_start_cmd", my_user(), "" ) )
_jod_bin := ALLTRIM( fetch_metric( "jodreports_bin", my_user(), "" ) )

// provjeri da li postoje ?
if EMPTY( _java_start ) .or. EMPTY( _jod_bin )
    MsgBeep( "Nisu podeseni parametri jod-reports... ?!??" )
    return _ok
endif

// postoji li jodreports-cli.jar ?
if !FILE( ALLTRIM(_jod_bin) )
    log_write( "ODT report gen: " + _jod_bin + " ne postoji na lokaciji !")
    MsgBeep( "Aplikacija " + _jod_bin + " ne postoji !" )
    return _ok
endif

log_write( "ODT report gen: java cmd - " + _java_start )
log_write( "ODT report gen: jod bin - " + _jod_bin )

// na windows masinama moramo radi DOS-a dodati ove navodnike
#ifdef __PLATFORM__WINDOWS
    _template := '"' + _template + '"'
    __xml_file := '"' + __xml_file + '"'
    __output_odt := '"' + __output_odt + '"'
    _jod_bin := '"' + _jod_bin + '"'
#endif

// slozi mi komandu za generisanje...
_cmd := _java_start + " " + _jod_bin + " " 
_cmd += _template + " "
_cmd += __xml_file + " "
_cmd += __output_odt

#ifdef __PLATFORM__WINDOWS
    if test_mode
        _cmd += " & pause"
    endif
#endif

log_write( "ODT report gen, cmd: " + _cmd )

SAVE SCREEN TO _screen
CLEAR SCREEN

? "Generisanje ODT reporta u toku..."

// pokreni generisanje reporta
_error := hb_run( _cmd )

RESTORE SCREEN FROM _screen

if _error <> 0
    log_write( "ODT report gen: greška - " + ALLTRIM( STR( _error )))
    MsgBeep( "Doslo je do greske prilikom generisanja reporta... !!!#" + "Greska: " + ALLTRIM(STR( _error )) )
    return _ok
endif

// sve je ok
_ok := .t.

return _ok


// -------------------------------------------------------------------
// stampanje odt fajla
//
// - output_file - naziv fajla za prikaz (npr. c:/out.odt)
// - from_params - .t. ili .f. pokreni odt report na osnovu parametara
// - test_mode - .t. ili .f., testiranje komande - samo windows
// -------------------------------------------------------------------
function f18_odt_print( output_file, from_params, test_mode )
local _ok := .f.
local _cmd 
local _oo_bin, _oo_writer, _oo_line
local _screen, _error

if ( output_file == NIL )
    __output_odt := my_home() + __output_name
else
    __output_odt := output_file
endif

if ( from_params == NIL )
    from_params := .f.
endif

if ( test_mode == NIL )
    test_mode := .f.
endif

if !FILE( __output_odt )
    MsgBeep( "Nema fajla za prikaz !!!!" )
    return _ok
endif

_oo_bin := ALLTRIM( fetch_metric( "openoffice_bin", my_user(), "" ) )
_oo_writer := ALLTRIM( fetch_metric( "openoffice_writer", my_user(), "" ) )
_oo_line := _oo_bin + _oo_writer

// ako je windows sredi mi sa navodnicima
#ifdef __PLATFORM__WINDOWS
    __output_odt := '"' + __output_odt + '"'
    _oo_line := '"' + _oo_line + '"'
#endif

// slozi mi komadnu za startanje...
_cmd := ""

#ifdef __PLATFORM__UNIX

    // platforme osx, linux
    if from_params 
        _cmd += _oo_line + " " + __output_odt
    else
		#ifdef __PLATFORM__DARWIN
        	_cmd += "open " + __output_odt
		#else
			_cmd += "xdg-open " + __output_odt
		#endif
    endif

#else __PLATFORM__WINDOWS

    if from_params
        _cmd += _oo_line + " " + __output_odt 
    else
        _cmd += __output_odt
    endif

    if test_mode
        _cmd += " & pause"
    endif

#endif

SAVE SCREEN TO _screen
CLEAR SCREEN

? "Prikaz odt fajla u toku..."

// pokreni komandu
log_write(_cmd)

_error := hb_run( _cmd )

RESTORE SCREEN FROM _screen

if _error <> 0
    MsgBeep( "Problem sa pokretanjem odt reporta !!!!#Greska: " + ALLTRIM(STR( _error )) )
    return _error
endif

// sve ok
_ok := .t.

return _ok



