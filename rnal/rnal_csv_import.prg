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
        
        METHOD get_vars()
    
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
AADD( _struct, { "ID", "C", 10, 0 } )
AADD( _struct, { "WIDTH", "C", 20, 0 } )
AADD( _struct, { "HEIGHT", "C", 20, 0 } )
AADD( _struct, { "QTTY", "C", 20, 0 } )

// otvori mi CSV fajl
oCsv := F18Csv():new()
oCsv:struct := _struct
oCsv:csvname := ::params["import_path"] + ::params["csv_file"]
oCsv:read()

altd()

// sada bi trebao da sam na toj tabeli...
GO TOP
SKIP 1

do while !EOF()

    ++ _count 

    // uzmi potrebna polja...    
    _art_id := _sql_get_value( "fmk.rnal_articles", "id", { { "art_desc", ALLTRIM( field->id ) } } ) 

    _qtty := string_to_number( field->qtty, "BA" )
    _height := string_to_number( field->height, "BA" )
    _width := string_to_number( field->width, "BA" )
 
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

    // sada podaci artikla i kolicina... 
    _rec["art_id"] := _art_id
    _rec["doc_it_wid"] := _width
    _rec["doc_it_hei"] := _height
    _rec["doc_it_qtt"] := _qtty

    dbf_update_rec( _rec )

    select (400)
    SKIP

enddo

if _count > 0
    Msgbeep( "Uspjesno importovano " + ALLTRIM( STR( _count ) ) + " zapisa." )
    _ok := .t.
endif

return _ok


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


function string_to_number(val)
return VAL(val)
