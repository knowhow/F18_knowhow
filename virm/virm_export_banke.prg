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

#include "f18.ch"
#include "hbclass.ch"
#include "common.ch"


CLASS VirmExportTxt

    METHOD New()
    METHOD params()
    METHOD export()

    METHOD export_setup()
    METHOD export_setup_read_params()
    METHOD export_setup_write_params()

    METHOD export_setup_duplicate()
    
    DATA export_params
    DATA formula_params
    DATA export_total
    DATA export_count
        
    PROTECTED:

        METHOD create_txt_from_dbf()
        METHOD _dbf_struct()
        METHOD create_export_dbf()
        METHOD fill_data_from_virm()
        METHOD get_export_line_macro()
        METHOD get_macro_line()
        METHOD get_export_params()
        METHOD get_export_list()
        METHOD copy_existing_formula()

ENDCLASS



METHOD VirmExportTxt:New()
::export_params := hb_hash()
::formula_params := hb_hash()
::export_total := 0
::export_count := 0
return SELF



// -----------------------------------------------------------
// struktura pomocne tabele
// -----------------------------------------------------------
METHOD VirmExportTxt:_dbf_struct()
local _dbf := {}
local _i, _a_tmp

// struktura...
AADD( _dbf, { "RBR"        , "N",  3, 0 } )
AADD( _dbf, { "MJESTO"     , "C", 30, 0 } )

AADD( _dbf, { "PRIM_RN"    , "C", 16, 0 } )
AADD( _dbf, { "PRIM_NAZ"   , "C", 50, 0 } )
AADD( _dbf, { "PRIM_MJ"    , "C", 30, 0 } )

AADD( _dbf, { "POS_RN"     , "C", 16, 0 } )
AADD( _dbf, { "POS_NAZ"    , "C", 50, 0 } )
AADD( _dbf, { "POS_MJ"     , "C", 30, 0 } )

AADD( _dbf, { "SVRHA"      , "C", 140, 0 } )
AADD( _dbf, { "SIFRA_PL"   , "C",   6, 0 } )

AADD( _dbf, { "DAT_VAL"    , "D",   8, 0 } )
AADD( _dbf, { "PER_OD"     , "D",   8, 0 } )
AADD( _dbf, { "PER_DO"     , "D",   8, 0 } )

AADD( _dbf, { "TIP_ST"     , "C",   1, 0 } )
AADD( _dbf, { "TIP_DOK"    , "C",   1, 0 } )
AADD( _dbf, { "V_UPL"      , "C",   1, 0 } )
AADD( _dbf, { "OPCINA"     , "C",   3, 0 } )
AADD( _dbf, { "BPO"        , "C",  13, 0 } )

AADD( _dbf, { "V_PRIH"     , "C",   6, 0 } )
AADD( _dbf, { "BUDZET"     , "C",   7, 0 } )
AADD( _dbf, { "PNABR"      , "C",  10, 0 } )

AADD( _dbf, { "IZNOS"      , "N",  15, 2 } )

AADD( _dbf, { "TOT_IZN"    , "N",  15, 2 } )
AADD( _dbf, { "TOT_ST"     , "N",  15, 2 } )

return _dbf


// -----------------------------------------------------------
// kreiranje pomocne tabele
// -----------------------------------------------------------
METHOD VirmExportTxt:create_export_dbf()
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
index on ( STR( rbr, 3 ) ) TAG "1"

return .t.




// -----------------------------------------------------------
// parametri tekuceg exporta
// -----------------------------------------------------------

METHOD VirmExportTxt:params()
local _ok := .f.
local _name
local _export := "D"
local _obr := "1"
local _file_name := PADR( "export_virm.txt", 50 )
local _id_formula := fetch_metric( "virm_export_banke_tek", my_user(), 1 )
local _x := 1

// citaj parametre
Box(, 15, 70 )

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

set_metric( "virm_export_banke_tek", my_user(), _id_formula )

::export_params := hb_hash()
::export_params["fajl"] := _file_name
::export_params["formula"] := _id_formula
::export_params["separator"] := ::formula_params["separator"]
::export_params["separator_formula"] := ::formula_params["separator_formula"]

_ok := .t.

return _ok




