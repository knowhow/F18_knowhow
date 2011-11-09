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

// variables

static l_new_it
static _doc


// ------------------------------------------
// unos ispravka stavki naloga.... 
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// ------------------------------------------
function e_doc_item( nDoc_no, lNew )
local nX := m_x
local nY := m_y
local nGetBoxX := 18
local nGetBoxY := 70
local cBoxNaz := "unos nove stavke"
local nRet := 0
local nFuncRet := 0
local cGetDOper := "N"
local lCopyAop
local nArt
private GetList:={}

_doc := nDoc_no

if lNew == nil
	lNew := .t.
endif

l_new_it := lNew

if l_new_it == .f.
	cBoxNaz := "ispravka stavke"
endif

select _doc_it

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos stavki naloga")

set_opc_box(nGetBoxX, 50)

// say top, bottom
@ m_x + 1, m_y + 2 SAY PADL("***** " + cBoxNaz , nGetBoxY - 2)
@ m_x + nGetBoxX, m_y + 2 SAY PADL("(*) popuna obavezna", nGetBoxY - 2) COLOR "BG+/B"

Scatter()

do while .t.

	nFuncRet := _e_box_item( nGetBoxX, nGetBoxY, @cGetDOper )
	
	if nFuncRet == 1
		
		select _doc_it
		
		if l_new_it
			append blank
		endif
		
		Gather()
		
		if cGetDOper == "D"
			
			lCopyAop := .f.
			
			// operacije moguæe kopirati samo ako je isti 
			// artikal i ako je redni broj <> 1

			if _doc_it->doc_it_no <> 1
				
				nArt := _doc_it->art_id
				
				skip -1
				
				if nArt == _doc_it->art_id
				
					lCopyAop := .t.
				
				endif
				
				skip 1
			
			endif
			
			if lCopyAop == .t. .and. pitanje(, "koristi operacije prethodne stavke ?", "N") == "D"
			
				// kopiraj operacije...
				_cp_oper( _doc, ;
					_doc_it->art_id, ;
					_doc_it->doc_it_no )
			
			else
				
				// manualno unesi operacije
				
				e_doc_ops( _doc, ;
				   lNew, ;
				   _doc_it->art_id, ;
				   _doc_it->doc_it_no )
				   
			endif
			
			select _doc_it
			
		endif
		
		if l_new_it
			loop
		endif
		
	endif
	
	BoxC()
	select _doc_it
	
	nRet := RECCOUNT2()
	
	exit

enddo

select _docs

m_x := nX
m_y := nY

return nRet


// -------------------------------------------------
// forma za unos podataka 
// cGetDOper , D - unesi dodatne operacije...
// -------------------------------------------------
static function _e_box_item( nBoxX, nBoxY, cGetDOper )
local nX := 1
local aArtArr := {}
local nTmpArea
local nLeft := 21

cGetDOper := "N"

if l_new_it
	
	_doc_no := _doc
	_doc_it_no := inc_docit( _doc )
	//_doc_it_altt := 0
	//_doc_acity := SPACE( LEN(_doc_acity) )
	_doc_it_type := " "
	
	// ako je nova stavka i vrijednost je 0, uzmi default...
	if _doc_it_altt == 0
		_doc_it_altt := gDefNVM
	endif

	if EMPTY( _doc_acity )
		_doc_acity := PADR( gDefCity, 50 )
	endif

	if _doc_it_schema == " "
		_doc_it_schema := "N"
	endif
	
endif

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("r.br stavke (*)", nLeft) GET _doc_it_no 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("ARTIKAL (*):", nLeft) GET _art_id VALID {|| s_articles( @_art_id, .f., .t. ), show_it( g_art_desc( _art_id, nil, .f. ) + ".." , 35 ) } WHEN set_opc_box( nBoxX, 50, "0 - otvori sifrarnik i pretrazi" )

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Tip artikla (*):", nLeft) GET _doc_it_type VALID {|| _doc_it_type $ " SR", show_it( _g_doc_it_type( _doc_it_type ) ) } WHEN set_opc_box( nBoxX, 50, "' ' - standardni, 'R' - radius, 'S' - shape") PICT "@!"

