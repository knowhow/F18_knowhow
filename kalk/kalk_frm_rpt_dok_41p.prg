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


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */
 


/*! \fn StKalk41PDV()
 *  \brief Stampa dokumenta tipa 41 PDV rezim
 */

function StKalk41PDV()
*{
local nCol0:=nCol1:=nCol2:=0
local nPom:=0

Private nMarza,nMarza2,nPRUC,aPorezi
nMarza:=nMarza2:=nPRUC:=0
aPorezi:={}

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

P_10CPI
Naslov4x()

select kalk_pripr

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
if cIdVd<>'47'
	m+=" ---------- ----------"
endif

? m

if cIdVd='47'
	? "*R * ROBA     * Kolicina *    MPC   *   PDV %  *   MPC     *"
	? "*BR*          *          *          *   PDV    *  SA PDV   *"
	? "*  *          *          *     ä    *     ä    *     ä     *"
else
	? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  *    MPC   *   PDV %  *MPC sa PDV*          *  MPC     *"
	? "*BR*          *          *   U MP   *         *          *   PDV    * -Popust  *  Popust  *  SA PDV  *"
	? "*  *          *          *    ä     *         *     ä    *     ä    *    ä     *          *    ä     *"
endif

? m

nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=0
nTot4a:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

	IF idpartner+brfaktp+idkonto+idkonto2<>cidd
     		set device to screen
     		Beep(2)
     		Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     		set device to printer
    	ENDIF

    	// formiraj varijable _....
    	Scatter() 
   	RptSeekRT()

    	// izracunaj nMarza2
        MarzaMPR()

    	KTroskovi()
  
	Tarifa(pkonto, idRoba, @aPorezi)
	
	if IsPdv()
	   // uracunaj i popust
           aIPor:=RacPorezeMP(aPorezi, mpc, mpcSaPP-RabatV, field->nc)
	else
           aIPor:=RacPorezeMP(aPorezi, mpc, mpcSaPP, field->nc)
	endif
	nPor1:=aIPor[1]
	
	VTPorezi()

    	DokNovaStrana(125, @nStr, 2)

    	nTot3+=  (nU3:= IF(ROBA->tip="U", 0, NC)*kolicina )
    	nTot4+=  (nU4:= nMarza2*Kolicina )
    	nTot5+=  (nU5:= MPC*Kolicina )
    
	nTot6+=  (nU6:=(nPor1)*Kolicina)
    	nTot7+=  (nU7:= MPcSaPP*Kolicina )

    	nTot8+=  (nU8:= (MPcSaPP-RabatV)*Kolicina )
    	nTot9+=  (nU9:= RabatV*Kolicina )

	// 1. red

    	@ prow()+1,0 SAY  Rbr PICTURE "999"
    	@ prow(),4 SAY  ""
    	?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"
    	IF lPoNarudzbi
    		IspisPoNar(IF(cIdVd=="41",.f.,))
    	ENDIF
    	@ prow()+1,4 SAY IdRoba
    	@ prow(),pcol()+1 SAY Kolicina PICTURE PicKol

    	nCol0:=pcol()

	// 2. red

    	@ prow(),nCol0 SAY ""
    	IF IDVD<>'47'
     		IF ROBA->tip="U"
       			@ prow(),pcol()+1 SAY 0                   PICTURE PicCDEM
     		ELSE
       			@ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
     		ENDIF
     		@ prow(),nMPos := pcol()+1 SAY nMarza2              PICTURE PicCDEM
    	ENDIF
   	@ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    	nCol1:=pcol()+1
    	@ prow(),pcol()+1 SAY aPorezi[POR_PPP]      PICTURE PicProc
    	if IDVD<>"47"
     		@ prow(),pcol()+1 SAY MPCSAPP-RabatV       PICTURE PicCDEM
     		@ prow(),pcol()+1 SAY RabatV               PICTURE PicCDEM
    	endif
    	@ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

	// 3. red

    	@ prow()+1,4 SAY idTarifa
    	@ prow(), nCol0 SAY ""
    	IF cIDVD<>'47'
     		IF ROBA->tip="U"
      			@ prow(), pcol()+1  SAY  0                picture picdem
     		ELSE
       			@ prow(), pcol()+1  SAY  nc*kolicina      picture picdem
     		ENDIF
     		@ prow(), pcol()+1  SAY  nmarza2*kolicina      picture picdem
    	ENDIF
    	@ prow(), pcol()+1 SAY  mpc*kolicina      picture picdem

    	@ prow(),nCol1    SAY  nPor1*kolicina    picture piccdem
    	if IDVD<>"47"
		@ prow(),pcol()+1 SAY  (mpcsapp-RabatV)*kolicina   picture picdem
		@ prow(),pcol()+1 SAY  RabatV*kolicina   picture picdem
    	endif
    	@ prow(),pcol()+1 SAY  mpcsapp*kolicina   picture picdem

	// 4. red

	if cIdVd <> '47'
    		@ prow()+1,nMPos SAY (nMarza2/nc)*100  picture picproc
    	endif
	skip 1

enddo


DokNovaStrana(125, @nStr, 3)

? m

@ prow()+1,0        SAY "Ukupno:"
@ prow(),nCol0  say  ""
IF cIDVD<>'47'
	@ prow(),pcol()+1 SAY nTot3 picture PicDEM
 	@ prow(),pcol()+1 SAY nTot4 picture PicDEM
endif
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
if !IsPDV()
	@ prow(),pcol()+1   SAY  space(len(picproc))
	@ prow(),pcol()+1   SAY  space(len(picproc))
endif
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
if cIDVD<>"47"
	@ prow(),pcol()+1   SAY  nTot8        picture        PicDEM
	@ prow(),pcol()+1   SAY  nTot9        picture        PicDEM
endif
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM

? m

DokNovaStrana(125, @nStr, 10)
nRec:=recno()

PDVRekTar41(cIdFirma, cIdVd, cBrDok, @nStr)

set order to tag "1"
go nRec
return
*}


