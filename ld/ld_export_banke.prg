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


CLASS LDExportTxt

    METHOD New()
    METHOD params()
    METHOD export()

    METHOD export_setup()
    METHOD export_setup_read_params()
    METHOD export_setup_write_params()

    METHOD export_setup_duplicate()

    DATA export_params
    DATA formula_params

    PROTECTED:

        METHOD create_txt_from_dbf()
        METHOD _dbf_struct()
        METHOD create_export_dbf()
        METHOD fill_data_from_ld()
        METHOD get_export_line_macro()
        METHOD get_export_params()
        METHOD get_export_list()
        METHOD copy_existing_formula()

ENDCLASS



METHOD LDExportTxt:New()
::export_params := hb_hash()
::formula_params := hb_hash()
return SELF



// -----------------------------------------------------------
// struktura pomocne tabele
// -----------------------------------------------------------
METHOD LDExportTxt:_dbf_struct()
local _dbf := {}
local _i, _a_tmp
local _dodatna_polja := ::export_params["dodatna_polja"]

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
AADD( _dbf, { "KNJIZ"   , "C", 50, 0 } )
AADD( _dbf, { "IZNOS_1" , "N", 15, 2 } )
AADD( _dbf, { "IZNOS_2" , "N", 15, 2 } )
AADD( _dbf, { "UNETO"   , "N", 15, 2 } )
AADD( _dbf, { "USATI"   , "N", 15, 2 } )

if !EMPTY( _dodatna_polja )
    _a_tmp := TokToNiz( _dodatna_polja, ";" )
    for _i := 1 to LEN( _a_tmp )
        if !EMPTY( _a_tmp[ _i ] )
            AADD( _dbf, { UPPER( _a_tmp[_i]) , "N", 15, 2 } )
        endif
    next
endif

return _dbf


// -----------------------------------------------------------
// kreiranje pomocne tabele
// -----------------------------------------------------------
METHOD LDExportTxt:create_export_dbf()
local _dbf
local _table_name := "export"

// struktura dbf-a
_dbf := ::_dbf_struct()

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




// -----------------------------------------------------------
// parametri tekuceg exporta
// -----------------------------------------------------------

METHOD LDExportTxt:params()
local _ok := .f.
local _mjesec := gMjesec
local _godina := gGodina
local _rj := SPACE(200)
local _name
local _export := "D"
local _obr := "1"
local _file_name := PADR( "export_ld.txt", 50 )
local _id_formula := fetch_metric( "ld_export_banke_tek", my_user(), 1 )
local _x := 1
local _dod_polja := PADR( fetch_metric("ld_export_banke_dodatna_polja", my_user(), "" ), 500 )

// citaj parametre
O_KRED

Box(, 15, 70 )

    @ m_x + _x, m_y + 2 SAY "Datumski period / mjesec:" GET _mjesec PICT "99"
    @ m_x + _x, col() + 1 SAY "godina:" GET _godina PICT "9999"
    @ m_x + _x, col() + 1 SAY "obracun:" GET _obr WHEN HelpObr(.t., _obr ) VALID ValObr( .t., _obr )

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Radna jedinica (prazno-sve):" GET _rj PICT "@S35"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Dodatna eksport polja (Sx, Ix):" GET _dod_polja PICT "@S32"
    
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Tekuca formula eksporta (1 ... n):" GET _id_formula PICT "999" VALID ::get_export_params( @_id_formula )
   
    read

    if LastKey() == K_ESC
        ::export_params := NIL
        BoxC()
        return _ok
    endif
 
    _file_name := ::formula_params["file"]
    _name := ::formula_params["name"]

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY REPLICATE( "-", 60 )
   
    ++ _x
 
    @ m_x + _x, m_y + 2 SAY "  Odabrana varijanta: " + PADR( _name, 30 ) 
   
    ++ _x

    @ m_x + _x, m_y + 2 SAY "         Sifra banke: " + ::formula_params["banka"]

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Naziv izlaznog fajla: " + PADR( _file_name, 20 ) 

    ++ _x 
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Eksportuj podatke (D/N)?" GET _export VALID _export $ "DN" PICT "@!"
    
    read

BoxC()

if LastKey() == K_ESC .or. _export == "N" 
    ::export_params := NIL
    return _ok
