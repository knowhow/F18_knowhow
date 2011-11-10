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
function s_partner(cIdPartn)

local cPom
local cIdBroj

PushWa()

o_partn()
select PARTN
SET ORDER TO TAG "ID"
seek cIdPartn

cPom := ""

cPom += ALLTRIM(naz) 


cMjesto := ALLTRIM(mjesto)
if EMPTY(cMjesto)
	cMjesto := "-NEP.MJ-"
endif

if !EMPTY(ptt)
	cMjesto := ALLTRIM(ptt) + " " + cMjesto
endif

cPom += ", " + cMjesto

cIdBroj := IzSifK("PARTN", "REGB", cIdPartn, .f.)
if EMPTY(cIdBroj)
	cIdBroj := "-NEP.ID-"
endif

cPom += ", " + cIdBroj

PopWa()
return cPom

// -----------------------------------------------
// podaci o mojoj firmi ubaceni u partnera "10"

//  lRetArray - .t. - vrati matricu
//              .f. - vrati string, default
// -----------------------------------------------
function my_firma(lRetArray)
local lNepopunjeno :=.f.
local cNaziv
local cMjesto
local cIdBroj
local cPtt
local cPom := gNFirma
PushWa()

if lRetArray == nil
	lRetArray := .f.
endif

o_partn()

SELECT partn
SET ORDER TO TAG "ID"
seek gFirma

if !found()
	APPEND BLANK
	replace id with gFirma
endif

cNaziv := naz
cMjesto := mjesto
cIdBroj := IzSifK("PARTN", "REGB", gFirma, .f.)
cAdresa := adresa
cPtt := ptt

if  EMPTY(cNaziv) .or. EMPTY(cMjesto) .or. EMPTY(cIdBroj) .or. EMPTY(cPTT) .or. EMPTY(cAdresa)
	lNepopunjeno:=.t.
endif


if lNepopunjeno
	if get_my_firma(@cNaziv, @cIdBroj, @cMjesto, @cAdresa,  @cPtt)
		replace naz with cNaziv ,;
			mjesto with cMjesto ,;
			adresa with cAdresa ,;
			ptt with cPtt
		USifK("PARTN", "REGB", gFirma, cIdBroj)
	else
		MsgBeep("Nepopunjeni podaci o maticnoj firmi !")
	endif
			
endif

cPom := TRIM(cNaziv) + ", Id.br: " + cIdBroj + " , " + cPtt + " " + ALLTRIM(cMjesto)
cPom += " , " + ALLTRIM(cAdresa)

PopWa()

if lRetArray 
	return { cNaziv, cIdBroj, cPtt, cMjesto, cAdresa }
else
	return cPom
endif


// --------------------------------
// --------------------------------
function get_my_firma(cNaziv, cIdBroj, cMjesto, cAdresa, cPtt)

Box (,7, 60)
@ m_x+1, m_y+2 SAY "Podaci o maticnooj firmi: "
@ m_x+1, m_y+2 SAY REPLICATE("-", 40)
@ m_x+3, m_y+2 SAY "Naziv   " GET cNaziv
@ m_x+4, m_y+2 SAY "Id.broj " GET cIdBroj
@ m_x+5, m_y+2 SAY "Mjesto  " GET cMjesto
@ m_x+6, m_y+2 SAY "Adresa  " GET cAdresa
@ m_x+7, m_y+2 SAY "PTT     " GET cPtt

READ

BoxC()

if LASTKEY() == K_ESC
	return .f.
else
	return .t.
endif

// -----------------------------------------------
// ger rejon partnera
//  - 1 ili " " federacija
//  - 2 - rs
//  - 3 - brcko district
// -----------------------------------------------
function part_rejon(cIdPart)
local cRejon
PushWa()

o_partn()
seek gFirma

cRejon := IzSifK("PARTN", "REJO", cIdPart, .f.)

PopWa()
return cRejon


// -------------------------------------
// sifrarnik partnera sa sifk/sifv
// -------------------------------------
function o_partn()

select F_PARTN
if !used()
	O_PARTN
endif

select F_SIFK
if !used()
	O_SIFK
endif

select F_SIFV
if !used()
	O_SIFV
endif

return

// ---------------------------------------------
// da li se radi o specijalnom partneru
//   - upravi za indirektno oporezivanje
// ---------------------------------------------
function IsUIO(cIdPartner)
return IsProfil(cIdPartner, "UIO")
