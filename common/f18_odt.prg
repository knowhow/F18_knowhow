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
static __output_pdf
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
_ok := _copy_odt_template( template )
if !_ok
	return _ok
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


// -----------------------------------------------------------------
// kopiranje odt template fajla
// -----------------------------------------------------------------
static function _copy_odt_template( template )
local _ret := .f.
local _a_source, _a_template
local _src_size, _src_date, _src_time
local _temp_size, _temp_date, _temp_time
local _copy := .f.

if !FILE( my_home() + template )
	_copy := .t.
else
	
	// fajl postoji na lokaciji
	// ispitaj velicinu, datum vrijeme...
	_a_source := DIRECTORY( my_home() + template )
	_a_template := DIRECTORY( F18_TEMPLATE_LOCATION + template ) 	

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
	// fajl ne postoji na lokaciji !!! kopiraj ga
    if FILE( F18_TEMPLATE_LOCATION + template )
        FileCopy( F18_TEMPLATE_LOCATION + template, my_home() + template )
    else
        MsgBeep( "Fajl " + F18_TEMPLATE_LOCATION + template + " ne postoji !???" )
        return _ret
    endif
endif

_ret := .t.

return _ret 



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
			_cmd += "xdg-open " + __output_odt + "&"
		#endif
    endif

#else __PLATFORM__WINDOWS

    if from_params
        _cmd += _oo_line + " " + __output_odt 
    else
        _cmd += "c:\knowhowERP\util\start.exe /m "  + __output_odt 
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


// ------------------------------------------------------
// otvaranje dokumenta na osnovu ekstenzije
// ------------------------------------------------------
function f18_open_mime_document( document )
local _cmd := ""

#ifdef __PLATFORM__UNIX

	#ifdef __PLATFORM__DARWIN
        	_cmd += "open " + document
	#else
			_cmd += "xdg-open " + document + " &"
	#endif

#else __PLATFORM__WINDOWS

    document := '"' + document + '"'
    _cmd += "c:\knowhowERP\util\start.exe /m " + document

#endif

_error := hb_run( _cmd )

if _error <> 0
    MsgBeep( "Problem sa otvaranjem dokumenta !!!!#Greska: " + ALLTRIM(STR( _error )) )
    return _error
endif

return 0



// ------------------------------------------------------------------
// konvertovanje odt fajla u pdf
// 
// koristi se jodreports util: jodconverter-cli.jar
// java -jar jodconverter-cli.jar input_file_odt output_file_pdf
// ------------------------------------------------------------------
function f18_convert_odt_to_pdf( input_file, output_file, overwrite_file )
local _ret := .f.
local _converter := "jodconverter-cli.jar"
local _conv_util
local _cmd
local _java_start, _jod_bin, _screen, _error

// input fajl
if ( input_file == NIL )
    __output_odt := my_home() + __output_name
else
    __output_odt := input_file
endif

// output fajl
if ( output_file == NIL )
	__output_pdf := my_home() + STRTRAN( __output_name, ".odt", ".pdf" )
else
	__output_pdf := output_file
endif

// overwrite izlaznog fajla
if ( overwrite_file == NIL )
	overwrite_file := .t.
endif

// konverter
#ifdef __PLATFORM__WINDOWS
	_conv_util := "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH + _converter
	__output_odt := '"' + __output_odt + '"'
	__output_pdf := '"' + __output_pdf + '"'
#else
	_conv_util := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH + _converter
#endif

// provjeri izlazni fajl
_ret := _check_out_pdf( @__output_pdf, overwrite_file )

if !_ret
	return _ret
endif  

// uzmi sada parametre...
_java_start := ALLTRIM( fetch_metric( "java_start_cmd", my_user(), "" ) )
_jod_bin := ALLTRIM( fetch_metric( "jodconverter_bin", my_user(), "" ) )

// provjeri da li postoje ?
if EMPTY( _java_start ) .or. EMPTY( _jod_bin )
    MsgBeep( "Nisu podeseni parametri jod-converter... ?!??" )
    return _ret
endif

// postoji li jodreports-cli.jar ?
if !FILE( ALLTRIM( _jod_bin ) )
    log_write( "ODT report conv: " + _jod_bin + " ne postoji na lokaciji !")
    MsgBeep( "Aplikacija " + _jod_bin + " ne postoji !" )
    return _ret
endif

log_write( "ODT report convert start" )

// na windows masinama moramo radi DOS-a dodati ove navodnike
#ifdef __PLATFORM__WINDOWS
    _jod_bin := '"' + _jod_bin + '"'
#endif

// slozi mi komandu za generisanje...
_cmd := _java_start + " " + _jod_bin + " " 
_cmd += __output_odt + " "
_cmd += __output_pdf

log_write( "ODT report convert, cmd: " + _cmd )

SAVE SCREEN TO _screen
CLEAR SCREEN

? "Konvertovanje ODT dokumenta u toku..."

// pokreni generisanje reporta
_error := hb_run( _cmd )

RESTORE SCREEN FROM _screen
 
if _error <> 0
    log_write( "ODT report convert: greška - " + ALLTRIM( STR( _error )))
    MsgBeep( "Doslo je do greske prilikom konvertovanja dokumenta... !!!#" + "Greska: " + ALLTRIM(STR( _error )) )
    return _ret
endif

_ret := .t.

return _ret



// ----------------------------------------------------------------
// provjera izlaznog fajla
// ----------------------------------------------------------------
static function _check_out_pdf( out_file, overwrite )
local _ret := .f.
local _i, _ext, _tmp, _wo_ext

if ( overwrite == NIL )
	overwrite := .t.
endif

// u slucaju overwrite-a
if overwrite
	FERASE( out_file )
	_ret := .t.
	return _ret
endif

// ekstenzija fajla
_ext := RIGHT( ALLTRIM( out_file ), 4 )

// fajl bez ekstenzije
_wo_ext := LEFT( ALLTRIM( out_file ), LEN( ALLTRIM( out_file) ) - LEN( _ext ) )

// vidi da dodaš neki sufiks
for _i := 1 to 99
	
	_tmp := _wo_ext + PADL( ALLTRIM(STR(_i)), 2, "0" ) + _ext

	if !FILE( _tmp )

		// imamo novi izlazni fajl
		out_file := _tmp

		exit

	endif

next

return _ret