endif

// snimi parametre

set_metric( "ld_export_banke_tek", my_user(), _id_formula )
set_metric( "ld_export_banke_dodatna_polja", my_user(), ALLTRIM( _dod_polja ) )

::export_params := hb_hash()
::export_params["mjesec"] := _mjesec
::export_params["godina"] := _godina
::export_params["obracun"] := _obr
::export_params["rj"] := _rj
::export_params["banka"] := ::formula_params["banka"]
::export_params["fajl"] := _file_name
::export_params["formula"] := _id_formula
::export_params["dodatna_polja"] := _dod_polja
::export_params["separator"] := ::formula_params["separator"]
::export_params["separator_formula"] := ::formula_params["separator_formula"]

_ok := .t.

return _ok



// ----------------------------------------------------------
// kopiranje formule iz postojece formule
// ----------------------------------------------------------
METHOD LDExportTxt:copy_existing_formula( id_formula )
local oExport := LDExportTxt():New()
local _tmp
private GetList := {}

if LEFT( id_formula, 1 ) == "#"
    id_formula := STRTRAN( ALLTRIM( id_formula ), "#", "" )
else
    return .t.
endif

// uzmi postojecu formulu...
if oExport:get_export_params( VAL( id_formula ) )

    _tmp := oExport:get_export_line_macro()

    if !EMPTY( _tmp  )
        id_formula := PADR( _tmp, 500 )
    else
        MsgBeep( "Zadata formula ne postoji !!!" )
    endif

endif

return .t.




// -----------------------------------------------------------
// generisanje podataka u pomocnu tabelu iz sql-a
// -----------------------------------------------------------

METHOD LDExportTxt:fill_data_from_ld()
local _ok := .f.
local _qry, _table
local _server := pg_server()
local _count, _rec
local _dod_polja := ::export_params["dodatna_polja"]
local _pro_polja, _a_polja, _i

_pro_polja := ""

if !EMPTY( _dod_polja )

    _a_polja := TokToNiz( ALLTRIM( _dod_polja ), ";" )

    for _i := 1 to LEN( _a_polja )
        if !EMPTY( _a_polja[_i] )
            _pro_polja += "ld." 
            _pro_polja += LOWER( _a_polja[ _i ] )
            _pro_polja += "," 
        endif
    next

endif

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
        " rd.brtekr AS tekrn, " + ;
        " rd.brknjiz AS knjiz, " + ;
        _pro_polja + ;
        " ld.uneto, " + ;
        " ld.usati, " + ;
        " ld.uodbici, " + ;
        " ld.uiznos" + ;
        " FROM fmk.ld_ld ld " + ;
        " LEFT JOIN fmk.ld_radn rd ON ld.idradn = rd.id "
        
_qry += " WHERE ld.godina = " + ALLTRIM( STR( ::export_params["godina"] ) )
_qry += " AND ld.mjesec = " + ALLTRIM( STR( ::export_params["mjesec"] ) )
_qry += " AND ld.obr = " + _sql_quote( ::export_params["obracun"] )
_qry += " AND rd.idbanka = " + _sql_quote( ::export_params["banka"] )
_qry += " AND rd.isplata = " + _sql_quote( "TR" )

if !EMPTY( ::export_params["rj"] )
    _qry += " AND " + _sql_cond_parse( "ld.idrj", ALLTRIM( ::export_params["rj"] ) )
endif

// sortiranje exporta po prezimenu
_qry += " ORDER BY ld.godina, ld.mjesec, ld.obr, rd.naz "

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
    _rec["tekrn"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("tekrn") ) )
    _rec["knjiz"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("knjiz") ) )

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

    if !EMPTY( _dod_polja )
        for _i := 1 to LEN( _a_polja )
            if !EMPTY( _a_polja[_i] )
                _rec[ LOWER( _a_polja[_i] ) ] := oRow:FieldGet( oRow:FieldPos( LOWER( _a_polja[_i] ) ) )
            endif
        next
    endif

    dbf_update_rec( _rec )

    _table:Skip()

enddo

_ok := .t.

return _ok





// -----------------------------------------------------------
// vraca liniju koja ce sluziti kao makro za odsjecanje i prikaz
// teksta 
// -----------------------------------------------------------