// ----------------------------------------------------------
// dupliciranje postavke eksporta
// ----------------------------------------------------------
METHOD VirmExportTxt:export_setup_duplicate()
local _existing := 1
local _new := 0
local oExisting := VirmExportTxt():New()
local oNew := VirmExportTxt():New()
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



// ----------------------------------------------------------
// kopiranje formule iz postojece formule
// ----------------------------------------------------------
METHOD VirmExportTxt:copy_existing_formula( id_formula, var )
local oExport := VirmExportTxt():New()
local _tmp
private GetList := {}

if LEFT( id_formula, 1 ) == "#"
    id_formula := STRTRAN( ALLTRIM( id_formula ), "#", "" )
else
    return .t.
endif

// uzmi postojecu formulu...
if oExport:get_export_params( VAL( id_formula ) )

    _tmp := oExport:get_export_line_macro( var )

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
METHOD VirmExportTxt:fill_data_from_virm()
local _ok := .f.
local _count, _rec
local _total := 0

select ( F_VIPRIPR )
if !USED()
    O_VIRM_PRIPR
endif

select virm_pripr
set order to tag "1"
go top

if RECCOUNT() == 0
    MsgBeep( "U pripremi nema virmana !!!" )
    return _ok
endif

_count := 0

do while !EOF()

    _total += field->iznos
    ++ _count

    select exp_bank
    append blank
    _rec := dbf_get_rec()

    // popuni sada _rec

    _rec["rbr"] := virm_pripr->rbr
    
    // mjesto
    _rec["mjesto"] := UPPER( virm_pripr->mjesto )

    // podaci posiljaoca i primaoca
    _rec["prim_rn"] := virm_pripr->kome_zr
    _rec["prim_naz"] := UPPER( virm_pripr->kome_txt )
    _rec["prim_mj"] := UPPER( virm_pripr->kome_sj )

    if EMPTY( _rec["prim_mj"] )
        _rec["prim_mj"] := _rec["mjesto"]
    endif

    _rec["pos_rn"] := virm_pripr->ko_zr
    _rec["pos_naz"] := UPPER( virm_pripr->ko_txt )
    _rec["pos_mj"] := UPPER( virm_pripr->ko_sj )

    if EMPTY( _rec["pos_mj"] )
        _rec["pos_mj"] := _rec["mjesto"]
    endif

    // svrha uplate
    _rec["svrha"] := UPPER( virm_pripr->svrha_doz )

    // sifra placanja po sifraniku TRN.DAT
    // ako je sifra duzine 4 za sifru se popuni sa 2 karaktera prazna
    _rec["sifra_pl"] := virm_pripr->svrha_pl

    // datum valute
    _rec["dat_val"] := virm_pripr->dat_upl
    
    // porezni period od-do
    _rec["per_od"] := virm_pripr->pod
    _rec["per_do"] := virm_pripr->pdo

    // tip stavke, fiskno "1"
    _rec["tip_st"] := "1"

    // tip dokumenta:
    // 0 - nalog za prenos
    // 1 - nalog za placanje JP
    _rec["tip_dok"] := "1"

    // vrsta uplate:
    // 0, 1 ili 2
    _rec["v_upl"] := "0"

    // broj poreznog obveznika
    _rec["bpo"] := virm_pripr->bpo

    // opcina
    _rec["opcina"] := virm_pripr->idops

    // vrsta prihoda
    _rec["v_prih"] := virm_pripr->idjprih

    // budzetska organizacija
    _rec["budzet"] := virm_pripr->budzorg

    // poziv na broj
    _rec["pnabr"] := virm_pripr->pnabr

    // iznos virmana
    _rec["iznos"] := virm_pripr->iznos
    
    // total stavki...
    _rec["tot_st"] := 0

    // total iznos...
    _rec["tot_izn"] := 0

    dbf_update_rec( _rec )

    select virm_pripr
    skip

enddo

// ubaci mi podatke o totalima u polja...
select exp_bank
set order to tag "1"
go top

do while !EOF()

    _rec := dbf_get_rec()
    _rec["tot_izn"] := _total
    _rec["tot_st"] := _count

    dbf_update_rec( _rec )

    skip

enddo

go top

::export_total := _total
::export_count := _count

_ok := .t.

return _ok





// -----------------------------------------------------------
// vraca liniju koja ce sluziti kao makro za odsjecanje i prikaz
// teksta 
// -----------------------------------------------------------
METHOD VirmExportTxt:get_export_line_macro( var )
local _struct

