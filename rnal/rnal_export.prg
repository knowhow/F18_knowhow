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


// -------------------------------------------
// export dokumenta
// nDoc_no - dokument broj
// lTemporary - priprema .t., kumulativ .f.
// lWriteRel - upisi rel_ver prvi zapis
// -------------------------------------------
function exp_2_lisec( nDoc_no, lTemporary, lWriteRel )
local cLocation
local cFile := ""
local nHnd
local nADOCS := F_DOCS
local nADOC_IT := F_DOC_IT
local nADOC_OP := F_DOC_OPS
local nTArea := SELECT()

local aRel
local aRelSpec
local aPos
local aPosSpec
local aPo2
local aPo2Spec
local aOrd
local aOrdSpec
local aTxt
local aTxtSpec
local aTx2Spec
local aTx3Spec
local aGl1
local aGl2
local aGl3
local aGlSpec
local aFr1
local aFr2
local aFrSpec

local ix
local i
local iy

local aArticles
local aElem


// napuni matrice sa specifikacijama record-a
aRelSpec := _get_rel()
aOrdSpec := _get_ord()
aPosSpec := _get_pos()
aPo2Spec := _get_po2()
aTxtSpec := _get_txt(1)
aTx2Spec := _get_txt(2)
aTx3Spec := _get_txt(3)
aFrSpec  := _get_frx()
aGlSpec  := _get_glx()

if lTemporary == nil
	lTemporary := .f.
endif

if lWriteRel == nil
	lWriteRel := .f.
endif

if lTemporary == .t.
	nADOCS := F__DOCS
	nADOC_IT := F__DOC_IT
	nADOC_OP := F__DOC_OPS
endif

select (nADOCS)
go top
seek docno_str( nDoc_no )


// ako je nalog 0 ili manje, znaci da nema broja
// nije odstampan !

if nDoc_no <= 0
	msgbeep("Broj naloga: " + ALLTRIM(STR(nDoc_no)) + ;
		"#Odradite prvo stampu naloga !" )
	return
endif

// uzmi lokaciju fajla
g_exp_location( @cLocation )

// kreiraj fajl exporta....
if cre_exp_file( nDoc_no, cLocation, @cFile, @nHnd ) == 0

	select (nTArea)
	msgbeep("Operacija ponistena, nista nije exportovano!")
	return

endif


// -----------------------------------------------------
//
// WRITE VALUES TO TRF FILE
//
// -----------------------------------------------------


Box(,2, 60)

@ m_x + 1, m_y + 2 SAY PADR("upisujem osnovne podatke", 50)

// upisi <REL>
aRel := add_rel( "" )
write_rec( nHnd, aRel, aRelSpec )

select (nADOCS)
nCustId := field->cust_id
nContId := field->cont_id

// nadji naziv narucioca
select customs
set filter to
set order to tag "1"
go top
seek custid_str(nCustid)

select contacts
set filter to
set order to tag "1"
go top
seek contid_str(nContId)

select (nADOCS)

// ako su podaci ispravni
if field->cust_id <> 0

	@ m_x + 1, m_y + 2 SAY PADR("upisujem podatke o partneru ...... ",50)
	// uzmi i upisi osnovne elemente naloga
	aOrd := add_ord( field->doc_no , ;
		field->cust_id , ;
		ALLTRIM( customs->cust_desc ) + " " + ALLTRIM(customs->cust_addr) + " " + ALLTRIM(customs->cust_tel) , ;
		ALLTRIM( field->doc_desc ) , ;
		ALLTRIM( field->doc_sh_desc ) , ;
		ALLTRIM( field->cont_add_desc ) , ;
		ALLTRIM( contacts->cont_desc) + " " + ALLTRIM(contacts->cont_tel) , ;
		nil, ;
		field->doc_date, ;
		field->doc_dvr_date, ;
		field->doc_ship_place )
		
	// UPISI <ORD>
	write_rec( nHnd, aOrd, aOrdSpec )
	
else

	select (nTArea)
	msgbeep("Nisu ispravni podaci narudzbe !!!!#Operacija prekinuta...")

	BoxC()

	// izadji....
	return

endif

// predji na stavke naloga

nCount := 0

