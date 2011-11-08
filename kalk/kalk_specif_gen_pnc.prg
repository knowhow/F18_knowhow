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


#include "kalk.ch"


function GenProdNc()
local cPKonto
local cIdRoba

local nNc
local cBrDok
local cIdVd
local dDatDok


O_PRODNC
O_ROBA
O_KALK

// mora biti otvorena radi KalknabP funkcije
O_KALK_PRIPR

O_KONCIJ
go top

Box(,3,60)

// prodji kroz sve prodavnice
do while !eof()

	SELECT koncij
	if !EMPTY(koncij->IdProdMjes)
		cPKonto = koncij->Id
	else
		skip
		loop
	endif
	
	// prodji kroz sve artikle
	@ m_x+1, m_y+2 SAY "Prodavnica: " + cPKonto
	SELECT roba
	GO TOP
	do while !eof()
	
		cIdRoba := roba->id
		if IsRobaInProdavnica(cPKonto, cIdRoba)
			@ m_x+2, m_y+2 SAY "Roba " + cIdRoba
			nNc:=GetNcForProdavnica(cPKonto, cIdRoba)
			cBrDok:="00000000"
			cIdVd := "00"
			dDatDok := DATE()
			SetProdNc(cPKonto, cIdRoba, cIdVd, cBrDok, dDatDok, nNc )
		else
			@ m_x+2, m_y+2 SAY "!Roba " + cIdRoba
		endif
		
		select roba
		skip
	enddo
			
	select koncij
	skip
enddo

BoxC()
return

/*
 * *******************************
 */
function IsRobaInProdavnica(cPKonto, cIdRoba)
*{

//  "4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALK")
SELECT kalk
SET ORDER TO TAG "4"
SEEK gFirma + cPKonto + cIdRoba

if found()
	return .t.
else
	return .f.
endif

*}


/*
 * *******************************
 */
function GetNcForProdavnica(cPKonto, cIdRoba)
*{
local nKolS
local nKolZn
local nNc1
local nSredNc
local dDatNab
local dRokTr

private _DatDok 

SELECT (F_PRIPR)
if !used()
	O_KALK_PRIPR
endif

_DatDok = DATE()
KalkNabP( gFirma, cIdRoba, cPKonto, @nKolS, @nKolZN, @nNc1, @nSredNc, @dDatNab, @dRokTr)

return nSredNc
*}


/*
 * *******************************
 */
 
function SetProdNc(cPKonto, cIdRoba, cIdVd, cBrDok, dDatDok, nNc )
*{
local nArr
nArr:=SELECT()

SELECT (F_PRODNC)
if !used()
	O_PRODNC
endif

seek cPKonto + cIdRoba

if !found()
	APPEND BLANK
	replace PKonto with cPKonto
	replace IdRoba with cIdRoba
endif

replace IdVd with cIdVd
replace BrDok with cBrDok
replace DatDok with dDatDok
replace Nc with nNc

select (nArr)
return
*}



function SetIdPartnerRoba()
*{
local cPKonto
local cIdRoba

local nNc
local cBrDok
local cIdVd
local dDatDok


O_ROBA
O_PARTN
go top

Box(,3,60)


for i = 1 to 7

	if (i==1)
		cGodina = ""
	elseif (i==2)
		cGodina = "2002"
	elseif (i==3)
		cGodina = "2001"
	elseif (i==4)
		cGodina = "2000"
	elseif (i==5)
		cGodina = "1999"
	elseif (i==6)
		cGodina = "1998"
	elseif (i==7)
		cGodina = "1997"
	endif


	SELECT (F_KALK)
	use  (KUMPATH+cGodina+"\kalk") 
	set order to tag "1"

	
	@ m_x+1, m_y+2 SAY iif(cGodina=="", "2003", cGodina)
	
	SEEK gFirma + "10"
	do while !eof() .and. (IdVd == "10")

		@ m_x+2, m_y+2 SAY kalk->IdRoba
		
		SELECT ROBA
		cIdPartner = kalk->IdPartner
		SEEK kalk->IdRoba
		if found()
			if Empty(IdPartner)
				replace IdPartner with cIdPartner
			endif
		endif

		SELECT KALK
		skip
	enddo

	select kalk
	USE

next

BoxC()
return