function PDVRekTar41(cIdFirma, cIdVd, cBrDok, nStr)
*{
local nTot1
local nTot2
local nTot3
local nTot4
local nTot5
local nTotP
local aPorezi

select kalk_pripr
set order to tag "2"
seek cIdfirma+cIdvd+cBrdok

m:="------ " 
for i:= 1 to 6
 m += REPLICATE("-", 10) + " "
next

if glUgost
  m += " ---------- ----------"
endif

? m
if glUgost
?  "* Tar *  PDV%    *  P.P %   *   MPV    *    PDV   *   P.Potr *  Popust  * MPVSAPDV*"
else
?  "* Tar *  PDV%    *   MPV    *    PDV   * MPV-Pop. *  Popust  *  MPV    *"
?  "*     *          *  bez PDV *    PDV   *  sa PDV  *          * sa PDV  *"
endif
? m


nTot1:=0

nTot2:=0
nTot2b:=0

nTot3:=0
nTot4:=0
nTot5:=0
nTot6:=0
nTot7:=0
nTot8:=0
// popust
nTotP:=0 

aPorezi:={}

do while !eof() .and. cIdfirma+cIdvd+cBrDok==idfirma+idvd+brdok
	cIdTarifa:=idtarifa
  	nU1:=0
  	nU2:=0
  	nU2b:=0
  	nU5:=0
  	nUp:=0
  	select tarifa
  	hseek cIdtarifa
	
	Tarifa(kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi)

  	select kalk_pripr
  	fVTV:=.f.
  	do while !eof() .and. cIdfirma+cIdVd+cBrDok==idFirma+idVd+brDok .and. idTarifa==cIdTarifa
	
		select roba
		hseek kalk_pripr->idroba
		select kalk_pripr
		SetStPor_()
	
		Tarifa(kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi)
    
    		// mpc bez poreza
		nU1+=kalk_pripr->mpc*kolicina


		aIPor:=RacPorezeMP (aPorezi, mpc, mpcSaPP-RabatV, nc)

    		// PDV
    		nU2+=aIPor[1]*kolicina
		
		// ugostiteljstvo porez na potr
		if glUgost
    		 nU2b+=aIPor[3]*kolicina
		endif

		nU5+= kalk_pripr->MpcSaPP * kolicina
    		nUP+= rabatv*kolicina
	
		nTot6 += (kalk_pripr->mpc - kalk_pripr->nc ) * kolicina
    
    		skip
  	enddo
  
  	nTot1+=nU1
  	nTot2+=nU2
	if glUgost
  	   nTot2b+=nU2b
	endif
  	nTot5+=nU5
  	nTotP+=nUP
  
  	? cIdtarifa

  	@ prow(),pcol()+1 SAY aPorezi[POR_PPP] pict picproc
	if glUgost
  	  @ prow(),pcol()+1 SAY aPorezi[POR_PP] pict picproc
	endif
  
  	nCol1:=pcol()
	// mpv bez pdv
  	@ prow(),nCol1 +1   SAY nU1 pict picdem
	// PDV
  	@ prow(),pcol()+1   SAY nU2 pict picdem
	if glUgost
  	  @ prow(),pcol()+1   SAY nU2b pict picdem
	endif
	// mpv - popust
  	@ prow(),pcol()+1   SAY nU5-nUp pict picdem
	// popust
  	@ prow(),pcol()+1   SAY nUp pict picdem
	// mpv
  	@ prow(),pcol()+1   SAY nU5 pict picdem
enddo

DokNovaStrana(125, @nStr, 4)
? m

? "UKUPNO"

@ prow(),nCol1+1    SAY nTot1 pict picdem
@ prow(),pcol()+1   SAY nTot2 pict picdem
if glUgost
  @ prow(),pcol()+1   SAY nTot2b pict picdem
endif
// popust
@ prow(),pcol()+1   SAY nTot5-nTotP pict picdem  
@ prow(),pcol()+1   SAY nTotP pict picdem  
@ prow(),pcol()+1   SAY nTot5 pict picdem
? m
if cIdVd<>"47" .and. !IsJerry()
	? "RUC:"
	@ prow(),pcol()+1 SAY nTot6 pict picdem
? m
endif

return
*}

