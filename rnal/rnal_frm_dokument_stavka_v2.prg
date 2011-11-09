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
static __doc
static __doc_it_no


// --------------------------------------------
// pregled dodatni stavki naloga
// --------------------------------------------
function box_it2( nDoc_no, nDoc_it_no )
local nX := m_x
local nY := m_y
local GetList := {}
local nTArea := SELECT()

private kol
private imekol

docit2_kol(@imekol, @kol)

select _doc_it2

__doc := nDoc_no
__doc_it_no := nDoc_it_no

Box(,17,70)

// opcije
@ m_x + 16, m_y + 2 SAY "<c+N> nova stavka  <F2> ispravka  <c+T> brisi stavku "
@ m_x + 17, m_y + 2 SAY "<c+F9> brisi sve "

ObjDBedit("it2", 15, 70, {|Ch| it2_handler() },"Unos dodatni stavki naloga","",,,,,1)

BoxC()

select (nTArea)

m_x := nX
m_y := nY

return


// -----------------------------------------------------
// key handler
// -----------------------------------------------------
static function it2_handler()
local nRet := DE_CONT

do case 
	case (Ch == K_F2)
	
		if field->doc_it_no <> 0 .and. ;
			e_doc_it2( __doc, __doc_it_no, .f. ) <> 0
			nRet := DE_REFRESH
		endif

	case (Ch == K_CTRL_N)
		
		if e_doc_it2( __doc, __doc_it_no, .t. ) <> 0
			nRet := DE_REFRESH
		endif

	case (Ch == K_CTRL_T)
		
		if Pitanje(, "Izbrisati stavku ?", "N") == "D"
			select _doc_it2
			delete
			nRet := DE_REFRESH
		endif
	
	case (Ch == K_CTRL_F9)
		
		if Pitanje(,"Izbrisati kompletnu tabelu ?", "N") == "D"
			if Pitanje(,"Sigurni 100% ?", "N") == "D"
				select _doc_it2
				zap
				nRet := DE_REFRESH
			endif
		endif

endcase

return nRet


// ---------------------------------------------
// setuje matricu kolona tabele _DOC_IT2
// ---------------------------------------------
static function docit2_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {"Stavka", {|| doc_it_no }, "it_no" })
AADD(aImeKol, {"R.br", {|| it_no }, "it_no" })
AADD(aImeKol, {"Artikal", {|| art_id }, "art_id" })
AADD(aImeKol, {"Kol.", {|| doc_it_qtt }, "doc_it_qtt" })
AADD(aImeKol, {"Kol.2", {|| doc_it_q2 }, "doc_it_q2" })
AADD(aImeKol, {"Cijena", {|| doc_it_pri }, "doc_it_pri" })
AADD(aImeKol, {"Opis", {|| sh_desc }, "sh_desc" })
AADD(aImeKol, {"Napomene", {|| desc }, "desc" })

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ------------------------------------------
// unos ispravka dodatni stavki naloga.... 
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// ------------------------------------------
function e_doc_it2( nDoc_no, nDoc_it_no, lNew )
local nX := m_x
local nY := m_y
local nGetBoxX := 18
local nGetBoxY := 70
local cBoxNaz := "unos nove stavke"
local nRet := 0
local nFuncRet := 0
private GetList:={}

__doc := nDoc_no
__doc_it_no := nDoc_it_no

if lNew == nil
	lNew := .t.
endif

l_new_it := lNew

if l_new_it == .f.
	cBoxNaz := "ispravka stavke"
endif

select _doc_it2

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos stavki naloga")

set_opc_box(nGetBoxX, 50)

// say top, bottom
@ m_x + 1, m_y + 2 SAY PADL("***** " + cBoxNaz , nGetBoxY - 2)
@ m_x + nGetBoxX, m_y + 2 SAY PADL("(*) popuna obavezna", nGetBoxY - 2) COLOR "BG+/B"

Scatter()

do while .t.

	nFuncRet := _e_box_it2( nGetBoxX, nGetBoxY )
	
	if nFuncRet == 1
		
		select _doc_it2
		
		if l_new_it
			append blank
		endif
		
		Gather()
		
		if l_new_it
			loop
		endif
		
	endif
	
	BoxC()
	select _doc_it2
	
	nRet := RECCOUNT2()
	
	exit

enddo

select _doc_it2

m_x := nX
m_y := nY

return nRet


// -------------------------------------------------
// forma za unos podataka 
// cGetDOper , D - unesi dodatne operacije...
// -------------------------------------------------
static function _e_box_it2( nBoxX, nBoxY )
local nX := 1
local nLeft := 21
local cPicQtty := "999999.999"
local cPicPrice := "999999.99"

if l_new_it
	_doc_no := __doc
	_doc_it_no := __doc_it_no
	_it_no := inc_docit2( __doc, __doc_it_no )
endif

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Stavka naloga (*)", nLeft) GET _doc_it_no ;
	VALID {|| if(l_new_it, _it_no := inc_docit2( _doc_no, _doc_it_no ), .t.), .t. }

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("r.br stavke (*)", nLeft) GET _it_no PICT "9999"

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("FMK ARTIKAL (*):", nLeft) GET _art_id VALID {|| p_roba( @_art_id ), _doc_it_pri := g_roba_price( _art_id ), show_it( g_roba_desc( _art_id ) + ".." , 35 ) } WHEN set_opc_box( nBoxX, 50, "uzmi sifru iz FMK sifrarnika" )

nX += 2
	
@ m_x + nX, m_y + 2 SAY PADL("kolicina (*):", nLeft + 3) GET _doc_it_qtt ;
	PICT cPicQtty WHEN set_opc_box( nBoxX, 50 )

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("kolicina 2:", nLeft + 3) GET _doc_it_q2 ;
	PICT cPicQtty WHEN set_opc_box( nBoxX, 50, "dodatna kolicina" )

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("cijena:", nLeft + 3) GET _doc_it_pri ;
	PICT cPicPrice WHEN set_opc_box( nBoxX, 50, "opciono cijena" )

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("opis:", nLeft) GET _sh_desc PICT "@S40" WHEN set_opc_box( nBoxX, 50, "opis vezan za samu stavku")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("napomena:", nLeft) GET _desc PICT "@S40" WHEN set_opc_box( nBoxX, 50, "dodatne napomene vezane za samu stavku")


read

ESC_RETURN 0

return 1


// -------------------------------------------
// uvecaj broj stavke naloga
// -------------------------------------------
static function inc_docit2( nDoc_no, nDoc_it_no )
local nTArea := SELECT()
local nTRec := RECNO()
local nRet := 0

select _doc_it2
go top
set order to tag "1"
seek doc_str( nDoc_no ) + docit_str( nDoc_it_no )

do while !EOF() .and. field->doc_no == nDoc_no .and. ;
	field->doc_it_no == nDoc_it_no
	nRet := field->it_no
	skip
enddo

nRet += 1

select (nTArea)
go (nTRec)

return nRet


// ----------------------------------------------
// vraca opis robe
// ----------------------------------------------
function g_roba_desc( cId )
local cDescr := ""
local nTArea := SELECT()

O_ROBA
select roba
seek cId

if FOUND()
	cDescr := ALLTRIM( roba->naz )
endif

select (nTArea)
return cDescr


// ----------------------------------------------
// vraca cijenu robe
// ----------------------------------------------
function g_roba_price( cId )
local nPrice
local nTArea := SELECT()

O_ROBA
select roba
seek cId

if FOUND()
	nPrice := roba->vpc
endif

select (nTArea)
return nPrice

