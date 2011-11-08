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



// da li se koristi unutrasnja obrada
function is_uobrada()
if IzFmkIni("KALK", "UObrada", "N", KUMPATH) == "D"
	return .t.
else
	return .f.
endif
return .f.


// -----------------------------------------------
// report - unutrasnja obrada
// -----------------------------------------------
function r_uobrada()
local cOdobrenje
local dDatOd
local dDatDo
local cExpDbf
local cLaunch
local cKonto
local cJciNo
local cExNo

// daj uslove
if _get_vars( @cKonto, @cOdobrenje, @cJciNo, @cExNo, ;
		@dDatOd, @dDatDo, @cExpDbf ) == 0
	return
endif

// generisi report u tmp
_gen_rpt( cKonto, cOdobrenje, cJciNo, cExNo, dDatOd, dDatDo )


if cExpDbf == "D"
	
	// exportuj tabelu
	cLaunch := exp_report()
	tbl_export( cLaunch )
	
	return
endif

// prikazi specifikaciju
_show_rpt()

return




// -----------------------------------------------
// forma sa uslovima izvjestaja
// -----------------------------------------------
static function _get_vars( cKonto, cOdobrenje, cJciNo, ;
		cExNo, dDOd, dDdo, cExpDbf )
local GetList := {}

cKonto := PADR("1010", 7)
cOdobrenje := SPACE(20)
cJciNo := SPACE(20)
cExNo := SPACE(20)

dDOd := DATE()
dDDo := DATE()

cExpDbf := "N"

Box(, 8, 60)
	
	@ m_x + 1, m_y + 2 SAY "Magacinski konto" GET cKonto VALID P_konto(@cKonto)
	
	@ m_x + 3, m_y + 2 SAY "Datum od:" GET dDOd 
	
	@ m_x + 3, col() + 1 SAY "do:" GET dDDo 
	
	@ m_x + 5, m_y + 2 SAY "  Odobrenje broj:" GET cOdobrenje 
	@ m_x + 6, m_y + 2 SAY "        JCI broj:" GET cJCIno 
	@ m_x + 7, m_y + 2 SAY "        EX3 broj:" GET cExno 
	
	@ m_x + 8, m_y + 2 SAY "Exportovati tabelu u dbf ?" GET cExpDbf VALID cExpDbf $ "DN" PICT "@!"
	
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1



// ---------------------------------------------
// generisi report u pomocnu tabelu
// ---------------------------------------------
static function _gen_rpt( cKonto, cOdobrenje, cJciNo, cExNo, ;
			dDatOd, dDatDo )
local aFields 

aFields := _g_fields()
t_exp_create( aFields )

O_R_EXP
index on r_export->odobr_no + r_export->jci_no + r_export->ex_no + r_export->idroba tag "2"
set order to tag "2"


O_KALK
O_ROBA
O_SIFK
O_SIFV

select kalk
set order to tag "UOBR"
// idfirma + mkonto + odobr_no + dtos(datdok)

go top

seek gFirma + cKonto 

do while !EOF() .and. field->idfirma == gFirma .and. field->mkonto == cKonto

	// gledaju se samo dokumenti 10 i 96
	// provjeri i ostale uslove....

	cIdvd := field->idvd
	
	if !(cIdvd $ "96#10")
		skip 
		loop
	endif

	if DTOS(field->datdok) < DTos(dDatOd) .or. DTOS(field->datdok) > DTos(dDatDo)
		skip
		loop
	endif

	if !EMPTY( cOdobrenje )
		if field->odobr_no <> cOdobrenje
			skip
			loop
		endif
	endif

	if !EMPTY( cJciNo )
		if field->jci_no <> cJciNo
			skip
			loop
		endif
	endif

	if !EMPTY( cExNo )
		if field->ex_no <> cExNo
			skip
			loop
		endif
	endif

	cRobaId := field->idroba
	cJciNo := field->jci_no
	cExNo := field->ex_no
	cOdobrenje := field->odobr_no
	
	select roba
	hseek cRobaId
	
	cNaziv := field->naz
	cJmj := field->jmj
	
	select kalk
	
	if cIdvd == "10"
		nUlaz := field->kolicina
		nIzlaz := 0
	else
		nUlaz := 0
		nIzlaz := field->kolicina
	endif

	
	select r_export
	set order to tag "2"
	seek cOdobrenje + cJciNo + cExNo + cRobaId
	
	if !FOUND() .and. field->idroba <> cRobaId

		append blank
		
		replace field->idroba with cRobaId
		replace field->robanaz with cNaziv
		replace field->jmj with cJmj
		replace field->odobr_no with cOdobrenje
		replace field->jci_no with cJciNo
		replace field->ex_no with cExNo 

	endif

	replace field->kol_ul with field->kol_ul + nUlaz 
	replace field->kol_iz with field->kol_iz + nIzlaz
	replace field->stanje with field->stanje + (nUlaz - nIzlaz) 

	select kalk
	skip

enddo


return