read

ESC_RETURN 0

// set opisa na formi
cDimADesc := "(A) sirina [mm] (*):"
cDimBDesc := "(B) visina [mm] (*):"
cDimCDesc := "(C) sirina [mm] (*):"
cDimDDesc := "(D) visina [mm] (*):"

if _doc_it_type == "R"
	cDimADesc := "(A) fi [mm] (*):"
	cDimBDesc := "(B) fi [mm] (*):"
endif

if _doc_it_type $ "SR"
	_doc_it_schema := "D"
endif


nX += 1

@ m_x + nX, m_y + 2 SAY PADL("shema u prilogu (D/N)? (*):", nLeft + 9) GET _doc_it_schema PICT "@!" VALID {|| _doc_it_schema $ "DN" } WHEN {|| _set_arr( _art_id, @aArtArr), set_opc_box( nBoxX, 50, "da li postoji dodatna shema kao prilog") }

@ m_x + nX, col() + 2 SAY "pozicija" GET _doc_it_pos ;
	WHEN {|| set_opc_box(nBoxX, 50, "pozicija naljepnice") }

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("dod.nap.stavke:", nLeft) GET _doc_it_desc PICT "@S40" WHEN set_opc_box( nBoxX, 50, "dodatne napomene vezane za samu stavku")

nX += 2
	
