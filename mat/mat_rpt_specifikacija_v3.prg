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


static PicDEM := "99999999.99"
static PicBHD := "9999999999.99"
static PicKol := "9999999.99"



// -------------------------------------------------
// otvara potrebne tabele za report
// -------------------------------------------------
static function _o_rpt_tables()
O_ROBA
O_SIFV
O_SIFK
O_MAT_SUBAN
O_PARTN
return


static function _get_vars( params )
local _fmt
local _firma
local _konta
local _artikli
local _dat_od
local _dat_do
local _cnt := 1
local _ret := .t.

// inicijalizujem def.parametre
params["format"] := "2"
params["firma"] := gFirma
params["konta"] := SPACE(200)
params["artikli"] := SPACE(200)
params["dat_od"] := CTOD( "" )
params["dat_do"] := CTOD( "" )

_fmt := params["format"]
_firma := params["firma"]
_konta := params["konta"]
_artikli := params["artikli"]
_dat_od := params["dat_od"]
_dat_do := params["dat_do"]

Box( "Spe2", 7, 65, .f. )

    ++ _cnt

    @ m_x + _cnt, m_y + 2 SAY "Iznos u " + ValPomocna() + "/" + ValDomaca() + "(1/2) ?" GET _fmt ;
                VALID _fmt $ "12"
    read
    
    if _fmt == "1"
        _fmt := "2"
    else
        _fmt := "3"
    endif

    ++ _cnt
    ++ _cnt

    if gNW $ "DR"
        @ m_x + _cnt, m_y + 2 SAY "Firma "
        ?? gFirma, "-", gNFirma
    else
        @ m_x + _cnt, m_y + 2 SAY "Firma: " GET _firma ;
            VALID {|| P_Firma( @_firma ), _firma := left( _firma, 2 ), .t. }
    endif

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Konta : " GET _konta PICT "@S50"
    
    ++ _cnt
    @ m_x + 6, m_y + 2 SAY "Artikli : " GET _artikli PICT "@S50"
    
    ++ _cnt
    @ m_x + 7, m_y + 2 SAY "Datum dokumenta - od:" GET _dat_od
    @ m_x + 7, col() + 1 SAY "do:" GET _dat_do VALID _dat_do >= _dat_od

    read

BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// parametre napuni sa varijablama
params["format"] := _fmt
params["firma"] := _firma
params["konta"] := _konta
params["artikli"] := _artikli
params["dat_od"] := _dat_od
params["dat_do"] := _dat_do

return _ret



// -------------------------------------------------
// linija za ogranicavanje na izvjestaju
// -------------------------------------------------
static function _get_line( r_format )
local _line := ""

_line += REPLICATE( "-", 4 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )
_line += SPACE(1)
_line += REPLICATE( "-", 40 )
_line += SPACE(1)
_line += REPLICATE( "-", 3 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )

if r_format == "1"    
    _line += SPACE(1)
    _line += REPLICATE( "-", 10 )
    _line += SPACE(1)
    _line += REPLICATE( "-", 10 )
    _line += SPACE(1)
    _line += REPLICATE( "-", 10 )
endif

_line += SPACE(1)
_line += REPLICATE( "-", 11 )
_line += SPACE(1)
_line += REPLICATE( "-", 11 )
_line += SPACE(1)
_line += REPLICATE( "-", 11 )

if r_format == "1"
    _line += SPACE(1)
    _line += REPLICATE( "-", 12 )
    _line += SPACE(1)
    _line += REPLICATE( "-", 12 )
    _line += SPACE(1)
    _line += REPLICATE( "-", 12 )
endif

return _line



// ----------------------------------------------------
// sinteticka specifikacija
// ----------------------------------------------------
function mat_sint_specifikacija()
local _params := hb_hash()
local _usl_1
local _usl_2
local _dat_od
local _dat_do
local _firma
local _fmt
local _line
local _mark_pos
local _dug_1, _pot_1, _dug_2, _pot_2
local _ulaz_k_1, _izlaz_k_1, _ulaz_k_2, _izlaz_k_2
local _saldo_k_1, _saldo_k_2, _saldo_i_1, _saldo_i_2
local _rbr
local _id_roba, _roba_naz, _roba_jmj
local _filter := ""

