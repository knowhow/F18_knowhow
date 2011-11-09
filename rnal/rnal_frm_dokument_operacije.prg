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

static l_new_ops
static _doc
static __item_no
static __art_id
static __art_type
static _form_article
static _a_elem
static _a_arr

// ------------------------------------------
// unos ispravka operacija naloga
// nDoc_no - dokument broj
// lNew - nova stavka .t. or .f.
// nItem_no - stavka broj
// nArt_id - artikal id
// ------------------------------------------
function e_doc_ops( nDoc_no, lNew, nArt_id, nItem_no )
local nX := m_x
local nY := m_y
local nGetBoxX := 16
local nGetBoxY := 70
local cBoxNaz := "unos dodatnih operacija stavke"
local nRet := 0
local nFuncRet := 0
private GetList:={}

if nItem_no == nil
	nItem_no := 0
endif

_doc := nDoc_no
__item_no := nItem_no
__art_id := nArt_id
_from_article := .f.

if nItem_no > 0
	_from_article := .t.
endif

_a_arr := {}

// napuni matricu sa artiklom
_art_set_descr( __art_id, nil, nil, @_a_arr, .t. )

// napuni matricu sa elementima artikla
_g_art_elements( @_a_elem, __art_id )

__art_type := LEN(_a_elem)

if lNew == nil
	lNew := .t.
endif

l_new_ops := lNew

if l_new_ops == .f.
	cBoxNaz := "ispravka dodatne operacije stavke"
endif

select _doc_ops

UsTipke()

Box(, nGetBoxX, nGetBoxY, .f., "Unos dodatnih operacija naloga")

set_opc_box( nGetBoxX, 50 )

@ m_x + 1, m_y + 2 SAY PADL("***** " + cBoxNaz, nGetBoxY - 2)
@ m_x + nGetBoxX, m_y + 2 SAY PADL("(*) popuna obavezna", nGetBoxY - 2) COLOR "BG+/B"

Scatter()

do while .t.

	nFuncRet := _e_box_item( nGetBoxX, nGetBoxY )
	
	if nFuncRet == 1
		
		select _doc_ops
		
		if l_new_ops
			append blank
		endif
		
		Gather()
		
		if l_new_ops
			loop
		endif
		
	endif
	
	BoxC()
	select _doc_ops
	
	nRet := RECCOUNT2()
	
	exit

enddo

select _docs

m_x := nX
m_y := nY

return nRet



// -------------------------------------------------------
// kopiranje operacija sa prethodne stavke
// -------------------------------------------------------
function _cp_oper( nDoc_no, nArt_id, nDoc_it_no )
local nTArea := SELECT()
local nTRec := RECNO()
local nRec 
local nSrchItem := nDoc_it_no - 1
local nCnt := 0

select _doc_ops
set order to tag "1"
go top
seek docno_str( nDoc_no ) + docit_str( nSrchItem )

do while !EOF() .and. field->doc_no == nDoc_no ;
		.and. field->doc_it_no == nSrchItem

	skip 1
	
	nRec := RECNO()
	
	skip -1
	
	Scatter()
	
	append blank
	
	_doc_it_no := nDoc_it_no
	
	Gather()
	
	++ nCnt
	
	go (nRec)

enddo

select (nTArea)
go (nTRec)

if nCnt > 0
	msgbeep("Kopirano: " + ALLTRIM(STR(nCnt)) + " operacija !")
endif

return




// -------------------------------------------------
// forma za unos podataka 
// -------------------------------------------------
static function _e_box_item( nBoxX, nBoxY )
local nX := 1
local nLeft := 27
local cAop := ""
local cAopAtt := ""
local nH
local nW
local nElement := 0
local nTick := 0

if l_new_ops

	_doc_no := _doc
	_doc_op_no := inc_docop( _doc )
	_doc_it_el_no := 0
	_aop_id := 0
	_aop_att_id := 0
	_doc_op_desc := PADR("", LEN(_doc_op_desc))
	_doc_it_no := __item_no
	_aop_value := PADR("", LEN( _aop_value ))
	
	cAop := PADR("", 10)
	cAopAtt := PADR("", 10)

else
	
	cAop := PADL( STR(_aop_id, 10), 10 )
	cAopAtt := PADL( STR(_aop_att_id, 10), 10 )
	
endif


nX += 2

@ m_x + nX, m_y + 2 SAY PADL("r.br operacije (*):", nLeft) GET _doc_op_no WHEN {|| set_opc_box( nBoxX, 50 ), _doc_op_no == 0 }

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("odnosi se na stavku (*):", nLeft) GET _doc_it_no VALID {|| _item_range( _doc_it_no ) .and. show_it( g_item_desc( _doc_it_no ), 26 )} WHEN {|| set_opc_box( nBoxX, 50, "ova operacija ce se odnositi", "eksplicitno na unesenu stavku"), _from_article == .f. }
	
nX += 1
	
@ m_x + nX, m_y + 2 SAY PADL(" -> element stavke (*):", nLeft) GET _doc_it_el_no VALID {|| get_it_element( @_doc_it_el_no, @nElement ), show_it( get_elem_desc( _a_elem, _doc_it_el_no ), 26 ) } WHEN {|| _g_art_elements( @_a_elem, _g_art_it_no( _doc_it_no) ), set_opc_box( nBoxX, 50, "odnosi se na odredjeni element stavke", "") }

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("dodatna operacija (*):", nLeft) GET cAop VALID {|| s_aops( @cAop, cAop ), set_var(@_aop_id, @cAop) , show_it( g_aop_desc( _aop_id ), 20), rule_aop(g_aop_joker(_aop_id), _a_arr ) } WHEN set_opc_box( nBoxX, 50, "odaberi dodatnu operaciju", "0 - otvori sifrarnik")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("atribut dod. operacije:", nLeft) GET cAopAtt VALID {|| s_aops_att(@cAopAtt, _aop_id, cAopAtt ), set_var(@_aop_att_id, @cAopAtt), show_it(g_aop_att_desc( _aop_att_id ), 20), rule_aop( g_aatt_joker(_aop_att_id), _a_arr ) } WHEN set_opc_box( nBoxX, 50, "odaberi atribut dodatne operacije", "99 - otvori sifrarnik")

