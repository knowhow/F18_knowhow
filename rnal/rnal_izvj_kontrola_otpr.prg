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


#include "rnal.ch"


// -----------------------------------------------------
// provjera podataka, sta je prebaceno od otpremnica
// -----------------------------------------------------
function m_rpt_check()
local dD_from
local dD_to
local nOper
local cStatus
local nVar := 0

// uslovi izvjestaja
if std_vars( @dD_from, @dD_to, @nOper, @cStatus ) = 0
	return
endif

if Pitanje(,"Prikazati samo naloge koji nisu prebaceni ? (D/N)", "D") == "D"
	nVar := 1
endif

// napravi report
_cre_report( dD_from, dD_to, nOper, cStatus )

// rpt
_gen_rpt( dD_from, dD_to, nOper, nVar )

return



// ------------------------------------------------------
// stampa izvjestaja
// ------------------------------------------------------
static function _gen_rpt( dD_from, dD_to, nOper, nVar )
local cLine

START PRINT CRET

?

P_COND

_rpt_head( @cLine, dD_from, dD_to )

select _tmp1
go top

do while !EOF()

	// samo prikazi one koji nisu prebaceni
	if nVar = 1
		if ALLTRIM( field->fakt_d1 ) + ;
			ALLTRIM( field->pos_d1 ) <> "??"
			
			// preskoci ovaj zapis
			skip
			loop

		endif
	endif

	? field->doc_no
	@ prow(), pcol()+1 SAY PADR( field->customer, 30 )
	@ prow(), pcol()+1 SAY field->doc_date
	@ prow(), pcol()+1 SAY field->dvr_date
	@ prow(), pcol()+1 SAY field->fakt_d1
	//@ prow(), pcol()+1 SAY field->fakt_d2
	
	skip

enddo

? cLine

close all

FF
END PRINT

return


// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
static function _rpt_head( cLine, dD_from, dD_to )
local cTxt

? "------------------------------"
? "Dokumenti koji nisu obradjeni:"
? "------------------------------"
? "Datum od " + DTOC(dD_from) + " do " + DTOC(dD_to)

cLine := REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 8)
cLine += SPACE(1)
cLine += REPLICATE("-", 8)
cLine += SPACE(1)
cLine += REPLICATE("-", 10)

cTxt := PADR("Broj nal.", 10)
cTxt += SPACE(1)
cTxt += PADR("Kupac", 30)
cTxt += SPACE(1)
cTxt += PADR("Datum", 8)
cTxt += SPACE(1)
cTxt += PADR("Ispor.", 8)
cTxt += SPACE(1)
cTxt += PADR("FAKT", 10)

? cLine 
? cTxt
? cLine

return

// --------------------------------------------------------------
// provjeri linkove sa maloprodajnim racunima
// --------------------------------------------------------------
function chk_dok_11()
local dD_from := DATE()
local dD_to := DATE()
local aMemo
local cMemo
local aTmp
local i
local nNalog
local cFaktDok
local cReset := "N"

private GetList:={}

box(,2, 60)

	@ m_x + 1, m_y + 2 SAY "za datum od" GET dD_from
	@ m_x + 1, col() + 1 SAY "do" GET dD_to
	
	@ m_x + 2, m_y + 2 SAY "resetuj broj veze u RNAL (D/N)?" ;
		GET cReset VALID cReset $ "DN" PICT "@!"

	read
boxc()

if LastKey() == K_ESC
	return
endif

// napravi linkove sa doks-om
select (240)
use ( ALLTRIM(gFaKumDir) + "FAKT" ) alias "f_dok"
set order to tag "1"

// otvori potrebne tabele
o_tables( .f. )

select f_dok
go top

msgo("Popunjavam veze ...")

do while !EOF()
	
	// gledaj samo mp racune
	if ( field->idtipdok <> "11" ) .or. ( ALLTRIM(field->rbr) <> "1" )
		skip
		loop
	endif

	// provjeri datum faktura
	if ( field->datdok > dD_to ) .or. ( field->datdok < dD_from )
		skip
		loop
	endif

	cFaktDok := ALLTRIM( field->brdok )

	// uzmi memo polje
	aMemo := ParsMemo( field->txt )	
		
	if LEN( aMemo ) > 18
		// ovo je polje koje sadrzi brojeve veza...
		cMemo := aMemo[ 19 ]
	else
		cMemo := ""
	endif

	if !EMPTY( cMemo )

		// ubaci u matricu...
		aTmp := TokToNiz( cMemo, ";" )

		// obradi svaki pojedinacni nalog
		for i:=1 to len( aTmp )
			
			// evo broj naloga
			nNalog := VAL( ALLTRIM(aTmp[i]) )
			
			// prekontrolisi ga sada u rnal-u
			select docs
			go top
			seek docno_str( nNalog )

			if FOUND()
				
			  if cReset == "D"
			  	// resetuj polje fmk_doc prije svega
				replace fmk_doc with ""
			  endif

			  replace fmk_doc with ;
				_fmk_doc_upd( ;
					ALLTRIM( field->fmk_doc ), ;
					cFaktDok + "M" )
			
			endif

		next
	
	endif

	select f_dok
	skip