METHOD LDExportTxt:get_export_line_macro()
local _struct
_struct := ALLTRIM( ::formula_params["formula"] )
return _struct



// -----------------------------------------------------------
// pravi txt fajl na osnovu dbf tabele i makro linije
// -----------------------------------------------------------

METHOD LDExportTxt:create_txt_from_dbf()
local _ok := .f.
local _output_filename
local _output_dir 
local _curr_struct
local _separator, _separator_formule
local _line, _i, _a_struct

_output_dir := my_home() + "export" + SLASH

if DirChange( _output_dir ) != 0
    MakeDir( _output_dir )
endif
 
// fajl ide u my_home/export/
_output_filename := _output_dir + ALLTRIM( ::export_params["fajl"] )

SET PRINTER TO ( _output_filename )
SET PRINTER ON
set CONSOLE OFF

// kreriraj makro liniju 
_curr_struct := ::get_export_line_macro()
_separator := ::export_params["separator"]
_separator_formule := ::export_params["separator_formula"]
_a_struct := TokToNiz( _curr_struct, _separator_formule )
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

	?? to_win1250_encoding( hb_strtoutf8( &(_line) ), .t. )
	? 
	
    skip

enddo

SET PRINTER TO
SET PRINTER OFF
SET CONSOLE ON

if FILE( _output_filename )
    open_folder( _output_dir )
    MsgBeep( "Fajl uspjesno kreiran !" )
    _ok := .t.
else
    MsgBeep( "Postoji problem sa operacijom kreiranja fajla !!!" )
endif

// zatvori tabelu...
select exp_bank
use

DirChange( my_home() )

return _ok




// -----------------------------------------------------------
// glavna metoda exporta
// -----------------------------------------------------------

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


// ----------------------------------------------------------
// dupliciranje postavke eksporta
// ----------------------------------------------------------
METHOD LDExportTxt:export_setup_duplicate()
local _existing := 1
local _new := 0
local oExisting := LDExportTxt():New()
local oNew := LDExportTxt():New()
private GetList := {}

Box(, 3, 60 )

    @ m_x + 1, m_y + 2 SAY "*** DUPLICIRANJE POSTAVKI EKSPORTA"
    @ m_x + 2, m_y + 2 SAY "Koristiti postojece podesenje broj:" GET _existing PICT "999"
    @ m_x + 3, m_y + 2 SAY "      Kreirati novo podesenje broj:" GET _new PICT "999"

    read

BoxC()

if LastKey() == K_ESC
    return
endif

if _new > 0 .and. _new <> _existing

    oExisting:export_setup_read_params( _existing )

    oNew:formula_params := oExisting:formula_params
    oNew:export_setup_write_params( _new )

endif

return




// -----------------------------------------------------------
// podesenje varijanti exporta
// -----------------------------------------------------------

METHOD LDExportTxt:export_setup()
local _ok := .f.
local _x := 1
local _id_formula := fetch_metric( "ld_export_banke_tek", my_user(), 1 )
local _active, _formula, _filename, _name, _sep, _sep_formula, _banka
local _write_params

Box(, 12, 70 )

    @ m_x + _x, m_y + 2 SAY "Varijanta eksporta:" GET _id_formula PICT "999"

    read

    if LastKey() == K_ESC
        BoxC()
        return _ok
    endif

    ::export_setup_read_params( _id_formula )

    _formula := ::formula_params["formula"]
    _filename := ::formula_params["file"]
    _name := ::formula_params["name"]
    _sep := ::formula_params["separator"]
    _sep_formula := ::formula_params["separator_formula"]
    _banka := ::formula_params["banka"]

    if _formula == NIL
        // tek se podesavaju parametri za ovu formulu
        _formula := SPACE(500)
        _name := PADR( "XXXXX Banka", 100 )
        _filename := PADR( "", 50 )
        _banka := SPACE(6)
        _sep := ";"
        _sep_formula := ";"
    else
        _formula := PADR( ALLTRIM( _formula ), 500 )
        _name := PADR( ALLTRIM( _name ), 100 )
        _filename := PADR( ALLTRIM( _filename ), 50 )
        _sep := PADR( _sep, 1 )
        _sep_formula := PADR( _sep_formula, 1 )
        _banka := PADR( _banka, 6 )
    endif

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "(*)   Naziv:" GET _name PICT "@S50" VALID !EMPTY( _name )

    ++ _x
    ++ _x  

    @ m_x + _x, m_y + 2 SAY "(*)   Banka:" GET _banka PICT "@S50" VALID !EMPTY( _banka ) .and. P_Kred( @_banka )
    
    ++ _x
    ++ _x  

    @ m_x + _x, m_y + 2 SAY "(*) Formula:" GET _formula PICT "@S50" VALID ;
            {|| !EMPTY( _formula ) .and. ::copy_existing_formula( @_formula ) }

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Naziv izlaznog fajla:" GET _filename PICT "@S40"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Separator u izl.fajlu [ ; , . ]:" GET _sep 

    ++ _x
 
    @ m_x + _x, m_y + 2 SAY "    Separator formule [ ; , . ]:" GET _sep_formula 

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// write params

