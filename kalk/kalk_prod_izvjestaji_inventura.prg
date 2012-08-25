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


function StKalkIP( fZaTops )
local nCol1 := nCol2 := 0
local nPom := 0

private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,aPorezi

// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

aPorezi:={}
nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

if fzatops==NIL
	fZaTops:=.f.
endif

if !fZaTops
	cSamoObraz := Pitanje(,"Prikaz samo obrasca inventure (D-da,N-ne,S-sank lista) ?",,"DNS")
	if cSamoObraz == "S"
		StObrazSL()
		return
	endif
else
	cSamoObraz:="N"
endif

P_10CPI
select konto
hseek cidkonto
select kalk_pripr

?? "INVENTURA PRODAVNICA ", cIdkonto, "-", ALLTRIM( konto->naz )

IspisNaDan(10)

P_COND

?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)

select kalk_pripr

if (IsJerry())
	m:="--- -------------------------------------------- ------ ---------- ---------- ---------- ---------- ----------- ----------- -----------"
	? m
	? "*R *                                            *      *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika * Cijena  *  +VISAK  *"
	? "*BR*               R O B A                      *Tarifa*  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *         *  -MANJAK *"
else
	m:="--- --------------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
	? m
	? "*R * ROBA                                  *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika * Cijena  *  +VISAK  * -MANJAK  *"
	? "*BR* TARIFA                                *  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *         *          *          *"
endif

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


nTotVisak := 0
nTotManjak := 0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !EOF() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

	// !!!!!!!!!!!!!!!
	if idpartner + brfaktp + idkonto + idkonto2 <> cIdd
		Beep(2)
		Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
	endif

	KTroskovi()

	select ROBA
	HSEEK kalk_pripr->IdRoba

	select TARIFA
	HSEEK kalk_pripr->IdTarifa

	select kalk_pripr

	if ( prow() - gPStranica ) > 59
		FF
		@ prow(), 125 SAY "Str:" + STR( ++nStr, 3 )
	endif

	SKol := Kolicina

	@ prow() + 1, 0 SAY field->rbr PICT "XXX"
	@ prow(), 4 SAY  ""

	?? field->idroba, TRIM( LEFT( roba->naz, 40 )), "(", roba->jmj, ")"


	nPosKol := 30
	@ prow() + 1, 4 SAY field->idtarifa + SPACE(4)

	if cSamoObraz == "D"
		@ prow(), pcol() + nPosKol SAY field->kolicina PICT replicate("_",len(PicKol))
		@ prow(), pcol() + 1 SAY field->gkolicina PICT replicate(" ",len(PicKol))
	else
		@ prow(), pcol() + nPosKol SAY field->kolicina PICT PicKol
		@ prow(), pcol() + 1 SAY field->gkolicina PICT PicKol
	endif

	nC1 := pcol()

	if cSamoObraz == "D"
		@ prow(), pcol() + 1 SAY field->fcj PICT replicate(" ",len(PicDEM))
		@ prow(), pcol() + 1 SAY field->kolicina * field->mpcsapp PICT replicate("_",len(PicDEM))
		@ prow(), pcol() + 1 SAY field->Kolicina - field->gkolicina PICT replicate(" ",len(PicKol))
	else
		@ prow(), pcol() + 1 SAY field->fcj PICT Picdem // knjizna vrijednost
		@ prow(), pcol() + 1 SAY field->kolicina * field->mpcsapp PICT Picdem
		@ prow(), pcol() + 1 SAY field->kolicina - field->gkolicina PICT PicKol
	endif

	@ prow(), pcol() + 1 SAY field->mpcsapp PICT PicCDEM

	nTotb += field->fcj
	nTotc += field->kolicina * field->mpcsapp
	nTot4 += ( nU4 := ( field->MPCSAPP * field->Kolicina ) - field->fcj )
	nTotKol += field->kolicina
	nTotGKol += field->gkolicina
	
	if cSamoObraz=="D"
		@ prow(),pcol()+1 SAY nU4 pict replicate(" ",len(PicDEM))
	else

		if ( nU4 < 0 ) 
			
			// manjak
			@ prow(),pcol()+1 SAY 0 PICT picdem	
			@ prow(),pcol()+1 SAY nU4 PICT picdem
			nTotManjak += nU4	
		else
			
			// visak
			@ prow(), pcol()+1 SAY nU4 PICT picdem
			@ prow(),pcol()+1 SAY 0 PICT picdem
			nTotVisak += nU4
			
		endif
	endif

	skip 1

