/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

function Rpt_StanjePartnera()

O_PRENHH
O_PARTN

Box(,5,60)
	cDN:="N"
	cPartner:=SPACE(6)
	@ 1+m_x, 2+m_y SAY "Partner: " GET cPartner VALID EMPTY(cPartner) .or. P_Firma(@cPartner)
	@ 2+m_x, 2+m_y SAY "Prikazati samo ukupno stanje " GET cDN VALID cDN$"DN" PICT "@!"
	read
BoxC()

if LastKey()==K_ESC
	return
endif

select prenhh
set order to tag "1"
go top

START PRINT CRET
if !EMPTY(cPartner)
	seek cPartner	
endif

nUkupno:=0
nBrojac:=0

? "Izvjestaj izgenerisanih podataka o stanju partnera"
? "na dan: ", Date()
?
if cDN=="N"
	? "Legenda: "
	? "         F-POCST   - pocetno stanje FIN"
	? "         F-61-0022 - FIN nalog 61-0022 (primjer)"   
endif
?
? "----------------------------------------------------------------------------------------------"
? "Rbr. IDPartner/Naziv                    Datum    DatVal    Dok.    Veza       Dug/Pot   Iznos "
? "----------------------------------------------------------------------------------------------"
do while !EOF() .and. if(!EMPTY(cPartner), idpartner==cPartner, .t.)
	if cDN=="N"
		if ALLTRIM(field->dokument)=="STPART"
			skip
			loop
		endif
	else
		if ALLTRIM(field->dokument)<>"STPART"
			skip
			loop
		endif
	endif
	
	select partn
	hseek PADR(prenhh->idpartner, 6)
	cNazPartn:=field->naz
	
	select prenhh

	
	++nBrojac
	
	? STR(nBrojac, 4) + ". "
	?? field->idpartner
	?? cNazPartn
	?? field->datum, " "
	?? field->datval, " "
	if cDN=="N"
		?? field->dokument
	else
		?? SPACE(10)
	endif
	?? field->veza, SPACE(3)
	?? field->d_p
	?? field->iznos
	
	if field->d_p=="D"
		nUkupno+=field->iznos
	else
		nUkupno-=field->iznos
	endif
	
	skip
enddo

?
? "-------------------------------------------------------------------------------------------"
? "UKUPNO: " + SPACE(60), nUkupno
?

FF

ENDPRINT

return

