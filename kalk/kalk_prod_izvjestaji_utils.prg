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


function RekTarife(lVisak)
if IsPDV()
	RekTarPDV()
else
	RekTarPPP(lVisak)
endif
return


// PDV obracun
function RekTarPDV()
*{
local nKolona
local aPKonta
local nIznPRuc
private aPorezi

IF prow()> 55 + gPStranica
	FF
	@ prow(),123 SAY "Str:"+str(++nStr,3)
endif

nRec:=recno()
select kalk_pripr
set order to 2
seek cIdFirma+cIdVd+cBrDok
m:="------ ----------"

nKolona :=3

if glUgost
	nKolona += 2
endif

for i:=1 to nKolona
 m += " ----------" 
next

? m
if !glUgost
 ?  "* Tar.*  PDV%    *    MPV   *    PDV   *   MPV   *"
 ?  "*     *          *  bez PDV *   iznos  *  sa PDV *"
else
 ?  "* Tar.*   PDV    *  Por potr *   MPV   *    PDV   *  Porez   *   MPV   *"
 ?  "*     *   (%)    *    (%)    * bez PDV *   iznos  *  na potr.*  sa PDV *"
endif
? m

aPKonta:=PKontoCnt(cIdFirma+cIdvd+cBrDok)
nCntKonto:=len(aPKonta)

aPorezi:={}

for i:=1 to nCntKonto
	seek cIdFirma+cIdVd+cBrdok

	nTot1:=0
	nTot2:=0
	nTot2b:=0
	nTot3:=0
	nTot4:=0
	
	nTot5:=0
	nTot6:=0
	nTot7:=0
	do while !eof() .and. cIdFirma+cIdVd+cBrDok==idfirma+idvd+brdok
  		if aPKonta[i]<>field->PKONTO
    			skip
    			loop
  		endif

  		cIdtarifa:=idTarifa
  		// mpv
		nU1:=0
		
		// pdv
		nU2:=0

		if glUgost
		  // porez na potrosnju
		  nU2b:=0
		endif
		
		// mpv sa porezom
		nU3:=0
		
	  	select tarifa
		hseek cIdtarifa
	  	select kalk_pripr
  		do while !eof() .and. cIdfirma+cIdvd+cBrDok==idfirma+idvd+brdok .and. idTarifa==cIdTarifa

	    		if aPKonta[i]<>field->PKONTO
      				skip
      				loop
	    		endif
    	
			select roba
			hseek kalk_pripr->idroba
	
			Tarifa(kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi, cIdTarifa)
			select kalk_pripr
		
			nMpc:=DokMpc(field->idvd, aPorezi)
			if field->idvd=="19"
    				// nova cijena
    				nMpcsaPdv1:=field->mpcSaPP+field->fcj
    				nMpc1:=MpcBezPor(nMpcsaPdv1,aPorezi,,field->nc)
    				aIPor1:=RacPorezeMP(aPorezi, nMpc1, nMpcsaPdv1, field->nc)
    
    				// stara cijena
    				nMpcsaPdv2:=field->fcj
    				nMpc2:=MpcBezPor(nMpcsaPdv2,aPorezi,,field->nc)
    				aIPor2:=RacPorezeMP(aPorezi,nMpc2,nMpcsaPdv2,field->nc)
				aIPor:={0,0,0}
				aIPor[1]:=aIPor1[1]-aIPor2[1]
			else
				aIPor:=RacPorezeMP(aPorezi,nMpc,field->mpcSaPP,field->nc)
			endif
			nKolicina:=DokKolicina(field->idvd)
			nU1+=nMpc*nKolicina
			nU2+=aIPor[1]*nKolicina
			if glUgost
			 nU2b+=aIPor[3]*nKolicina
			endif
    			nU3+=field->mpcSaPP*nKolicina
			// ukupna bruto marza
			nTot6+=(nMpc-kalk_pripr->nc)*nKolicina
    			skip 1
	  	enddo
		nTot1+=nU1
		nTot2+=nU2
		if glUgost
		 nTot2b += nU2b
		endif
		nTot3+=nU3
  
		? cIdTarifa
  
		@ prow(),pcol()+1   SAY aPorezi[POR_PPP] pict picproc
		if glUgost
		    @ prow(),pcol()+1   SAY aPorezi[POR_PP] pict picproc
		endif
  
		nCol1:=pcol()+1
		@ prow(),pcol()+1   SAY nU1 pict picdem
		@ prow(),pcol()+1   SAY nU2 pict picdem
		if glUgost
		  @ prow(),pcol()+1   SAY nU2b pict picdem
		endif
		@ prow(),pcol()+1   SAY nU3 pict picdem
	enddo

	if prow()>56+gPStranica
		FF
		@ prow(),123 SAY "Str:"+str(++nStr,3)
	endif
	
	? m
	? "UKUPNO "+aPKonta[i]
	@ prow(),nCol1      SAY nTot1 pict picdem
	@ prow(),pcol()+1   SAY nTot2 pict picdem
	if glUgost
	   @ prow(),pcol()+1   SAY nTot2b pict picdem
	endif
	@ prow(),pcol()+1   SAY nTot3 pict picdem
	? m
next

set order to 1
go nRec
return
*}

/*! \fn PKontoCnt(cSeek)
 *  \brief Kreira niz prodavnickih konta koji se nalaze u zadanom dokumentu
 *  \param cSeek - firma + tip dok + broj dok
 */

function PKontoCnt(cSeek)
*{
local nPos, aPKonta
aPKonta:={}
// baza: kalk_pripr, order: 2
seek cSeek
do while !eof() .and. (IdFirma+Idvd+BrDok)=cSeek
  nPos:= ASCAN(aPKonta, PKonto)
  if nPos<1
    AADD(aPKonta, PKonto)
  endif
  skip
enddo

return aPKonta
*}


function DokKolicina(cIdVd)
*{
local nKol
if cIdVd=="IP"
        // kolicina = popisana kolicina
	// gkolicina = knjizna kolicina
	nKol:=kolicina - gkolicina
	// stajalo je nKol := gKolicin2 ali mi je rekapitulacija davala pogresnu
	// stvar
else
	nKol:=kolicina
endif
return nKol
*}



function DokMpc(cIdVd,aPorezi)
*{
local nMpc
if cIdVd=="IP"
	nMpc:=MpcBezPor(mpcSaPP, aPorezi, , nc)
else
	nMpc:=field->mpc
endif
return nMpc
*}


