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


#include "f18.ch"

static _pic := "999999999.99"
static _skip_docs := "#00#"


// --------------------------------------------
// otvara tabele potrebne za izvjestaj
// --------------------------------------------
static function _o_rpt_tables()
O_MAT_SUBAN
O_ROBA
O_SIFK
O_SIFV
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
    my_close_all_dbf()
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
P_COND2

_show_report( _params, _line )

FF
ENDPRINT

return


// -----------------------------------------------
// puni podatke pomocne tabele za izvjestaj
// -----------------------------------------------
static function _fill_rpt_data( param )
local _firma := param["firma"]
local _datum := param["datum"]
local _filter := ""
local _usl_konto, _usl_artikli
local _interv_1, _interv_2, _interv_3
local _dug_1, _dug_2, _pot_1, _pot_2
local _saldo_1, _saldo_2
local _id_roba, _roba_naz
local _ima_poc_stanje := .f.

select mat_suban
//"IdFirma+IdKonto+IdRoba+dtos(DatDok)"
set order to tag "3"

_usl_konto := Parsiraj( param["konta"], "IdKonto", "C" )
_usl_artikli := Parsiraj( param["artikli"], "IdRoba", "C" )

// napravi filter...
_filter := "idfirma == " + cm2str( _firma )

if _usl_konto != ".t."
    _filter += " .and. " + _usl_konto
endif

if _usl_artikli != ".t."
    _filter += " .and. " + _usl_artikli
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

    // prodji kroz odredjeni konto
    do while !EOF() .and. field->idkonto == _id_konto

        // resetuj brojace
        _int_k_1 := 0
        _int_k_2 := 0
        _int_k_3 := 0
        _int_i_1 := 0
        _int_i_2 := 0
        _int_i_3 := 0
        _saldo_k := 0
        _saldo_i := 0
        _dug := 0
        _pot := 0
        _ulaz := 0
        _izlaz := 0

        _id_roba := field->idroba

        // nadji mi robu
        select roba
        hseek _id_roba
        _roba_naz := roba->naz

        select mat_suban

        // prodji sada kroz stavke artikla
        do while !EOF() .and. field->idkonto == _id_konto .and. field->idroba == _id_roba
        
            // logika izvjestaja
                    
            if field->idvn == "00"
                _ima_poc_stanje := .t.
            endif

            if field->u_i == "1"
                _ulaz := field->kolicina
                _izlaz := 0
            else
                _izlaz := field->kolicina
                _ulaz := 0
            endif 

            if field->d_p = "1"
                _dug := field->iznos
                _pot := 0
            else
                _pot := field->iznos
                _dug := 0
            endif

            _saldo_k += _ulaz - _izlaz  
            _saldo_i += _dug - _pot  

            // ovo ce vratiti interval u odnosu na datum dokumenta
            _interval := _get_interval( field->datdok, _datum )

            // prvi interval, gledamo samo pozitivne ulaze
            if _interval <= param["interval_1"]
                // ovo je interval do 6 mjeseci npr..
                if ( ! ( field->idvn $ _skip_docs ) .and. field->kolicina > 0 ) .or. field->idvn == "03"
                    _int_i_1 += _dug 
                    _int_k_1 += _ulaz 
                endif
            endif

            // drugi interval, gledamo samo pozitivne ulaze opet
            if _interval > param["interval_1"] .and. _interval <= param["interval_2"]
                // ovo je interval od 6 do 12 mj, npr..  
                if ( ! ( field->idvn $ _skip_docs ) .and. field->kolicina > 0 ) .or. field->idvn == "03"
                    _int_i_2 += _dug 
                    _int_k_2 += _ulaz 
                endif
            endif
    
            // treci interval
            if _interval > param["interval_2"]
                // ovo je interval preko 12 mj, npr..  
                if field->kolicina > 0 .or. field->idvn == "03"
                    _int_i_3 += _dug 
                    _int_k_3 += _ulaz 
                endif
            endif
    
            skip

        enddo
        
        if ( _int_k_1 <= 0 )
            _int_k_1 := 0
            _int_i_1 := 0
        endif

        if ( _int_k_2 <= 0 )
            _int_k_2 := 0
            _int_i_2 := 0
        endif

        if ( _int_k_3 <= 0 )
            _int_k_3 := 0
            _int_i_3 := 0
        endif

        // ako je saldo manji od prvog intervala
        if ( _int_k_1 > 0 ) .and. ( _saldo_k < _int_k_1 )

            _int_k_1 := _saldo_k
            _int_i_1 := _saldo_i
    
            // ostale intervale resetuj
            _int_k_2 := 0
            _int_i_2 := 0

            _int_k_3 := 0
            _int_i_3 := 0

        // ako je saldo manji od drugog intervala
        elseif ( _int_k_1 == 0 .and. _int_k_2 > 0 ) .and. ( _saldo_k < _int_k_2 )

            // ostale intervale resetuj
            _int_k_1 := 0
            _int_i_1 := 0

            // a drugi setuj na ovaj iznos 
            _int_k_2 := _saldo_k
            _int_i_2 := _saldo_i

            _int_k_3 := 0
            _int_i_3 := 0

        // ako je saldo manji od treceg intervala
        elseif ( _int_k_1 == 0 .and. _int_k_2 == 0 .and. _int_k_3 > 0 ) .and. ( _saldo_k < _int_k_3 )

            // ostale intervale resetuj
            _int_k_1 := 0
            _int_i_1 := 0

            _int_k_2 := 0
            _int_i_2 := 0

            // a drugi setuj na ovaj iznos 
            _int_k_3 := _saldo_k
            _int_i_3 := _saldo_i

        else

            // ako nije nista od toga racunaj treci interval ovako
            _int_k_3 := ( _saldo_k - _int_k_1 - _int_k_2 )
            _int_i_3 := ( _saldo_i - _int_i_1 - _int_i_2 )
 
        endif

       
        // ako je negativan onda je nula
        if _int_k_3 < 0
            _int_k_3 := 0
            _int_i_3 := 0
        endif
   
        if ROUND( _saldo_k, 2 ) == 0 .and. param["prikaz_nule"] == "N"    
            // preskoci...
        else
            // ubaci u pomocnu tabelu podatke
            _fill_tmp_tbl( _id_konto, konto->naz, _id_roba, _roba_naz, ; 
                _int_k_1, _int_k_2, _int_k_3, ;
                _int_i_1, _int_i_2, _int_i_3, ;
                 _saldo_k, _saldo_i )
        endif
   
        select mat_suban

    enddo