// -------------------------------------
// vraca polja pomocne tabele
// -------------------------------------
static function _g_fields()
local aFld := {}

AADD( aFld, { "idroba", "C", 10, 0 })
AADD( aFld, { "robanaz", "C", 40, 0 })
AADD( aFld, { "jmj", "C", 3, 0 })

AADD( aFld, { "odobr_no", "C", 20, 0 })
AADD( aFld, { "jci_no", "C", 20, 0 })
AADD( aFld, { "ex_no", "C", 20, 5 })

AADD( aFld, { "kol_ul", "N", 15, 5 })
AADD( aFld, { "kol_iz", "N", 15, 5 })
AADD( aFld, { "stanje", "N", 15, 5 })

return aFld



// ---------------------------------------------
// prikazi report iz tabele
// ---------------------------------------------
static function _show_rpt( )
local cLine

// kreiraj indexe
O_R_EXP
index on r_export->odobr_no + r_export->jci_no + r_export->ex_no tag "1"

select r_export

set order to tag "1"

go top


START PRINT CRET

// zaglavlje specifikacije
_z_spec( @cLine )

nCnt := 0
nUTot_ul := 0
nUTot_iz := 0

do while !EOF()

	cOdobrenje := field->odobr_no
	cJciNo := field->jci_no

	nCntJci := 0

	nTot_ul := 0
	nTot_iz := 0

	do while !EOF() .and. field->odobr_no == cOdobrenje ;
			.and. field->jci_no == cJciNo
 
		
		cExNo := field->ex_no
		cJciNo := field->jci_no
		
		cRobaId := field->idroba
	
		// ispisi JCI i EX3
		if nCntJci == 0
			? SPACE(5), "JCI broj:", cJciNo, "EX3 broj:", cExNo 
		endif

		? STR(++ nCnt, 3) + "." 
		@ prow(), pcol() + 1 SAY cRobaId
	
		@ prow(), pcol()+1 SAY PADR(field->robanaz, 25) + ;
			"(" + field->jmj + ")"
	
		@ prow(), pcol()+1 SAY STR( field->kol_ul, 12, 2 )
		@ prow(), pcol()+1 SAY STR( field->kol_iz, 12, 2 )
		@ prow(), pcol()+1 SAY STR( field->stanje, 12, 2 )
	
		nTot_ul += field->kol_ul
		nTot_iz += field->kol_iz

		++ nCntJci

		if _nstr()
			FF
		endif

		skip
		
		// setuj pom.varijablu za robu
		cXRoba := cRobaId
	
	enddo

	// ispisi total za jedan JCI
	? PADR("Ukupno za JCI br:", cJciNo, 80) 
	@ prow(), pcol()+1 SAY STR( nTot_ul, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nTot_iz, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nTot_ul - nTot_iz, 12, 2 )

	
enddo

if _nstr()
	FF
endif

? cLine

? PADR( "UKUPNO:", 88 )

@ prow(), pcol() + 1 SAY STR( nUTot_ul, 12, 2 )
@ prow(), pcol() + 1 SAY PADR("", 12 )
@ prow(), pcol() + 1 SAY STR( nUTot_iz, 12, 2 )
@ prow(), pcol() + 1 SAY PADR("", 12)
@ prow(), pcol() + 1 SAY STR( nUTot_ul - nUTot_iz, 12, 2)

? cLine

FF
END PRINT

return


// ---------------------------------------------
// provjeri za novu stranicu...
// ---------------------------------------------
static function _nstr()

if prow() > 65
	return .t.
endif

return .f.




// ---------------------------------------------
// zaglavlje specifikacije
// ---------------------------------------------
static function _z_spec( cLine, cValuta )
local cTxt1 := ""
local cTxt2 := ""
local cRazmak := SPACE(1)

cLine := ""

// linija zaglavlja
cLine += REPLICATE("-", 4)
cLine += cRazmak
cLine += REPLICATE("-", 10)
cLine += cRazmak
cLine += REPLICATE("-", 30)
cLine += cRazmak
cLine += REPLICATE("-", 12)
cLine += cRazmak
cLine += REPLICATE("-", 12)
cLine += cRazmak
cLine += REPLICATE("-", 12)

// tekstualni dio zaglavlja - 1 red
cTxt1 += PADR( "R.br", 4 )
cTxt1 += cRazmak
cTxt1 += PADR( "Roba", 10 )
cTxt1 += cRazmak
cTxt1 += PADR( "Naziv (jmj)", 30 )
cTxt1 += cRazmak
cTxt1 += PADC( "Ulaz", 12 )
cTxt1 += cRazmak
cTxt1 += PADC( "Izlaz", 12 )
cTxt1 += cRazmak
cTxt1 += PADC( "Stanje", 12 )

?

P_COND2

B_ON

? "UNUTRASNJA OBRADA, pregled ulaza i izlaza za period"

B_OFF

? "na dan:", DTOC(DATE())
?

? cLine
? cTxt1
? cLine


return