select (nADOC_IT)
go top
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no

	nTRec := RECNO()

	@ m_x + 1, m_y + 2 SAY PADR("upisujem stavke naloga.....", 50)
	
	nDoc_it_no := field->doc_it_no
	nArt_id := field->art_id
	nHeight := field->doc_it_height
	nWidth := field->doc_it_width

	select articles
	set order to tag "1"
	seek artid_str( nArt_id )

	select (nADOC_IT)
	
	cGl1 := ""
	cPosGl1 := ""
	cGl2 := ""
	cPosGl2 := ""
	cGl3 := ""
	cPosGl3 := ""
	cFr1 := ""
	cPosFr1 := ""
	cFr2 := ""
	cPosFr2 := ""
	nGl1h := 0
	nGl1w := 0
	nGl2h := 0
	nGl2w := 0
	nGl3h := 0
	nGl3w := 0
	nUnit_w := nWidth
	nUnit_h := nHeight

	// uzmi i razlozi artikal
	// F4_A12_F3
	cArtDesc := ALLTRIM( articles->art_desc )

	// napuni aElem sa elemetima artikla
	aElem := {}
	// aelem = { elem_id, descriptin, rec.no }
	_g_art_elements( @aElem, articles->art_id )

	// aArtDesc[1] = F4
	// ....    [2] = A12
	// ....    [3] = F3
	aArtDesc := TokToNiz( cArtDesc, "_" )

	aArticles := {}

	for i := 1 to LEN( aArtDesc )
	
		nElem := aElem[i, 1]
		// sta je ovaj elemenat
		
		cType := g_grd_by_elid( nElem )

		// aArt { elem_no, art_desc, position, 
		//        width, height, posx, posy, neww, newh, 
		//        x, y, type}
		AADD( aArticles, { nElem, ;
				aArtDesc[i], ;
				ALLTRIM(STR(++nCount)), ;
				nWidth, ;
				nHeight, ;
				0, 0, ;
				nWidth, nHeight, ;
				0, 0, cType } )	
		
		@ m_x + 2, m_y + 2 SAY PADR(cArtdesc + " - ok stavka - " + ;
				ALLTRIM(STR(i)), 50)

	next

	// pregledaj operacije artikla
	// npr: ako ima brusenje - mora se dodati po 3 mm na dimenzije

	// ima za upis u <PO2>
	lPo2Write := .f.

	select (nADOC_OP)
	set order to tag "1"
	go top
	seek docno_str(nDoc_no) + docit_str(nDoc_it_no)

	do while !EOF() .and. field->doc_no == nDoc_no ;
			.and. field->doc_it_no == nDoc_it_no

		cJoker := g_aatt_joker( field->aop_att_id )
			
		select (nADOC_OP)
	
		// moramo znati i koji je element
		nElemPos := field->doc_it_el_no
	
		// kod brusenja dodaj na dimenzije po 3mm
		if cJoker == "<A_B>"
		
			lPo2Write := .t.

			nScan := ASCAN( aArticles, { |xvar| xvar[1] == nElemPos } )

			if nScan <> 0

				// ako su init.vrijednosti spucaj mu 
				// tacnu h i w mjeru

				if aArticles[nScan, 8] = 0
					aArticles[nScan, 8] := nWidth
				endif
				if aArticles[nScan, 9] = 0
					aArticles[nScan, 9] := nHeight
				endif

				// upisi preracunate vrijednosti
				// u matricu...

				nHtmp := _calc_dimension( nHeight, .t. )
			  	nWtmp := _calc_dimension( nWidth, .t. )
			
				// povecanje
				aArticles[ nScan, 6 ] += gAddToDim
				aArticles[ nScan, 7 ] += gAddToDim
				
				// nove dimenzije
				aArticles[ nScan, 8 ] += gAddToDim 
				aArticles[ nScan, 9 ] += gAddToDim
			endif
		endif

		// kod prepust stakala - takodjer gledaj druge dimenzije
		if "A_PREP" $ cJoker 
			
			lPo2Write := .t.

			cValue := field->aop_value 

			nScan := ASCAN( aArticles, { |xvar| xvar[1] == nElemPos } )

			
			nH := 0
			nW := 0

			nHraz := 0
			nWraz := 0

			// izracunaj koje su dimenzije prepusta
			get_prep_dim( cValue, @nW, @nH )

			nHraz := ( nH - nHeight )
			nWraz := ( nW - nWidth )

			if nScan <> 0
			
				if aArticles[nScan, 8] = 0
					aArticles[nScan, 8] := nWidth
				endif

				if aArticles[nScan, 9] = 0
					aArticles[nScan, 9] := nHeight
				endif

				// povecanje
				aArticles[ nScan, 6 ] += nWraz
				aArticles[ nScan, 7 ] += nHraz

				// nova dimenzija
				aArticles[ nScan, 8 ] += nWraz
				aArticles[ nScan, 9 ] += nHraz
			endif

		endif

		skip
	enddo

	select (nADOC_IT)
	go (nTRec)

	// napuni varijable
	for ix := 1 to LEN( aArticles )
		
		if ix == 1
			cGl1 := aArticles[ix, 2]
			cPosGl1 := aArticles[ix, 3]
			nGl1w := aArticles[ix, 8]
			nGl1h := aArticles[ix, 9]
		endif
		
		if ix == 2
			cFr1 := aArticles[ix, 2]
			cPosFr1 := aArticles[ix, 3]
		endif

		if ix == 3
			cGl2 := aArticles[ix, 2]
			cPosGl2 := aArticles[ix, 3]
			nGl2w := aArticles[ix, 8]
			nGl2h := aArticles[ix, 9]
		endif

		if ix == 4
			cFr2 := aArticles[ix, 2]
			cPosFr2 := aArticles[ix, 3]
		endif

		if ix == 5
			cGl3 := aArticles[ix, 2]
			cPosGl3 := aArticles[ix, 3]
			nGl3w := aArticles[ix, 8]
			nGl3h := aArticles[ix, 9]
		endif
	next

	// samo ako su dimenzije ispravne.....
	if ( field->doc_it_width <> 0 .and. ;
		field->doc_it_height <> 0 .and. ;
		field->doc_it_qtty <> 0 )
		
		// ubaci u matricu podatke
		aPos := add_pos( field->doc_it_no, ;
			"", ;
			nil, ;
			field->doc_it_qtty, ;
			nGl1w, ;
			nGl1h, ;
			cPosGl1, ;
			cPosFr1, ;
			cPosGl2, ;
			cPosFr2, ;
			cPosGl3 )

		// upisi <POS>
		write_rec( nHnd, aPos, aPosSpec )
		
		
	endif
	
	// da li ima za dodatne informacije <PO2> ?
	if lPo2Write == .t. 
	  
		  aPo2 := add_po2( "", ;
			nGl1w, ;
			nGl1h, ;
			0, 0, 0, 0, ;
			0, ; //_step( nGl1w, nUnit_w ), ;
			0, ; //_step( nGl1h, nUnit_h ), ;
			0, 0, ;
			nGl2w, ;
			nGl2h, ;
			0, 0, 0, 0, ;
			_step( nGl2w, nGl1w ) , ;
			_step( nGl2h, nGl1h ), ;
			0, 0, ;
			0, 0, ;
			nGl3w, ;
			nGl3h, ;
			0, 0, 0, 0, ;
			_step( nGl3w, nGl2w ), ;
			_step( nGl3h, nGl2h ), ;
			0, 0, ;
			0, 0 )
	
		// upisi <PO2>
		write_rec( nHnd, aPo2, aPo2Spec )
		
	
	endif

	// upisi <GLx> <FRx>
	_a_gx_fx( nHnd, cGl1, cGl2, cGl3, cFr1, cFr2, ;
			aGlSpec, aFrSpec )

	// ako ima napomena...
	if !EMPTY( field->doc_it_desc )
		
		// upisi <TXT> ostale informacije
		aTxt := add_txt( 1, ALLTRIM( field->doc_it_desc ) )
		write_rec(nHnd, aTxt, aTxtSpec )

	endif

	select (nADOC_IT)
	go (nTRec)

	skip
	
