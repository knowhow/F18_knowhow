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



#include "fakt.ch"

 
function RptInvObrPopisa()
local nRecNo
private nStr:=0

cLin:="--- --------------------------------------------- ------------ ------------"

cIdFirma:=idFirma
cIdTipDok:=idTipDok
cBrDok:=brDok

nRecNo:=RecNo()

START PRINT CRET

ZInvp(cLin)

GO TOP
do while !eof() 
	SELECT roba
	HSEEK fakt_pripr->idRoba
    	select fakt_pripr

	DokNovaStrana(125,@nStr,1)
	
	@ PROW()+1,0 SAY field->rbr PICTURE "XXX"
	@ PROW(),4 SAY ""
	
	?? PADR(field->idRoba+""+TRIM(LEFT(roba->naz,40))+" ("+roba->jmj+")", 37)
	
	// popisana kolicina    	
	?? SPACE(10)+REPLICATE("_", LEN(PicKol)-1)+SPACE(2)
	
	// VP cijena
	?? TRANSFORM(field->cijena, PicCDem)
    	skip
enddo

DokNovaStrana(125,@nStr,4)

? cLin

PrnClanoviKomisije()

END PRINT

select fakt_pripr
GO nRecNo

return
*}

/*! \fn ZInvp(cLinija)
 *  \brief Zaglavlje izvjestaja inventura
 *  \param cUlaz - Proslijedjuje se linija koja se ispise iznad i ispod zaglavlja 
 */
 
function ZInvp(cLinija)
?
P_10CPI
?? "OBRAZAC POPISA INVENTURE :"
P_COND2
?
? "DOKUMENT BR. :", cIdFirma+"-"+cIdTipDok+"-"+cBrDok, SPACE(2), "Datum:", DatDok
?
DokNovaStrana(125,@nStr,-1)

? cLinija
? "*R * ROBA                                        *  Popisana  *   Cijena   *"
? "*BR*                                             *  Kolicina  *     VP     *"
? cLinija

return
*}