@ m_x + nX, m_y + 2 SAY PADL( cDimADesc , nLeft + 3) GET _doc_it_width PICT Pic_Dim() VALID val_width(_doc_it_width) .and. rule_items("DOC_IT_WIDTH", _doc_it_width, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

// ako je tip SHAPE
if _doc_it_type == "S"
	
	@ m_x + nX, col() + 2 SAY PADL( cDimCDesc , nLeft + 3) GET _doc_it_w2 PICT Pic_Dim() VALID val_width(_doc_it_w2) .and. rule_items("DOC_IT_WIDTH", _doc_it_w2, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

else

	_doc_it_w2 := 0

endif

nX += 1

@ m_x + nX, m_y + 2 SAY PADL( cDimBDesc , nLeft + 3) GET _doc_it_heigh PICT Pic_Dim() VALID val_heigh(_doc_it_heigh) .and. rule_items("DOC_IT_HEIGH", _doc_it_heigh, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

// ako je tip SHAPE
if _doc_it_type == "S"
		
	@ m_x + nX, col() + 2 SAY PADL( cDimDDesc , nLeft + 3) GET _doc_it_h2 PICT Pic_Dim() VALID val_heigh(_doc_it_h2) .and. rule_items("DOC_IT_HEIGH", _doc_it_h2, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

else
	_doc_it_h2 := 0
endif

nX += 1


@ m_x + nX, m_y + 2 SAY PADL("kolicina [kom] (*):", nLeft + 3) GET _doc_it_qtty PICT Pic_Qtty() VALID val_qtty(_doc_it_qtty) .and. rule_items("DOC_IT_QTTY", _doc_it_qtty, aArtArr ) WHEN set_opc_box( nBoxX, 50 )

nX += 1

read

ESC_RETURN 0


if rule_items( "DOC_IT_ALTT", _doc_it_altt, aArtArr ) <> .t.


	@ m_x + nX, m_y + 2 SAY PADL("nadm. visina [m] (*):", nLeft + 3) GET _doc_it_altt PICT "999999" VALID val_altt(_doc_it_altt) WHEN set_opc_box( nBoxX, 50, "Nadmorska visina izrazena u metrima" )

	@ m_x + nX, col() + 2 SAY "grad:" GET _doc_acity VALID !EMPTY(_doc_acity) PICT "@S20" WHEN set_opc_box(nBoxX, 50, "Grad u kojem se montira proizvod")


else
	
	// pobrisi screen na lokaciji nadmorske visine
	@ m_x + nX, m_y + 2 SAY SPACE(70)
	
	// ponisti vrijednosti da ne bi ostale zapamcene u bazi
	_doc_it_altt := 0
	_doc_acity := ""
	
endif

// ako je nova stavka obezbjedi unos operacija...
if l_new_it

	nX += 2

	@ m_x + nX, m_y + 2 SAY PADL("unesi dod.oper.stavke (D/N)? (*):", nLeft + 15) GET cGetDOper PICT "@!" VALID cGetDOper $ "DN" WHEN set_opc_box( nBoxX, 50, "unos dodatnih operacija za stavku")

endif

read

ESC_RETURN 0

return 1








// -----------------------------------
// vraca tip stavke naloga
// -----------------------------------
function _g_doc_it_type( cType )
local cRet := "standard"

if cType == "S"
	cRet := "shape"
elseif cType == "R"
	cRet := "radius"
endif

return cRet 


// ------------------------------------
// setuj matricu sa artiklom
// ------------------------------------
static function _set_arr( nArt_id, aArr )
local nTArea := SELECT()

_art_set_descr( nArt_id, .f., .f., @aArr, .t.)

select (nTArea)

return .t.



// -------------------------------------------
// uvecaj broj stavke naloga
// -------------------------------------------
function inc_docit( nDoc_no )
local nTArea := SELECT()
local nTRec := RECNO()
local nRet := 0

select _doc_it
go top
set order to tag "1"
seek doc_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no
	nRet := field->doc_it_no
	skip
enddo

nRet += 1

select (nTArea)
go (nTRec)

return nRet


// -------------------------------------
// validacija precnika (fi)
// -------------------------------------
static function val_fi( nVal )
local lRet := .f.
if nVal <> 0
	lRet := .t.
endif
val_msg(lRet, "FI mora biti <> 0 !")
return lRet


// -------------------------------------
// validacija kolicine
// -------------------------------------
static function val_qtty( nVal )
local lRet := .f.
if nVal <> 0
	lRet := .t.
endif
val_msg(lRet, "Kolicina mora biti <> 0 !")
return lRet


// -------------------------------------
// validacija nadmorske visine
// -------------------------------------
static function val_altt( nVal )
local lRet := .f.
if nVal <> 0
	lRet := .t.
endif

val_msg(lRet, "Nadmorska visina mora biti <> 0 !")

return lRet


// ----------------------------------
// validacija visine
// ----------------------------------
static function val_width( nVal )
local lRet := .f.
if nVal >= 0 .and. nVal <= max_width()
	lRet := .t.
endif
val_msg(lRet, "!! Dozvoljeni opseg 0 - " + ALLTRIM(STR(max_width())) + " mm" )
return lRet



// ----------------------------------
// validacija sirine
// ----------------------------------
static function val_heigh( nVal )
local lRet := .f.
if nVal >= 0 .and. nVal <= max_heigh()
	lRet := .t.
endif
val_msg(lRet, "!! Dozvoljeni opseg 0 - " + ALLTRIM(STR(max_heigh())) + " mm" )
return lRet



// -------------------------------------
// poruka pri validaciji
// -------------------------------------
static function val_msg(lRet, cMsg)
if lRet == .f.
	MsgBeeP(cMsg)
endif
return 



// -----------------------------------------------
// kopiranje stavki sa drugog naloga
// -----------------------------------------------
function cp_items()
local nDocCopy
local cQ_it
local cQ_aops
local cSeason
local nRet := 1
local nTArea := SELECT()

nRet := _cp_box( @nDocCopy, @cQ_it, @cQ_aops, @cSeason )

// ako necu nista raditi - izlazim
if nRet = 0
	return nRet
endif

select _docs

// imam parametre, idem na kopiranje
__cp_items( _docs->doc_no, nDocCopy, cQ_it, cQ_aops, cSeason )

select (nTArea)

return nRet


// ----------------------------------------------
// box sa uslovim kopiranja
// 
// nDoc - broj dokumenta
// cQ_it - pitanje za kopiranje stavki (d/n)
// cQ_aops - pitanje za kopiranje operac. (d/n)
// ----------------------------------------------
static function _cp_box( nDoc, cQ_It, cQ_Aops, cSeason )
local nRet := 1
local GetList := {}

nDoc := 0
cQ_it := "D"
cQ_Aops := "D"
cSeason := SPACE(4)

Box(, 5, 55 )
	
	@ m_x + 1, m_y + 2 SAY "Nalog iz kojeg kopiramo:" GET nDoc ;
		PICT "9999999999" VALID ( nDoc > 0 )

	@ m_x + 1, col() + 2 SAY "sezona:" GET cSeason ;
	
	@ m_x + 3, m_y + 2 SAY "   Kopirati stavke naloga (D/N)" GET cQ_it ;
		PICT "@!" VALID ( cQ_it $ "DN" )
	
	@ m_x + 4, m_y + 2 SAY "Kopirati operacije naloga (D/N)" GET cQ_Aops ;
		PICT "@!" VALID ( cQ_Aops $ "DN" )

	read
BoxC()


if LastKey() == K_ESC
	nRet := 0
endif

return nRet



// ---------------------------------------------------
// kopiraj stavke naloga 
// 
// nDoc - originalni dokument
// nDocCopy - dokument s kojeg kopiramo
// ---------------------------------------------------
static function __cp_items( nDoc, nDocCopy, cQ_it, cQ_aops, cSeason )
local nTArea := SELECT()
local nDocItCopy 
local nT_Docit := F_DOC_IT
local nT_Docops := F_DOC_OPS
local lSeason := .f.

if cQ_it == "N"
	return
endif

cSeason := ALLTRIM( cSeason )

if !EMPTY( cSeason ) .and. VAL( cSeason ) <> YEAR(DATE())
	
	lSeason := .t.

	// pozicioniraj se na tabele iz sezone
	
	select (nT_docit)
	use
	select (nT_docit)
	use ( KUMPATH + cSeason + SLASH + "DOC_IT.DBF") alias doc_it
	
	select (nT_docops)
	use
	select (nT_docops)
	use ( KUMPATH + cSeason + SLASH + "DOC_OPS.DBF") alias doc_ops

endif

select (nT_docit)
set order to tag "1"
go top
seek docno_str( nDocCopy )

// kada sam pronasao nalog sada idemo na kopiranje stavki ...
select _doc_it
go bottom
// redni broj
nDoc_it_no := field->doc_it_no
	
select (nT_docit)
do while !EOF() .and. field->doc_no = nDocCopy

	nDocItCopy := field->doc_it_no
		
	scatter()
		
	select _doc_it
	append blank

	// zamjeni broj dokumenta i redni broj
	_doc_no := nDoc
	_doc_it_no := ++nDoc_it_no
		
	gather()

	// kopiraj i operacije ove stavke, ako je to uredu
	if cQ_aops == "N"

		select ( nT_docit )
		skip
		loop
	
	endif

	select ( nT_docops )
	go top
	seek docno_str( nDocCopy ) + docit_str( nDocItCopy )

	do while !EOF() .and. field->doc_no = nDocCopy ;
			.and. field->doc_it_no = nDocItCopy
				
		scatter()
		
		select _doc_ops
		append blank
				
		// samo ovo zamjeni sa trenutnim dokumentom
		_doc_no := nDoc
		_doc_it_no := nDoc_it_no

		gather()

		select ( nT_docops )				
		skip

	enddo
		
	select ( nT_docit )
	skip

enddo

if lSeason == .t.
	// vrati se na stare tabele
	select (nT_docit)
	use
	select (nT_docops)
	use
	O_DOC_IT
	O_DOC_OPS
endif

select (nTArea)

return



