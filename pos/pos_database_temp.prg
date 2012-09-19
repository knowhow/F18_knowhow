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
Zapp() 
__dbPack()

return



// -------------------------------------------
// pos -> priprz
// -------------------------------------------
function pos_2_priprz()
local _rec
local _t_area := SELECT()

O_PRIPRZ
select priprz

Zapp()
__dbPack()

select pos
seek pos_doks->( IdPos + IdVd + DTOS(datum) + BrDok )

do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

    _rec := dbf_get_rec()

    hb_hdel( _rec, "rbr" )
    
    select roba
    HSEEK _rec["idroba"]

    _rec["robanaz"] := roba->naz
    _rec["jmj"] := roba->jmj
    _rec["barkod"] := roba->barkod

    select priprz
    append blank 

    dbf_update_rec( _rec )

    select pos
    skip

enddo

select ( _t_area )
return



// ----------------------------------------
// prebaci iz pos u _pripr
// ----------------------------------------
function pos2_pripr()
local _rec

select _pos_pripr

Zapp()
__dbPack()

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
            do while !eof() .and. _POS->(IdVd+IdOdj+IdDio)==(cIdVd+cIdOdj+cIdDio)
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






