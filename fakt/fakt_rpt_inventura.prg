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


#include "fakt.ch"


function RptInv()
local nTota:=0
local nTotb:=0
local nTotc:=0
local nTotd:=0
local nRecNo
local nRazlika:=0
local nVisak:=0
local nManjak:=0
local cPict
private nStr:=0

cLin:="--- --------------------------------------- ---------- ---------- ----------- ----------- ----------- ----------- ----------- -----------"

cIdFirma:=idFirma
cIdTipDok:=idTipDok
cBrDok:=brDok

nRecNo:=RecNo()

START PRINT CRET

fakt_zagl_inventura(cLin)

GO TOP
do while !eof()
    	SELECT roba
	HSEEK fakt_pripr->idRoba
    	select fakt_pripr

	DokNovaStrana(125,@nStr,1)
	
	@ PROW()+1,0 SAY field->rbr PICTURE "XXX"
	@ PROW(),4 SAY ""
	
	?? PADR(field->idRoba+" "+TRIM(LEFT(roba->naz,40))+" ("+roba->jmj+")",36)
	
	// popisana kolicina    	
	@ PROW(),PCOL()+1 SAY field->kolicina PICTURE PicKol
	
	// knjizena kolicina
	@ PROW(),PCOL()+1 SAY VAL(field->serbr) PICTURE PicKol
	
	nC1:=PCOL()+1
     	
	// knjizna vrijednost
	@ PROW(),PCOL()+1 SAY (VAL(field->serbr))*(field->cijena) PICTURE PicDem

	// popisana vrijednost
	@ PROW(),PCOL()+1 SAY (field->kolicina)*(field->cijena) PICTURE PicDem
	
	// razlika
	nRazlika:=(VAL(field->serbr))-(field->kolicina)
	@ PROW(),PCOL()+1 SAY nRazlika PICTURE PicKol
	
	// VP cijena
    	@ PROW(),PCOL()+1 SAY field->cijena PICTURE PicCDem
	
    	if (nRazlika>0)
		nVisak:=nRazlika*(field->cijena)
		nManjak:=0
	elseif (nRazlika<0)
		nVisak:=0
		nManjak:=nRazlika*(field->cijena)
	else
		nVisak:=0
		nManjak:=0
	endif
	
	// VPV visak
	@ PROW(),PCOL()+1 SAY nVisak PICTURE PicDem
	nTotc+=nVisak
	
	// VPV manjak
	@ PROW(),PCOL()+1 SAY -nManjak PICTURE PicDem
	nTotd+=-nManjak
	
	// sumiraj knjizne vrijednosti
	nTota+=(VAL(field->serbr))*(field->cijena) 
	
	// sumiraj popisane vrijednosti
	nTotb+=(field->kolicina)*(field->cijena) 
	
	skip
enddo

DokNovaStrana(125,@nStr,3)

// UKUPNO:
// nTota - suma knj.vrijednosti
// nTotb - suma pop.vrijednosti
// nTotc - suma VPV visak
// nTotd - suma VPV manjak

? cLin
@ PROW()+1,0 SAY "Ukupno:"
@ PROW(),nC1 SAY nTota PICTURE PicDem
@ PROW(),PCOL()+1 SAY nTotb PICTURE PicDem
@ PROW(),PCOL()+1 SAY REPLICATE(" ",LEN(PicDem))
@ PROW(),PCOL()+1 SAY REPLICATE(" ",LEN(PicDem))
@ PROW(),PCOL()+1 SAY nTotc PICTURE PicDem
@ PROW(),PCOL()+1 SAY nTotd PICTURE PicDem
? cLin

END PRINT

O_FAKT_PRIPR
select fakt_pripr
GO nRecNo

return
*}


/*! \fn fakt_zagl_inventura(cLinija)
 *  \brief Zaglavlje izvjestaja inventura
 *  \param cLinija - Proslijedjuje se linija koja se ispisuje iznad i ispod zaglavlja 
 */
 
function fakt_zagl_inventura(cLinija)
?
P_10CPI
?? "INVENTURA VP :"
P_COND
?
? "DOKUMENT BR. :", cIdFirma+"-"+cIdTipDok+"-"+cBrDok, SPACE(2), "Datum:", datDok
?
DokNovaStrana(125,@nStr,-1)
? cLinija
?  "*R * ROBA                                  * Popisana * Knjizna  *  Knjizna  * Popisana  *  Razlika  *  Cijena   *   Visak   *  Manjak  *"
?  "*BR*                                       * Kolicina * Kolicina *vrijednost *vrijednost *  (kol)    *    VP     *    VPV    *   VPV    *"
? cLinija

return
*}


