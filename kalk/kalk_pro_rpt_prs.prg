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


// -----------------------------------------------------
// report: specifikacija po sastavnicama
// -----------------------------------------------------
function rpt_prspec()
local cBrFakt
local cValuta
local dDatOd
local dDatDo
local cRekap
local cExpDbf

if _get_vars( @cBrFakt, @cValuta, ;
		@dDatOd, @dDatDo, @cRekap, @cExpDbf ) == 0
	return
endif

if cRekap == "N" .or. Pitanje(,"Generisati stavke izvjestaja (D/N", "D") == "D"
	_gen_rpt( cBrFakt, cValuta, dDatOd, dDatDo, cRekap )
endif


if cExpDbf == "D"
	
	if cRekap == "D"
		MsgBeep( "Moguce exportovati samo specifikacija !")
		return
	endif
	
	tbl_export()
	
	return

endif

if cRekap == "D"
	_show_rekap( cValuta, cBrFakt )
	return
endif
_show_rpt( cValuta )

return




// -----------------------------------------------
// forma sa uslovima izvjestaja
// -----------------------------------------------
static function _get_vars( cBrFakt, cValuta, dDOd, dDdo, cRekap, cExpDbf )
local GetList := {}

cBrFakt := SPACE(10)
cValuta := "KM "
dDOd := DATE()
dDDo := DATE()
cRekap := "N"
cExpDbf := "N"

Box(, 8, 60)
	
	@ m_x + 1, m_y + 2 SAY "Broj fakture dokumenta 'PR':" GET cBrFakt VALID !EMPTY(cBrFakt)
	
	@ m_x + 2, m_y + 2 SAY "Izvjestaj pravi u valuti (KM/EUR):" GET cValuta VALID !EMPTY(cValuta)
	
	@ m_x + 3, m_y + 2 SAY "Datum od:" GET dDOd 
	
	@ m_x + 4, m_y + 2 SAY "Datum do:" GET dDDo 
	
	@ m_x + 6, m_y + 2 SAY "Napravi samo rekapitulaciju po tarifama:" GET cRekap VALID cRekap $ "DN" PICT "@!"
	
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
static function _gen_rpt( cBrFakt, cValuta, dDatOd, dDatDo, cRekap )
local aFields 
local nKolPrim
local nKolSec
local cJmjPrim
local cJmjSec
local cSastId
local cRobaId
local _idx

aFields := _g_fields()
t_exp_create( aFields )

_idx := my_home() + "brfakt_pr.idx"

O_R_EXP
O_KALK
O_ROBA
O_SIFK
O_SIFV

select kalk

go top

// kreiraj index
INDEX ON ("brfakt") TO (_idx) FOR (idfirma == gFirma .and. Idv == "PR") 
dbSetIndex(_idx)

go TOP
do while !EOF() .and. field->brfaktp == cBrFakt

	// redni broj > 900 su sastavnice
	// a sve do toga je proizvod
	
	if VAL(field->rbr) >= 900
	
		// ovo je sastavnica, uzmi ID
		cSastId := field->idroba
		
		select roba
		set order to tag "ID"
		seek cSastId
		
		// naziv sastavnice
		cSastNaz := field->naz
		// jedinica mjere - primarna (KOM, MET)
		cJmjPrim := field->jmj 

		
		select kalk
	else
		
		// ovo je proizvod, uzmi samo id
		cRobaId := field->idroba
		
		skip
		loop
	
	endif
	
	select r_export
	append blank

	// id proizvoda
	replace field->idroba with cRobaId
	
	// id sastavnice
	replace field->idsast with cSastId
	
	// naziv sastavnice
	replace field->sastnaz with cSastNaz
	
	// carinski tarifni broj
	// uzmi iz sifk ("ROBA", "TARB")
	replace field->ctarbr with IzSifkRoba("TARB", cSastId , .f. )
	
	// primarna jedinica mjere sastavnice
	replace field->jmjprim with cJmjPrim
	
	// kolicina iz kalk-a, u primarnoj jedinici mjere
	nKolPrim := kalk->kolicina
	replace field->kolprim with nKolPrim 

	// sekundarna jedinica mjere
	// sracunaj odmah sve za upis u tabelu
	cJmjSec := ""
	nKolSec := SJMJ( 1, cSastId, @cJmjSec )
	replace field->jmjsec with cJmjSec
	
	// kolicina u sekundarnoj jmj po 1 komadu
	replace field->kolseck with nKolSec

	// kolicina u drugoj jedinici mjere
	replace field->kolsec with ROUND( nKolPrim * nKolSec, 4 )
	
	// cijena sastavnice
	replace field->cijena with kalk->nc

		
	// cijena po komadu kg
	replace field->izn1 with ROUND( field->cijena / nKolSec, 4 ) 

	// ukupno u kg
	replace field->izn2 with ROUND( field->kolprim * field->cijena, 4 )

	select kalk
	skip

