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
#include "fileio.ch"

static __output_odt
static __output_pdf
static __jod_converter := "jodconverter-cli.jar"
static __jod_reports := "jodreports-cli.jar"
static __java_run_cmd := "java -Xmx128m -jar"
static __util_path
static __current_odt

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
local _cmd
local _error
local _util_path
local _jod_full_path

// xml fajl
if ( xml_file == NIL )
    __xml_file := my_home() + DATA_XML_FILE
else
    __xml_file := xml_file
endif

// output fajl
if ( output_file == NIL )
    __output_odt := my_home() + gen_random_odt_name()
else
    __output_odt := output_file
endif

// tekuci odt koji je generisan
__current_odt := __output_odt

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
delete_odt_files()

log_write( "ODT report gen: pobrisao fajl " + __output_odt, 7 )

// ovo ce nam biti template lokcija
_template := my_home() + template

// vraca util path za operativni sistem
__util_path := get_util_path()
// daj mi liniju jod utilitija
_jod_full_path := __util_path + __jod_reports

// postoji li jodreports-cli.jar ?
if !FILE( ALLTRIM( _jod_full_path ) )
    log_write( "ODT report gen: " + __jod_reports + " ne postoji na lokaciji !", 7 )
    MsgBeep( "Aplikacija " + __jod_reports + " ne postoji !" )
    return _ok
endif

// na windows masinama moramo radi DOS-a dodati ove navodnike
#ifdef __PLATFORM__WINDOWS
    _template := '"' + _template + '"'
    __xml_file := '"' + __xml_file + '"'
    __output_odt := '"' + __output_odt + '"'
    _jod_full_path := '"' + _jod_full_path + '"'
#endif

// slozi mi komandu za generisanje...
_cmd := __java_run_cmd + " " + _jod_full_path + " " 
_cmd += _template + " "
_cmd += __xml_file + " "
_cmd += __output_odt

log_write( "ODT report gen, cmd: " + _cmd, 7 )

SAVE SCREEN TO _screen
CLEAR SCREEN

? "Generisanje ODT reporta u toku ...  fajl: ..." + RIGHT( __current_odt, 20 )

// pokreni generisanje reporta, async = .f.
_error := f18_run(_cmd, NIL, NIL, .f.)
RESTORE SCREEN FROM _screen

if _error <> 0
    log_write( "ODT report gen: greška - " + ALLTRIM( STR( _error )), 7 )
    MsgBeep( "Doslo je do greske prilikom generisanja reporta... !!!#" + "Greska: " + ALLTRIM(STR( _error )) )
    return _ok
endif

// sve je ok
_ok := .t.

return _ok



// ---------------------------------------------------------
// generise random odt out file name
// ---------------------------------------------------------
static function gen_random_odt_name()
local _i
local _tmp := "out.odt"

for _i := 1 to 1000
    _tmp := "out_" + PADL( ALLTRIM( STR( _i ) ), 4, "0" ) + ".odt"
    if !FILE( my_home() + _tmp )
        exit
    endif
next

return _tmp




// -----------------------------------------------------------------
// brise odt fajlove 
// -----------------------------------------------------------------
static function delete_odt_files()
local _tmp
local _f_path

_f_path := my_home()
_tmp := "out_*.odt"

// lock fajl izgleda ovako
//.~lock.out_0001.odt#

AEVAL( DIRECTORY( _f_path + _tmp ), { | aFile | ;
        if( ;
            FILE( _f_path + ".~lock." + ALLTRIM( aFile[1]) + "#" ), ;
            .t., ;
            FERASE( _f_path + ALLTRIM( aFile[1]) ) ;
        ) ;
    })

sleep(1)

return




// ------------------------------------------------------------------
// vraca util path po operativnom sistemu
// ------------------------------------------------------------------
static function get_util_path()
local _path := ""

#ifdef __PLATFORM__WINDOWS
	_path := "c:" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#else
	_path := SLASH + "opt" + SLASH + "knowhowERP" + SLASH + "util" + SLASH
#endif

return _path



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
local _screen, _error := 0

if ( output_file == NIL )
    __output_odt := __current_odt
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

// ako je windows sredi mi sa navodnicima
#ifdef __PLATFORM__WINDOWS
    __output_odt := '"' + __output_odt + '"'
#endif

SAVE SCREEN TO _screen
CLEAR SCREEN

? "Prikaz odt fajla u toku ...   fajl: ..." + RIGHT( __current_odt, 20 )

#ifndef TEST
	_error := f18_open_document(__output_odt)
#endif

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

if Pitanje(, "Otvoriti " + ALLTRIM( document ) + " ?", "D" ) == "N"
    return 0
endif

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

_error := f18_run( _cmd )

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
local _jod_full_path, _util_path
local _cmd
local _screen, _error

// input fajl
if ( input_file == NIL )
    __output_odt := __current_odt
else
    __output_odt := input_file
endif

// output fajl
if ( output_file == NIL )
	__output_pdf := STRTRAN( __current_odt, ".odt", ".pdf" )
else
	__output_pdf := output_file
endif

// overwrite izlaznog fajla
if ( overwrite_file == NIL )
	overwrite_file := .t.
endif

// konverter
#ifdef __PLATFORM__WINDOWS
	__output_odt := '"' + __output_odt + '"'
	__output_pdf := '"' + __output_pdf + '"'
#endif

// provjeri izlazni fajl
_ret := _check_out_pdf( @__output_pdf, overwrite_file )
if !_ret
	return _ret
endif  

// daj mi path do util direktorija
_util_path := get_util_path()
// daj mi punu putanju jod-converter-a
_jod_full_path := _util_path + __jod_converter

// postoji li jodconverter-cli.jar ?
if !FILE( ALLTRIM( _jod_full_path ) )
    log_write( "ODT report conv: " + __jod_converter + " ne postoji na lokaciji !", 7 )
    MsgBeep( "Aplikacija " + __jod_converter + " ne postoji !" )
    return _ret
endif

log_write( "ODT report convert start", 9 )

// na windows masinama moramo radi DOS-a dodati ove navodnike
#ifdef __PLATFORM__WINDOWS
    _jod_full_path := '"' + _jod_full_path + '"'
#endif

// slozi mi komandu za generisanje...
_cmd := __java_run_cmd + " " + _jod_full_path + " " 
_cmd += __output_odt + " "
_cmd += __output_pdf

log_write( "ODT report convert, cmd: " + _cmd, 7 )

SAVE SCREEN TO _screen
CLEAR SCREEN

? "Konvertovanje ODT dokumenta u toku..."

// pokreni generisanje reporta
_error := f18_run( _cmd )

RESTORE SCREEN FROM _screen
 
if _error <> 0
    log_write( "ODT report convert: greška - " + ALLTRIM( STR( _error )), 7 )
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



