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


function StKalk95_PDV()
local cKto1
local cKto2
local cIdZaduz2
local cPom
local nCol1:=0
local nCol2:=0
local nPom:=0

private nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

P_COND2

?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok

@ prow(),125 SAY "Str:"+str(++nStr,3)

?
if cidvd=="16"  // doprema robe
 	? "PRIJEM U MAGACIN (INTERNI DOKUMENT)"
elseif cidvd=="96"
 	? "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
elseif cidvd=="97"
 	? "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
elseif cidvd=="95"
 	? "OTPIS MAGACIN"
endif
?

select kalk_pripr

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


?
? PADL(cPom, 14), cKto1 + "- " + PADR( konto->naz, 20 )

if !empty(cKto2)

	if cIdVd $ "95#96#97"
		cPom:= "Zaduzuje:"
	else
		cPom:= "Razduzuje:"
	endif

	select konto
	hseek cKto2
    ? PADL(cPom, 14), cKto2 + "- " + PADR( konto->naz, 20 )
endif
?

select kalk_pripr

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "*R * ROBA     * KOLICINA *   NC     *  MARZA   * PROD.CIJ.*   PDV%   * PROD.CIJ.*"
? "*BR* TARIFA   *          *          *          * BEZ.PDV  *   PDV    * SA PDV   *"
? "*  * KONTO    *    �     *    �     *    �     *    �     *    �     *     �    *"
? m

nTot:=0 
nTot1:=0 
nTot2:=0 
nTot3:=0
nTot4:=0 
nTot5:=0
nTot6:=0
nTot7:=0 
nTot8:=0
nTot9:=0
nTotA:=0
nTotB:=nTotP:=nTotM:=0

select kalk_pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD
	vise_kalk_dok_u_pripremi(cIdd)
    	RptSeekRT()
    	KTroskovi()
	DokNovaStrana(125, @nStr, 2)
	if gKalo=="1"
        	SKol:=Kolicina-GKolicina-GKolicin2
    	else
        	SKol:=Kolicina
    	endif

        nPDVStopa := tarifa->opp
	nPDV := MPCsaPP * (tarifa->opp/100)

       	nTot1+= (nU1:=round(NC*(GKolicina+GKolicin2),gZaokr))
	nTot8+= (nU8:=round(NC *    (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    	nTot9+= (nU9:=round(nMarza* (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    	nTotA+= (nUA:=round(VPC   * (Kolicina-Gkolicina-GKolicin2),gZaokr) )

    	// total porez
	nTotP+=(nUP:=nPDV * kolicina)
	
    	// total mpcsapp
	nTotM+=(nUM:=MPCsaPP * kolicina)
   
    	// 1. PRVI RED
	@ prow()+1,0 SAY  Rbr PICTURE "999"
    	@ prow(),4 SAY  ""
	?? trim(LEFT(ROBA->naz,40)), "(", ROBA->jmj,")"
	
    	@ prow()+1,4 SAY IdRoba
    	nCol1:=pcol()+1
    	@ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol
    	@ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY nMarza/NC*100         PICTURE PicProc
    	@ prow(),pcol()+1 SAY VPC                   PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY nPDVStopa         PICTURE PicProc
    	@ prow(),pcol()+1 SAY MPCsaPP           PICTURE PicCDEM

	// 2. DRUGI RED
    	@ prow()+1,4 SAY IdTarifa
    	@ prow(),pcol()+27 SAY nMarza               PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY 0  		   PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY nPDV  		   PICTURE PicCDEM

	// 3. TRECI RED
    	@ prow()+1,4 SAY idkonto
	@ prow()+1,nCol1   SAY nU1         picture         PICDEM
    	@ prow(),pcol()+1  SAY nU8         picture         PICDEM
    	@ prow(),pcol()+1  SAY nU9         picture         PICDEM
    	@ prow(),pcol()+1  SAY nUA         picture         PICDEM
    	@ prow(),pcol()+1  SAY nUP         picture         PICDEM
    	@ prow(),pcol()+1  SAY nUM         picture         PICDEM

  	skip
enddo

DokNovaStrana(125, @nStr, 5)
? m

@ prow() + 1,0 SAY "Ukupno:"
@ prow(),nCol1     SAY nTot1         picture         PICDEM
@ prow(),pcol()+1  SAY nTot8         picture         PICDEM
@ prow(),pcol()+1  SAY nTot9         picture         PICDEM
@ prow(),pcol()+1  SAY nTotA         picture         PICDEM
@ prow(),pcol()+1  SAY nTotP         picture         PICDEM
@ prow(),pcol()+1  SAY nTotM         picture         PICDEM

? m
if cIdVD == "16"
	? "Magacin se zaduzuje po nabavnoj vrijednosti " + ALLTRIM(TRANSFORM(nTot8,picdem))
else
	? "Magacin se razduzuje po nabavnoj vrijednosti " + ALLTRIM(TRANSFORM(nTot8,picdem))
endif
? m

return