do case 
    case var == "i"
        // item line
        _struct := ALLTRIM( ::formula_params["formula"] )
    case var == "h1"
        // header 1
        _struct := ALLTRIM( ::formula_params["head_1"] )
    case var == "h2"
        // header 2
        _struct := ALLTRIM( ::formula_params["head_2"] )
    case var == "f1"
         // footer 1
        _struct := ALLTRIM( ::formula_params["footer_1"] )
    case var == "f2"
         // footer 2
        _struct := ALLTRIM( ::formula_params["footer_2"] )
    otherwise
        MsgBeep( "macro not defined !" )
        _struct := ""
endcase

return _struct



METHOD VirmExportTxt:get_macro_line( var )
local _macro := ""
local _i, _curr_struct
local _separator, _separator_formule
local _a_struct

// kreriraj makro liniju za stavku
_curr_struct := ::get_export_line_macro( var )

if EMPTY( _curr_struct )
    return _macro
endif

_separator := ::export_params["separator"]
_separator_formule := ::export_params["separator_formula"]
_a_struct := TokToNiz( _curr_struct, _separator_formule )

for _i := 1 to LEN( _a_struct )

    if !EMPTY( _a_struct[ _i ] )

        // plusevi izmedju...
        if _i > 1
            _macro += " + "
        endif

        // makro
        _macro += _a_struct[ _i ]

        // ako treba separator
        if _i < LEN( _a_struct ) .and. !EMPTY( _separator )
            _macro += ' + "' + _separator + '" '
        endif

    endif

next

return _macro




// -----------------------------------------------------------
// pravi txt fajl na osnovu dbf tabele i makro linije
// -----------------------------------------------------------

METHOD VirmExportTxt:create_txt_from_dbf()
local _ok := .f.
local _output_filename
local _output_dir 
local _line
local _head_1, _head_2
local _footer_1, _footer_2
local _force_eol

_output_dir := my_home() + "export" + SLASH

if DirChange( _output_dir ) != 0
    MakeDir( _output_dir )
endif
 
// fajl ide u my_home/export/
_output_filename := _output_dir + ALLTRIM( ::export_params["fajl"] )

_force_eol := ::formula_params["forsiraj_eol"] == "D"

SET PRINTER TO ( _output_filename )
SET PRINTER ON
set CONSOLE OFF

// predji na upis podataka
select exp_bank
set order to tag "1"
go top

// header 1
_head_1 := ::get_macro_line( "h1" )

if !EMPTY( _head_1 )    
	?? to_win1250_encoding( hb_strtoutf8( &(_head_1 ) ), .t. )
    if _force_eol
        ?
    endif
endif

// header 2
_head_2 := ::get_macro_line( "h2" )

if !EMPTY( _head_2 )    
	?? to_win1250_encoding( hb_strtoutf8( &(_head_2) ), .t. )
    if _force_eol
        ?
    endif
endif

// sada stavke...
_line := ::get_macro_line( "i" )

// predji na upis podataka
select exp_bank
set order to tag "1"
go top

do while !EOF()
    // upisi u fajl...
	?? to_win1250_encoding( hb_strtoutf8( &(_line) ), .t. )
    if _force_eol
        ?
    endif
    skip
enddo

// vrati se na vrh tabele
go top

// footer 1
_footer_1 := ::get_macro_line( "f1" )

if !EMPTY( _footer_1 )    
	?? to_win1250_encoding( hb_strtoutf8( &(_footer_1 ) ), .t. )
    if _force_eol
        ?
    endif
endif

// footer 2
_footer_2 := ::get_macro_line( "f2" )

if !EMPTY( _footer_2 )    
	?? to_win1250_encoding( hb_strtoutf8( &(_footer_2) ), .t. )
    if _force_eol
        ?
    endif
endif


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

METHOD VirmExportTxt:export()
local _ok := .f.

if ::export_params == NIL
    MsgBeep( "Prekidam operaciju exporta !" )
    return _ok
endif

// kreiraj tabelu exporta
::create_export_dbf()

// napuni je podacima iz obračuna
if ! ::fill_data_from_virm()
    MsgBeep( "Problem sa eksportom podataka !!!" )
    return _ok
endif

// kreiraj txt fajl na osnovu dbf tabele
if ! ::create_txt_from_dbf()
    return _ok