enddo

FERASE(_idx)

my_close_all_dbf()

return



// -------------------------------------
// vraca polja pomocne tabele
// -------------------------------------
static function _g_fields()
local aFld := {}

AADD( aFld, { "idroba", "C", 10, 0 })
AADD( aFld, { "idsast", "C", 10, 0 })
AADD( aFld, { "sastnaz", "C", 40, 0 })
AADD( aFld, { "ctarbr", "C", 20, 0 })

AADD( aFld, { "jmjprim", "C", 3, 0 })
AADD( aFld, { "jmjsec", "C", 3, 0 })

AADD( aFld, { "kolprim",   "N", 15, 5 })
AADD( aFld, { "kolsec",   "N", 15, 5 })
AADD( aFld, { "kolseck", "N", 15, 5 })
AADD( aFld, { "cijena",  "N", 15, 5 })
AADD( aFld, { "izn1",   "N", 15, 5 })
AADD( aFld, { "izn2",   "N", 15, 5 })

return aFld



// ---------------------------------------------
// prikazi report iz tabele
// ---------------------------------------------
static function _show_rpt( cValuta )
local cLine

// kreiraj indexe
O_R_EXP
index on r_export->idroba + r_export->idsast tag "1"

select r_export

set order to tag "1"

go top


START PRINT CRET

// zaglavlje specifikacije
_z_spec( @cLine, cValuta )

cXRoba := "XX"

nCnt := 0

nTKPrim := 0
nTKSec := 0
nTIznU := 0

do while !EOF()
	
	cRobaId := field->idroba
	
	// RBR + ROBA
	if cRobaId <> cXRoba 
		? STR(++ nCnt, 3) + "." 
		@ prow(), pcol() + 1 SAY cRobaId
	else
		// ako je ista roba - ne prikazuj je...
		? SPACE(4) 
		@ prow(), pcol() + 1 SAY SPACE(10)
	endif
	
	// ID sastavnica
	@ prow(), pcol()+1 SAY field->idsast
	
	// naziv sastavnice
	@ prow(), pcol()+1 SAY field->sastnaz
	
	// carinski tarifni broj
	@ prow(), pcol()+1 SAY field->ctarbr
	
	// kolicina primarna  (komadi ili metri)
	@ prow(), pcol()+1 SAY STR( field->kolprim, 12, 2 )

	nTKPrim += field->kolprim
	
	// kolicina sekundarna SIFK (kg po komadu)
	@ prow(), pcol()+1 SAY STR( field->kolseck, 12, 2 )

	// kolicina sekundarna SIFK (ukupno)
	@ prow(), pcol()+1 SAY STR( field->kolsec, 12, 2 )

	nTKSec += field->kolsec

	// cijena po jmj
	@ prow(), pcol()+1 SAY STR( field->izn1, 12, 2 )

	// ukupna vrijednost
	@ prow(), pcol()+1 SAY STR( field->izn2, 12, 2 )

	nTIznU += field->izn2
	
	if _nstr()
		FF
	endif

	// setuj pom.varijablu za robu
	cXRoba := cRobaId
	
	skip
