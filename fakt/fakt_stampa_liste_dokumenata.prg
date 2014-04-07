/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"

#define PARTNER_LEN 45

// ---------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------
function stampa_liste_dokumenata( dDatOd, dDatDo, qqTipDok, cIdFirma, objekat_id, cImeKup, lOpcine, aUslOpc, valute ) 
local m, cDinDnem, cRezerv, nC, nIznos, nRab, nIznosD, nIznos3, nRabD, nRab3, nOsn_tot, nPDV_tot, nUkPDV_tot
local gnLMarg := 0
local nCol1 := 0
local _params := fakt_params()
local lVrstep := _params["fakt_vrste_placanja"]

if valute == NIL
    valute := SPACE(3)
endif

SELECT F_FAKT_DOKS
if !USED()
    O_FAKT_DOKS
endif

START PRINT CRET
?

P_COND

?? space(gnLMarg)
?? "FAKT: Stampa dokumenata na dan:", date(), space(10), "za period", dDatOd, "-", dDatDo
?

? space(gnLMarg)

IspisFirme(cIdfirma)

if !EMPTY(qqTipDok)
    ?? SPACE(2), "za tipove dokumenta:", trim(qqTipDok)
endif

if !EMPTY( valute )
    ?? SPACE(2), "za valute:", valute
endif

if _params["fakt_objekti"] .and. !Empty(objekat_id)
    ?? SPACE(2), "uslov po objektu: ", TRIM(objekat_id)
    ? fakt_objekat_naz(objekat_id)
endif

m := "----- -------- -- -- ---------"

m += " " + REPLICATE("-", PARTNER_LEN) 

m += " ------------ ------------ ------------ ------------ ------------ ------------ ---"

if fieldpos("SIFRA")<>0
    m += " --"
endif

if lVrsteP
    m += " -------"
endif

if fieldpos("DATPL")<>0
    m += " --------"
endif

P_COND2
? space(gnLMarg)
?? m
? space(gnLMarg)

?? "  Rbr Dat.Dok  RJ TD Br.Dok   " +  PADC("Partner", PARTNER_LEN) + "   Ukupno       Rabat         UKUPNO     OSNOVICA       PDV       UK.SA PDV      VAL"

if fieldpos("SIFRA") <> 0
    ?? " OP"
endif

if lVrsteP
    ?? " Nac.pl."
endif

if fieldpos("DATPL") <> 0
    ?? " Dat.pl. "
endif

? space(gnLMarg)
?? m

nC       := 0
// domaca valuta
nIznos   := 0
nRab     := 0
// strana valuta
nIznosD  := 0
nRabD    := 0
// ukupno domaca i strana
nIznos3  := 0
nRab3    := 0
// domaca valuta
nOsn_tot := 0
nPdv_tot := 0
nUkPDV_tot := 0
// strana valuta
nOsn_tot_s := 0
nPdv_tot_s := 0
nUkPDV_tot_s := 0

cRezerv := " "

cImeKup := TRIM( cImeKup )

