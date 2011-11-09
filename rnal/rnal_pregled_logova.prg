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
static __doc_no

// ------------------------------------------
// lista loga sa promjenama za nalog
// nDoc_no - broj dokumenta
// ------------------------------------------
function frm_lst_log( nDoc_no )
local nTArea

nTArea := SELECT()

__doc_no := nDoc_no

o_tables(.f.)

tbl_list()

select (nTArea)

return



// -------------------------------------------------
// otvori tabelu pregleda
// -------------------------------------------------
static function tbl_list()
local cFooter
local cHeader

private ImeKol
private Kol

cHeader := " Nalog broj: " + docno_str(__doc_no) + " "
cFooter := " Pregled promjena na nalogu... "

Box(, 20, 77)

_set_box()

select doc_log
set order to tag "1"

set_f_kol()
set_a_kol(@ImeKol, @Kol)

Beep(2)

ObjDbedit("lstlog", 20, 77, {|| k_handler() }, cHeader, cFooter,,,,,5)

BoxC()

return


// ------------------------------------------
// setovanje dna boxa
// ------------------------------------------
static function _set_box()
local cLine1 := ""
local cLine2 := ""
local nOptLen := 24
local cOptSep := "|"

cLine1 := PADR("<ESC> Izlaz", nOptLen)
cLine1 += cOptSep + " "
cLine1 += PADR("<c-P> Stampa liste", nOptLen)

@ m_x + 20, m_y + 2 SAY cLine1

return


// ------------------------------------------------
// setovanje filtera
// ------------------------------------------------
static function set_f_kol()
local cFilter 

cFilter := "doc_no == " + docno_str( __doc_no )
select doc_log
set filter to &cFilter
go top

return



// ---------------------------------------------
// pregled - key handler
// ---------------------------------------------
static function k_handler()
local nTblFilt
local cLogDesc := ""
local cPom

// napravi string iz rnlog/rnlog_it
cLogDesc := g_log_desc( doc_log->doc_no , ;
			doc_log->doc_log_no , ;
			doc_log_type )

cPom := STRTRAN(cLogDesc, "#", ",")

// prikaz stringa u browse - box-u
s_log_desc_on_form( cPom )

do case
	
	// refresh na browse
	// radi prikaza s_log_opis...()
	case (Ch == K_UP) .or. ;
		(Ch == K_PGUP) .or. ;
		(Ch == K_DOWN) .or. ;
		(Ch == K_PGDN)
		
		return DE_REFRESH
		
	// detaljni prikaz box-a sa promjenama
	case (Ch == K_ENTER)
	
		// ima li pravo pristupa
		if !ImaPravoPristupa(goModul:oDataBase:cName, "DOK", "LOGDETAIL")
			msgbeep( cZabrana )
			select docs
			return DE_CONT
		endif
		
		sh_log_box( cLogDesc )
		return DE_CONT
	
	// stampa liste log-a
	case (Ch == K_CTRL_P)
		if Pitanje(, "Stampati liste promjena (D/N) ?", "D") == "D"
			// stampa liste
			return DE_CONT
		endif
		select doc_log
		return DE_CONT
	
endcase

return DE_CONT



// -------------------------------------------------------
// setovanje kolona tabele za pregled log-a
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}

AADD(aImeKol, {"dat./vr./oper.", {|| DTOC(doc_log_date) + " / " + PADR(doc_log_time, 5) + " " + PADR( getusername( operater_id ), 10) + ".." }, "datum", {|| .t.}, {|| .t.} })

AADD(aImeKol, {"prom.tip" , {|| PADR(s_log_type(doc_log_type), 12) }, "tip", {|| .t.}, {|| .t.} })

AADD(aImeKol, {"kratki opis" , {|| PADR(doc_log_desc, 30) + ".." }, "opis", {|| .t.}, {|| .t.} })

aKol:={}

for i:=1 to LEN(aImeKol)
	AADD(aKol,i)
next

return


// --------------------------------------------
// vraca opis tipa promjene
// --------------------------------------------
static function s_log_type( cType )
local xRet:=""

cType := ALLTRIM(cType)