enddo


return



// --------------------------------------------------------------
// vraca interval u odnosu na tekuci datum i datum dokumenta
// --------------------------------------------------------------
static function _get_interval( dat_dok, datum )
local _ret := 1

_ret := ( datum - dat_dok ) / 30

return _ret




// -----------------------------------------------
// stampa izvjestaj iz pomocne tabele
// -----------------------------------------------
static function _show_report( param, line )
local _rbr := 0
local _u_int_k_1, _u_int_k_2, _u_int_k_3, _u_saldo_k, _u_saldo_i
local _t_int_k_1, _t_int_k_2, _t_int_k_3, _t_saldo_k, _t_saldo_i
local _mark_pos := 0
local _id_konto, _konto_naz

// ispis zaglavlje...
_zaglavlje( param, line )

select r_export
set order to tag "1"
go top

_t_int_k_1 := 0
_t_int_k_2 := 0
_t_int_k_3 := 0
_t_int_i_1 := 0
_t_int_i_2 := 0
_t_int_i_3 := 0
_t_saldo_k := 0
_t_saldo_i := 0

do while !EOF()

    _id_konto := field->id_konto
    _konto_naz := field->konto_naz
 
    _u_int_k_1 := 0
    _u_int_k_2 := 0
    _u_int_k_3 := 0
    _u_int_i_1 := 0
    _u_int_i_2 := 0
    _u_int_i_3 := 0
    _u_saldo_k := 0
    _u_saldo_i := 0

    do while !EOF() .and. field->id_konto == _id_konto

        _n_str( 63 )
           
        @ prow() + 1, 0 SAY ++_rbr PICT '9999'
        @ prow(), pcol() + 1 SAY field->id_roba
        @ prow(), pcol() + 1 SAY PADR( field->roba_naz, 40 )

        _mark_pos := pcol()
    
        @ prow(), pcol() + 1 SAY field->saldo_k   PICT _pic
        @ prow(), pcol() + 1 SAY field->saldo_i   PICT _pic

        @ prow(), pcol() + 1 SAY field->inter_k_1 PICT _pic
        @ prow(), pcol() + 1 SAY field->inter_i_1 PICT _pic
        
        @ prow(), pcol() + 1 SAY field->inter_k_2 PICT _pic
        @ prow(), pcol() + 1 SAY field->inter_i_2 PICT _pic
        
        @ prow(), pcol() + 1 SAY field->inter_k_3 PICT _pic
        @ prow(), pcol() + 1 SAY field->inter_i_3 PICT _pic
        
        _u_int_k_1 += field->inter_k_1
        _u_int_k_2 += field->inter_k_2
        _u_int_k_3 += field->inter_k_3
        _u_saldo_k += field->saldo_k
 
        _u_int_i_1 += field->inter_i_1
        _u_int_i_2 += field->inter_i_2
        _u_int_i_3 += field->inter_i_3
        _u_saldo_i += field->saldo_i
    
        _t_int_k_1 += field->inter_k_1
        _t_int_k_2 += field->inter_k_2
        _t_int_k_3 += field->inter_k_3
        _t_saldo_k += field->saldo_k
    
        _t_int_i_1 += field->inter_i_1
        _t_int_i_2 += field->inter_i_2
        _t_int_i_3 += field->inter_i_3
        _t_saldo_i += field->saldo_i

        skip

    enddo

    // ispisi total za konto
    ? line
    
    @ prow() + 1, 0 SAY PADR( " kt:", 4 )
    @ prow(), pcol() + 1 SAY PADR( _id_konto, 10 )
    @ prow(), pcol() + 1 SAY PADR( _konto_naz, 40 )
    @ prow(), pcol() + 1 SAY _u_saldo_k PICT _pic
    @ prow(), pcol() + 1 SAY _u_saldo_i PICT _pic
    @ prow(), pcol() + 1 SAY _u_int_k_1 PICT _pic
    @ prow(), pcol() + 1 SAY _u_int_i_1 PICT _pic
    @ prow(), pcol() + 1 SAY _u_int_k_2 PICT _pic
    @ prow(), pcol() + 1 SAY _u_int_i_2 PICT _pic
    @ prow(), pcol() + 1 SAY _u_int_k_3 PICT _pic
    @ prow(), pcol() + 1 SAY _u_int_i_3 PICT _pic
    ? line

