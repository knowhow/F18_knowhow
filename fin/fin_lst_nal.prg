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

// -----------------------------------------
// stampa svih naloga - export u DBF
// -----------------------------------------
function st_sv_nal()


aFields := get_exp_fields()
t_exp_create( aFields )

O_SUBAN
O_KONTO
O_PARTN

select suban
set order to tag "4"
go top
// "4", "idFirma+IdVN+BrNal+Rbr"

Box(, 4, 60)

@ m_x+1, m_y+2 SAY "Exportujem naloge......"

do while !EOF() .and. gFirma == idfirma

	select partn
	seek suban->idpartner
	
	cPartNaz := partn->naz
	
	if EMPTY(suban->idpartner)
		cPartNaz := ""
	endif
		
	select suban

	fill_export( field->idfirma, field->idvn, field->brnal, ;
		field->rbr, field->idkonto, field->idpartner, cPartNaz, ;
		field->d_p, field->iznosbhd, field->datdok, ;
		field->datval, field->brdok, field->opis)

	@ m_x + 3, m_y+ 2 SAY "nalog-> " + idvn + "-" + brnal

	skip
enddo

BoxC()

tbl_export()


return


// ---------------------------------------------
// vraca definiciju polja tabele exporta
// ---------------------------------------------
static function get_exp_fields()
local aDBF := {}

AADD(aDBF, {"IDVN", "C", 2, 0})
AADD(aDBF, {"BRNAL", "C", 4, 0})
AADD(aDBF, {"RBR", "C", 4, 0})
AADD(aDBF, {"IDKONTO", "C", 7, 0})
AADD(aDBF, {"IDPARTN", "C", 6, 0})
AADD(aDBF, {"NAZPART", "C", 40, 0})
AADD(aDBF, {"DUG", "N", 18, 8})
AADD(aDBF, {"POT", "N", 18, 8})
AADD(aDBF, {"DATUM", "D", 8, 0})
AADD(aDBF, {"DATVAL", "D", 8, 0})
AADD(aDBF, {"VEZA", "C", 10, 0})
AADD(aDBF, {"OPIS",  "C", 40, 0})

return aDBF



// ----------------------------------------------------------------
// napuni tabelu exporta
// ----------------------------------------------------------------
static function fill_export( cIdF, cIdVn, cBrNal, cRbr, cIdKto, ;
			cIdPart, cPartNaz, cD_P, nIznos, dDatum, ;
			dValuta, cVeza, cOpis)

local nArr := SELECT()

O_R_EXP

append blank
replace idvn with cIdVn
replace brnal with cBrNal
replace rbr with cRbr
replace idkonto with cIdKto
replace idpartn with cIdPart
replace nazpart with cPartNaz

if cD_P == "1"
	replace dug with nIznos
	replace pot with 0
else
	replace dug with 0
	replace pot with nIznos
endif

replace datum with dDatum
replace datval with dValuta
replace veza with cVeza
replace opis with cOpis


select (nArr)

return



