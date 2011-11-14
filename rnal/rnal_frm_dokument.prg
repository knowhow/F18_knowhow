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

// novi dokument, bool
static l_new
static _doc
static _doc_it
static __item_no
static __art_id
static l_auto_tab


// ---------------------------------------------
// edit dokument
// lNewDoc - novi dokument .t. or .f.
// ---------------------------------------------
function ed_document( lNewDoc )

if lNewDoc == nil
	lNewDoc := .f.
endif

l_new := lNewDoc

// otvori radne i pripremne tabele...
o_tables(.t.)

// otvori unos dokumenta
_document()

return



// ---------------------------------------------
// otvara unos novog dokumenta
// ---------------------------------------------
static function _document()
local cHeader
local cFooter
local i
local nX
local nY
local nRet := 1
local cCol1 := "W/B"
local cCol2 := "W+/G"
private ImeKol
private Kol

Box(, 22, 77)

l_auto_tab := .f.

select _doc_it
go top
select _doc_ops
go top
select _docs
go top
_doc := _docs->doc_no

// ispisi header i footer
header_footer()

m_y += 50
m_x += 6

do while .t.

	if ALIAS() == "_DOCS"
		
		nX := 6
		nY := 78
		
		m_x -= 6
		m_y -= 50
	
		// prikazi naslov tabele
		_say_tbl_desc( m_x + 1, ;
				m_y + 1, ;
				cCol2, ;
				"*** osnovni podaci", ;
				20 )
		
		docs_kol(@ImeKol, @Kol)
		
	elseif ALIAS() == "_DOC_IT"

		nX := 15
		nY := 49
		
		m_x += 6
		
		_say_tbl_desc( m_x + 1 , ;
				m_y + 1, ;
				cCol2, ;
				"*** stavke naloga" , ;
				20 )
		
		docit_kol(@ImeKol, @Kol)

	elseif ALIAS() == "_DOC_OPS"

		nX := 15
		nY := 28
		m_y += 50
		
		_say_tbl_desc( m_x + 1, ;
				m_y + 1, ;
				cCol2, ;
				"*** dod.oper.", ;
				20 )
	
		docop_kol(@ImeKol, @Kol)
		
	endif
	
	ObjDBedit("docum", nX, nY, {|Ch| key_handler(Ch)},"","",,,,,1)

	if ALIAS() == "_DOCS"
		
		//m_x -= 6
		//m_y -= 50
		
	endif

	if LastKey() == K_ESC
	
		if _docs->doc_status == 3
		
			MsgBeep("Dokument ostavljen za doradu !!!")
		
		endif
		
		exit
	
	endif

enddo

BoxC()

return nRet



// ---------------------------------------
// prikaz osnovni podaci
// nX - x koord.
// nY - y koord.
// cTxt - tekst
// cColSheme - kolor shema...
// nLeft - poravnanje ulijevo nnn
// ---------------------------------------
function _say_tbl_desc(nX, nY, cColSheme, cTxt, nLeft)

if nLeft == nil
	nLeft := 20
endif

if cColSheme == nil
	@ nX, nY SAY PADR( cTxt, nLeft )
else
	@ nX, nY SAY PADR( cTxt, nLeft ) COLOR cColSheme
endif

return


// -----------------------------------------------
// prikazi header i footer 
// -----------------------------------------------
static function header_footer()
local nTArea := SELECT()
local cHeader
local cFooter
local cLineClr := "GR+/B"

cFooter := "<TAB> brow.tab "
cFooter += "<c-N> nova "
cFooter += "<c-T> brisi "
cFooter += "<F2> ispravka "
cFooter += "<c-P> stampa "
cFooter += "<a-A> azur."


cHeader := "dok.broj: "
cHeader += doc_str( _doc )
cHeader += SPACE(5)

if l_new
	cHeader += "UNOS NOVOG DOKUMENTA"
else
	cHeader += "DORADA DOKUMENTA"
endif

cHeader += SPACE(5)
cHeader += "operater: "
cHeader += ALLTRIM( f18_user() )

@ m_x, m_y + 2 SAY cHeader
@ m_x + 6, m_y + 1 SAY REPLICATE("Í", 78) COLOR cLineClr
@ m_x + 21, m_y + 1 SAY REPLICATE("Í", 78) COLOR cLineClr
@ m_x + 22, m_y + 1 SAY cFooter

for i:=7 to 20
	@ m_x + i, m_y + 50 SAY "º" COLOR cLineClr
next

select (nTArea)

return



