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


#include "pos.ch"


// ---------------------------------------------------------
// uglavnom funkcije za manipulaciju sa temporary tabelama
// _priprz, _pos, _priprg itd...
// ---------------------------------------------------------



// -------------------------------------------------------------
// prebacuje stavke iz tabele _pos_pripr u tabelu _pos
// -------------------------------------------------------------
function _pripr2_pos( cIdVrsteP )
local cBrdok
local nTrec := 0
local _rec

if cIdVrsteP == nil
    cIdVrsteP := ""
endif

select _pos_pripr
go top

cBrdok := field->brdok

do while !EOF()
    
    _rec := dbf_get_rec()

    select _pos
    append blank
    
    if ( gRadniRac == "N" )
        // u _pos_pripr mora biti samo jedan dokument!!!
        _rec["brdok"] := cBrDok   
    endif

    _rec["idvrstep"] := cIdVrsteP

    dbf_update_rec( _rec )
    
    select _pos_pripr
    skip

enddo

// pobrisi mi _pos_pripr
select _pos_pripr
my_dbf_zap()

return


// ------------------------------------------
// odabir opcija za povrat pripremu
// ------------------------------------------
static function pripr_choice()
local _ch := "1"

// brisati
// spojiti

Box(, 3, 50 )
    @ m_x + 1, m_y + 2 SAY "Priprema nije prazna, sta dalje ? "
    @ m_x + 2, m_y + 2 SAY " (1) brisati pripremu  "
    @ m_x + 3, m_y + 2 SAY " (2) spojiti na postojeci dokument " GET _ch VALID _ch $ "12"
    read
BoxC()

// na ESC
if LastKey() == K_ESC
    // marker "0" za nista odabrano
    _ch := "0"
    return _ch
endif

return _ch




// -------------------------------------------
// pos -> priprz
// -------------------------------------------
function pos_2_priprz()
local _rec
local _t_area := SELECT()
local _oper := "1"
local _exist, _rec2

O_PRIPRZ
select priprz

if RECCOUNT() <> 0
    _oper := pripr_choice()
endif

// brisat cemo pripremu....
if _oper == "1"
   my_dbf_zap()
endif

if _oper == "2"
    // postojeci zapis... u priprz
    _rec2 := dbf_get_rec()
endif

MsgO( "Vrsim povrat dokumenta u pripremu ..." )

select pos
seek pos_doks->( IdPos + IdVd + DTOS(datum) + BrDok )

do while !EOF() .and. pos->( IdPos + IdVd + DTOS( datum ) + BrDok ) == ;
                    pos_doks->( IdPos + IdVd + DTOS( datum ) + BrDok )

    _rec := dbf_get_rec()

    hb_hdel( _rec, "rbr" )
    
    select roba
    HSEEK _rec["idroba"]

    _rec["robanaz"] := roba->naz
    _rec["jmj"] := roba->jmj
    _rec["barkod"] := roba->barkod

    // ako je operacija spajanja
    // spoji dokumente sa postojecim u pripremi....
    if _oper == "2"
        _rec["idpos"] := _rec2["idpos"]
        _rec["idvd"] := _rec2["idvd"]
        _rec["brdok"] := _rec2["brdok"]
    endif

    select priprz
    
    if _oper <> "2"
        append blank 
    endif

    if _oper == "2"

        // pronadji postojeci artikal...
        set order to tag "1"
        hseek _rec["idroba"]

        if !FOUND()
            append blank
        else
            // uzmi postojeci zapis iz pripreme
            _exist := dbf_get_rec()
            // dodaj na postojecu kolicinu kolicinu sa novog dokumenta
            _rec["kol2"] := _rec["kol2"] + _exist["kol2"]
        endif

    endif

    dbf_update_rec( _rec )

    select pos
    skip

enddo

MsgC()

select ( _t_area )
return



// ----------------------------------------
// prebaci iz pos u _pripr
// ----------------------------------------
function pos2_pripr()
local _rec

select _pos_pripr

my_dbf_zap()

go top
scatter()

select pos
seek pos_doks->( IdPos+IdVd+dtos(datum)+BrDok )

do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

    _rec := dbf_get_rec()
    hb_hdel( _rec, "rbr" )
    
    select roba
    HSEEK _IdRoba
    _rec["robanaz"] := roba->naz
    _rec["jmj"] := roba->jmj

    select _pos_pripr
    append blank 

    dbf_update_rec( _rec )

    select pos
    skip

enddo

select _pos_pripr

return






/*! \fn UkloniRadne(cIdRadnik)
 *  \brief Ukloni radne racune (koj se nalaze u _POS tabeli)
 *  \param cIdRadnik
 */
 
function UkloniRadne(cIdRadnik)
SELECT _POS
Set order to tag "1"
SEEK gIdPos+VD_RN
while !eof() .and. _POS->(IdPos+IdVd)==(gIdPos+VD_RN)
    if _POS->IdRadnik==cIdRadnik .and. _POS->M1 == "Z"
        Del_Skip ()
    else
        SKIP
    endif
end
SELECT ZAKSM
return



// --------------------------------------------------------------------------
// vraca dokumente iz privremene pripreme u pripremu zaduzenja itd...
// --------------------------------------------------------------------------
function pos_vrati_dokument_iz_pripr(cIdVd,cIdRadnik,cIdOdj,cIdDio)
local cSta
local cBrDok

do case
    case cIdVd == VD_ZAD
        cSta := "zaduzenja"
    case cIdVd == VD_OTP
        cSta := "otpisa"
    case cIdVd == VD_INV
        cSta := "inventure"
    case cIdVd == VD_NIV
        cSta := "nivelacije"
    otherwise 
        cSta := "ostalo"
endcase

select _pos
set order to tag "2"         
// IdVd+IdOdj+IdRadnik

seek cIdVd+cIdOdj+cIdDio

if FOUND()      
    // .and. (Empty (cIdDio) .or. _POS->IdDio==cIdDio)
    if _pos->idradnik <> cIdRadnik
        // ne mogu dopustiti da vise radnika radi paralelno inventuru, nivelaciju
        // ili zaduzenje
        MsgBeep ("Drugi radnik je poceo raditi pripremu "+cSta+"#"+"AKO NASTAVITE, PRIPREMA SE BRISE!!!", 30)
        if Pitanje(,"Zelite li nastaviti?", " ")=="N"
            return .f.
        endif
        // xIdRadnik := _POS->IdRadnik
        do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)     
            // IdRadnik, xIdRadnik
            Del_Skip()
        enddo
        MsgBeep("Izbrisana je priprema "+cSta)
    else

        Beep (3)

        if Pitanje(, "Poceli ste pripremu! Zelite li nastaviti? (D/N)", "D" ) == "N"
            // brisanje prethodne pripreme
            do while !EOF() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)
                Del_Skip()
            enddo
            MsgBeep ("Priprema je izbrisana ... ")
        else
            // vrati ono sto je poceo raditi
            SELECT _POS
            do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)
                Scatter()
                SELECT PRIPRZ
                Append Blank
                Gather()
                SELECT _POS
                Del_Skip()
            enddo
            SELECT PRIPRZ
            GO TOP
        endif
    endif
endif

SELECT _POS
Set order to tag "1"

return .t.






