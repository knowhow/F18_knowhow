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


#include "mat.ch"

static _pic := "999999999.99"

// --------------------------------------------
// otvara tabele potrebne za izvjestaj
// --------------------------------------------
static function _o_rpt_tables()
O_MAT_SUBAN
O_PARTN
O_KONTO
return



// ----------------------------------------------
// specifikacija po broju dana
// ----------------------------------------------
function mat_spec_br_dan()
local _params := hb_hash()
local _line

_o_rpt_tables()

// uslovi izvjestaja
if !_get_vars( @_params )
    close all
    return 
endif

// kreiraj pomocnu tabelu
_cre_tmp_tbl()
// otvori tabele izvjestaja
_o_rpt_tables()

msgO("Punim pomocnu tabelu izvjestaja...")

// napuni podatke pomocne tabele
_fill_rpt_data( _params )

msgC()

// linija za report
_line := _get_line()

// ispisi izvjestaj iz pomocne tabele
START PRINT CRET
?
P_COND

_show_report( _params, _line )

FF
END PRINT

return


// -----------------------------------------------
// puni podatke pomocne tabele za izvjestaj
// -----------------------------------------------
static function _fill_rpt_data( param )
local _firma := param["firma"]
local _datum := param["datum"]
local _filter := ""
local _usl_1
local _interv_1, _interv_2, _interv_3
local _dug_1, _dug_2, _pot_1, _pot_2
local _saldo_1, _saldo_2

select mat_suban
//"IdFirma+IdKonto+IdRoba+dtos(DatDok)"
set order to tag "3"

_usl_1 := Parsiraj( param["konta"], "IdKonto", "C" )

// napravi filter...
_filter := "idfirma == " + cm2str( _firma )

if _usl_1 != ".t."
    _filter += " .and. " + _usl_1
endif

if !empty( _datum )
    _filter += " .and. DTOS(datdok) <= " + Cm2Str( DTOS( _datum ) )
endif

set filter to &_filter
go top


do while !EOF()
    
    _id_konto := field->idkonto
    
    select konto
    hseek _id_konto

    select mat_suban

    // resetuj brojace
    _interv_1 := 0
    _interv_2 := 0
    _interv_3 := 0
    _saldo_1 := 0
    _saldo_2 := 0
    _dug_1 := 0
    _dug_2 := 0
    _pot_1 := 0
    _pot_2 := 0

    do while !EOF() .and. field->idkonto == _id_konto
        
        // logika izvjestaja
        
        if field->d_p = "1"
            _dug_1 := field->iznos
            _pot_1 := 0
        else
            _pot_1 := field->iznos
            _dug_1 := 0
        endif

        _saldo_1 += _dug_1 - _pot_1  
        _saldo_2 += _dug_2 - _pot_2

        // ovo ce vratiti interval u odnosu na datum dokumenta
        _interval := _get_interval( field->datdok, _datum )

        // prvi interval
        if _interval <= param["interval_1"]
            // ovo je interval do 6 mjeseci npr..
            _interv_1 += _dug_1 - _pot_1
        endif

        // drugi interval
        if _interval > param["interval_1"] .and. _interval <= param["interval_2"]
            // ovo je interval od 6 do 12 mj, npr..  
            _interv_2 += _dug_1 - _pot_1
        endif
    
        // treci interval
        if _interval > param["interval_2"]
            // ovo je interval preko 12 mj. npr...
            _interv_3 += _dug_1 - _pot_1
        endif

        skip

    enddo
   
    if ROUND( _interv_1 + _interv_2 + _interv_3 + _saldo_1, 2 ) == 0 .and. param["prikaz_nule"] == "N"    
        // preskoci...
    else
        // ubaci u pomocnu tabelu podatke
        _fill_tmp_tbl( _id_konto, konto->naz, ; 
                _interv_1, _interv_2, _interv_3, _saldo_1 )
    endif
   
    select mat_suban

enddo


return



// --------------------------------------------------------------
// vraca interval u odnosu na tekuci datum i datum dokumenta
// --------------------------------------------------------------
static function _get_interval( dat_dok, datum )
local _month_dok
local _month_datum
local _ret := 1

_month_dok := MONTH( dat_dok ) 
_month_datum := MONTH( datum )

if _month_datum > _month_dok
    _ret := ( _month_datum - _month_dok )
endif

return _ret




// -----------------------------------------------
// stampa izvjestaj iz pomocne tabele
// -----------------------------------------------
static function _show_report( param, line )
local _rbr := 0
local _u_int_1, _u_int_2, _u_int_3, _u_saldo
local _mark_pos := 0

// ispis zaglavlje...
_zaglavlje( param, line )

select r_export
set order to tag "1"
go top

_u_int_1 := 0
_u_int_2 := 0
_u_int_3 := 0
_u_saldo := 0

do while !EOF()
    
    // provjera novog reda... 
    if prow() > 63
        FF
    endif

    @ prow() + 1, 0 SAY ++_rbr PICT '9999'
    @ prow(), pcol() + 1 SAY field->id_konto
    @ prow(), pcol() + 1 SAY PADR( field->konto_naz, 40 )

    _mark_pos := pcol()
    
    @ prow(), pcol() + 1 SAY field->inter_1 PICT _pic
    @ prow(), pcol() + 1 SAY field->inter_2 PICT _pic
    @ prow(), pcol() + 1 SAY field->inter_3 PICT _pic
    @ prow(), pcol() + 1 SAY field->saldo   PICT _pic

    _u_int_1 += field->inter_1
    _u_int_2 += field->inter_2
    _u_int_3 += field->inter_3
    _u_saldo += field->saldo

    skip

enddo   

// ukupno....
? line
? "UKUPNO :"

