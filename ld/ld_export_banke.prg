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
#include "hbclass.ch"
#include "hbcompat.ch"
#include "common.ch"


CLASS LDExportTxt

    METHOD New()
    METHOD params()
    METHOD export()

    METHOD export_formula_setup()
    METHOD export_formula_read_params()
    METHOD export_formula_write_params()

    DATA export_params
    DATA formula_params

    PROTECTED:

        METHOD create_txt_from_dbf()
        METHOD create_export_dbf()
        METHOD fill_data_from_ld()
        METHOD get_export_struct()
        METHOD get_export_params()
        METHOD get_export_list()

        DATA export_formula
 
ENDCLASS



METHOD LDExportTxt:New()
::export_params := hb_hash()
::formula_params := hb_hash()
return SELF




METHOD LDExportTxt:create_export_dbf()
local _dbf := {}
local _table_name := "export"

// struktura...
AADD( _dbf, { "IDRJ"    , "C", 2, 0 } )
AADD( _dbf, { "OBR"     , "C", 1, 0 } )
AADD( _dbf, { "GODINA"  , "N", 4, 0 } )
AADD( _dbf, { "MJESEC"  , "N", 2, 0 } )
AADD( _dbf, { "IDRADN"  , "C", 6, 0 } )
AADD( _dbf, { "PUNOIME" , "C", 50, 0 } )
AADD( _dbf, { "IME"     , "C", 30, 0 } )
AADD( _dbf, { "IMEROD"  , "C", 30, 0 } )
AADD( _dbf, { "PREZIME" , "C", 40, 0 } )
AADD( _dbf, { "JMBG"    , "C", 13, 0 } )
AADD( _dbf, { "TEKRN"   , "C", 50, 0 } )
AADD( _dbf, { "IZNOS_1" , "N", 15, 2 } )
AADD( _dbf, { "IZNOS_2" , "N", 15, 2 } )
AADD( _dbf, { "UNETO"   , "N", 15, 2 } )
AADD( _dbf, { "USATI"   , "N", 15, 2 } )

select ( F_TMP_1 )
use

FERASE( my_home() + _table_name + ".dbf" )
FERASE( my_home() + _table_name + ".cdx" )

dbcreate( my_home() + _table_name + ".dbf", _dbf )

select ( F_TMP_1 )
use
my_use_temp( "EXP_BANK", my_home() + _table_name + ".dbf", .f., .f. )

// indeksi...
index on ( punoime ) TAG "1"
index on ( jmbg ) TAG "2"

return .t.





METHOD LDExportTxt:params()
local _ok := .f.
local _mjesec := gMjesec
local _godina := gGodina
local _rj := SPACE(200)
local _file_name := PADR( "export_ld.txt", 50 )
local _id_formula := 1
local _x := 1

// citaj parametre

Box(, 8, 65 )

    @ m_x + _x, m_y + 2 SAY "Datumski period / mjesec:" GET _mjesec PICT "99"
    @ m_x + _x, col() + 1 SAY "godina:" GET _godina PICT "9999"

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Radna jedinica (prazno-sve):" GET _rj PICT "@S20"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Tekuca formula eksporta (1 ... n):" GET _id_formula PICT "999" VALID ::get_export_params( @_id_formula )
   
    read
 
    _file_name := PADR( ::formula_params["file"], 50 )

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Naziv izlaznog fajla:" GET _file_name PICT "@S20"
    
    read

BoxC()

if LastKey() == K_ESC
    ::export_params := NIL
    return _ok
endif

// snimi parametre

::export_params := hb_hash()
::export_params["mjesec"] := _mjesec
::export_params["godina"] := _godina
::export_params["rj"] := _rj
::export_params["fajl"] := _file_name
::export_params["formula"] := _id_formula

_ok := .t.

return _ok





METHOD LDExportTxt:fill_data_from_ld()
local _ok := .f.
local _qry, _table
local _server := pg_server()
local _count, _rec

_qry := "SELECT " + ;
        " ld.godina, " + ;
        " ld.mjesec, " + ;
        " ld.obr, " + ;
        " ld.idrj, " + ;
        " ld.idradn, " + ;
        " rd.ime, " + ;
        " rd.imerod, " + ;
        " rd.naz, " + ;
        " rd.matbr AS jmbg, " + ;
        " ld.uneto, " + ;
        " ld.usati, " + ;
        " ld.uodbici, " + ;
        " ld.uiznos" + ;
        " FROM fmk.ld_ld ld " + ;
        " LEFT JOIN fmk.ld_radn rd ON ld.idradn = rd.id "
        
_qry += " WHERE ld.godina = " + ALLTRIM( STR( ::export_params["godina"] ) )
_qry += " AND ld.mjesec = " + ALLTRIM( STR( ::export_params["mjesec"] ) )