// otvori potrebne tabele
_o_rpt_tables()

// daj mi uslove izvjestaja
if !_get_vars( @_params )
    close all
    return
endif

_usl_1 := Parsiraj( _params["konta"], "IdKonto", "C" )
_usl_2 := Parsiraj( _params["artikli"], "IdRoba", "C" )
_dat_od := _params["dat_od"]
_dat_do := _params["dat_do"]
_firma := LEFT( _params["firma"], 2 )
_fmt := _params["format"]

select mat_suban   
// "IdFirma+IdRoba+dtos(DatDok)"
set order to tag "1"

// napravi filter...
_filter := "idfirma == " + cm2str( _firma )

if _usl_1 != ".t."
    _filter += " .and. " + _usl_1
endif

if _usl_2 != ".t."
    _filter += " .and. " + _usl_2
endif

if !empty( _dat_od ) .or. !empty( _dat_do )
    _filter += " .and. DTOS(datdok) <= " + Cm2Str( DTOS( _dat_do ) )
    _filter += " .and. DTOS(datdok) >= " + Cm2Str( DTOS( _dat_od ) )
endif

set filter to &_filter

go top

EOF CRET

// daj mi liniju za izvjestaj
_line := _get_line( _fmt )

START PRINT CRET

?
_mark_pos := 0

// stampaj zaglavlje
_zaglavlje( _params, _line )

select mat_suban

_rbr := 0
_uk_dug_1 := 0
_uk_pot_1 := 0
_uk_dug_2 := 0
_uk_pot_2 := 0

do while !EOF()
   
    // provjera novog reda... 
    if prow() > 63
        FF
    endif

    select mat_suban
      
    _id_roba := field->idroba

    // resetuj brojace...
    _dug_1 := 0
    _pot_1 := 0
    _dug_2 := 0
    _pot_2 := 0
    _ulaz_k_1 := 0
    _izlaz_k_1 := 0
    _ulaz_k_2 := 0
    _izlaz_k_2 := 0
    _saldo_k_1 := 0
    _saldo_k_2 := 0
    _saldo_i_1 := 0
    _saldo_i_2 := 0

    do while !EOF() .and. _id_roba = field->idroba

        // saberi ulaze/izlaze
        if field->u_i = "1"
            _ulaz_k_1 += field->kolicina
        else
            _izlaz_k_1 += field->kolicina
        endif
        
        // saberi iznose d/p
        if field->d_p = "1"
            _dug_1 += field->iznos
            _dug_2 += field->iznos2
        else
            _pot_1 += field->iznos
            _pot_2 += field->iznos2
        endif
        
        skip
    
    enddo

    select roba
    hseek _id_roba

    _roba_naz := PADR( field->naz, 40 )
    _roba_jmj := field->jmj

    select mat_suban

    _saldo_k_1 := _ulaz_k_1 - _izlaz_k_1
    _saldo_i_1 := _dug_1 - _pot_1
    _saldo_k_2 := _ulaz_k_2 - _izlaz_k_2
    _saldo_i_2 := _dug_2 - _pot_2

    @ prow() + 1, 0 SAY ++_rbr PICT '9999'
    @ prow(), pcol() + 1 SAY _id_roba
    @ prow(), pcol() + 1 SAY _roba_naz
    @ prow(), pcol() + 1 SAY _roba_jmj

    if _fmt == "1"
        @ prow(), pcol() + 1 SAY roba->nc PICT "999999.999"
        @ prow(), pcol() + 1 SAY roba->vpc PICT "999999.999"
        @ prow(), pcol() + 1 SAY roba->mpc PICT "999999.999"
    endif

    @ prow(), pcol() + 1 SAY _ulaz_k_1 PICTURE picKol
    @ prow(), pcol() + 1 SAY _izlaz_k_1 PICTURE picKol
    @ prow(), pcol() + 1 SAY _saldo_k_1 PICTURE picKol
    
    _mark_pos := pcol()
     
    if _fmt $ "12"
        @ prow(),pcol()+1 SAY _dug_1 PICT PicDEM
        @ prow(),pcol()+1 SAY _pot_1 PICT PicDEM
        @ prow(),pcol()+1 SAY _saldo_i_1 PICT PicDEM
    endif
     
    if _fmt $ "13"
        @ prow(),pcol()+1 SAY _dug_2 PICT PicBHD
        @ prow(),pcol()+1 SAY _pot_2 PICT PicBHD
        @ prow(),pcol()+1 SAY _saldo_i_2 PICT PicBHD
    endif

    _uk_dug_1 += _dug_1
    _uk_pot_1 += _pot_1
    _uk_dug_2 += _dug_2
    _uk_pot_2 += _pot_2