enddo

if _nstr()
	FF
endif

? cLine

? PADR( "UKUPNO:", 88 )

@ prow(), pcol() + 1 SAY STR( nTKPrim, 12, 2 )
@ prow(), pcol() + 1 SAY PADR("", 12 )
@ prow(), pcol() + 1 SAY STR( nTKSec, 12, 2 )
@ prow(), pcol() + 1 SAY PADR("", 12)
@ prow(), pcol() + 1 SAY STR( nTIznU, 12, 2)

? cLine

FF
ENDPRINT

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
cLine += REPLICATE("-", 10)
cLine += cRazmak
cLine += REPLICATE("-", 40)
cLine += cRazmak
cLine += REPLICATE("-", 20)
cLine += cRazmak
cLine += REPLICATE("-", 12)
cLine += cRazmak
cLine += REPLICATE("-", 12)
cLine += cRazmak
cLine += REPLICATE("-", 12)
cLine += cRazmak
cLine += REPLICATE("-", 12)
cLine += cRazmak
cLine += REPLICATE("-", 12)

// tekstualni dio zaglavlja - 1 red
cTxt1 += PADR( "R.br", 4 )
cTxt1 += cRazmak
cTxt1 += PADR( "Proizvod", 10 )
cTxt1 += cRazmak
cTxt1 += PADR( "Sifra i naziv sastavnice", 51 )
cTxt1 += cRazmak
cTxt1 += PADC( "Carinski", 20 )
cTxt1 += cRazmak
cTxt1 += PADC( "Normativ", 12 )
cTxt1 += cRazmak
cTxt1 += PADC( "Masa (kg/kom", 12 )
cTxt1 += cRazmak
cTxt1 += PADC( "Ukupna masa", 12 )
cTxt1 += cRazmak
cTxt1 += PADC( "Cijena", 12 )
cTxt1 += cRazmak
cTxt1 += PADC( "Ukupna", 12 )

// tekstualni dio zaglavlja - 2 red
cTxt2 += PADR( "", 4 )
cTxt2 += cRazmak
cTxt2 += PADR( "", 10 )
cTxt2 += cRazmak
cTxt2 += PADR( "", 51 )
cTxt2 += cRazmak
cTxt2 += PADC( "tarifni br.", 20 )
cTxt2 += cRazmak
cTxt2 += PADC( "(m, kom)", 12 )
cTxt2 += cRazmak
cTxt2 += PADC( "kg/met)", 12 )
cTxt2 += cRazmak
cTxt2 += PADC( "(kg)", 12 )
cTxt2 += cRazmak
cTxt2 += PADC( "(kg)", 12 )
cTxt2 += cRazmak
cTxt2 += PADC( "vr. (" + ALLTRIM( cValuta ) + ")" , 12 )


?

P_COND2

B_ON

? "Specifikacija sastavnica i normativima za proizvode po fakturi"

B_OFF

? "na dan:", DTOC(DATE())
?

? cLine
? cTxt1
? cTxt2
? cLine


return



// ---------------------------------------------
// zaglavlje rekapitulacije
// ---------------------------------------------
static function _z_rekap( cLine, cValuta, cFaktBr)
local cTxt1 := ""
local cTxt2 := ""
local cRazmak := SPACE(1)

cLine := ""

// linija zaglavlja
cLine += REPLICATE("-", 4)
cLine += cRazmak
cLine += REPLICATE("-", 20)
cLine += cRazmak
cLine += REPLICATE("-", 40)
cLine += cRazmak
cLine += REPLICATE("-", 16)
cLine += cRazmak
cLine += REPLICATE("-", 12)
cLine += cRazmak
cLine += REPLICATE("-", 12)