if !EMPTY( ::export_params["rj"] )
    _qry += " AND " + _sql_cond_parse( "ld.idrj", ALLTRIM( ::export_params["rj"] ) )
endif

_qry += " ORDER BY ld.godina, ld.mjesec, ld.obr, ld.idrj, ld.idradn "

MsgO( "formiranje sql upita u toku ..." )

_table := _sql_query( _server, _qry )

MsgC()

if _table == NIL
    return NIL
endif

_table:Refresh()
_count := 0

// napunit ce iz sql upita tabelu export
do while !_table:EOF()

    ++ _count

    oRow := _table:GetRow()
    
    select exp_bank
    append blank

    _rec := dbf_get_rec()
    _rec["godina"] := oRow:FieldGet( oRow:FieldPos("godina") )
    _rec["mjesec"] := oRow:FieldGet( oRow:FieldPos("mjesec") )
    _rec["idrj"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("idrj") ) )
    _rec["obr"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("obr") ) )
    _rec["idradn"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("idradn") ) )
    _rec["jmbg"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("jmbg") ) )

    _rec["punoime"] := ;
        ALLTRIM( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("ime") ) ) ) + " (" + ;
        ALLTRIM( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("imerod") ) ) ) + ") " + ;
        ALLTRIM( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("naz") ) ) )

    _rec["ime"] := ALLTRIM( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("ime") ) ) )
    _rec["imerod"] := ALLTRIM( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("imerod") ) ) )
    _rec["prezime"] := ALLTRIM( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("naz") ) ) )
 
    _rec["iznos_1"] := oRow:FieldGet( oRow:FieldPos("uiznos") )
    // iznos_2 ostavljam prazno...

    _rec["usati"] := oRow:FieldGet( oRow:FieldPos("usati") )
    _rec["uneto"] := oRow:FieldGet( oRow:FieldPos("uneto") )

    dbf_update_rec( _rec )

    _table:Skip()

enddo

_ok := .t.

return _ok






METHOD LDExportTxt:get_export_struct()
local _struct
_struct := ALLTRIM( ::formula_params["formula"] )
return _struct



METHOD LDExportTxt:create_txt_from_dbf()
local _ok := .f.
local _output_filename 
local _curr_struct
local _separator
local _line, _i, _a_struct

_output_filename := my_home() + ALLTRIM( ::export_params["fajl"] )

SET PRINTER TO ( _output_filename )
SET PRINTER ON
set CONSOLE OFF

// kreriraj makro liniju 
_curr_struct := ::get_export_struct()
_separator := ::formula_params["separator"]
_a_struct := TokToNiz( _curr_struct, ";" )
_line := ""

for _i := 1 to LEN( _a_struct )

    if !EMPTY( _a_struct[ _i ] )

        // plusevi izmedju...
        if _i > 1
            _line += " + "
        endif

        // makro
        _line += _a_struct[ _i ]

        // ako treba separator
        if _i < LEN( _a_struct ) .and. !EMPTY( _separator )
            _line += ' + "' + _separator + '" '
        endif

    endif

next

// predji na upis podataka
select exp_bank
set order to tag "1"
go top

do while !EOF()
        
    // upisi u fajl...

	?? to_win1250_encoding( &(_line) )
	? 
	
    skip

enddo

SET PRINTER TO
SET PRINTER OFF
SET CONSOLE ON

if FILE( _output_filename )
    MsgBeep( "Fajl uspjesno kreiran !" )
    _ok := .t.
else
    MsgBeep( "Postoji problem sa operacijom kreiranja fajla !!!" )
endif

// zatvori tabelu...
select exp_bank
use

return _ok





METHOD LDExportTxt:export()
local _ok := .f.

if ::export_params == NIL
    MsgBeep( "Prekidam operaciju exporta !" )
    return _ok
endif

// kreiraj tabelu exporta
::create_export_dbf()

// napuni je podacima iz obračuna
if ! ::fill_data_from_ld()
    MsgBeep( "Za trazeni period ne postoje podaci u obracunima !!!" )
    return _ok
endif

// kreiraj txt fajl na osnovu dbf tabele
if ! ::create_txt_from_dbf()
    return _ok
endif

_ok := .t.
return _ok





METHOD LDExportTxt:export_formula_setup()
local _ok := .f.
local _x := 1
local _id_formula := fetch_metric( "ld_export_banke_tek", my_user(), 1 )
local _active, _formula, _filename, _name, _sep
local _write_params

