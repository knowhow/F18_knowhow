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


// -----------------------------------------
// box za upit sumiranja
// -----------------------------------------
static function _g_sumbox( lReturn )

lReturn := Pitanje(,"Sumirati stavke sa naloga (D/N)","D") = "D"

return

// ------------------------------------------
// sta generisati, uslovi generacije
// ------------------------------------------
static function _vp_mp( cVpMp )
local nX := 1
local nRet := 1
private GetList := {}

Box(, 3, 65 )

	@ m_x + nX, m_y + 2 SAY "Generisati:"
	++ nX
	@ m_x + nX, m_y + 2 SAY " [V] opremnicu vp (dok 12)"
	++ nX
	@ m_x + nX, m_y + 2 SAY " [M] otprenicu mp (dok 13)" GET cVpMp ;
		VALID cVpMp $ "VM" PICT "@!" 
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet



// --------------------------------------------------------
// export u FMK v.2
//
// lTemp - .t. - stampa iz pripreme, .f. - kumulativ
// nDoc_no - broj dokumenta
// aDocList - matrica sa listom naloga za obradu
//            ako je zadata, radit ce na osnovu
//            vise naloga
// lNoGen - nemoj generisati ponovo stavke, vec postoje
// --------------------------------------------------------
function exp_2_fmk( lTemp, nDoc_no, aDocList, lNoGen )
local nTArea := SELECT()
local nADocs := F_DOCS
local nADOC_IT := F_T_DOCIT
local nADOC_IT2 := F_T_DOCIT2
local nADOC_OP := F_T_DOCOP
local cFmkDoc
local nCust_id
local i
local lSumirati
local cVpMp := "V"

if lNoGen == nil
	lNoGen := .f.
endif

if lNoGen == .f.
	// napuni podatke za prenos
	st_pripr( lTemp, nDoc_no, aDocList )
endif

// generisati sta ?
if _vp_mp( @cVpMp ) == 0
	select (nTarea)
	return
endif

if Pitanje(,"Promjeniti podatke isporuke ?", "N") == "D"
	// selektuj stavke
	sel_items()
endif

// sumirati stavke da ili ne
_g_sumbox( @lSumirati )

if !FILE(ALLTRIM(gFaPrivDir) + "PRIPR.DBF")
	msgbeep("Nije podesena lokacija FAKT ???")
	select (nTarea)
	return
endif

// select pripreme fakt
select (245)
use ( ALLTRIM(gFaPrivDir) + "PRIPR" ) alias X_TBL

// provjeri da li je priprema FAKT prazna
if RECCOUNT2() > 0
	msgbeep("priprema fakt nije prazna !")
	select (245)
	use
	select (nTArea)
	return
endif

if lTemp == .t.
	nADocs := F__DOCS
endif

t_rpt_open()

// --------------------------------------------
// 1 korak :
// uzmi podatke partnera, dokumenta iz T_PARS
// --------------------------------------------

nCust_id := VAL( g_t_pars_opis( "P01" ) )
nCont_id := VAL( g_t_pars_opis( "P10" ) )

cCust_desc := g_cust_desc( nCust_id )
cCont_desc := g_cont_desc( nCont_id )

dDatDok := CTOD( g_t_pars_opis( "N02" ) )

if ALLTRIM( cCust_desc ) == "NN"
	// ako je NN kupac u RNAL, dodaj ovo kao contacts....
	cPartn := PADR( g_rel_val("1", "CONTACTS", "PARTN", ALLTRIM(STR(nCont_id)) ), 6 )
else
	// dodaj kao customs
	cPartn := PADR( g_rel_val("1", "CUSTOMS", "PARTN", ALLTRIM(STR(nCust_id)) ), 6 )
endif