enddo

msgc()

// prekini vezu sa doks
select (240)
use

return



// ---------------------------------------------------------------
// glavna funkcija za kreiranje pomocne tabele
// ---------------------------------------------------------------
static function _cre_report( dD_f, dD_t, nOper, cStatus )
local aField
local cValue := ""
local aValue := {}
local nDoc_no
local aFmk
local cSep := ";"
local i
local cFFirma := "10"
local cFTipDok := "12"
local cPFirma := ""
local cPTipDok := ""

// kreiraj tmp tabelu
aField := _rpt_fields()

cre_tmp1( aField )
O__TMP1
index on STR( doc_no, 10) tag "1"

// napravi linkove sa fakt-om i pos-om
select (240)
use ( ALLTRIM(gFaKumDir) + "FAKT" ) alias "f_dok"
set order to tag "1"

// otvori potrebne tabele
o_tables( .f. )

_main_filter( dD_f, dD_t, nOper, cStatus )

Box(, 1, 50 )

do while !EOF()
	
	// uzmi podatke dokumenta da vidis treba li da se generise
	// u izvjestaj ?

	nDoc_no := field->doc_no
	
	@ m_x + 1, m_y + 2 SAY "obradjujem nalog: " + ALLTRIM(STR(nDoc_no))

	dDoc_date := field->doc_date
	dDvr_date := field->doc_dvr_date
	nCust := field->cust_id
	nCont := field->cont_id
	cCustomer := ALLTRIM( g_cust_desc( nCust ) )
	cCustomer += "/" + ALLTRIM( g_cont_desc( nCont ) )
	cFmk_doc := ALLTRIM( field->fmk_doc )

	// idi dalje
	if !EMPTY( cFmk_doc)
		skip
		loop
	endif
	
	// da li ga ima u FAKT-u ?
	
	cDokument := ALLTRIM(STR(nDoc_no)) + ";"
	cF_doc1 := "?"
	cF_doc2 := "?"
	cP_doc1 := "?"

	select f_dok
	seek cFFirma + cFTipDok

	// resetuj memo vrijednost
	aMemo := {}

	do while !EOF() .and. field->idfirma + field->idtipdok == ;
		cFFirma + cFTipDok
			
		// gledaj samo redni broj jedan fakture
		if ALLTRIM( field->rbr ) <> "1"
			skip
			loop
		endif

		// uzmi memo polje
		aMemo := ParsMemo( field->txt )	
		
		if LEN( aMemo ) > 18
			cMemo := aMemo[ 19 ]
		else
			cMemo := ""
		endif

		// tu je !
		if cDokument $ cMemo
			cF_doc1 := field->brdok
			exit
		endif

		skip
	enddo
	
	app_to_tmp1( nDoc_no, cCustomer, dDoc_date, dDvr_date, ;
			cF_doc1, cF_doc2, cP_doc1 )

	// idemo dalje...
	select docs
	skip

enddo

BoxC()

return


// -------------------------------------------------
// dodaj u pomocnu tabelu
// -------------------------------------------------
static function app_to_tmp1( nDoc_no, cCustomer, dDate, dDel_date, ;
	cFakt_dok1, cFakt_dok2, cPos_dok1 )
local nTArea := SELECT()

O__TMP1
go top
seek docno_str( nDoc_no )

if !FOUND()
	append blank
	replace field->doc_no with nDoc_no
endif

replace field->customer with cCustomer
replace field->doc_date with dDate
replace field->dvr_date with dDel_date
replace field->fakt_d1 with cFakt_dok1
replace field->fakt_d2 with cFakt_dok2
replace field->pos_d1 with cPos_dok1

select (nTArea)
return



// -----------------------------------------
// polja tabele izvjestaja
// -----------------------------------------
static function _rpt_fields()
local aRet := {}

AADD(aRet, { "doc_no", "N", 10, 0 })
AADD(aRet, { "customer", "C", 50, 0 })
AADD(aRet, { "doc_date", "D", 8, 0 })
AADD(aRet, { "dvr_date", "D", 8, 0 })
AADD(aRet, { "fakt_d1", "C", 10, 0 })
AADD(aRet, { "fakt_d2", "C", 10, 0 })
AADD(aRet, { "pos_d1", "C", 10, 0 })

return aRet


// -------------------------------------------------
// filter 
// -------------------------------------------------
static function _main_filter( dDFrom, dDTo, nOper, cStatus )
local cFilter := ""

select docs

cFilter += "(doc_status == 0 .or. doc_status > 2)"
cFilter += " .and. DTOS(doc_date) >= " + cm2str(DTOS(dDFrom))
cFilter += " .and. DTOS(doc_date) <= " + cm2str(DTOS(dDTo))

if nOper <> 0
	cFilter += ".and. operater_i = " + STR( nOper, 3 )
endif

set filter to &cFilter
go top

return