Box(, 10, 70 )

    @ m_x + _x, m_y + 2 SAY "Varijanta eksporta:" GET _id_formula PICT "999"

    read

    ::export_formula_read_params( _id_formula )

    _formula := ::formula_params["formula"]
    _filename := ::formula_params["file"]
    _name := ::formula_params["name"]
    _sep := ::formula_params["separator"]

    if _formula == NIL
        // tek se podesavaju parametri za ovu formulu
        _formula := SPACE(500)
        _name := PADR( "XXXXX Banka", 100 )
        _filename := PADR( "", 50 )
        _sep := ";"
    else
        _formula := PADR( ALLTRIM( _formula ), 500 )
        _name := PADR( ALLTRIM( _name ), 100 )
        _filename := PADR( ALLTRIM( _filename ), 50 )
        _sep := PADR( _sep, 1 )
    endif

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Naziv:" GET _name PICT "@S40" VALID !EMPTY( _name )

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Formula:" GET _formula PICT "@S40" VALID !EMPTY( _formula )

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Naziv izlaznog fajla:" GET _filename PICT "@S20"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Koristi se separator [ ; , . ]:" GET _sep 

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// write params

set_metric( "ld_export_banke_tek", my_user(), _id_formula )

::formula_params["separator"] := _sep
::formula_params["formula"] := _formula
::formula_params["file"] := _filename
::formula_params["name"] := _name

::export_formula_write_params( _id_formula )

return _ok






METHOD LDExportTxt:export_formula_read_params( id )
local _param_name := "ld_export_" + PADL( ALLTRIM(STR(id)), 2, "0" ) + "_"
local _ok := .t.

::formula_params := hb_hash()
::formula_params["name"] := fetch_metric( _param_name + "name", NIL, NIL )
::formula_params["file"] := fetch_metric( _param_name + "file", NIL, NIL )
::formula_params["formula"] := fetch_metric( _param_name + "formula", NIL, NIL )
::formula_params["separator"] := fetch_metric( _param_name + "sep", NIL, NIL )

return _ok







METHOD LDExportTxt:export_formula_write_params( id )
local _param_name := "ld_export_" + PADL( ALLTRIM(STR(id)), 2, "0" ) + "_"

set_metric( _param_name + "name", NIL, ALLTRIM( ::formula_params["name"] ) )
set_metric( _param_name + "file", NIL, ALLTRIM( ::formula_params["file"] ) )
set_metric( _param_name + "formula", NIL, ALLTRIM( ::formula_params["formula"] ) )
set_metric( _param_name + "sep", NIL, ALLTRIM( ::formula_params["separator"] ) )

return .t.







METHOD LDExportTxt:get_export_params( id )
local _ok := .f.

if id == 0
    id := ::get_export_list()
endif

if id == 0
    MsgBeep( "Potrebno izabrati neku od varijanti !" )
    return _ok
endif

::export_formula_read_params( id )

if ::formula_params["name"] == NIL  
    MsgBeep( "Za ovu varijantu ne postoji podesenje !!!" )        
else
    _ok := .t.
endif

return _ok






METHOD LDExportTxt:get_export_list()
local _id := 0
local _i
local _param_name := "ld_export_"
local _opc, _opcexe, _izbor := 1

_opc := {}
_opcexe := {}

for _i := 1 to 10

    ::export_formula_read_params( _i )

    if ::formula_params["name"] <> NIL .and. !EMPTY( ::formula_params["name"] )
       
        _tmp := ""
        _tmp += PADL( ALLTRIM(STR( _i )) + ".", 4 )
        _tmp += PADR( ::formula_params["name"], 40 )

        AADD( _opc, _tmp )
        AADD( _opcexe, {|| "" } )

    endif

next

do while .t. .and. LastKey() != K_ESC
    _izbor := Menu( "choice", _opc, _izbor, .f. )
	if _izbor == 0
        exit
    else
        _id := VAL( LEFT ( _opc[ _izbor ], 3 ) )
        _izbor := 0
    endif
enddo

return _id




function ld_export_banke()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. export podataka za banku                " )
AADD( _opcexe, {|| ld_export_txt_banka()  } )
AADD( _opc, "2. postavke formula exporta   " )
AADD( _opcexe, {|| ld_export_txt_setup()  } )

f18_menu( "el", .f., _izbor, _opc, _opcexe )

return





function ld_export_txt_banka( params )
local oExp

oExp := LDExportTxt():New()

// u slucaju da nismo setovali parametre, pozovi ih
if params == NIL
    oExp:params()
else
    // setuj parametre na osnovu proslijedjenih...
    oExp:export_params := hb_hash()
    oExp:export_params["godina"] := params["godina"]
    oExp:export_params["mjesec"] := params["mjesec"]
endif

oExp:export()

return




function ld_export_txt_setup()
local oExp

oExp := LDExportTxt():New()
oExp:export_formula_setup()

return