set_metric( "ld_export_banke_tek", my_user(), _id_formula )

::formula_params["separator"] := _sep
::formula_params["separator_formula"] := _sep_formula
::formula_params["formula"] := _formula
::formula_params["file"] := _filename
::formula_params["name"] := _name
::formula_params["banka"] := _banka

::export_setup_write_params( _id_formula )

return _ok





// -----------------------------------------------------------
// citanje podesenja varijanti
// -----------------------------------------------------------


METHOD LDExportTxt:export_setup_read_params( id )
local _param_name := "ld_export_" + PADL( ALLTRIM(STR(id)), 2, "0" ) + "_"
local _ok := .t.

::formula_params := hb_hash()
::formula_params["name"] := fetch_metric( _param_name + "name", NIL, NIL )
::formula_params["file"] := fetch_metric( _param_name + "file", NIL, NIL )
::formula_params["formula"] := fetch_metric( _param_name + "formula", NIL, NIL )
::formula_params["separator"] := fetch_metric( _param_name + "sep", NIL, NIL )
::formula_params["separator_formula"] := fetch_metric( _param_name + "sep_formula", NIL, ";" )
::formula_params["banka"] := fetch_metric( _param_name + "banka", NIL, NIL )

return _ok





// -----------------------------------------------------------
// snimanje podesenja varijanti
// -----------------------------------------------------------

METHOD LDExportTxt:export_setup_write_params( id )
local _param_name := "ld_export_" + PADL( ALLTRIM(STR(id)), 2, "0" ) + "_"

set_metric( _param_name + "name", NIL, ALLTRIM( ::formula_params["name"] ) )
set_metric( _param_name + "file", NIL, ALLTRIM( ::formula_params["file"] ) )
set_metric( _param_name + "formula", NIL, ALLTRIM( ::formula_params["formula"] ) )
set_metric( _param_name + "sep", NIL, ALLTRIM( ::formula_params["separator"] ) )
set_metric( _param_name + "sep_formula", NIL, ALLTRIM( ::formula_params["separator_formula"] ) )
set_metric( _param_name + "banka", NIL, ::formula_params["banka"] )

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

::export_setup_read_params( id )

if ::formula_params["name"] == NIL .or. EMPTY( ::formula_params["name"]  )
    MsgBeep( "Za ovu varijantu ne postoji podesenje !!!#Ukucajte 0 da bi odabrali iz liste." )        
else
    _ok := .t.
endif

return _ok






METHOD LDExportTxt:get_export_list()
local _id := 0
local _i
local _param_name := "ld_export_"
local _opc, _opcexe, _izbor := 1
local _m_x := m_x
local _m_y := m_y

_opc := {}
_opcexe := {}

for _i := 1 to 20

    ::export_setup_read_params( _i )

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

m_x := _m_x
m_y := _m_y

return _id




function ld_export_banke()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. export podataka za banku                " )
AADD( _opcexe, {|| ld_export_txt_banka()  } )
AADD( _opc, "2. postavke formula exporta   " )
AADD( _opcexe, {|| ld_export_txt_setup()  } )
AADD( _opc, "3. dupliciranje podesenja eksporta   " )
AADD( _opcexe, {|| LDExportTxt():New():export_setup_duplicate()  } )

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
oExp:export_setup()

return


