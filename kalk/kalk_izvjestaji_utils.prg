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

 

function ViseDokUPripremi(cIdd)

if field->idPartner+field->brFaktP+field->idKonto+field->idKonto2<>cIdd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
endif

return

// -----------------------------------------------------
// prikaz dodatnih informacija za dokument
// -----------------------------------------------------
function show_more_info( cPartner, dDatum, cFaktura, cMU_I )
local cRet := ""
local cMIPart := ""
local cTip := ""

if !EMPTY( cPartner )
	
	// naziv partnera sa dokumenta ...
	cMIPart := ALLTRIM( Ocitaj( F_PARTN, cPartner, "NAZ" ) )

	if cMU_I == "1"
		cTip := "dob.:"
	else
		cTip := "kup.:"
	endif

	cRet := DTOC( dDatum )
	cRet += ", "
	cRet += "br.dok: "
	cRet += ALLTRIM( cFaktura )
	cRet += ", "
	cRet += cTip 
	cRet += " " 
	cRet += cPartner 
	cRet += " ("
	cRet += cMIPart
	cRet += ")"
	
endif

return cRet



/*! \fn PrikaziDobavljaca(cIdRoba, nRazmak, lNeIspisujDob)
 *  \brief Funkcija vraca dobavljaca cIdRobe na osnovu polja roba->dob
 *  \param cIdRoba
 *  \param nRazmak - razmak prije ispisa dobavljaca
 *  \param lNeIspisujDob - ako je .t. ne ispisuje "Dobavljac:"
 *  \return cVrati - string "dobavljac: xxxxxxx"
 */

function PrikaziDobavljaca(cIdRoba, nRazmak, lNeIspisujDob)
*{
if lNeIspisujDob==NIL
	lNeIspisujDob:=.t.
else
	lNeIspisujDob:=.f.
endif

cIdDob:=Ocitaj(F_ROBA, cIdRoba, "SifraDob")

if lNeIspisujDob
	cVrati:=SPACE(nRazmak) + "Dobavljac: " + TRIM(cIdDob)
else
	cVrati:=SPACE(nRazmak) + TRIM(cIdDob)
endif

if !Empty(cIdDob)
	return cVrati
else
	cVrati:=""
	return cVrati
endif
*}


function PrikTipSredstva(cKalkTip)
if !EMPTY(cKalkTip)
	? "Uslov po tip-u: "
	if cKalkTip=="D"
		?? cKalkTip, ", donirana sredstva"
	elseif cKalkTip=="K"
		?? cKalkTip, ", kupljena sredstva"
	else
		?? cKalkTip, ", --ostala sredstva"
	endif
endif

return


// ---------------------------------------
// vraca naziv objekta na osnovu konta
// ---------------------------------------
function g_obj_naz(cKto)
local cVal := ""
local nTArr

nTArr := SELECT()

O_OBJEKTI
select objekti
set order to tag "idobj"
go top
seek cKto

if FOUND()
	cVal := objekti->naz
endif

select (nTArr)

return cVal


