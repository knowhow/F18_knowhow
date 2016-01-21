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



// -----------------------------------------------------
// vraca naslov dokumenta
// -----------------------------------------------------
static function _get_naslov_dokumenta( id_vd )
local _ret := "????"

if id_vd == "16"  
    _ret := "PRIJEM U MAGACIN (INTERNI DOKUMENT):"
elseif id_vd == "96"
    _ret := "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
elseif id_vd == "97"
    _ret := "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
elseif id_vd == "95"
    _ret := "OTPIS MAGACIN:"
endif

return _ret




// ----------------------------------------------------------
// stampa kalkulacije tip-a 95, 96, 97
// ----------------------------------------------------------
function StKalk95_1()
local cKto1
local cKto2
local cIdZaduz2
local cPom
local _naslov
local nCol1 := nCol2 := 0, nPom := 0
local _page_len := RPT_PAGE_LEN
private nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

nStr := 0
cIdPartner := field->IdPartner
cBrFaktP := field->BrFaktP
dDatFaktP := field->DatFaktP
cIdKonto := field->IdKonto
cIdKonto2 := field->IdKonto2
cIdZaduz2 := field->IdZaduz2

P_12CPI

?? "KALK BR:", cIdFirma + "-" + cIdVD + "-" + ALLTRIM( cBrDok ), "  Datum:", field->datdok

@ prow(), 76 SAY "Str:" + STR( ++nStr, 3 )

// ispis naslov dokumenta
_naslov := _get_naslov_dokumenta( cIdVd )

?
? _naslov
? 

if cIdVd $ "95#96#97"
    cPom:= "Razduzuje:"
    cKto1:= cIdKonto2
    cKto2:= cIdKonto
else
    cPom:= "Zaduzuje:"
    cKto1:= cIdKonto
    cKto2:= cIdKonto2
endif

select konto
hseek cKto1

? PADL( cPom, 14 ), ALLTRIM( cKto1 ) + " - " + PADR( konto->naz, 60 )

if !EMPTY( cKto2 )

    if cIdVd $ "95#96#97"
        cPom := "Zaduzuje:"
    else
        cPom := "Razduzuje:"
    endif

    select konto
    hseek cKto2
   
    ? PADL( cPom, 14 ), ALLTRIM( cKto2 ) + " - " + PADR( konto->naz, 60 )

endif

if !EMPTY( cIdZaduz2 )

    select ( F_FAKT_OBJEKTI )
    if !Used()
        O_FAKT_OBJEKTI
    endif

    go top
    hseek cIdZaduz2

    ? PADL( "Rad.nalog:", 14 ), ALLTRIM( cIdZaduz2 ) + " - " + ALLTRIM( fakt_objekti->naz )

endif

?

select kalk_pripr

P_10CPI
P_COND

m := _get_line()

? m
? "*Rbr.* Konto * ARTIKAL  (sifra-naziv-jmj)                                 * Kolicina *   NC     *    NV     *"
? m

nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := nTotb := nTotc := nTotd := 0

private cIdd := field->idpartner + field->brfaktp + field->idkonto + field->idkonto2

do while !EOF() .and. cIdFirma == field->IdFirma ;
                .and. cBrDok == field->BrDok ;
                .and. cIdVD == field->IdVD

    nT4 := nT5 := nT8 := 0
    cBrFaktP := field->brfaktp
    dDatFaktP := field->datfaktp
    cIdpartner := field->idpartner
    
    select ( F_PARTN )
    if !Used()
        O_PARTN
    endif
    select partn
    hseek cIdPartner

    // vrni se na kalk
    select kalk_pripr

    do while !EOF() .and. cIdFirma == field->IdFirma ;
                    .and. cBrDok == field->BrDok ;
                    .and. cIdVD == field->IdVD ;
                    .and. field->idpartner + field->brfaktp + DTOS( field->datfaktp ) == cIdpartner + cBrfaktp + DTOS( dDatfaktp )

        if cIdVd $ "97" .and. field->tbanktr == "X"
            skip 1
            loop
        endif

        select roba
        hseek kalk_pripr->idroba
        
        select tarifa
        hseek kalk_pripr->idtarifa

        select kalk_pripr
        
        KTroskovi()

        if prow() > ( _page_len + gPStranica )
            FF
            @ prow(), 125 SAY "Str:" + STR( ++nStr, 5 )
        endif

        skol := field->kolicina

        // NV
        nT4 += ( nU4 := field->nc * field->kolicina )

        @ prow() + 1, 0 SAY field->rbr PICT "99999"
        
        if field->idvd == "16"
            cNKonto := field->idkonto
        else
            cNKonto := field->idkonto2
        endif
        
        @ prow(), 6 SAY ""
        
        ?? PADR( cNKonto, 7 ), PADR( ALLTRIM( field->idroba ) + "-" + ;
                ALLTRIM( roba->naz ) + " (" + ALLTRIM( roba->jmj ) + ")", 60 )
        
        @ prow(), nC1 := pcol() + 1 SAY field->kolicina PICT PicKol
        @ prow(), pcol() + 1 SAY field->nc PICT piccdem
        @ prow(), pcol() + 1 SAY nU4 PICT picdem

        skip
    
    enddo

    nTot4 += nT4
    nTot5 += nT5
    nTot8 += nT8
  
    ? m
  
    if prow() > ( _page_len + gPStranica )
        FF
        @ prow(), 125 SAY "Str:" + STR( ++nStr, 5 )
    endif

    @ prow() + 1, 0 SAY "Ukupno za: "
        ?? ALLTRIM( cIdpartner ) +  " - " + ALLTRIM( partn->naz )

    if prow() > ( _page_len + gPStranica )
        FF
        @ prow(), 125 SAY "Str:" + STR( ++nStr, 5 )
    endif

    ? "Broj fakture:", ALLTRIM( cBrFaktP ), "/", dDatFaktp
    @ prow(), nC1 SAY 0 PICT "@Z " + picdem
    @ prow(), pcol() + 1 SAY nT4 PICT picdem
  
    ? m

enddo

if prow() > ( _page_len + gPStranica )
    FF
    @ prow(), 125 SAY "Str:" + STR( ++nStr, 5 )
endif

? m

@ prow() + 1, 0 SAY "Ukupno:"
@ prow(), nC1 SAY 0 PICT "@Z " + picdem
@ prow(), pcol() + 1 SAY nTot4 PICT picdem

? m

return


static function _get_line()
local _line := ""

_line += REPLICATE( "-", 5 ) 
_line += SPACE(1)
_line += REPLICATE( "-", 7 ) 
_line += SPACE(1)
_line += REPLICATE( "-", 60 ) 
_line += SPACE(1)
_line += REPLICATE( "-", 10 ) 
_line += SPACE(1)
_line += REPLICATE( "-", 10 ) 
_line += SPACE(1)
_line += REPLICATE( "-", 11 ) 

return _line


