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

function PrepisKumPr()
local nSir:=80
local nRobaSir:=40
local cLm:=SPACE(5)
local cPicKol:="999999.999"

START PRINT CRET

if gVrstaRS=="S"
	P_INI
	P_10CPI
else
	nSir:=40
	nRobaSir:=18
	cLM:=""
	cPicKol:="9999.999"
endif

ZagFirma()

if empty(pos_doks->IdPos)
	? PADC("KUMULATIV PROMETA "+ALLTRIM(pos_doks->BrDok),nSir)
else
	? PADC("KUMULATIV PROMETA "+ALLTRIM(pos_doks->IdPos)+"-"+ALLTRIM(pos_doks->BrDok),nSir)
endif

?
? PADC(FormDat1(pos_doks->Datum),nSir)
?
SELECT VRSTEP
HSEEK pos_doks->IdVrsteP

if gVrstaRS=="S"
	cPom:=VRSTEP->Naz
else
	cPom:=LEFT(VRSTEP->Naz,23)
endif

? cLM+"Vrsta placanja:",cPom

select partn
HSEEK pos_doks->IdGost

if gVrstaRS=="S"
	cPom:=partn->Naz
else
	cPom:=LEFT(partn->Naz,23)
endif

? cLM+"Gost / partner:",cPom

if pos_doks->Placen==PLAC_JEST.or.pos_doks->IdVrsteP==gGotPlac
	? cLM+"       Placeno:","DA"
else
	? cLM+"       Placeno:","NE"
endif

SELECT POS
HSEEK pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

? cLM
if gVrstaRS=="S"
	?? "Sifra    Naziv                                    JMJ Cijena  Kolicina"
	m:=cLM+"-------- ---------------------------------------- --- ------- ----------"
else
	?? "Sifra    Naziv              JMJ Kolicina"
	m:=cLM+"-------- ------------------ --- --------"
endif
? m

nFin:=0
SELECT POS

do while !eof().and.POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
	if gVrstaRS=="S".and.prow()>63-dodatni_redovi_po_stranici()
		FF
	endif
	? cLM
	?? IdRoba,""
	SELECT ROBA
	HSEEK POS->IdRoba
	?? PADR(ROBA->Naz,nRobaSir),ROBA->Jmj,""
	SELECT POS
	if gVrstaRS=="S"
		?? TRANS(POS->Cijena,"9999.99"),""
	endif
	?? TRANS(POS->Kolicina,cPicKol)
	nFin+=POS->(Kolicina*Cijena)
	skip
enddo

if gVrstaRS=="S".and.prow()>63-dodatni_redovi_po_stranici()-7
	FF
endif

? m
? cLM

if gVrstaRS=="S"
	?? PADL("IZNOS DOKUMENTA ("+TRIM(gDomValuta)+")",13+nRobaSir),TRANS(nFin,"999,999,999,999.99")
else
	?? PADL("IZNOS DOKUMENTA ("+TRIM(gDomValuta)+")",10+nRobaSir),TRANS(nFin,"9,999,999.99")
endif

? m

if gVrstaRS=="S"
	FF
else
	PaperFeed()
endif

ENDPRINT
select pos_doks
return
*}