@ prow(), _mark_pos SAY ""

@ prow(), pcol() + 1 SAY _u_int_1 PICT _pic
@ prow(), pcol() + 1 SAY _u_int_2 PICT _pic
@ prow(), pcol() + 1 SAY _u_int_3 PICT _pic
@ prow(), pcol() + 1 SAY _u_saldo PICT _pic

? line


return


// -------------------------------------------------
// linija za ogranicavanje na izvjestaju
// -------------------------------------------------
static function _get_line()
local _line := ""

_line += REPLICATE( "-", 4 )
_line += SPACE(1)
_line += REPLICATE( "-", 7 )
_line += SPACE(1)
_line += REPLICATE( "-", 40 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )

return _line






// -------------------------------------------
// zaglavlje izvjestaja.
// -------------------------------------------
static function _zaglavlje( param, line )
local _r_line_1 := ""
local _r_line_2 := ""
local _r_line_3 := ""

? "MAT: SPECIFIKACIJA PO ROCNIM INTERVALIMA, na dan", DATE()
? "Firma: " + param["firma"]

select partn
hseek param["firma"]

select r_export

?? ", " + ALLTRIM( partn->naz )

if !empty( ALLTRIM( param["konta"] ))
    ? "Za konta: " + ALLTRIM(param["konta"]) 
endif

// definisi _r_line...
_r_line_1 += PADR( " R.", 5 )
_r_line_2 += PADR( " br.", 5 )
_r_line_3 += PADR( "", 5 )

_r_line_1 += PADR( " SIFRA", 8 )
_r_line_2 += PADR( " KONTA", 8 )
_r_line_3 += PADR( "", 8 )

_r_line_1 += PADR( "", 41 )
_r_line_2 += PADR( "      N A Z I V   K O N T A", 41 )
_r_line_3 += PADR( "", 41 )

_r_line_1 += PADR( " VRIJEDNOST", 13 )
_r_line_2 += PADR( "    DO", 13 )
_r_line_3 += PADR( "   " + ALLTRIM(str(param["interval_1"], 3)) + " mj.", 13 )

_r_line_1 += PADR( " VRIJEDNOST", 13 )
_r_line_2 += PADR( "  OD " + ALLTRIM(str(param["interval_1"], 3)) + " mj.", 13 )
_r_line_3 += PADR( "  DO " + ALLTRIM(str(param["interval_2"], 3)) + " mj.", 13 )

_r_line_1 += PADR( " VRIJEDNOST", 13 )
_r_line_2 += PADR( "   PREKO", 13 )
_r_line_3 += PADR( "   " + ALLTRIM(str(param["interval_2"], 3)) + " mj.", 13 )

_r_line_1 += PADR( "   UKUPNA", 13 )
_r_line_2 += PADR( " VRIJEDNOST", 13 )
_r_line_3 += PADR( "", 13 )


? line
? _r_line_1
? _r_line_2
? _r_line_3
? line

return




// ----------------------------------------------
// parametri izvjestaja
// ----------------------------------------------
static function _get_vars( params )
local _cnt := 1
local _ret := .t.
local _konta := SPACE(200)
local _firma := gFirma
local _date := DATE()
local _int_1 := 6
local _int_2 := 12
local _nule := "N"

Box(, 10, 70 )

    if gNW == "D"
        @ m_x + _cnt, m_y + 2 SAY "Firma "
	    ?? gFirma, "-", gNFirma
    else
	    @ m_x + _cnt, m_y + 2 SAY "Firma: " GET _firma ;
		    VALID {|| P_Firma( @_firma ), _firma := left( _firma, 2 ), .t. }
    endif

    ++ _cnt
    ++ _cnt

    @ m_x + _cnt, m_y + 2 SAY "Konto (prazno-sva):" GET _konta PICT "@S50"

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Izvjestaj se pravi na dan:" GET _date

    ++ _cnt
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Interval 1 (mj):" GET _int_1 PICT "999"
    
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Interval 2 (mj):" GET _int_2 PICT "999"

    ++ _cnt
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Prikaz stavki sa stanjem 0 (D/N)?" GET _nule ;
            VALID _nule $ "DN" PICT "!@"
    
    read

BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// setuj parmetre u hash matricu
params["firma"] := _firma
params["datum"] := _date
params["konta"] := _konta
params["interval_1"] := _int_1
params["interval_2"] := _int_2
params["prikaz_nule"] := _nule

return _ret



// ------------------------------------------------
// filovanje pomocne tabele 
// ------------------------------------------------
static function _fill_tmp_tbl( id_konto, konto_naz, ; 
            interval_1, interval_2, interval_3, saldo )

local _arr := SELECT()

select (F_R_EXP)
if !used()
    O_R_EXP
endif

append blank
replace field->id_konto with id_konto
replace field->konto_naz with konto_naz
replace field->inter_1 with interval_1
replace field->inter_2 with interval_2
replace field->inter_3 with interval_3
replace field->saldo with saldo

select (_arr)

return


// -------------------------------------------------------
// vraca matricu pomocne tabele za izvjestaj
// -------------------------------------------------------
static function _cre_tmp_tbl()
local _dbf := {}

AADD( _dbf, { "id_konto", "C", 7, 0 } )
AADD( _dbf, { "konto_naz","C", 50, 0 } )
AADD( _dbf, { "inter_1", "N", 15, 3 } )
AADD( _dbf, { "inter_2", "N", 15, 3 } )
AADD( _dbf, { "inter_3", "N", 15, 3 } )
AADD( _dbf, { "saldo", "N", 15, 3 } )

// kreiraj tabelu
t_exp_create( _dbf )

O_R_EXP
// indeksiraj...
index on id_konto tag "1" 

return




