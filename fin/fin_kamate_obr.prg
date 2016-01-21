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

static picdem := "9999999999999.99"


// --------------------------------------------------
// obracun kamata izvjestaj
// --------------------------------------------------
function kamate_obracun_pojedinacni( fVise )
local nKumKam := 0
local nGlavn := 2892359.28
local dDatOd := CTOD("01.02.92")
local dDatDo := CTOD("30.09.96")

private cVarObracuna := "Z"

if fvise = NIL
	fVise := .f.
endif

if !fVise

	Box( "#OBRACUN KAMATE ZA JEDNU GLAVNICU", 3, 77 )
 		@ m_x + 1, m_y + 2 SAY "Glavnica:" GET nGlavn PICT "9999999999999.99"
 		@ m_x + 2, m_y + 2 SAY "Od datuma:" GET dDatOd
 		@ m_x + 2, col() + 2 SAY "do:" GET dDatDo
 		@ m_x + 3, m_y + 2 SAY "Varijanta obracuna kamate (Z-zatezna kamata,P-prosti kamatni racun)" GET cVarObracuna VALID cVarObracuna$"ZP" PICT "@!"
 		read
		ESC_BCR
	BoxC()

endif 

O_KS
set order to tag "2"

START PRINT CRET

?
P_10CPI
? space(45), "K A M A T E"
?
?
B_ON
? space(45),"Preduzece:", gNFirma
B_OFF
?
? "Partner: _____________________________________"
?
? "Obracun kamate po dokumentu : ________________ "
?
?

if ( cVarObracuna == "Z" )
	? "Obracun zatezne kamate za period:",dDatOd,"-",dDatDo
else
	? "Prosti kamatni obracun za period:",dDatOd,"-",dDatDo
endif

?
? "   Glavnica:"
@ prow(), pcol()+1 SAY nGlavn pict picDEM

if ( cVarObracuna == "Z" )
	? m := "-------- -------- --- ---------------- ---------- ------- ----------------"
	? "     Period       Dana      Osnovica     Tip kam.  Konform.      Iznos"
	? "                                         i stopa    koef         kamate"
else
	? m := "-------- -------- --- ---------------- --------- ----------------"
	? "     Period       Dana    Osnovica       Stopa       Iznos"
	? "                                                     kamate"
endif

? m

nKumKam := 0

seek dtos(dDatOd)
if dDatOd < ks->DatOd .or. EOF()
	skip -1
endif

do while .t.

	ddDatDo := MIN( ks->DatDO, dDatDo )

	nPeriod:= ddDatDo-dDatOd+1

	if (cVarObracuna=="P")
		if (Prestupna(YEAR(dDatOd)))
			nExp:=366
		else
			nExp:=365
		endif
	else
		if ks->tip=="G"
			if ks->duz==0
				nExp:=365
			else
				nExp:=ks->duz
			endif
		elseif ks->tip=="M"
			if ks->duz==0
				dExp:= "01."
				if month(ddDatdo)==12
					dExp+="01."+alltrim(str(year(ddDatdo)+1))
				else
					dExp+=alltrim(str(month(ddDatdo)+1))+"."+alltrim(str(year(ddDatdo)))
				endif
				nExp:=day(ctod(dExp)-1)
			else
				nExp:=ks->duz
			endif
		elseif ks->tip=="3"
			nExp:=ks->duz
		endif
	endif
	
	if ks->den<>0  .and. dDatOd==ks->datod
 		? "********* Izvrsena Denominacija osnovice sa koeficijentom:",ks->den,"****"
 		nGlavn:=round(nGlavn*ks->den,2)
 		nKumKam:=round(nKumKam*ks->den,2)
	endif

	if (cVarObracuna=="Z") 
		nKKam:=((1+ks->stkam/100)^(nPeriod/nExp) - 1.00000)
		nIznKam:=nKKam*nGlavn
	else
		nKStopa:=ks->stkam/100
		nIznKam := nGlavn * nKStopa * nPeriod/nExp 
	endif

	nIznKam:=round(nIznKam,2)

	? dDatOd, ddDatDo

	@ prow(), pcol() + 1 SAY nPeriod pict "999"
	@ prow(), pcol() + 1 SAY nGlavn pict picdem

	if ( cVarObracuna == "Z" )
		@ prow(),pcol()+1 SAY ks->tip
		@ prow(),pcol()+1 SAY ks->stkam
		@ prow(),pcol()+1 SAY nKKam*100 pict "9999.99"
	else
		@ prow(),pcol()+1 SAY ks->stkam
	endif

	@ prow(),pcol()+1 SAY nIznKam pict picdem

	nKumKam+=nIznKam
	
	if (cVarObracuna=="Z")
		nGlavn+=nIznKam
	endif

	if dDatDo <= ks->datdo 
        // kraj obracuna
 		exit
	endif
	
	skip

	dDatOd := ks->DatOd

enddo

? m
?
? "Ukupno kamata    :",transform(nKumKam,"999,999,999,999,999.99")
?
if (cVarObracuna=="Z")
	? "NOVO STANJE      :",transform(nGlavn,"999,999,999,999,999.99")
else
	? "GLAVNICA+KAMATA  :",transform(nGlavn+nKumKam,"999,999,999,999,999.99")
endif

?

FF
END PRINT

my_close_all_dbf()
return



// Racuna prestupnu godinu
function Prestupna( nGodina )
local lPrestupna
lPrestupna := .f.
if nGodina % 4 == 0
	lPrestupna := .t.
endif
return lPrestupna