nX += 1

@ m_x + nX, m_y + 2 SAY PADL( "vrijednost:", nLeft ) GET _aop_value ;
	VALID {|| _g_dim_it_no(_doc_it_no, nElement, @nH, @nW, @nTick) .and. is_g_config( @_aop_value, _aop_att_id, nH, nW, nTick )} ;
	PICT "@S40" ;
	WHEN set_opc_box( nBoxX, 50, "vrijednost operacije ako postoji", "kod brusenja, poliranja..." )

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("dodatni opis:", nLeft) GET _doc_op_desc PICT "@S40" WHEN set_opc_box( nBoxX, 50, "dodatni opis vezan uz navedene", "operacije" )


read

ESC_RETURN 0

return 1


// --------------------------------------------
// vraca opis iz matrice - opis elementa
// --------------------------------------------
function get_elem_desc( aElem, nVal, nLen )
local xRet := ""
local nChoice

if nLen == nil
	nLen := 17
endif

nChoice := ASCAN( aElem, {|xVal| xVal[1] == nVal } )

if nChoice > 0
	xRet := aElem[ nChoice, 2 ]
endif

xRet := PADR(xRet, nLen)

return xRet


// --------------------------------------------------
// vraca arr sa elementima artikla...
// --------------------------------------------------
function get_it_element( nDoc_it_e_id, nElement )
local nXX := m_x
local nYY := m_y

if nDoc_it_e_id > 0
	nElement := _get_a_element( _a_elem, nDoc_it_e_id )
	return .t.
endif

// odaberi element
nDoc_it_e_id := _pick_element( _a_elem, @nElement )

m_x := nXX
m_y := nYY

return .t.


// ------------------------------------------------
// vraca element iz matrice
// ------------------------------------------------
static function _get_a_element( aElem, nEl_no )
local nTmp 

nTmp := ASCAN( aElem, { |xVal| xVal[1] = nEl_no })

if nTmp <> 0
	nElement := aElem[ nTmp, 3 ]
endif

return nElement



// -----------------------------------------
// uzmi element...
// -----------------------------------------
static function _pick_element( aElem, nChoice )
local nRet
local i
local cPom
private GetList:={}
private izbor := 1
private opc := {}
private opcexe := {}

nChoice := 1

for i:=1 to LEN(aElem)

	cPom := PADL( ALLTRIM(STR(i)) + ")", 3 ) + " " + PADR( aElem[i, 2] , 40 )
	
	AADD(opc, cPom)
	AADD(opcexe, {|| nChoice := izbor, izbor := 0 })
	
next

Menu_sc("izbor")

if LastKey() == K_ESC

	nChoice := 0
	nRet := 0
	
else
	nRet := aElem[ nChoice, 1 ]
endif

return nRet

// ---------------------------------------------
// da li je stavka u rangu stavki tabele
// ---------------------------------------------
static function _item_range( nItemNo )
local lRet := .t.
local nTArea := SELECT()
local nDocItRec 

select _doc_it

nDocItRec := _doc_it->(RECCOUNT2())

if nItemNo > nDocItRec .or. nItemNo <= 0
	lRet := .f.
endif

select (nTArea)

if lRet == .f.
	MsgBeep("Nepostojeca stavka naloga !!!##Nalog sadrzi " + ;
		ALLTRIM(STR(nDocItRec)) + " stavki.")
endif

return lRet


// --------------------------------------------
// vrati opis odnosi se na stavku
// --------------------------------------------
static function g_item_desc( doc_it_no )
local xRet := ""
xRet := "na " + ALLTRIM(STR(doc_it_no)) + " stavku naloga"
return xRet


// ----------------------------------------------------
// vraca dimenzije stavke 
// ----------------------------------------------------
static function _g_dim_it_no( nDoc_it_no, nElement, nH, nW, nTick )
local nArt_id := 0
local nTArea := SELECT()
local nTRec := RECNO()
local aArr := {}

nH := 0
nW := 0
nTick := 0

select _doc_it
set order to tag "1"
seek docno_str( _doc) + docit_str( nDoc_it_no )

if FOUND()
	
	nH := field->doc_it_height
	nW := field->doc_it_width

	// uzmi debljinu...

	nTick := g_gl_tickness( _a_arr, nElement )

endif

select (nTArea)
go (nTRec)

return .t.



// ---------------------------------------------
// vraca artikal za stavku
// ---------------------------------------------
static function _g_art_it_no( nDoc_it_no )
local nArt_id := 0
local nTArea := SELECT()
local nTRec := RECNO()

select _doc_it
set order to tag "1"
seek docno_str( _doc) + docit_str( nDoc_it_no )

if FOUND()
	nArt_id  := field->art_id
endif

select (nTArea)
go (nTRec)

return nArt_id



// -------------------------------------------
// uvecaj broj stavke naloga
// -------------------------------------------
function inc_docop( nDoc_no )
local nTArea := SELECT()
local nTRec := RECNO()
local nRet := 0

select _doc_ops
go top
set order to tag "1"
seek docno_str( nDoc_no )

do while !EOF() .and. field->doc_no == nDoc_no
	nRet := field->doc_op_no
	skip
enddo

nRet += 1

select (nTArea)
go (nTRec)

return nRet





