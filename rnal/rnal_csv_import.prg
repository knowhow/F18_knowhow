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
#include "hbclass.ch"
#include "common.ch"

CLASS RnalCsvImport

    DATA params
    
    VAR doc_no

    METHOD new()
    METHOD import()
   
    PROTECTED:

		METHOD get_article()    
		METHOD get_shape_type()    
        METHOD get_vars()
		METHOD csv_browse()
		METHOD csv_browse_key_handler()
		METHOD string_to_number()
    
ENDCLASS



// -----------------------------------------------------
// -----------------------------------------------------
METHOD RnalCsvImport:New( _doc_no )
::params := NIL
::doc_no := _doc_no
return self



// ----------------------------------------------------
// ----------------------------------------------------
METHOD RnalCsvImport:import()
local _ok := .f.
local oCsv
local _struct := {}
local _rec, _art_id, _qtty, _height, _width
local _count := 0

if ::params == NIL .and. !::get_vars()
    return _ok
endif

// sada ja ovo rucno zadajem...
// prakticno obicna struktura kao za DBF tabelu
AADD( _struct, { "POSITION", "C", 20, 0 } )
AADD( _struct, { "WIDTH", "C", 15, 0 } )
AADD( _struct, { "HEIGHT", "C", 15, 0 } )
AADD( _struct, { "QTTY", "C", 10, 0 } )
AADD( _struct, { "SHAPE", "C", 10, 0 } )
AADD( _struct, { "M2",   "C", 15, 0 } )
AADD( _struct, { "UM2",   "C", 15, 0 } )
AADD( _struct, { "MARKER", "C", 1, 0 } )

// otvori mi CSV fajl
oCsv := CsvReader():new()
oCsv:struct := _struct
oCsv:csvname := ::params["import_path"] + ::params["csv_file"]
oCsv:read()

if RECCOUNT() == 0
	return _ok
endif

SELECT csvimp
GO TOP

// markiraj sve stavke za prenos, osim headera
DO WHILE !EOF()
	IF UPPER( ALLTRIM( field->position ) ) <> "POZICIJA"
		REPLACE field->marker WITH "*"
	ENDIF
	SKIP
ENDDO

GO TOP

// daj mi pregled csvimp tabele
if ::csv_browse() == 0
	return _ok
endif

_art_id := ::get_article()

if _art_id == NIL
	return _ok
endif

GO TOP

do while !EOF()

	// preskacemo sve što nije markirano za prenos
	if field->marker <> "*"
		SKIP 1
		LOOP
	endif

	if VAL( field->height ) == 0 .or. VAL( field->width ) == 0 .or. VAL( field->qtty ) == 0
		SKIP 1
		LOOP
	endif

    ++ _count 

    _qtty := ::string_to_number( field->qtty, "BA" )
    _height := ::string_to_number( field->height, "BA" )
    _width := ::string_to_number( field->width, "BA" )
 
    select _doc_it
    APPEND BLANK

    _rec := dbf_get_rec()

    // standardna polja bitna za unos
    _rec["doc_no"] := ::doc_no
    _rec["doc_it_no"] := inc_docit( ::doc_no )
    _rec["doc_it_typ"] := " "
    _rec["it_lab_pos"] := "I"
    _rec["doc_it_alt"] := gDefNVM
    _rec["doc_acity"] := PADR( gDefCity, 50 )
    _rec["doc_it_sch"] := "N" 
	_rec["doc_it_typ"] := ::get_shape_type( csvimp->shape )
	_rec["doc_it_pos"] := ALLTRIM( csvimp->position )

    // sada podaci artikla i kolicina... 
    _rec["art_id"] := _art_id
    _rec["doc_it_wid"] := _width
    _rec["doc_it_hei"] := _height
    _rec["doc_it_qtt"] := _qtty

    dbf_update_rec( _rec )

    SELECT csvimp
    SKIP

enddo

//if _count > 0
//    Msgbeep( "Uspjesno importovano " + ALLTRIM( STR( _count ) ) + " zapisa." )
    _ok := .t.
//endif

return _ok




// ---------------------------------------------------
// ---------------------------------------------------
METHOD RnalCsvImport:get_article()
RETURN get_items_article()