enddo


if prow()-gPStranica>58
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

if cSamoObraz=="D"
	? m
	?
	?
	? space(80),"Clanovi komisije: 1. ___________________"
	? space(80),"                  2. ___________________"
	? space(80),"                  3. ___________________"
	return
endif

? m
@ prow()+1, 0 SAY PADR( "Ukupno:", 43)
@ prow(),pcol()+1 SAY nTotKol pict pickol
@ prow(),pcol()+1 SAY nTotGKol pict pickol
@ prow(),pcol()+1 SAY nTotb pict picdem
@ prow(),pcol()+1 SAY nTotc pict picdem
@ prow(),pcol()+1 SAY 0 pict picdem
@ prow(),pcol()+1 SAY 0 pict picdem
@ prow(),pcol()+1 SAY nTotVisak pict picdem
@ prow(),pcol()+1 SAY nTotManjak pict picdem

? m

? "Rekapitulacija:"
? "---------------"
? "  popisana kolicina:", STR( nTotKol, 18, 2 )
? "popisana vrijednost:", STR( nTotC, 18, 2 )
? "   knjizna kolicina:", STR( nTotGKol, 18, 2 )
? " knjizna vrijednost:", STR( nTotB, 18, 2 )
? "          + (visak):", STR( nTotVisak, 18, 2 )
? "         - (manjak):", STR( nTotManjak, 18, 2 )

? m

// Visak
RekTarife( .t. )

// Manjak
//RekTarife( .f. )

if !fZaTops
	?
	?
	? "Napomena: Ovaj dokument ima sljedeci efekat na karticama:"
	? "     1 - izlaz za kolicinu manjka"
	? "     2 - storno izlaza za kolicinu viska"
	?
endif

return





/*! \fn StObrazSL()
 *  \brief Stampa forme obrasca sank liste
 */

function StObrazSL()
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2


P_10CPI
select konto; hseek cidkonto; select kalk_pripr
?? "INVENTURA PRODAVNICA ",cidkonto,"-",konto->naz
P_COND
?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)

select kalk_pripr

m:="--- -------------------------------------------- ------ ---------- ---------- ---------- --------- ----------- -----------"
? m
? "*R *                                            *      *  Pocetne * Primljena*  Zavrsna * Prodajna * Cijena  *   Iznos  *"
? "*BR*               R O B A                      *Tarifa*  zalihe  *  kolicina*  zaliha  * kolicina *         */realizac.*"
? m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
    	Beep(2)
    	Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
    endif

    KTroskovi()

    select ROBA; HSEEK kalk_pripr->IdRoba
    select TARIFA; HSEEK kalk_pripr->IdTarifa
    select kalk_pripr

    if prow()-gPStranica>59
    	FF
    	@ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    SKol:=Kolicina

    @ prow()+1,0 SAY  Rbr PICTURE "XXX"
    @ prow(),4 SAY  ""
    ?? idroba, LEFT(ROBA->naz,40 - 13),"("+ROBA->jmj+")"
    nPosKol:=1
    @ prow(),pcol()+1 SAY IdTarifa
    if gcSLObrazac=="2"
	   @ prow(),pcol()+nPosKol SAY Kolicina  PICTURE PicKol
    else
	   @ prow(),pcol()+nPosKol SAY GKolicina  PICTURE PicKol
    endif
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY MPCSAPP             PICTURE PicCDEM
    nTotb+=fcj
    ntotc+=kolicina*mpcsapp
    nTot4+=  (nU4:= MPCSAPP*Kolicina-fcj)

    @ prow(),pcol()+1 SAY nU4  pict replicate("_",len(PicDEM))
    skip

enddo


if prow()-gPStranica>58
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m
return