// ako je partner prazno
if EMPTY( cPartn )

	if ALLTRIM( cCust_desc ) == "NN"
		
		// ako je NN kupac, presvicaj se na CONTACTS
		
		// probaj naci partnera iz PARTN
		if fnd_partn( @cPartn, nCont_id, cCont_desc ) == 1 
		
			add_to_relation( "CONTACTS", "PARTN", ;
				ALLTRIM(STR(nCont_id)) , cPartn )
			
		else
		
			select (245)
			use
			
			select (nTArea)
			msgbeep("Operacija prekinuta !!!")
			return
		
		endif

	else
		// probaj naci partnera iz PARTN
		if fnd_partn( @cPartn, nCust_id, cCust_desc ) == 1 
		
			add_to_relation( "CUSTOMS", "PARTN", ;
				ALLTRIM(STR(nCust_id)) , cPartn )
			
		else
		
			select (245)
			use
			
			select (nTArea)
			msgbeep("Operacija prekinuta !!!")
			return
		
		endif
	endif
endif


// ----------------------------------------------
// 2. korak 
// prebaci robu iz doc_it2
// ----------------------------------------------

cFirma := "10"

cIdVd := "12"
cCtrlNo := "22"

// ako je MP onda je drugi set
if cVpMp == "M"
	cIdVd := "13"
	cCtrlNo := "23"
endif

cBrDok := fa_new_doc( cFirma, cCtrlNo )
cFmkDoc := cIdVd + "-" + ALLTRIM(cBrdok)
nRbr := 0

select (nADOC_IT2)
set order to tag "2"
go top

do while !EOF()
		
	nDoc_no := field->doc_no
	cArt_id := field->art_id
	nQtty := field->doc_it_qtt
	cDesc := field->desc

	if lSumirati == .t.
		
		nQtty := 0

		do while !EOF() .and. field->art_id == cArt_id
			
			nQtty += field->doc_it_qtt

			skip
		enddo
	endif

	nPrice := field->doc_it_pri

	if EMPTY( cArt_id )
		skip
		loop
	endif

	if nQtty = 0
		skip
		loop
	endif

	select X_TBL
	
	go bottom
	skip -1

	if !EMPTY( x_tbl->rbr )
		nRbr := VAL( x_tbl->rbr )
	endif
	
	append blank
	
	scatter()

	_txt := ""
	_rbr := STR( ++nRbr, 3 )
	_idpartner := cPartn
	_idfirma := "10"
	_brdok := cBrDok
	_idtipdok := cIdVd
	_datdok := dDatDok
	_idroba := cArt_id
	_cijena := nPrice
	_kolicina := nQtty
	_dindem := "KM "
	_zaokr := 2


	if x_tbl->(FIELDPOS("OPIS")) <> 0
		_opis := cDesc
	endif


	gather()

	// sada ubaci vezu
	go top
	
	cTmp_veza := ""

	if x_tbl->(FIELDPOS("DOK_VEZA")) <> 0
		
		// veza, broj naloga

		cTmp_veza := _fmk_doc_upd( field->dok_veza, ;
			ALLTRIM(STR( nDoc_No )) )
		replace field->dok_veza with cTmp_veza
	endif

	scatter()

	_txt := ""

	// roba tip U - nista
	a_to_txt( "", .t. )
	// dodatni tekst otpremnice - nista
	a_to_txt( "", .t. )
	// naziv partnera
	a_to_txt( _g_pfmk_desc( cPartn ) , .t. )
	// adresa
	a_to_txt( _g_pfmk_addr( cPartn ) , .t. )
	// ptt i mjesto
	a_to_txt( _g_pfmk_place( cPartn ) , .t. )
	// broj otpremnice
	a_to_txt( "" , .t. )
	// datum  otpremnice
	a_to_txt( DTOC( dDatDok ) , .t. )
	
	// broj ugovora - nista
	a_to_txt( "", .t. )
	
	// datum isporuke - nista
	a_to_txt( "", .t. )
	
	// 10. datum valute - nista
	a_to_txt( "", .t. )
	
	// 11. 
	a_to_txt( "", .t. )
	// 12. 
	a_to_txt( "", .t. )
	// 13. 
	a_to_txt( "", .t. )
	// 14. 
	a_to_txt( "", .t. )
	// 15. 
	a_to_txt( "", .t. )
	// 16. 
	a_to_txt( "", .t. )
	// 17. 
	a_to_txt( "", .t. )
	// 18. 
	a_to_txt( "", .t. )
	// 19. 
	a_to_txt( cTmp_veza, .t. )

	gather()

	select (nADOC_IT2)

	if lSumirati == .f.
		skip
	endif