// ---------------------------------------------
// setuje matricu kolona tabele _DOCS
// ---------------------------------------------
static function docs_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {PADC("Narucioc", 20), {|| PADR(g_cust_desc( cust_id ), 18) + ".."}, "cust_id" })
AADD(aImeKol, {PADC("Datum", 8), {|| doc_date}, "doc_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADC("Dat.isp", 8), {|| doc_dvr_da}, "doc_dvr_da" })
AADD(aImeKol, {"Vr.isp", {|| PADR(doc_dvr_ti, 5)}, "doc_dvr_ti"  })
AADD(aImeKol, {"Mj.isp", {|| PADR(doc_ship_p,10)}, "doc_ship_p" })
AADD(aImeKol, {"Kontakt", {|| PADR(g_cont_desc( cont_id ), 8) + ".." }, "cont_id" })
AADD(aImeKol, {"Kont.opis", {|| PADR(cont_add_d, 18) + ".."}, "cont_add_d" })
AADD(aImeKol, {"Vrsta p.", {|| doc_pay_id}, "doc_pay_id" })
AADD(aImeKol, {"Prioritet", {|| doc_priori}, "doc_priori" })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// ---------------------------------------------
// setuje matricu kolona tabele _DOC_IT
// ---------------------------------------------
static function docit_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {"R.br", {|| doc_it_no }, "doc_it_no" })
AADD(aImeKol, {"Artikal", {|| PADR(g_art_desc( art_id, nil, .f. ), 18) + ".." }, "art_id" })
AADD(aImeKol, {"sirina", {|| TRANSFORM(doc_it_width, PIC_DIM()) }, "doc_it_width" })
AADD(aImeKol, {"visina", {|| TRANSFORM(doc_it_heigh, PIC_DIM()) }, "doc_it_heigh" })
AADD(aImeKol, {"kol.", {|| TRANSFORM(doc_it_qtty, PIC_QTTY()) }, "doc_it_qtty" })


for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// setuje matricu kolona tabele _DOC_OP
// ---------------------------------------------
static function docop_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {"dod.oper", {|| PADR(g_aop_desc( aop_id ),10) }, "aop_id"})
AADD(aImeKol, {"atr.dod.oper", {|| PADR( g_aop_att_desc( aop_att_id ), 10 ) }, "aop_att_id" })
AADD(aImeKol, {"dod.opis", {|| PADR(doc_op_desc, 15) + ".."}, "doc_op_desc" })

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// ---------------------------------------------
// obrada dogadjaja na tipke tastature
// ---------------------------------------------
static function key_handler()
local nRet := DE_CONT
local nX := m_x
local nY := m_y
local GetList := {}
local nRec := RecNo()
local nDocNoNew := 0
local cDesc := ""
local nArea