enddo

?  _line
?  "UKUPNO :"

@  prow(), _mark_pos SAY ""

if _fmt $ "12"  
    @ prow(), pcol() + 1 SAY _uk_dug_1 PICT PicDEM
    @ prow(), pcol() + 1 SAY _uk_pot_1 PICT PicDEM
    @ prow(), pcol() + 1 SAY ( _uk_dug_1 - _uk_pot_1 ) PICT PicDEM
endif

if _fmt $ "13"
    @ prow(), pcol() + 1 SAY _uk_dug_2 PICT PicBHD
    @ prow(), pcol() + 1 SAY _uk_pot_2 PICT PicBHD
    @ prow(), pcol() + 1 SAY ( _uk_dug_2 - _uk_pot_2 ) PICT PicBHD
endif

? _line

FF
END PRINT

close all

return


// ------------------------------------------------------------
// zaglavlje izvestaja...
// ------------------------------------------------------------
static function _zaglavlje( param, line )

P_COND
@ prow(), 0 SAY "MAT.P: SPECIFIKACIJA ROBE (U "

if param["format"] == "1"
    ?? ValPomocna() + "/" + ValDomaca() + ") "
elseif param["format"] == "2"
    ?? ValPomocna() + ") "
else
    ?? ValDomaca() + ") "
endif
    
if !empty( param["dat_od"] ) .or. !empty( param["dat_do"] )
    ?? "ZA PERIOD OD", param["dat_od"], "-", param["dat_do"]
endif
   
?? "      NA DAN:"
@ prow(), pcol() + 1 SAY DATE()

@ prow() + 1, 0 SAY "FIRMA:"
@ prow(), pcol() + 1 SAY param["firma"]

select partn
hseek param["firma"]

@ prow(), pcol() + 1 SAY field->naz
@ prow(), pcol() + 1 SAY field->naz2
   
? "Kriterij za " + KonSeks("konta") + ":", trim( param["konta"] )
   
select mat_suban
? line
   
if param["format"] == "2"
    ? "*R. *  SIFRA   *       N A Z I V                        *J. *       K O L I C I N A          *     V R I J E D N O S T          *"
    ? "*Br.*                                                       -------------------------------- ------------------------------------"
    ? "*   *          *                                        *MJ.*   ULAZ   *  IZLAZ   *  STANJE  *  DUGUJE   * POTRAZUJE *  SALDO   *"
elseif param["format"] == "3"
    ? "*R. *  SIFRA   *       N A Z I V                        *J. *       K O L I C I N A          *        V R I J E D N O S T          *"
    ? "*Br.*                                                       -------------------------------- ---------------------------------------"
    ? "*   *          *                                        *MJ.*   ULAZ   *  IZLAZ   *  STANJE  *  DUGUJE    *  POTRAZUJE *  SALDO    *"
endif
    
?  line

return