do case
	case cType == "01"
		xRet := "otvoren"
	case cType == "99"
		xRet := "realizovan"
	case cType == "98"
		xRet := "real.dio"
	case cType == "97"
		xRet := "ponisten"
	case cType == "96"
		xRet := "nije ispor."
	case cType == "10"
		xRet := "osn.podaci"
	case cType == "11"
		xRet := "pod.isporuka"
	case cType == "12"
		xRet := "kontakti"
	case cType == "13"
		xRet := "placanje"
	case cType == "20"
		xRet := "artikli"
	case cType == "21"
		xRet := "lom"
	case cType == "30"
		xRet := "d.operacije"
endcase
return xRet


// -------------------------------------------
// prikaz opisa log-a na formi
// cLogText se lomi na 3 reda...
// -------------------------------------------
static function s_log_desc_on_form(cLogText)
local aLogArr:={}
local cRow1
local cRow2
local cRow3
local nLenText:=76
local cOpis

cRow1 := SPACE(nLenText)
cRow2 := SPACE(nLenText)
cRow3 := SPACE(nLenText)

aLogArr := SjeciStr(cLogText, nLenText)

if LEN(aLogArr) > 0
	
	cRow1 := aLogArr[1]
	
	if LEN(aLogArr) > 1
		cRow2 := aLogArr[2]
	endif
	
	if LEN(aLogArr) > 2
		cRow3 := aLogArr[3]
	endif
endif

// separator
@ m_x + 16, m_y + 2 SAY SPACE(nLenText)
@ m_x + 16, m_y + 2 SAY PADR(cRow1, nLenText) COLOR "I"
// prvi red
@ m_x + 17, m_y + 2 SAY SPACE(nLenText)
@ m_x + 17, m_y + 2 SAY PADR(cRow2, nLenText) COLOR "I"
// drugi red
@ m_x + 18, m_y + 2 SAY SPACE(nLenText)
@ m_x + 18, m_y + 2 SAY PADR(cRow3, nLenText) COLOR "I"

return


// -------------------------------------------------------
// formira i vraca string na osnovu tabela DOC_LOG/DOC_LIT
// -------------------------------------------------------
static function g_log_desc(nDoc_no, nDoc_log_no, cDoc_log_type)
local cRet := ""
local nTArea := SELECT()
local nTRec := RECNO()
local cTBFilter := DBFILTER()

select doc_log
set order to tag "1"

cDoc_log_type := ALLTRIM(cDoc_log_type)

do case
	case cDoc_log_type == "01"
		cRet := _lit_01_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "99"
		cRet := _lit_99_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "98"
		cRet := _lit_99_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "97"
		cRet := _lit_99_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "96"
		cRet := _lit_99_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "10"
		cRet := _lit_10_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "11"
		cRet := _lit_11_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "12"
		cRet := _lit_12_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "13"
		cRet := _lit_13_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "20"
		cRet := _lit_20_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "21"
		cRet := _lit_21_get(nDoc_no, nDoc_log_no)
	case cDoc_log_type == "30"
		cRet := _lit_30_get(nDoc_no, nDoc_log_no)
endcase

select (nTArea)
set filter to &cTBFILTER
go (nTRec)

return cRet



// -------------------------------------------------
// vraca opis akcije prema oznaci cAkcija
// -------------------------------------------------
static function g_action_info(cAction)
local xRet := ""

do case 
	case cAction == "E"
		xRet := "update"
	case cAction == "+"
		xRet := "insert"
	case cAction == "-"
		xRet := "delete"
endcase

return xRet


// ------------------------------------------
// prikaz box-a sa informacijama loga
// ------------------------------------------
static function sh_log_box(cLogTxt)
local aBoxTxt := {}
local cPom 
local cResp := "OK"
private GetList:={}

aBoxTxt := toktoniz(cLogTxt, "#") 

if LEN(aBoxTxt) == 0
	return
endif

Box(, LEN(aBoxTxt) + 2, 70)
	
	@ m_x + 1, m_y + 2 SAY "Detaljni prikaz promjene: " COLOR "I" 
	
	for i:=1 to LEN(aBoxTxt)

		@ m_x + (i+1), m_y + 2 SAY PADR(aBoxTxt[i], 65)
	next

	@ m_x + LEN(aBoxTxt) + 2, m_y + 2 GET cResp 
	
	read
BoxC()

if LastKey() == K_ESC .or. cResp == "OK"
	return
endif

return 