enddo

// -----------------------------------------------
// 3. korak :
// prebaci sve iz T_DOCIT
// -----------------------------------------------

select (nADOC_IT)
set order to tag "5"
// index: art_sh_desc
go top

nRbr := 0

do while !EOF() 

	// da li je markirano za prenos
	if field->print == "N"
		skip
		loop
	endif

	nDoc_no := field->doc_no

	nArt_id := field->art_id
	
	// ukupna kvadratura
	nM2 := field->doc_it_total

	// opis artikla (kratki)
	cArt_sh := field->art_sh_desc
	
	cIdRoba := g_rel_val("1", "ARTICLES", "ROBA", ALLTRIM(STR(nArt_id)) )
	
	// uzmi cijenu robe iz sifrarnika robe
	nPrice := g_art_price( cIdRoba )

	// uzmi opis artikla
	cArt_desc := g_art_desc( nArt_id )

	if EMPTY(cIdRoba)
		
		if fnd_roba( @cIdRoba, nArt_id, cArt_desc ) == 1
		
			add_to_relation( "ARTICLES", "ROBA", ;
				ALLTRIM(STR(nArt_id)), cIdRoba )
		
		
		else
			msgbeep("Neki artikli nemaju definisani u tabeli relacija#Prekidam operaciju !")	
			select (245)
			use
			
			select (nTArea)
			return
		endif
	endif

	select (nADOC_IT)
	
	if lSumirati == .t.

		nM2 := 0

		// sracunaj za iste artikle
		do while !EOF() .and. field->art_sh_desc == cArt_sh

			if field->print == "D"
				// kolicina
				nM2 += field->doc_it_total
			endif

			skip

		enddo
	
	endif	
	
	select X_TBL
	
	go bottom
	skip -1

	if !EMPTY( x_tbl->rbr )
		nRbr := VAL( x_tbl->rbr )
	endif
	
	append blank
	
	scatter()

	_txt := ""
	_rbr := STR( ++nRbr, 3 )
	_idpartner := cPartn
	_idfirma := "10"
	_brdok := cBrDok
	_idtipdok := cIdVd
	_datdok := dDatDok
	_idroba := cIdRoba
	_cijena := nPrice
	_kolicina := nM2
	_dindem := "KM "
	_zaokr := 2
	
	if x_tbl->(FIELDPOS("OPIS")) <> 0
		_opis := cArt_sh
	endif


	gather()

	// sada ubaci broj veze, na prvi slog
	go top
	
	cTmp_veza := ""

	if x_tbl->(FIELDPOS("DOK_VEZA")) <> 0
		// veza, broj naloga
		cTmp_veza := _fmk_doc_upd( field->dok_veza, ;
			  ALLTRIM(STR( nDoc_No )) )

		replace field->dok_veza with cTmp_veza
	endif
	
	// dodaj i memo polje
	scatter()
	
	_txt := ""

	// roba tip U - nista
	a_to_txt( "", .t. )
	// dodatni tekst otpremnice - nista
	a_to_txt( "", .t. )
	// naziv partnera
	a_to_txt( _g_pfmk_desc( cPartn ) , .t. )
	// adresa
	a_to_txt( _g_pfmk_addr( cPartn ) , .t. )
	// ptt i mjesto
	a_to_txt( _g_pfmk_place( cPartn ) , .t. )
	// broj otpremnice
	a_to_txt( "" , .t. )
	// datum  otpremnice
	a_to_txt( DTOC( dDatDok ) , .t. )
	
	// broj ugovora - nista
	a_to_txt( "", .t. )
	
	// datum isporuke - nista
	a_to_txt( "", .t. )
	
	// 10. datum valute - nista
	a_to_txt( "", .t. )
	
	// 11. 
	a_to_txt( "", .t. )
	// 12. 
	a_to_txt( "", .t. )
	// 13. 
	a_to_txt( "", .t. )
	// 14. 
	a_to_txt( "", .t. )
	// 15. 
	a_to_txt( "", .t. )
	// 16. 
	a_to_txt( "", .t. )
	// 17. 
	a_to_txt( "", .t. )
	// 18. 
	a_to_txt( "", .t. )
	// 19. 
	a_to_txt( cTmp_veza, .t. )

	gather()

	// setuj da je dokument prenesen u DOCS
	select (nADocs)
	seek docno_str(nDoc_no)
	replace doc_in_fmk with 1
	replace fmk_doc with _fmk_doc_upd( ALLTRIM( field->fmk_doc ), ;
		ALLTRIM(cBrDok) )
	
	
	select (nADOC_IT)

	if lSumirati == .f.
		skip
	endif
	
