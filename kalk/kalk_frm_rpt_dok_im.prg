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


#include "kalk.ch"

// ------------------------------------------------
// stampa kalkulacije tipa "IM"
// ------------------------------------------------
function StKalkIM()
local nCol1:=0
local nCol2:=0
local nPom:=0

private nPrevoz
private nCarDaz
private nZavTr
private nBankTr
private nSpedTr
private nMarza
private nMarza2

// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

cSamoObrazac := Pitanje(,"Prikaz samo obrasca inventure? (D/N)")

cPrikazCijene:="D"

if cSamoObrazac == "D"
	cPrikazCijene:=Pitanje(,"Prikazati cijenu na obrascu? (D/N)")
endif

cCijenaTip:=Pitanje(,"Na obrascu prikazati VPC (D) ili NC (N)?", "N")

P_10CPI
SELECT konto
HSEEK cIdkonto
SELECT kalk_pripr
?? "INVENTURA MAGACIN ",cidkonto,"-",konto->naz
P_COND2
?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)


select kalk_pripr
m:="--- --------------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -----------"
? m
?  "*R * ROBA                                  *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika *  Cijena  *   VISAK  *  MANJAK  *"
?  "*BR* TARIFA                                *  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *          *          *          *"
? m

nTot4:=0
nTot5:=0
nTot6:=0
nTot7:=0
nTot8:=0
nTot9:=0
nTota:=0
nTotb:=0
nTotc:=0
nTotd:=0
nTotKol:=0
nTotGKol:=0

private cIdd:=idPartner+brFaktP+idKonto+idKonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVd

    KTroskovi()
    RptSeekRT()
    DokNovaStrana(125, @nStr, 3)
    SKol:=Kolicina

    if cCijenaTIP=="N"
    	nCijena:=field->nc
    else
    	nCijena:=field->vpc
    endif

    @ prow()+1,0 SAY  Rbr PICTURE "XXX"
    @ prow(),4 SAY  ""
    ?? idroba, trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"

	if lKoristitiBK .and. !EMPTY( roba->barkod )
		?? ", BK: " + ROBA->barkod
	endif

    @ prow()+1,4 SAY IdTarifa+space(4)
    if cSamoObrazac == "D"
      @ prow(),pcol()+30 SAY Kolicina  PICTURE replicate("_",len(PicKol))
      @ prow(),pcol()+1 SAY GKolicina  PICTURE replicate(" ",len(PicKol))
    else
      @ prow(),pcol()+30 SAY Kolicina  PICTURE PicKol
      @ prow(),pcol()+1 SAY GKolicina  PICTURE PicKol
    endif
    nC1:=pcol()+1

    if cSamoObrazac == "D"
     @ prow(),pcol()+1 SAY gkolicina*nCijena  PICTURE replicate(" ",len(PicDEM))
     @ prow(),pcol()+1 SAY kolicina*nCijena   PICTURE replicate("_",len(PicDEM))
     @ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE replicate(" ",len(PicKol))
    else
     @ prow(),pcol()+1 SAY gkolicina*nCijena PICTURE Picdem // knjizna vrijednost
     @ prow(),pcol()+1 SAY kolicina*nCijena  PICTURE Picdem // popisana vrijednost
     @ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE PicKol // visak-manjak
    endif
    if (cPrikazCijene=="D")
    	@ prow(),pcol()+1 SAY nCijena  PICTURE PicCDEM // veleprodajna cij
    else
    	@ prow(),pcol()+1 SAY nCijena  PICTURE replicate(" ", LEN(PicDEM))
    endif

    nTotb+=gkolicina*nCijena
    nTotc+=kolicina*nCijena

		nU4 := nCijena*(Kolicina-gKolicina)
    nTot4 += nU4

		nTotKol += kolicina
    nTotGKol += gkolicina

    if cSamoObrazac == "D"
	      @ prow(),pcol()+1 SAY nU4  pict replicate(" ",len(PicDEM))
    else
	      @ prow(),pcol()+1 SAY nU4 pict IF(nU4>0,picdem,replicate(" ",len(PicDEM)))
	      @ prow(),pcol()+1 SAY IF(nU4<0,-nU4,nU4) pict IF(nU4<0,picdem,replicate(" ",len(PicDEM)))
    endif

    skip

enddo

DokNovaStrana(125, @nStr, 5)

if cSamoObrazac == "D"
	PrnClanoviKomisije()
  	return
endif

? m
@ prow()+1,0 SAY "Ukupno:"
@ prow(),(pcol()*6)+2 SAY nTotKol pict gPicKol
@ prow(),pcol()+1 SAY nTotGKol pict gPicKol
@ prow(),pcol()+1 SAY nTotb pict gPicDem
@ prow(),pcol()+1 SAY nTotc pict gPicDem
@ prow(),pcol()+1 SAY 0 pict gPicDem
@ prow(),pcol()+1 SAY 0 pict gPicDem
@ prow(),pcol()+1 SAY nTot4 pict IF(nTot4>0, gPicDem, REPLICATE(" ", LEN(PicDEM)))
@ prow(),pcol()+1 SAY IF(nTot4<0,-nTot4,nTot4)  pict IF(nTot4<0,gPicDem,replicate(" ",len(gPicDem)))

? m


return
