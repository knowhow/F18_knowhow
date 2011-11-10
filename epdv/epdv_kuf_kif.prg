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


#include "epdv.ch"

/*
* ----------------------------------------------------------------
*                           Copyright Sigma-com software 2006
* ----------------------------------------------------------------
*/

// -------------------------------------------
// azuriranje kufa
// -------------------------------------------
function azur_kif()
return azur_ku_ki("KIF")

// -------------------------------------------
// azuriranje kif-a
// -------------------------------------------
function azur_kuf()
return azur_ku_ki("KUF")


// -------------------------------------------
// povrat kuf dokument
// -------------------------------------------
function pov_kuf( nBrDok )
return pov_ku_ki("KUF", nBrDok )

// -------------------------------------------
// povrat kif dokument
// -------------------------------------------
function pov_kif(nBrDok)
return pov_ku_ki("KIF", nBrDok)


// -------------------------------------------
// -------------------------------------------
function azur_ku_ki(cTbl)
local nBrDok
public _br_dok := 0

if cTbl == "KUF"
	o_kuf(.t.)
	// privatno podrucje
	nPArea := F_P_KUF
	
	// kumulativ 
	nKArea := F_KUF
else
	o_kif(.t.)
	nPArea := F_P_KIF
	nKArea := F_KIF
endif


Box(, 2, 60)

nCount := 0

SELECT (nPArea)
if RECCOUNT2() == 0
	return 0
endif

nNextGRbr:= next_g_r_br(cTbl)


SELECT (nPArea)
GO TOP

// novi dokument je u pripremi i nema uopste postavljen
// broj dokumenta
if (br_dok == 0)
	nNextBrDok := next_br_dok(cTbl)
	nBrdok := nNextBrDok
else
	nBrDok := br_dok
endif

do while !eof()
	
	Scatter()
	
	// datum azuriranja
	_datum_2 := DATE()
	_g_r_br := nNextGRbr
	
	_br_dok := nBrDok
	
	++nCount
	@ m_x+1, m_y+2 SAY PADR("Dodajem P_KIF -> KUF " + transform(nCount, "9999"), 40)
	@ m_x+2, m_y+2 SAY PADR("   "+ cTbl +" G.R.BR: " + transform(nNextGRbr, "99999"), 40)

	nNextGRbr ++
	
	SELECT (nKArea)
	APPEND BLANK
	Gather()

	select (nPArea)
	SKIP
enddo

SELECT (nKArea)
use

@ m_x+1, m_y+2 SAY PADR("Brisem pripremu ...", 40)

// sve je ok brisi pripremu
SELECT (nPArea)
zap
use

if (cTbl == "KUF")
	o_kuf(.t.)
else
	o_kuf(.t.)
endif	

BoxC()

MsgBeep("Azuriran je " + cTbl + " dokument " + STR( _br_dok, 6, 0) )

return _br_dok



// -------------------------------------------
// povrat kuf/kif dokumenata u pripremu
// -------------------------------------------
function pov_ku_ki(cTbl, nBrDok)


if (cTbl == "KUF")
	o_kuf(.t.)
	// privatno podrucje
	nPArea := F_P_KUF
	
	// kumulativ 
	nKArea := F_KUF
else
	o_kif(.t.)
	nPArea := F_P_KIF
	nKArea := F_KIF
endif



nCount := 0


SELECT (nKArea)
set order to tag "BR_DOK"
seek STR(nBrdok, 6, 0)


if !found()
	SELECT (nPArea)
	return 0
endif

SELECT (nPArea)
if RECCOUNT2()>0
	MsgBeep("U pripremi postoji dokument#ne moze se izvrsiti povrat#operacija prekinuta !")
	return -1
endif


Box(, 2, 60)
SELECT (nKArea)
// dodaj u pripremu dokument
do while !eof() .and. (br_dok == nBrDok)
	
	++nCount
	@ m_x+1, m_y+2 SAY PADR("P_" + cTbl+  " -> " + cTbl + " :" + transform(nCount, "9999"), 40)
	

	SELECT (nKArea)
	// setuj mem vars _
	Scatter()
	
	SELECT (nPArea)
	// dodaj zapis
	APPEND BLANK
	// memvars -> db
	Gather()
	
	// kumulativ tabela
	SELECT (nKArea)
	SKIP	
enddo

// vrati sam dokument, sada mogu  dokument izbrisati iz kumulativa
seek STR(nBrdok, 6, 0)
do while !eof() .and. (br_dok == nBrDok)
	
	SKIP
	// sljedeci zapis
	nTRec := RECNO()
	SKIP -1
	
	++nCount
	@ m_x+1, m_y+2 SAY PADR("Brisem " + cTbl + transform(nCount, "9999"), 40)
	
	DELETE
	// idi na sljedeci
	go nTRec
	
enddo

SELECT (nKArea)
use


if (cTbl == "KUF")
	o_kuf(.t.)
else
	o_kif(.t.)
endif	

BoxC()

MsgBeep("Izvrsen je povrat dokumenta " + STR( nBrDok, 6, 0) + " u pripremu" )

return nBrDok


// --------------------------------------
// renumeracija rednih brojeva - priprema
// --------------------------------------
function renm_rbr(cTbl, lShow)

if lShow == nil
	lShow := .t.
endif

if cTbl == "P_KUF"
	SELECT F_P_KUF
	if !used()
		O_P_KUF
	endif
	
elseif cTbl == "P_KIF"
	SELECT F_P_KIF
	
	SELECT F_P_KIF
	if !used()
		O_P_KIF
	endif
endif

SET ORDER TO TAG "datum"
// "datum" - "dtos(datum)+src_br_2"
GO TOP
nRbr := 1
do while !eof()
	replace r_br with nRbr
	++nRbr
	SKIP
enddo

if lShow
	MsgBeep("Renumeracija izvrsena")
endif

return


// --------------------------------------
// renumeracija rednih brojeva - priprema
// --------------------------------------
function renm_g_rbr(cTbl, lShow)
local nRbr
local nLRbr

if lShow == nil
	lShow := .t.
endif

if cTbl == "KUF"
	SELECT F_KUF
	if !used()
		O_KUF
	endif
	
elseif cTbl == "P_KIF"
	SELECT F_KIF
	
	SELECT F_KIF
	if !used()
		O_KIF
	endif
endif

SET ORDER TO TAG "l_datum"
// "l_datum" - "lock+tos(datum)+src_br_2"

SET SOFTSEEK ON
SEEK "DZ" 
SKIP -1
if lock == "D"
	// postljednji zauzet broj
	nLRbr := g_r_br
else
	nLRbr := 0
endif

PRIVATE cFilter := "!(lock == 'D')"

// iskljuci lockovane slogove 
SET FILTER TO &cFilter
GO TOP

Box(,3, 60)
nRbr:= nLRbr
do while !eof()

 	++nRbr
	@ m_x+1, m_y+2 SAY cTbl + ":" + STR(nRbr, 8, 0)	
	
	replace g_r_br with nRbr
	
	++nRbr
	SKIP
enddo
BoxC()

USE

if lShow
	MsgBeep( cTbl + " : G.Rbr Renumeracija izvrsena")
endif

return