endif

_ok := .t.
return _ok



// -----------------------------------------------------------
// podesenje varijanti exporta
// -----------------------------------------------------------

METHOD VirmExportTxt:export_setup()
local _ok := .f.
local _x := 1
local _id_formula := fetch_metric( "virm_export_banke_tek", my_user(), 1 )
local _active, _formula, _filename, _name, _sep, _sep_formula
local _head_1, _head_2, _footer_1, _footer_2, _force_eol
local _write_params

Box(, 15, 70 )

    #ifdef __PLATWORM__DARWIN
        readinsert(.t.)
    #endif

    @ m_x + _x, m_y + 2 SAY "Varijanta eksporta:" GET _id_formula PICT "999"

    read

    if LastKey() == K_ESC
        BoxC()
        return _ok
    endif

    ::export_setup_read_params( _id_formula )

    _formula := ::formula_params["formula"]
    _head_1 := ::formula_params["head_1"]
    _head_2 := ::formula_params["head_2"]
    _footer_1 := ::formula_params["footer_1"]
    _footer_2 := ::formula_params["footer_2"]
    _filename := ::formula_params["file"]
    _name := ::formula_params["name"]
    _sep := ::formula_params["separator"]
    _sep_formula := ::formula_params["separator_formula"]
    _force_eol := ::formula_params["forsiraj_eol"]

    if _formula == NIL
        // tek se podesavaju parametri za ovu formulu
        _formula := SPACE(1000)
        _head_1 := _formula
        _head_2 := _formula
        _footer_1 := _formula
        _footer_2 := _formula
        _name := PADR( "XXXXX Banka", 100 )
        _filename := PADR( "", 50 )
        _sep := ";"
        _sep_formula := ";"
        _force_eol := "D"
    else
        _formula := PADR( ALLTRIM( _formula ), 1000 )
        _head_1 := PADR( ALLTRIM( _head_1 ), 1000 )
        _head_2 := PADR( ALLTRIM( _head_2 ), 1000 )
        _footer_1 := PADR( ALLTRIM( _footer_1 ), 1000 )
        _footer_2 := PADR( ALLTRIM( _footer_2 ), 1000 )
        _name := PADR( ALLTRIM( _name ), 500 )
        _filename := PADR( ALLTRIM( _filename ), 500 )
        _sep := PADR( _sep, 1 )
        _sep_formula := PADR( _sep_formula, 1 )
        _force_eol := PADR( _force_eol, 1 )
    endif

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "(*)   Naziv:" GET _name PICT "@S50" VALID !EMPTY( _name )

    ++ _x
    ++ _x  

    @ m_x + _x, m_y + 2 SAY "(*)  Zagl.1:" GET _head_1 PICT "@S50" ;
            VALID {|| EMPTY( _head_1 ) .or. ::copy_existing_formula( @_head_1, "h1" ) }
    
    ++ _x  

    @ m_x + _x, m_y + 2 SAY "(*)  Zagl.2:" GET _head_2 PICT "@S50" ;
            VALID {|| EMPTY( _head_2 ) .or. ::copy_existing_formula( @_head_2, "h2" ) }
    
    ++ _x  
    
    @ m_x + _x, m_y + 2 SAY "(*) Formula:" GET _formula PICT "@S50" ; 
            VALID {|| !EMPTY( _formula ) .and. ::copy_existing_formula( @_formula, "i" ) }

    ++ _x

    @ m_x + _x, m_y + 2 SAY "(*)  Podn.1:" GET _footer_1 PICT "@S50" ;
            VALID {|| EMPTY( _footer_1 ) .or. ::copy_existing_formula( @_footer_1, "f1" ) }
 
    ++ _x

    @ m_x + _x, m_y + 2 SAY "(*)  Podn.2:" GET _footer_2 PICT "@S50" ;
            VALID {|| EMPTY( _footer_2 ) .or. ::copy_existing_formula( @_footer_2, "f2" ) }
    
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Naziv izlaznog fajla:" GET _filename PICT "@S40"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Separator u izl.fajlu [ ; , . ]:" GET _sep 

    ++ _x
 
    @ m_x + _x, m_y + 2 SAY "    Separator formule [ ; , . ]:" GET _sep_formula 

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "     Forsiraj kraj linije (D/N):" GET _force_eol VALID _force_eol $ "DN" PICT "!@" 

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

