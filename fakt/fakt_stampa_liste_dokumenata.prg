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
function stampa_liste_dokumenata(dDatOd, dDatDo, qqTipDok, cIdFirma, cRadniNalog, lVrsteP,  cImeKup, lOpcine, aUslOpc)
local m, cDinDnem, cRezerv, nC, nIznos, nRab, nIznosD, nIznos3, nRabD, nRab3, nOsn_tot, nPDV_tot, nUkPDV_tot
local gnLMarg := 0
local nCol1 := 0

SELECT F_FAKT_DOKS
if !USED()
  O_FAKT_DOKS
endif


START PRINT CRET DOCNAME "FAKT_stampa_dokumenata_na_dan_" + DTOC(date())
?

P_COND

?? space(gnLMarg)
?? "FAKT: Stampa dokumenata na dan:", date(), space(10), "za period", dDatOd, "-", dDatDo
?

? space(gnLMarg)

IspisFirme(cIdfirma)

if !empty(qqTipDok)
    ?? SPACE(2), "za tipove dokumenta:", trim(qqTipDok)
endif
if glRadNal .and. !Empty(cRadniNalog)
    ?? SPACE(2), "uslov po radnom nalogu: ", TRIM(cRadniNalog)
    ? GetNameRNal(cRadniNalog)
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
nIznos   := 0
nRab     := 0
nIznosD  := 0
nRabD    := 0
nIznos3  := 0
nRab3    := 0
nOsn_tot := 0
nPdv_tot := 0
nUkPDV_tot := 0

cRezerv := " "

cImeKup:=trim(cimekup)

do while !eof() .and. if( !EMPTY( cIdFirma ), IdFirma == cIdFirma, .t. )

  cDinDem := fakt_doks->dindem

  if !empty(cImekup)
     if !(partner == cImeKup)
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
        nIznos3    += ROUND(fakt_doks->iznos,  gFZaok)
        nRab3      += fakt_doks->rabat
        nOsn_tot   += nOsn_izn
        nPdv_tot   += nPdv_izn
        nUkPDV_tot += nUkPDV_izn

  else

        @ prow(),pcol()+1 SAY str(iznos + rabat,12,2)
        @ prow(),pcol()+1 SAY str(Rabat, 12, 2)
        @ prow(),pcol()+1 SAY str(ROUND(iznos,gFZaok),12,2)
        
        // osnovica i pdv na prikazu
        @ prow(),pcol()+1 SAY STR( nOsn_izn := ROUND(_osnovica( idtipdok, idpartner, iznos ),gFZaok),  12, 2)
        @ prow(),pcol()+1 SAY STR( nPDV_izn := ROUND(_pdv( idtipdok, idpartner, iznos ),gFZaok),  12, 2)
        @ prow(),pcol()+1 SAY STR( nUkPdv_izn := ROUND(_uk_sa_pdv( idtipdok, idpartner, iznos ), gFZaok), 12, 2 )

        nIznosD   += ROUND(iznos,gFZaok)
        nRabD     += rabat
        nIznos3   += ROUND(iznos*UBaznuValutu(datdok),gFZaok)
        nRab3     += rabat * UBaznuValutu(datdok)
        nOsn_tot  += nOsn_izn * UBaznuValutu(datdok)
        nPdv_tot  += nPdv_izn * UBaznuValutu(datdok)
        nUkPdv_tot+= nUkPdv_izn * UBaznuValutu(datdok)

  endif

  @ prow(), pcol() + 1 SAY cDinDEM

  if fieldpos("SIFRA")<>0
      @ prow(),pcol()+1 SAY iif(empty(sifra), space(2), left(CryptSC(sifra),2))
  endif

  if lVrsteP
      @ prow(),pcol()+1 SAY idvrstep+"-"+LEFT(VRSTEP->naz,4)
  endif

  if fieldpos("DATPL") <> 0
    @ prow(), pcol() + 1 SAY datpl
  endif
  skip

enddo

? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+ValBazna()+":"
@ prow(),nCol1    SAY  STR(nIznos+nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nIznos,12,2)
@ prow(),pcol()+1 SAY  STR(nOsn_tot,12,2)
@ prow(),pcol()+1 SAY  STR(nPDV_tot,12,2)
@ prow(),pcol()+1 SAY  STR(nUkPDV_tot,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValBazna(),3)
? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+ValSekund()+":"
@ prow(),nCol1    SAY  STR(nIznosD+nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nIznosD,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValSekund(),3)

? space(gnLMarg);?? m
? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+valbazna()+"+"+valsekund()+":"
@ prow(),nCol1    SAY  STR(nIznos3+nRab3,12,2)
@ prow(),pcol()+1 SAY  STR(nRab3,12,2)
@ prow(),pcol()+1 SAY  STR(nIznos3,12,2)
@ prow(),pcol()+1 SAY  LEFT(VAlBazna(),3)
? space(gnLMarg);?? m

FF
END PRINT

return .t.

