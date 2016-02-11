/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

// porez na promet proizvoda
function RekTarPPP( lVisak )
local aPKonta
local nIznPRuc
private aPorezi

if lVisak == NIL
	lVisak :=.f.
endif

IF prow() > 55+gPStranica
	FF
	@ prow(),123 SAY "Str:"+str(++nStr,3)
endif

nRec:=recno()
select kalk_pripr
set order to tag "2"

if (cIdVd == "IP")
  ?
  if lVisak
    ? "Rekapitulacija IP - Visak "
  else
   ? "Rekapitulacija IP - Manjak "
  endif
  ? "------------------------------------- "
endif

seek cIdFirma+cIdVd+cBrDok
m:="------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
?  "* Tar.*  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *    PP    * MPVSAPP *"
? m

aPKonta:=PKontoCnt(cIdFirma+cIdvd+cBrDok)
nCntKonto:=LEN(aPKonta)

aPorezi:={}

for i:=1 to nCntKonto
	seek cIdFirma+cIdVd+cBrdok

	nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
	nTot5:=nTot6:=nTot7:=0
	do while !eof() .and. cIdFirma+cIdVd+cBrDok==idfirma+idvd+brdok
  		
		if aPKonta[i]<> PKONTO
    			skip
    			loop
  		endif
		
		// IP dokument ima dvije rekapitulacije
		if cIdVd == "IP"
				// kolicina = popisana kolicina
				// gkolicina = knjizna kolicina
				if lVisak 
					// manjak
					if kolicina < gkolicina
						// manjak preskoci na rekap
						// viska
						SKIP
						LOOP
					endif
				else
					// visak
					if (kolicina > gkolicina)
						// visak preskoci na rekap
						// manjka
						SKIP
						LOOP
					endif
				endif
		endif

  		cIdtarifa:=idtarifa
  		// mpv
		nU1:=0
		// ppp
		nU2:=0
		// ppu
		nU3:=0
		// pp
		nU4:=0
		// mpv sa porezom
		nU5:=0

	  	select tarifa
		HSEEK cIdtarifa
	  	select kalk_pripr
  		do while !eof() .and. cIdfirma+cIdvd+cBrDok==idfirma+idvd+brdok .and. idTarifa==cIdTarifa

			// IP dokument ima dvije rekapitulacije
			if cIdVd == "IP"
				// kolicina = popisana kolicina
				// gkolicina = knjizna kolicina
				if lVisak 
					// manjak
					if kolicina < gkolicina
						// manjak preskoci na rekap
						// viska
						SKIP
						LOOP
					endif
				else
					// visak
					if (kolicina > gkolicina)
						// visak preskoci na rekap
						// manjka
						SKIP
						LOOP
					endif
				endif
			endif
		
	    		if aPKonta[i] <> PKONTO
      				skip
      				loop
	    		endif
    	
			select roba
			HSEEK kalk_pripr->idroba
	
			Tarifa( kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi, cIdTarifa)
			select kalk_pripr
		
    			VtPorezi()

			nMpc := DokMpc(idvd, aPorezi)
			if idvd=="19"
    				// nova cijena
    				nMpcSaPP1:=field->mpcSaPP+field->fcj
    				nMpc1:=MpcBezPor(nMpcSaPP1,aPorezi,,field->nc)
    				aIPor1:=RacPorezeMP(aPorezi,nMpc1,nMpcSaPP1,field->nc)
    
    				// stara cijena
    				nMpcSaPP2:=field->fcj
    				nMpc2:=MpcBezPor(nMpcSaPP2, aPorezi, , nc)
    				aIPor2:=RacPorezeMP(aPorezi, nMpc2, nMpcSaPP2, nc)
				aIPor:={0,0,0}
				aIPor[1]:=aIPor1[1]-aIPor2[1]
				aIPor[2]:=aIPor1[2]-aIPor2[2]
				aIPor[3]:=aIPor1[3]-aIPor2[3]
			else
				aIPor:=RacPorezeMP(aPorezi,nMpc,field->mpcSaPP,field->nc)
			endif
			nKolicina:= DokKolicina(idvd)
			nU1+=nMpc*nKolicina
			nU2+=aIPor[1]*nKolicina
			nU3+=aIPor[2]*nKolicina
			nU4+=aIPor[3]*nKolicina
    			nU5+=field->mpcSaPP*nKolicina
			// ukupna bruto marza
			nTot6+=(nMpc-kalk_pripr->nc)*nKolicina
    			skip 1
	  	enddo
		nTot1+=nU1
		nTot2+=nU2
		nTot3+=nU3
		nTot4+=nU4
		nTot5+=nU5
  
		//nTot6+=(mpc-nc)*nKolicina
		? cIdTarifa
  		
		if LEN(aPorezi) > 0
		 @ prow(),pcol()+1   SAY aPorezi[POR_PPP] pict picproc
		 @ prow(),pcol()+1   SAY PrPPUMP() pict picproc
		 @ prow(),pcol()+1   SAY aPorezi[POR_PP] pict picproc
		else
	         @ prow(),pcol()+1   SAY 0 pict picproc
		 @ prow(),pcol()+1   SAY 0 pict picproc
		 @ prow(),pcol()+1   SAY 0 pict picproc
	        endif
  
		nCol1:=pcol()+1
		@ prow(),pcol()+1   SAY nU1 pict picdem
		@ prow(),pcol()+1   SAY nU2 pict picdem
		@ prow(),pcol()+1   SAY nU3 pict picdem
		@ prow(),pcol()+1   SAY nU4 pict picdem
		@ prow(),pcol()+1   SAY nU5 pict picdem
	enddo

	if prow() > 56+gPStranica
		FF
		@ prow(),123 SAY "Str:"+str(++nStr,3)
	endif
	
	? m
	? "UKUPNO "+aPKonta[i]
	@ prow(),nCol1      SAY nTot1 pict picdem
	@ prow(),pcol()+1   SAY nTot2 pict picdem
	@ prow(),pcol()+1   SAY nTot3 pict picdem
	@ prow(),pcol()+1   SAY nTot4 pict picdem
	@ prow(),pcol()+1   SAY nTot5 pict picdem
	? m
next

set order to tag "1"
go nRec
return