do case 

	// automatski tab
	case l_auto_tab == .t.
			
		KEYBOARD CHR(K_TAB)
		l_auto_tab := .f.
		return DE_REFRESH
			
	// browse tabele
	case Ch == K_TAB

		if ALIAS() == "_DOCS"
		
			_say_tbl_desc( m_x + 1, m_y + 1, ;
					nil, "*** osnovni podaci", 20 )
			
			select _doc_it
			nRet := DE_ABORT
			
		elseif ALIAS() == "_DOC_IT"
			
			_say_tbl_desc( m_x + 1, m_y + 1, ;
					nil, "*** stavke naloga", 20 )
			
			__art_id := field->art_id
			__item_no := field->doc_it_no
			
			select _doc_ops
			nRet := DE_ABORT

		elseif ALIAS() == "_DOC_OPS"

			_say_tbl_desc( m_x + 1, m_y + 1, ;
					nil, "*** dod.oper.", 20 )
			
			select _docs
			nRet := DE_ABORT
			
		endif

	// nove stavke
	case Ch == K_CTRL_N
	
		nRet := DE_CONT

		if ALIAS() == "_DOCS"
		
			if e_doc_main_data( .t. ) == 1
			
				select _docs
				nRet := DE_REFRESH
				l_auto_tab := .t.

			endif
			
			select _docs
			
		elseif ALIAS() == "_DOC_IT"

			select _docs
			if RECCOUNT2() == 0
				MsgBeep("Nema definisanog naloga !!!")
				select _doc_it
				return DE_CONT
			endif
		
			_doc := field->doc_no
			
			select _doc_it
			set order to tag "1"
			
			if e_doc_item( _doc, .t. ) <> 0
			
				select _doc_it
				set order to tag "1"
				nRet := DE_REFRESH

			endif
			
			select _doc_it
			set order to tag "1"
	
		elseif ALIAS() == "_DOC_OPS"

			select _docs
			if RECCOUNT2() == 0
				MsgBeep("Nema definisanog naloga !!!")
				select _doc_ops
				return DE_CONT
			endif
			
			select _doc_ops
			
			if e_doc_ops( _doc, .t., __art_id ) <> 0
			
				select _doc_ops
				nRet := DE_REFRESH

			endif
			
			select _doc_ops
			
		endif
				
	case Ch == K_F2 .or. Ch == K_ENTER
	
		nRet := DE_CONT
		
		if RECCOUNT2() == 0
			return nRet
		endif
		
		if ALIAS() == "_DOCS"
		
			if _docs->doc_status == 3
			
				MsgBeep("Ispravka osnovnih podataka onemogucena kod dorade#Opcija promjena sluzi u tu svrhu !!!")
				return DE_CONT
				
			endif
			
			if e_doc_main_data( .f. ) == 1
			
				select _docs
				nRet := DE_REFRESH

			endif

			select _docs
		
		elseif ALIAS() == "_DOC_IT"

			if e_doc_item( _doc, .f. ) <> 0
			
				select _doc_it
				nRet := DE_REFRESH

			endif

			select _doc_it
	
		elseif ALIAS() == "_DOC_OPS"

			if e_doc_ops( _doc, .f., __art_id ) <> 0
			
				select _doc_ops
				nRet := DE_REFRESH

			endif

			select _doc_ops
	
		endif
	
	case Ch == K_CTRL_T

		nRet := DE_CONT
		
		if ALIAS() == "_DOCS"
		
			if docs_delete() == 1
				
				l_auto_tab := .t.
				KEYBOARD CHR(K_TAB)
				nRet := DE_REFRESH
				
			endif
			
		elseif ALIAS() == "_DOC_IT"

			if docit_delete() == 1
				
				nRet := DE_REFRESH
				
			endif

		elseif ALIAS() == "_DOC_OPS"

			if docop_delete() == 1
			
				nRet := DE_REFRESH
			
			endif
			
		endif

	case UPPER(CHR(Ch)) == "E"
		
		// export dokumenta
		m_export( _docs->doc_no, nil, .t., .t. )
		
		return DE_CONT

	case Ch == K_ALT_C

		nRet := DE_CONT

		if ALIAS() == "_DOC_IT"
			// kopiranje stavki naloga
			if cp_items() <> 0
				nRet := DE_REFRESH
			endif
		else
			msgbeep("Za ovu operaciju pozicionirajte se na#unos stavki naloga !!!")
		endif

		select _doc_it

		m_x := nX
		m_y := nY

		return nRet

	case Ch == K_ALT_A
		
		nRet := DE_CONT

		if ALIAS() == "_DOCS" .and. RECCOUNT2() <> 0 .and. ;
			Pitanje(,"Izvrsiti azuriranje dokumenta (D/N) ?", "D") == "D"
			
			// ima li stavki u nalogu
			if _doc_integ() == 0
				msgbeep("!!! Azuriranje naloga onemoguceno !!!")
				return DE_CONT
			endif
			
			// busy....
			if field->doc_status == 3
				_g_doc_desc( @cDesc )
			endif
			
			// uzmi novi broj dokumenta
			nDocNoNew := _new_doc_no()

			// ako je baza zauzeta...
			if nDocNoNew == -1
				return DE_CONT
			endif

			// filuj sve tabele sa novim brojem
			fill__doc_no( nDocNoNew )
			
			// insertuj nalog u kumulativ
			if doc_insert( cDesc ) == 1
				
				select _docs
				l_auto_tab := .t.
				KEYBOARD CHR(K_TAB)
				nRet := DE_REFRESH
						
			endif
		
		elseif ALIAS() <> "_DOCS"
			Msgbeep("Pozicionirajte se na tabelu osnovnih podataka")
		
		endif
		
		return nRet

	case Ch == K_CTRL_P

		// stampa naloga
		nTArea := SELECT()
		select _docs
		
		// ima li stavki u nalogu
		if _doc_integ( .t. ) == 0
			return DE_CONT
		endif
			
		select _docs
		
		// uzmi novi broj dokumenta
		nDocNoNew := _new_doc_no()

		// ako je baza zauzeta
		if nDocNoNew == -1
			return DE_CONT
		endif

		// filuj sve tabele sa novim brojem
		fill__doc_no( nDocNoNew )
		
		select _docs
		go top
		
		st_nalpr( .t. , _docs->doc_no )
		
		select (nTArea)
		go top

		nRet := DE_CONT

	case Ch == K_CTRL_O

		// obracunski list......
		nTArea := SELECT()
		select _docs
		
		// ima li stavki u nalogu
		if _doc_integ( .t. ) == 0
			return DE_CONT
		endif
			
		select _docs
		
		// uzmi novi broj dokumenta
		nDocNoNew := _new_doc_no()

		// ako je baza zauzeta
		if nDocNoNew == -1
			return DE_CONT
		endif

		// filuj sve tabele sa novim brojem
		fill__doc_no( nDocNoNew )
		
		select _docs
		go top
		
		st_obr_list( .t. , _docs->doc_no )
		
		select (nTArea)
		go top

		nRet := DE_CONT

	case Ch == K_CTRL_R
		
		if ALIAS() == "_DOC_IT" .and. RECCOUNT2() <> 0 
			box_it2( field->doc_no, field->doc_it_no )
		endif

		nRet := DE_CONT
	
	case Ch == K_CTRL_L
		
		st_label( .t., _docs->doc_no )
		
		nRet := DE_CONT