// write params

set_metric( "virm_export_banke_tek", my_user(), _id_formula )

::formula_params["separator"] := _sep
::formula_params["separator_formula"] := _sep_formula
::formula_params["formula"] := _formula
::formula_params["head_1"] := _head_1
::formula_params["head_2"] := _head_2
::formula_params["footer_1"] := _footer_1
::formula_params["footer_2"] := _footer_2
::formula_params["file"] := _filename
::formula_params["name"] := _name
::formula_params["forsiraj_eol"] := _force_eol

::export_setup_write_params( _id_formula )

return _ok





// -----------------------------------------------------------
// citanje podesenja varijanti
// -----------------------------------------------------------

METHOD VirmExportTxt:export_setup_read_params( id )
local _param_name := "virm_export_" + PADL( ALLTRIM(STR(id)), 2, "0" ) + "_"
local _ok := .t.

::formula_params := hb_hash()
::formula_params["name"] := fetch_metric( _param_name + "name", NIL, NIL )
::formula_params["file"] := fetch_metric( _param_name + "file", NIL, NIL )
::formula_params["formula"] := fetch_metric( _param_name + "formula", NIL, NIL )
::formula_params["head_1"] := fetch_metric( _param_name + "head_1", NIL, NIL )
::formula_params["head_2"] := fetch_metric( _param_name + "head_2", NIL, NIL )
::formula_params["footer_1"] := fetch_metric( _param_name + "footer_1", NIL, NIL )
::formula_params["footer_2"] := fetch_metric( _param_name + "footer_2", NIL, NIL )
::formula_params["separator"] := fetch_metric( _param_name + "sep", NIL, NIL )
::formula_params["separator_formula"] := fetch_metric( _param_name + "sep_formula", NIL, ";" )
::formula_params["forsiraj_eol"] := fetch_metric( _param_name + "force_eol", NIL, NIL )

return _ok





// -----------------------------------------------------------
// snimanje podesenja varijanti
// -----------------------------------------------------------

METHOD VirmExportTxt:export_setup_write_params( id )
local _param_name := "virm_export_" + PADL( ALLTRIM(STR(id)), 2, "0" ) + "_"

set_metric( _param_name + "name", NIL, ALLTRIM( ::formula_params["name"] ) )
set_metric( _param_name + "file", NIL, ALLTRIM( ::formula_params["file"] ) )
set_metric( _param_name + "formula", NIL, ALLTRIM( ::formula_params["formula"] ) )
set_metric( _param_name + "head_1", NIL, ALLTRIM( ::formula_params["head_1"] ) )
set_metric( _param_name + "head_2", NIL, ALLTRIM( ::formula_params["head_2"] ) )
set_metric( _param_name + "footer_1", NIL, ALLTRIM( ::formula_params["footer_1"] ) )
set_metric( _param_name + "footer_2", NIL, ALLTRIM( ::formula_params["footer_2"] ) )
set_metric( _param_name + "sep", NIL, ALLTRIM( ::formula_params["separator"] ) )
set_metric( _param_name + "sep_formula", NIL, ALLTRIM( ::formula_params["separator_formula"] ) )
set_metric( _param_name + "force_eol", NIL, ALLTRIM( ::formula_params["forsiraj_eol"] ) )

return .t.




METHOD VirmExportTxt:get_export_params( id )
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






METHOD VirmExportTxt:get_export_list()
local _id := 0
local _i
local _param_name := "virm_export_"
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




function virm_export_banke()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. export podataka za banku                " )
AADD( _opcexe, {|| virm_export_txt_banka()  } )
AADD( _opc, "2. postavke formula exporta   " )
AADD( _opcexe, {|| virm_export_txt_setup()  } )
AADD( _opc, "3. dupliciranje postojecih postavaki " )
AADD( _opcexe, {|| VirmExportTxt():New():export_setup_duplicate()  } )

f18_menu( "el", .f., _izbor, _opc, _opcexe )

return





function virm_export_txt_banka( params )
local oExp

oExp := VirmExportTxt():New()

// u slucaju da nismo setovali parametre, pozovi ih
if params == NIL
    oExp:params()
endif

oExp:export()

return




function virm_export_txt_setup()
local oExp

oExp := VirmExportTxt():New()
oExp:export_setup()

return