enddo   

// ukupno....
? line
? "UKUPNO :"

@ prow(), _mark_pos SAY ""
@ prow(), pcol() + 1 SAY _t_saldo_k PICT _pic
@ prow(), pcol() + 1 SAY _t_saldo_i PICT _pic
@ prow(), pcol() + 1 SAY _t_int_k_1 PICT _pic
@ prow(), pcol() + 1 SAY _t_int_i_1 PICT _pic
@ prow(), pcol() + 1 SAY _t_int_k_2 PICT _pic
@ prow(), pcol() + 1 SAY _t_int_i_2 PICT _pic
@ prow(), pcol() + 1 SAY _t_int_k_3 PICT _pic
@ prow(), pcol() + 1 SAY _t_int_i_3 PICT _pic
? line


return


// ------------------------------------
// provjera novog reda... 
// ------------------------------------
static function _n_str( row )
if prow() > row
    FF
endif
return



// -------------------------------------------------
// linija za ogranicavanje na izvjestaju
// -------------------------------------------------
static function _get_line()
local _line := ""

_line += REPLICATE( "-", 4 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )
_line += SPACE(1)
_line += REPLICATE( "-", 40 )
_line += SPACE(1)
_line += REPLICATE( "-", 25 )
_line += SPACE(1)
_line += REPLICATE( "-", 25 )
_line += SPACE(1)
_line += REPLICATE( "-", 25 )
_line += SPACE(1)
_line += REPLICATE( "-", 25 )


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

if !empty( ALLTRIM( param["artikli"] ))
    ? "Artikli: " + ALLTRIM(param["artikli"]) 
endif


// definisi _r_line...
_r_line_1 += PADR( " R.", 5 )
_r_line_2 += PADR( " br.", 5 )
_r_line_3 += PADR( "", 5 )

_r_line_1 += PADR( " SIFRA", 11 )
_r_line_2 += PADR( " ART.", 11 )
_r_line_3 += PADR( "", 11 )

_r_line_1 += PADR( "", 41 )
_r_line_2 += PADR( "      N A Z I V   A R T I K L A", 41 )
_r_line_3 += PADR( "", 41 )

_r_line_1 += PADR( "  UKUPNE VRIJEDNOSTI", 26 )
_r_line_2 += PADR( "", 26 )
_r_line_3 += PADR( PADC("KOLICINA", 12) + PADC("IZNOS", 12), 26 )

_r_line_1 += PADR( "           DO " + ALLTRIM(str(param["interval_1"], 3)) + " mj.", 26 )
_r_line_2 += PADR( "", 26 )
_r_line_3 += PADR( PADC("KOLICINA", 12) + PADC("IZNOS", 12), 26 )

_r_line_1 += PADR( "       OD " + ALLTRIM(str(param["interval_1"], 3)) + " mj.", 26 )
_r_line_2 += PADR( "       DO " + ALLTRIM(str(param["interval_2"], 3)) + " mj.", 26 )
_r_line_3 += PADR( PADC("KOLICINA", 12) + PADC("IZNOS", 12), 26 )