endcase

m_x := nX
m_y := nY

return nRet

// ----------------------------------------
// vraca box sa opisom
// ----------------------------------------
function _g_doc_desc( cDesc )
local GetList := {}

Box(,5, 70)
	cDesc := SPACE(150)
	@ m_x + 1, m_y + 2 SAY "Unesi opis promjene na nalogu:"
	@ m_x + 3, m_y + 2 SAY "Opis:" GET cDesc VALID !EMPTY(cDesc) PICT "@S60"
	read
BoxC()

ESC_RETURN 0

return 1


// -------------------------------------------
// docs - integritet
// -------------------------------------------
static function _doc_integ( lPrint )
local nTAREA := SELECT()
local nRet := 1
local cTmp := ""
local nItems := 0
local nCustId := 0
local nContId := 0

if lPrint == nil
	lPrint := .f.
endif

select _docs

nCustId := field->cust_id
nContId := field->cont_id

select _doc_it
nItems := RECCOUNT2()

// vrati se gdje si bio...
select (nTAREA)

if lPrint == .f. .and. ( nItems == 0 .or. nCustId == 0 .or. nContId == 0 )
	nRet := 0
elseif lPrint == .t. .and. ( nItems == 0 )
	nRet := 0
endif

if nItems == 0
	MsgBeep("Nalog mora da sadrzi najmanje 1 stavku !!!")
endif

if lPrint == .f.
	if nCustId == 0
		MsgBeep("Polje narucioca mora biti popunjeno !!!")
	endif
	if nContId == 0
		MsgBeep("Polje kontakta mora biti popunjeno !!!")
	endif
endif

return nRet



// --------------------------------------------
// opcija brisanja dokumenta
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docs_delete( lSilent )
local nDoc_no
local nDoc_status 

if lSilent == nil
	lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati nalog iz pripreme (D/N) ?!???", "N") == "N"
	return 0
endif

nDoc_no := field->doc_no
nDoc_status := field->doc_status

// brisi dokument
delete

select _doc_it
go top
do while !EOF()
	delete
	skip
enddo

select _doc_ops
go top
do while !EOF()
	delete
	skip
enddo

if nDoc_status == 3

	// ukloni marker sa azuriranog dokumenta (busy)

	set_doc_marker( nDoc_no, 0 )

elseif nDoc_status == 0
	
	// treba ga brisati i iz azuriranih naloga
	// jer je zauzeo vec broj

	select docs
	go top
	seek docno_str( nDoc_no )
	if FOUND() .and. field->doc_no == nDoc_no
		delete
	endif

endif

select _docs
go top

return 1


// --------------------------------------------
// opcija brisanja stavke naloga
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docit_delete( lSilent )
local nDoc_it_no

if lSilent == nil
	lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati stavku (D/N)?", "D") == "N"
	return 0
endif

nDoc_it_no := field->doc_it_no

delete

select _doc_ops
set order to tag "1"
go top
seek doc_str( _doc ) + docit_str( nDoc_it_no )

do while !EOF() .and. field->doc_no == _doc ;
		.and. field->doc_it_no == nDoc_it_no

	delete
	skip
enddo

select _doc_it

return 1


// --------------------------------------------
// opcija brisanja operacije
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docop_delete( lSilent )
if lSilent == nil
	lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati stavku (D/N)?", "D") == "N"
	return 0
endif

delete

return 1


// ------------------------------------------------
// validacija vrijednosti, mora se unjeti
// ------------------------------------------------
function must_enter( xVal )
local lRet := .t.

if VALTYPE(xVal) == "C"
	if EMPTY(xVal)
		lRet := .f.
	endif
elseif VALTYPE(xVal) == "N"
	if xVal == 0
		lRet := .f.
	endif
elseif VALTYPE(xVal) == "D"
	if CTOD("") == xVal
		lRet := .f.
	endif
endif

msg_must_enter( lRet )

return lRet

// -----------------------------------------
// poruka za must_enter validaciju
// -----------------------------------------
static function msg_must_enter( lVal )
if lVal == .f.
	MsgBeep("Unos polja obavezan !!!")
endif
return


