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



// ----------------------------------------------------
// zaglavlje firme treba uzeti iz parametara firme
// ----------------------------------------------------
function ZagFirma()
return




// -----------------------------------------------------------
// izvlaci realizacija kase na dan = dDatum u pom tabelu
// -----------------------------------------------------------
function RealNaDan(dDatum)
local nUkupno
local lOpened

SELECT(F_POS)
lOpened:=.t.
if !USED()
    O_POS
    lOpened:=.f.
endif

//"4", "dtos(datum)", KUMPATH+"POS"
SET ORDER TO TAG "4"
seek DTOS(dDatum)

nUkupno:=0
cPopust:=Pitanje(,"Uzeti u obzir popust","D")
do while !EOF() .and. dDatum==field->datum
    if field->idVd=="42"
        if cPopust=="D"
            nUkupno+=field->kolicina*(field->cijena-field->ncijena)
        else
            nUkupno+=field->kolicina*field->cijena
        endif
    endif
    SKIP
enddo

if !lOpened
    USE
endif
return nUkupno



// ----------------------------------------------------------------------
// kasa izvuci - funkcija koja izvlaci iznose po tipovima dokumenata
// ----------------------------------------------------------------------
function KasaIzvuci(cIdVd, cDobId)
// cIdVD - Id vrsta dokumenta
// Opis: priprema pomoce baze POM.DBF za realizaciju

if ( cDobId == nil )
    cDobId := ""
endif

MsgO("formiram pomocnu tabelu izvjestaja...")

SEEK cIdVd + DTOS(dDat0)

do while !eof().and.pos_doks->IdVd==cIdVd.and.pos_doks->Datum<=dDat1

    if ( !EMPTY(cIdPos) .and. pos_doks->IdPos <> cIdPos ) .or. ( !EMPTY(cSmjena) .and. pos_doks->Smjena <> cSmjena )
            SKIP
        loop
    endif
    
    SELECT pos 
    SEEK pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
  
    do while !eof().and.pos->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

        if (!EMPTY(cIdOdj).and.pos->IdOdj<>cIdOdj).or.(!EMPTY(cIdDio).and.pos->IdDio<>cIdDio)
            SKIP 
            loop
        endif
            
        select roba 
        HSEEK pos->IdRoba

        if roba->(fieldpos("sifdob"))<>0
            if !Empty(cDobId)
                if roba->sifdob <> cDobId
                    select pos
                    skip
                    loop
                endif
            endif
        endif
        
        if roba->( FIELDPOS("idodj") ) <> 0
            SELECT odj 
            HSEEK roba->IdOdj
        endif
        
        nNeplaca := 0
            
        if RIGHT(odj->naz,5)=="#1#0#"  // proba!!!
            nNeplaca:=pos->(Kolicina*Cijena)
        elseif RIGHT(odj->naz,6)=="#1#50#"
            nNeplaca:=pos->(Kolicina*Cijena)/2
        endif
            
        if gPopVar="P" 
            nNeplaca+=pos->(kolicina*nCijena) 
        endif

        SELECT pom  
        GO TOP
        seek pos_doks->IdPos + pos_doks->IdRadnik + pos_doks->IdVrsteP + pos->IdOdj + pos->IdRoba + pos->IdCijena
        
        if !found()

            APPEND BLANK
            replace IdPos WITH pos_doks->IdPos
            replace IdRadnik WITH pos_doks->IdRadnik
            replace IdVrsteP WITH pos_doks->IdVrsteP
            replace IdOdj WITH pos->IdOdj
            replace IdRoba WITH pos->IdRoba
            replace IdCijena WITH pos->IdCijena
            replace Kolicina WITH pos->Kolicina
            replace Iznos WITH pos->Kolicina * POS->Cijena
            replace Iznos3 WITH nNeplaca
                
            if gPopVar=="A"
                REPLACE Iznos2 WITH pos->nCijena
            endif

            if roba->(fieldpos("K1")) <> 0
                REPLACE K2 WITH roba->K2,K1 WITH roba->K1
            endif

        else

            replace Kolicina WITH Kolicina + POS->Kolicina
            replace Iznos WITH Iznos + POS->Kolicina * POS->Cijena
            replace Iznos3 WITH Iznos3 + nNeplaca

            if gPopVar=="A"
                REPLACE Iznos2 WITH Iznos2+pos->nCijena
            endif

        endif
            
        SELECT pos
        skip

    enddo
    
    select pos_doks  
    skip

enddo

MsgC()

return