do while !EOF() .and. if( !EMPTY( cIdFirma ), IdFirma == cIdFirma, .t. )

    cDinDem := fakt_doks->dindem

    if !empty( ALLTRIM( cImekup ) ) 
        if !( field->partner = ALLTRIM( cImeKup ) )
            skip 
            loop
        endif
    endif

    if lOpcine
        SELECT PARTN
        HSEEK fakt_doks->idpartner
        select fakt_doks
        if !(PARTN->(&aUslOpc))
            skip
            loop
        endif
    endif

    select fakt_doks

    ? space(gnLMarg)

    ?? Str(++nC, 4) + ".", datdok, idfirma, idtipdok, brdok + Rezerv + " "

    IF m1 <> "Z"
        ?? PADR( fakt_doks->partner, PARTNER_LEN )
    ELSE
        ?? PADC ("<<dokument u pripremi>>", PARTNER_LEN)
    ENDIF

    nCol1 := pcol()+1

    if cDinDem == LEFT(ValBazna(), 3)

        @ prow(), pcol()+1 SAY str(iznos + rabat, 12, 2)
        @ prow(), pcol()+1 SAY str(Rabat, 12, 2)
        @ prow(), pcol()+1 SAY str(ROUND(iznos, gFZaok), 12, 2)
        
        // osnovica i pdv na prikazu
        @ prow(), pcol()+1 SAY STR( nOsn_izn := ROUND(_osnovica( idtipdok, idpartner, iznos ), gFZaok),  12, 2 )
        @ prow(), pcol()+1 SAY STR( nPdv_izn := ROUND(_pdv( idtipdok, idpartner, iznos ), gFZaok),  12, 2 )
        @ prow(), pcol()+1 SAY STR( nUkPdv_izn := ROUND(_uk_sa_pdv( idtipdok, idpartner, iznos ), gFZaok), 12, 2 )
        
        nIznos     += ROUND(fakt_doks->iznos, gFZaok)
        nRab       += fakt_doks->rabat
        
        // iznos obje valute... u KM
        nIznos3    += ROUND(fakt_doks->iznos,  gFZaok)
        nRab3      += fakt_doks->rabat
        
        nOsn_tot   += nOsn_izn
        nPdv_tot   += nPdv_izn
        nUkPDV_tot += nUkPDV_izn

    else

        @ prow(),pcol()+1 SAY STR( ( fakt_doks->iznos / UBaznuValutu( fakt_doks->datdok ) ) + ;
                                fakt_doks->rabat, 12, 2 )
        @ prow(),pcol()+1 SAY STR( fakt_doks->rabat, 12, 2 )
        @ prow(),pcol()+1 SAY STR( ROUND( fakt_doks->iznos / UBaznuValutu( fakt_doks->datdok), gFZaok ), 12, 2 )
        
        // osnovica i pdv na prikazu
        @ prow(),pcol()+1 SAY STR( nOsn_izn := ROUND( _osnovica( idtipdok, idpartner, iznos / UBaznuValutu( datdok ) ),gFZaok),  12, 2)
        @ prow(),pcol()+1 SAY STR( nPDV_izn := ROUND( _pdv( idtipdok, idpartner, iznos / UBaznuValutu( datdok ) ),gFZaok),  12, 2)
        @ prow(),pcol()+1 SAY STR( nUkPdv_izn := ROUND( _uk_sa_pdv( idtipdok, idpartner, iznos / UBaznuValutu( datdok ) ), gFZaok), 12, 2 )

        nIznosD   += ROUND( fakt_doks->iznos / UBaznuValutu( datdok ), gFZaok )
        nRabD     += fakt_doks->rabat
  
        // total obje valute... ovu preracunaj u KM
        nIznos3   += ROUND( fakt_doks->iznos, gFZaok ) 
        nRab3     += fakt_doks->rabat
        
        nOsn_tot_s  += nOsn_izn
        nPdv_tot_s  += nPdv_izn
        nUkPdv_tot_s += nUkPdv_izn

    endif

    @ prow(), pcol() + 1 SAY cDinDEM

    if fieldpos("SIFRA") <> 0
        @ prow(),pcol()+1 SAY iif(empty(sifra), space(2), left(CryptSC(sifra),2))
    endif

    if lVrsteP
        @ prow(),pcol()+1 SAY idvrstep + "-" + LEFT(VRSTEP->naz,4)
    endif

    if fieldpos("DATPL") <> 0
        @ prow(), pcol() + 1 SAY datpl
    endif

    skip

enddo

? space(gnLMarg)
?? m
? space(gnLMarg)

// domaca valuta
?? "UKUPNO " + ValBazna() + ":"
@ prow(),nCol1    SAY  STR(nIznos+nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nIznos,12,2)
@ prow(),pcol()+1 SAY  STR(nOsn_tot,12,2)
@ prow(),pcol()+1 SAY  STR(nPDV_tot,12,2)
@ prow(),pcol()+1 SAY  STR(nUkPDV_tot,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValBazna(),3)

? space(gnLMarg)
?? m
? space(gnLMarg)

// strana valuta
?? "UKUPNO " + ValSekund() + ":"
@ prow(),nCol1    SAY  STR(nIznosD+nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nIznosD,12,2)
@ prow(),pcol()+1 SAY  STR(nOsn_tot_s,12,2)
@ prow(),pcol()+1 SAY  STR(nPDV_tot_s,12,2)
@ prow(),pcol()+1 SAY  STR(nUkPDV_tot_s,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValSekund(),3)

? space(gnLMarg)
?? m
? space(gnLMarg)
?? m
? space(gnLMarg)

// zbirno...
?? "UKUPNO " + ALLTRIM( valbazna() ) + " + " + ALLTRIM( valsekund() ) + ":"
@ prow(),nCol1    SAY  STR( nIznos3 + nRab3, 12, 2 )
@ prow(),pcol()+1 SAY  STR( nRab3, 12, 2 )
@ prow(),pcol()+1 SAY  STR( nIznos3,12, 2 )
@ prow(),pcol()+1 SAY  LEFT( VAlBazna(), 3 )

? space(gnLMarg)
?? m

FF
ENDPRINT

return .t.