// ---------------------------------------------------
// ---------------------------------------------------
METHOD RnalCsvImport:get_shape_type( shape )
local _type := " "

if LOWER( ALLTRIM( shape ) ) == "nepravilni"
	_type := "S"
endif

RETURN _type





// ---------------------------------------------------
// ---------------------------------------------------
METHOD RnalCsvImport:csv_browse()
local _box_x := MAXROWS() - 10
local _box_y := MAXCOLS() - 10
local _t_area := SELECT()
local _ret := 0
local _header := "Pregled importovanih podataka CSV fajla..."
local _x := m_x
local _y := m_y
private ImeKol := {}
private Kol := {}
private GetList := {}

// kolone browse-a
AADD( ImeKol, { PADC( "Pozicija", 20 ), {|| position }, "position" } )
AADD( ImeKol, { PADC( "Sirina", 15 ), {|| width }, "width" } )
AADD( ImeKol, { PADC( "Visina", 15 ), {|| height }, "height" } )
AADD( ImeKol, { PADC( "Kolicina", 15 ), {|| qtty }, "qtty" } )
AADD( ImeKol, { PADC( "Oblik", 10 ), {|| shape }, "shape" } )
AADD( ImeKol, { PADC( "Marker", 6 ), {|| marker }, "marker" } )

for _i := 1 to LEN( ImeKol )
    AADD( Kol, _i )
next

SELECT csvimp
GO TOP

// otvori box
Box(, _box_x, _box_y )

@ m_x + _box_x, m_x + 2 SAY "<SPACE> markiranje stavki za prenos  <ESC> izlaz"

ObjDbedit( "csvimp", _box_x, _box_y, {|| ::csv_browse_key_handler() }, _header, "foot",,,,, 1 )

if LastKey() == K_ESC .and. Pitanje(, "Importovati sadržaj fajla (D/N) ?", "D" ) == "D"
	_ret := 1
endif

BoxC()

m_x := _x
m_y := _y

select ( _t_area )

return _ret


// ---------------------------------------------------
// ---------------------------------------------------
METHOD RnalCsvImport:csv_browse_key_handler()

DO CASE

	CASE Ch == K_SPACE
		IF field->marker == "*"
			REPLACE field->marker WITH ""
		ELSE
			REPLACE field->marker WITH "*"
		ENDIF
		RETURN DE_REFRESH

ENDCASE 

return DE_CONT



// ----------------------------------------------------
// ----------------------------------------------------
METHOD RnalCsvImport:get_vars()
local _ok := .f.
local _x := 1
local _import_path := PADR( fetch_metric( "rnal_csv_import_path", my_user(), "" ), 200 )
local _imp_ok := "D"
local _csv_file := ""
local _csv_filter := "*.csv"
local _delimiter := ","

Box(, 5, 60 )

    @ m_x + _x, m_y + 2 SAY "*** import CSV fajla"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Lokacija fajla:" GET _import_path PICT "@S35"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Izvrsiti import fajla (D/N) ?" GET _imp_ok VALID _imp_ok $ "DN" PICT "@!"

    READ

BoxC()

if LastKey() == K_ESC .or. _imp_ok == "N"
    return _ok
endif

_import_path := ALLTRIM( _import_path )
if RIGHT( _import_path, 1 ) <> SLASH
    _import_path += SLASH
endif

// zabiljezi za ubuduce
set_metric( "rnal_csv_import_path", my_user(), _import_path )

// idemo na izbor fajla
if get_file_list_array( _import_path, _csv_filter, @_csv_file ) == 0
    return _ok
endif

if Pitanje(, "Import fajla " + _csv_file + " (D/N) ?", "D" ) == "N"
    return _ok
endif

_ok := .t.

::params := hb_hash()
::params["import_path"] := ALLTRIM( _import_path )
::params["csv_file"] := _csv_file
::params["delimiter"] := _delimiter

return _ok


METHOD RnalCsvImport:string_to_number( val, countryCode )
local sepDec := ","
local sep1000 := "."
local cTmp

if countryCode == NIL
   countryCode = "BA"
endif

if countryCode == "EN"
   return VAL( val )
endif

cTmp := strtran( val, sep1000, "" )
cTmp := strtran( val, sepDec, "." )

return VAL( cTmp )