enddo


// sredi redne brojeve pripreme
select x_tbl
set order to tag "0"
go top
nRbr := 0
do while !EOF()
	replace field->rbr with STR( ++nRbr, 3 )
	skip
enddo

select (245)
use

msgbeep("export dokumenta zavrsen !")

select (nTArea)

return


// --------------------------------------------
// dodaj dokument u listu 
// --------------------------------------------
function _fmk_doc_upd( cField, cFmkDok )
local cLista := ""
local cSep := ";"
local cTmp 
local aTmp
local cTmpVal := ""
local nSeek
local i

cTmp := cField
aTmp := TokToNiz( cTmp, cSep )
nSeek := ASCAN( aTmp, { |xVal| xVal == cFmkDok } )

if nSeek = 0
	
	AADD( aTmp, cFmkDok  )
	// sortiraj
	ASORT( aTmp )

endif

// zatim daj u listu sve stavke
for i := 1 to LEN( aTmp )
	if !EMPTY( aTmp[i] )
		cLista += aTmp[ i ] + cSep
	endif
next

return cLista



// ----------------------------------------------------
// sracunaj kolicinu na osnovu vrijednosti polja
// ----------------------------------------------------
function _g_kol( cValue, cQttyType, nKol, nQtty, ;
		nHeigh1, nWidth1, nHeigh2, nWidth2 )

local nTmp := 0

if nHeigh2 == nil
	nHeigh2 := 0
endif

if nWidth2 == nil
	nWidth2 := 0
endif

// po metru
if UPPER(cQttyType) == "M"	

	// po metru, znaèi uzmi sve stranice stakla
	
	if "#D1#" $ cValue
		nTmp += nWidth1
	endif
	
	if "#D4#" $ cValue
	
		if nWidth2 <> 0
			nTmp += nWidth2
		else
			nTmp += nWidth1
		endif
	
	endif

	if "#D2#" $ cValue
		nTmp += nHeigh1
	endif

	if "#D3#" $ cValue
		if nHeigh2 <> 0
			nTmp += nHeigh2
		else
			nTmp += nHeigh1
		endif
	endif

	// pretvori u metre
	nKol := ( nQtty * nTmp ) / 1000
	
endif

// po m2
if UPPER(cQttyType) == "M2"
	
	nKol := c_ukvadrat( nQtty, nHeigh1, nWidth1 ) 
	
endif

// po komadu
if UPPER(cQttyType) == "KOM"
	
	// busenje
	if "<A_BU>" $ cValue

		// broj rupa za busenje
		cTmp := STRTRAN( ALLTRIM(cValue), "<A_BU>:#" )
		aTmp := TokToNiz( cTmp, "#" )

		nKol := LEN( aTmp )
	
	else
		nKol := nQtty
	endif

endif