enddo

BoxC()

select (nADOC_IT)
go top

close_exp_file( cFile )

select (nTArea)

msgbeep("Export zavrsen ... kreiran je fajl#" + ;
	IF( LEN(cLocation) > 20,  ;
		PADR( cLocation, 20 ) + "..." , ;
		cLocation ) + cFile )

return

// ----------------------------------------------------
// step vrijednost kod razlicite dimenzije stakla
// nGl1 - vrijednost za staklo
// nUnit - vrijednost za kompletnu jedinicu
// ----------------------------------------------------
static function _step( nGl1, nUnit )
local nZero := 0
local nStep := 0

do case
	case ( nGl1 <> 0 ) .and. ( nGl1 <> nUnit ) 
		
		nStep := ABS(nGl1 - nUnit)
		return nStep

endcase

return nZero


// --------------------------------------------------
// upisi vrijednosti gx - fx
// --------------------------------------------------
static function _a_gx_fx(nHnd, cGl1, cGl2, cGl3, ;
			cFr1, cFr2, ;
			aGlSpec, aFrSpec )

// upisi <GLx>, <FRx>
if !EMPTY( cGl1 )
		
	aGl1 := add_glx( "1", cGl1 )
	write_rec( nHnd, aGl1, aGlSpec )
		
endif
if !EMPTY( cFr1 )
			
	aFr1 := add_frx( "1", cFr1 )
	write_rec( nHnd, aFr1, aFrSpec )
			
endif
if !EMPTY( cGl2 )
			
	aGl2 := add_glx( "2", cGl2 )
	write_rec( nHnd, aGl2, aGlSpec )
			
endif
if !EMPTY( cFr2 )
			
	aFr2 := add_frx( "2", cFr2 )
	write_rec( nHnd, aFr2, aFrSpec )
			
endif
if !EMPTY( cGl3 )

	aGl3 := add_glx( "3", cGl3 )
	write_rec( nHnd, aGl3, aGlSpec )
	
endif
		
return


// -------------------------------------------------------------
// kalkuliranje nove dimenzije ako je brusenje u pitanju
// -------------------------------------------------------------
static function _calc_dimension( nDimension, lBrusenje )
local nNewDim := nDimension

if lBrusenje == .t.
	nNewDim := nDimension + gAddToDim
endif

return nNewDim