_r_line_1 += PADR( "     PREKO " + ALLTRIM(str(param["interval_2"], 3)) + " mj.", 26 )
_r_line_2 += PADR( "", 26 )
_r_line_3 += PADR( PADC("KOLICINA", 12) + PADC("IZNOS", 12), 26 )


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
local _artikli := SPACE(200)
local _firma := gFirma
local _date := DATE()
local _int_1 := 6
local _int_2 := 12
local _nule := "N"
local _curr_user := "<>"

_konta := fetch_metric("mat_spec_br_dana_konta", _curr_user, _konta )
_artikli := fetch_metric("mat_spec_br_dana_artikli", _curr_user, _artikli )
_firma := fetch_metric("mat_spec_br_dana_firma", _curr_user, _firma )
_int_1 := fetch_metric("mat_spec_br_dana_interval_1", _curr_user, _int_1 )
_int_2 := fetch_metric("mat_spec_br_dana_interval_2", _curr_user, _int_2 )
_nule := fetch_metric("mat_spec_br_dana_prikaz_nula", _curr_user, _nule )
_date := fetch_metric("mat_spec_br_dana_datum", _curr_user, _date )

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

    @ m_x + _cnt, m_y + 2 SAY "  Konto (prazno-sva):" GET _konta PICT "@S45"

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Artikli (prazno-sva):" GET _artikli PICT "@S45"
    
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Izvjestaj se pravi na dan:" GET _date

    ++ _cnt
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Interval 1 (mj):" GET _int_1 PICT "999"
    
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Interval 2 (mj):" GET _int_2 PICT "999"

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
params["artikli"] := _artikli
params["interval_1"] := _int_1
params["interval_2"] := _int_2
params["prikaz_nule"] := _nule

// snimi parametre
set_metric("mat_spec_br_dana_konta", f18_user(), _konta )
set_metric("mat_spec_br_dana_artikli", f18_user(), _artikli )
set_metric("mat_spec_br_dana_firma", f18_user(), _firma )
set_metric("mat_spec_br_dana_interval_1", f18_user(), _int_1 )
set_metric("mat_spec_br_dana_interval_2", f18_user(), _int_2 )
set_metric("mat_spec_br_dana_prikaz_nula", f18_user(), _nule )
set_metric("mat_spec_br_dana_datum", f18_user(), _date )

return _ret



// ------------------------------------------------
// filovanje pomocne tabele 
// ------------------------------------------------
static function _fill_tmp_tbl( id_konto, konto_naz, id_roba, roba_naz, ; 
            int_k_1, int_k_2, int_k_3, int_i_1, int_i_2, int_i_3, saldo_k, saldo_i )

local _arr := SELECT()

select (F_R_EXP)
if !used()
    O_R_EXP
endif

append blank
replace field->id_konto with id_konto
replace field->konto_naz with konto_naz
replace field->id_roba with id_roba
replace field->roba_naz with roba_naz
replace field->inter_k_1 with int_k_1
replace field->inter_k_2 with int_k_2
replace field->inter_k_3 with int_k_3
replace field->inter_i_1 with int_i_1
replace field->inter_i_2 with int_i_2
replace field->inter_i_3 with int_i_3
replace field->saldo_k with saldo_k
replace field->saldo_i with saldo_i

select (_arr)

return


// -------------------------------------------------------
// vraca matricu pomocne tabele za izvjestaj
// -------------------------------------------------------
static function _cre_tmp_tbl()
local _dbf := {}

AADD( _dbf, { "id_konto", "C", 7, 0 } )
AADD( _dbf, { "konto_naz","C", 50, 0 } )
AADD( _dbf, { "id_roba", "C", 10, 0 } )
AADD( _dbf, { "roba_naz","C", 50, 0 } )
AADD( _dbf, { "inter_k_1", "N", 15, 3 } )
AADD( _dbf, { "inter_k_2", "N", 15, 3 } )
AADD( _dbf, { "inter_k_3", "N", 15, 3 } )
AADD( _dbf, { "inter_i_1", "N", 15, 3 } )
AADD( _dbf, { "inter_i_2", "N", 15, 3 } )
AADD( _dbf, { "inter_i_3", "N", 15, 3 } )
AADD( _dbf, { "saldo_k", "N", 15, 3 } )
AADD( _dbf, { "saldo_i", "N", 15, 3 } )

// kreiraj tabelu
t_exp_create( _dbf )

O_R_EXP
// indeksiraj...
index on id_konto + id_roba tag "1" 

return