if EMPTY( cQttyType )

	nKol := nQtty

endif

return



// ----------------------------------------------------
// pronadji partnera u PARTN
// ----------------------------------------------------
static function fnd_partn( xPartn, nCustId, cDesc  )
local nTArea := SELECT()
private GetList:={}

O_PARTN

xPartn := SPACE(6)

Box(, 5, 70)
	@ m_x + 1, m_y + 2 SAY "Narucioc: " 
	@ m_x + 1, col() + 1 SAY ALLTRIM(STR(nCustId)) COLOR "I"
	@ m_x + 1, col() + 1 SAY " -> " 
	@ m_x + 1, col() + 1 SAY PADR(cDesc, 50) + ".." COLOR "I"
	@ m_x + 2, m_y + 2 SAY "nije definisan u relacijama, pronadjite njegov par !!!!"
	@ m_x + 4, m_y + 2 SAY "sifra u FMK =" GET xPartn VALID p_firma( @xPartn )
	read
BoxC()

select (nTArea)

ESC_RETURN 0
return 1


// ----------------------------------------------------
// pronadji robu u ROBA
// ----------------------------------------------------
static function fnd_roba( xRoba, nArtId, cDesc )
local nTArea := SELECT()
private GetList:={}

O_ROBA
O_SIFK
O_SIFV

xRoba := SPACE(10)

Box(, 5, 70)
	@ m_x + 1, m_y + 2 SAY "Artikal:" 
	@ m_x + 1, col() + 1 SAY ALLTRIM(STR(nArtId)) COLOR "I"
	@ m_x + 1, col() + 1 SAY " -> " 
	@ m_x + 1, col() + 1 SAY PADR(cDesc, 50) + ".." COLOR "I"
	@ m_x + 2, m_y + 2 SAY "nije definisan u tabeli relacija, pronadjite njegov par !!!"
	@ m_x + 4, m_y + 2 SAY "sifra u FMK =" GET xRoba VALID p_roba( @xRoba )
	read
BoxC()

select (nTArea)

ESC_RETURN 0
return 1



// ----------------------------------------
// vraca naziv partnera iz FMK
// ----------------------------------------
static function _g_pfmk_desc( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
	xRet := ALLTRIM( partn->naz )
endif

select (nTArea)
return xRet


// ----------------------------------------
// vraca adresu partnera iz FMK
// ----------------------------------------
static function _g_pfmk_addr( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
	xRet := ALLTRIM( partn->adresa )
endif

select (nTArea)
return xRet


// ----------------------------------------
// vraca mjesto i ptt partnera iz FMK
// ----------------------------------------
static function _g_pfmk_place( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
	xRet := ALLTRIM( partn->ptt ) + " " + ALLTRIM( partn->mjesto )
endif

select (nTArea)
return xRet




// ----------------------------------------------
// novi dokument u fakt-u
// ----------------------------------------------
static function fa_new_doc( cFaFirma, cFaTipDok )
local cDokBr := REPLICATE("9", 8)
local nTArea := SELECT()
local cPom
local nPom

select 113
use ( ALLTRIM(gFaKumDir) + "DOKS" ) alias FA_DOKS
set order to tag "1"
go top
seek cFaFirma + cFaTipDok + CHR(254)
skip -1

if field->idfirma == cFaFirma .and. field->idtipdok == cFaTipDok
	cPom := ALLTRIM( field->brdok )
	nPom := VAL( cPom )
else
	nPom := 0
endif

cDokBr := PADL( ALLTRIM(STR( nPom + 1 )), 5, "0" )

select (nTArea)
return cDokBr


// -----------------------------------
// dodaj u polje txt tekst
// lVise - vise tekstova
// -----------------------------------
static function a_to_txt( cVal, lEmpty )
local nTArr
nTArr := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif

// ako je prazno nemoj dodavati
if !lEmpty .and. EMPTY(cVal)
	return
endif

_txt += CHR(16) + cVal + CHR(17)

select (nTArr)
return


