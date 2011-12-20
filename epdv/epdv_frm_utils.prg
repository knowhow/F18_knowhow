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

// ----------------------------------------------
// validacija
// ----------------------------------------------
function v_id_tar(cIdTar, nOsnov, nPdv,  nShow, lNova)
local nStopa 
local nPrerPdv

PushWa()


P_Tarifa(@cIdTar)

SELECT TARIFA
SET ORDER TO TAG "ID"
SEEK cIdTar
nStopa := tarifa->opp

nPrerPdv := ROUND(nOsnov * nStopa / 100, ZAO_IZN())

if lNova
	// nema se sta pitati
	nPdv := nPrerPdv
else

	if ((ROUND(nPrerPdv, 4) <> ROUND(nPdv, 4))) 
		if Pitanje("", "Preracunati prema stopi PDV ?", "N") == "D"
			nPdv :=	nPrerPdv
		endif
	endif
endif

if nShow <> nil
	@ row(), nShow + 2 SAY "Tarifa:" + stopa_pdv(nStopa)
	@ row(), col() + 2 SAY "iznos pdv: " 
	@ row(), col() + 2 SAY nPdV PICT PIC_IZN()
endif

PopWa()

return .t.

// ------------------------------
// partner
// ------------------------------
function v_part(cIdPart, cIdTar, cTbl, lShow)

if lShow == nil
	lShow := .t.
endif

p_partneri(@cIdPart)

if IsIno(cIdPart)
	if lShow
		if cTbl == "KUF"
			MsgBeep("Ino dobavljac, setuje tarifu na PDV7UV !")
			cIdTar := PADR("PDV7UV", 6)
		else
			MsgBeep("Ino kupac, setuje tarifu na PDV0IZ !")
			cIdTar := PADR("PDV0IZ", 6)
			
		endif
	endif
endif

// uprava za indirektno oporezivanje
if IsUio(cIdPart)
	cIdTar := PADR("UIO", 6)
endif

return .t.

// --------------------------
// --------------------------
function v_nazad(nNazad)
for i:=1 to nNazad
	KEYBOARD K_UP
next
return .t.


