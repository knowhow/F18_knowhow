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



// --------------------------------
// lista sastavnica
// --------------------------------
function g_sast_list()
local cMarker
local cLaunch
local cKto
local lExpDbf := .f.
local cExpDbf
local nVar := 2

// uslovi exporta
if  _get_vars( @cMarker, @cKto, @cExpDbf ) == 0
	return
endif

if cExpDbf == "D"
	lExpDbf := .t.
endif


if lExpDbf == .t.
	cLaunch := exp_report()
endif

// kreiraj kroz export tabelu ovaj pregled....
aFields := _g_fields()
t_exp_create( aFields )

O_R_EXP

// kreiraj i privremeni index
index on r_export->idsast tag "1"


// sada kada imas sve uslove, napravi selekciju
O_ROBA
O_SAST

select sast
set order to tag "IDRBR"
go top


Box(, 3, 60)

@ m_x + 1, m_y + 2 SAY "sortiram podatke....."


do while !EOF()

	cRoba := field->id

	select roba
	go top
	seek cRoba

	if FOUND() .and. field->id == cRoba 
		
		if !EMPTY(cMarker) .and. field->k1 <> cMarker
			
			select sast
			skip
			loop
			
		endif
		
	else
		
		select sast
		skip
		loop
		
	endif

	select sast
	
	do while !EOF() .and. field->id == cRoba

		fill_exp_tbl( sast->id2, _art_naz(sast->id2), ;
				sast->kolicina, 0 )
	
		@ m_x + 3, m_y + 2 SAY "sastavnica: " + sast->id2
		
		skip
	enddo
	
enddo

// sada izracunaj stanja za sve u r_export
select r_export
set order to tag "1"

go top

do while !EOF()

	// izracunaj stanje
	replace field->stanje with g_kalk_stanje( field->idsast, cKto )

	if field->kol > 0 .and. field->stanje <= field->kol
		replace field->total with field->kol - field->stanje
	else
		replace field->total with 0
	endif

	skip

enddo

BoxC()

// i sada daj report
// .....

if EMPTY( cKto )
	nVar := 1
endif


r_sast_list( cMarker, nVar )


if lExpDbf == .t.
	tbl_export( cLaunch )
endif

return



// ------------------------------------------
// report sastavnice
// ------------------------------------------
static function r_sast_list( cMarker, nVar )
local cSpace := SPACE(2)
local cLine
local i

START PRINT CRET

select r_export
set order to tag "1"
go top

i := 0

?

P_COND

? cSpace + "Specifikacija sastavnica po oznaci"
? cSpace + "Oznaka: " + cMarker
?

cLine := cSpace + REPLICATE("-", 5) + SPACE(1) + REPLICATE("-", 10) + ;
	SPACE(1) + ;
	REPLICATE("-", 40) + SPACE(1) + REPLICATE("-", 10) + ;
	IIF( nVar == 2, SPACE(1) + REPLICATE("-", 10) + SPACE(1) + ;
	REPLICATE("-", 10) , "" )



? cLine

? cSpace + PADR("R.br", 5), PADR("Sifra", 10), PADR("Naziv", 40), PADR("Kol.po", 10), IF( nVar == 2, PADR("Stanje", 10) + SPACE(1) + PADR("Ukupno", 10), "" )
? cSpace + PADR("", 5), PADR("", 10), PADR("", 40), PADR("sastav.", 10), IF( nVar == 2, PADR("po kart.", 10) + SPACE(1) + PADR("", 10), "")
? cSpace + PADR("", 5), PADR("", 10), PADR("", 40), PADC("(1)", 10), IF( nVar == 2, PADC("(2)", 10) + SPACE(1) + PADC("(1-2)", 10) , "")

? cLine

do while !EOF()

	? cSpace + STR( ++i, 4 ) + ")"
	
	@ prow(), pcol() + 1 SAY field->idsast
	@ prow(), pcol() + 1 SAY field->naz
	@ prow(), pcol() + 1 SAY STR(field->kol, 10, 2)
	
	if nVar == 2
		
		@ prow(), pcol() + 1 SAY STR(field->stanje, 10, 2)
		@ prow(), pcol() + 1 SAY STR(field->total, 10, 2)
		
	endif

	skip
enddo

? cLine

FF
END PRINT

return




// vraca naziv robe
static function _art_naz( cId )
local nTArea := SELECT()
local cRet

select roba
seek cId
cRet := naz

select (nTArea)
return cRet


// -----------------------------------------------
// vraca stanje sa lagera za cKto i cIdRoba
// -----------------------------------------------
static function g_kalk_stanje( cIdRoba, cKto )
local nTArea := SELECT()
local nStanje := 0

if !EMPTY(cKto)

	O_KALK
	select kalk
	set order to tag "3"
	go top

	seek gFirma + cKto + cIdRoba

	do while !EOF() .and. idfirma+mkonto+idroba == gFirma + cKto + cIdRoba

		if mu_i == "1" 
			
			if idvd $ "12#22#94"
				nStanje += kolicina-gkolicina-gkolicin2
			else
				nStanje += kolicina
			endif
			
		elseif mu_i == "5"
			
			nStanje -= kolicina
		endif
		
		skip
	enddo

endif

select (nTArea)

return nStanje



// ----------------------------------------------
// uslovi liste
// ----------------------------------------------
static function _get_vars( cMark, cMagKto, cExpDbf )
local nX := 1

cMark := SPACE(4)
cMagKto := SPACE(7)
cExpDbf := "D"

Box(, 10, 60)

	@ m_x + nX, m_y + 2 SAY "***** Lista sastavnica po oznaci"
	
	nX += 3

	@ m_x + nX, m_y + 2 SAY "Oznaka koristena u K1 (prazno-sve):" GET cMark 
	
	nX += 2

	@ m_x + nX, m_y + 2 SAY "Gledaj stanje sirovina na kontu:" GET cMagKto VALID EMPTY(cMagKto) .or. p_konto( @cMagKto ) 
	
  	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Export u dbf?" GET cExpDbf VALID cExpDbf $ "DN" PICT "@!"
	
	read
BoxC()


if lastkey() == K_ESC
	return 0
endif

return 1


// --------------------------------------------
// specifikacija polja tabele exporta
// --------------------------------------------
static function _g_fields()
local aFields := {}

AADD( aFields, {"IDSAST", "C", 10, 0 } )
AADD( aFields, {"NAZ", "C", 40, 0 } )
// kolicina po sastavnicama
AADD( aFields, {"KOL", "N", 15, 5 } )
// kolicina u kalk-u
AADD( aFields, {"STANJE", "N", 15, 5 } )
// razlika
AADD( aFields, {"TOTAL", "N", 15, 5 } )

return aFields



// ---------------------------------------------------------
// filuj tabelu exporta sa vrijednostima....
// ---------------------------------------------------------
static function fill_exp_tbl( cSast, cNaz, nKol, nStanje )
local nTArea := SELECT()

O_R_EXP

select r_export
set order to tag "1"

seek cSast

if !FOUND()
	
	append blank
	replace field->idsast with cSast
	replace field->naz with cNaz

endif

replace field->kol with field->kol + nKol

// stanje je uvijek isto njega ne sabiri
replace field->stanje with nStanje

if field->kol > 0 .and. field->stanje <= field->kol
	replace field->total with field->kol - field->stanje
else
	replace field->total with 0
endif

select (nTArea)
return