// tekstualni dio zaglavlja - 1 red
cTxt1 += PADR( "R.br", 4 )
cTxt1 += cRazmak
cTxt1 += PADC( "Carinska", 20 )
cTxt1 += cRazmak
cTxt1 += PADC( "Opis", 40 )
cTxt1 += cRazmak
cTxt1 += PADC( "Utroseno", 16 )
cTxt1 += cRazmak
cTxt1 += PADC( "Tezina", 12 )
cTxt1 += cRazmak
cTxt1 += PADC( "Ukupna", 12 )

// tekstualni dio zaglavlja - 2 red
cTxt2 += PADR( "", 4 )
cTxt2 += cRazmak
cTxt2 += PADC( "tarifni br.", 20 )
cTxt2 += cRazmak
cTxt2 += PADC( "", 40 )
cTxt2 += cRazmak
cTxt2 += PADC( "isporuka", 16 )
cTxt2 += cRazmak
cTxt2 += PADC( "(kg)", 12 )
cTxt2 += cRazmak
cTxt2 += PADC( "vr. (" + ALLTRIM(cValuta) + ")", 12 )

?

P_COND

B_ON

? PADC( "REKAPITULACIJA PO TARIFNIM OZNAKAMA", 60)

B_OFF

?
? PADC( "prilog fakturi: " + cFaktBr, 60 )
?
?

? cLine
? cTxt1
? cTxt2
? cLine


return


// ---------------------------------------------------
// prikazi rekapitulaciju
// ---------------------------------------------------
static function _show_rekap( cValuta, cFaktBr )
local cLine 
local aTmp
local i

O_R_EXP

index on r_export->ctarbr tag "2"

select r_export
set order to tag "2"

go top

START PRINT CRET

// daj zaglavlje rekapitulacije
_z_rekap( @cLine, cValuta, cFaktBr )

nCnt := 0

nUTKPrim := 0
nUTKSek := 0
nUTIznU := 0

do while !EOF()

	cCTarBr := field->ctarbr
	
	nTKPrim := 0
	nTKSek := 0
	nTIznU := 0
	
	do while !EOF() .and. field->ctarbr == cCTarBr
 
		// ukupno primarna jmj (kom, met)
		nTKPrim += field->kolprim
		// oznaka primarne jedinice
		cJmjPrim := field->jmjprim
		// ukupno u sekundarnoj jmj (kg)
		nTKSek += field->kolsec
		// ukupna vrijednost
		nTIznU += field->kolprim * field->cijena
		
		skip
	enddo

	nUTKPrim += nTKPrim
	nUTKSek += nTKSek
	nUTIznU += nTIznU
	
	++ nCnt
	
	// ispisi ove sume...
	
	? STR( nCnt, 3 ) + "."

	@ prow(), pcol() + 1 SAY cCTarBr

	cCTarOpis := IzFmkIni( "CarTarife", ALLTRIM( cCTarBr ), ;
			"????", KUMPATH )

	aTmp := SjeciStr( cCTarOpis, 40 )

	@ prow(), pcol() + 1 SAY PADR( aTmp[1], 40 )
	
	@ prow(), pcol() + 1 SAY STR( nTKPrim, 12, 2 )

	@ prow(), pcol() + 1 SAY cJmjPrim

	@ prow(), pcol() + 1 SAY STR( nTKSek, 12, 2 )

	@ prow(), pcol() + 1 SAY STR( nTIznU, 12, 2 )
	
	// ostatak opisa tarife stavi u druge redove
	if LEN( aTmp ) > 1
	
		for i := 2 to LEN( aTmp )
			
			? SPACE(25)
			
			@ prow(), pcol()+1 SAY PADR( aTmp[i], 40 )
			
		next
		
	endif
	
enddo

? cLine
? PADR( "UKUPNO:", 83)
@ prow(), pcol()+1 SAY STR( nUTKSek, 12, 2 )
@ prow(), pcol()+1 SAY STR( nUTIznU, 12, 2 )
? cLine


FF
ENDPRINT

return



