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


// meni opcije provjere integriteta
function mnu_kt_int1()
local dDatOd
local dDatDo
local cKonto
local cFirma
local aProd
local i

if get_vars(@dDatOd, @dDatDo, @cKonto, @cFirma) == 0
	return
endif

// kreiraj tabelu errors
cre_errors()
// brisi tabelu errors
BrisiError()

O_KALK
O_ROBA

aProd:={}
g_k_prod(@aProd, cKonto)

if LEN(aProd) == 0
	MsgBeep("Nema definisanih prodavnica u koncij.dbf!")
	return
endif

// aProd {1, 2, 3, 4}
//        koncij->id, koncij->idprodmj, koncij->kumtops, koncij->siftops

// prodji kroz prodavnice
for i:=1 to LEN(aProd)
	// izvrsi provjeru... podataka
	k_t_integ(dDatOd, dDatDo, aProd[i, 1], aProd[i, 2], aProd[i, 3], aProd[i, 4], cFirma)
	// provjera integriteta robe
	roba_integ(aProd[i, 1], SIFPATH, aProd[i, 4], aProd[i, 3])
next

// pokreni report
RptInteg(.t.)

return


// napuni matricu sa prodavnicama
static function g_k_prod(aProd, cKonto)
O_KONCIJ
select koncij 
set order to tag "ID"
go top

if !EMPTY(cKonto)
	seek cKonto
	if FOUND()
		AADD(aProd, {koncij->id, koncij->idprodmjes, koncij->kumtops, koncij->siftops})
	endif
else
	do while !EOF()
		if LEFT(koncij->id, 3)=="132" .and. !EMPTY(koncij->kumtops)
			AADD(aProd, {koncij->id, koncij->idprodmjes, koncij->kumtops, koncij->siftops})
		endif
		skip
	enddo
endif

return


// setovanje varijabli uslova testa
static function get_vars(dDatOd, dDatDo, cKonto, cFirma)

dDatOd := CToD("")
dDatDo := DATE()
cKonto := SPACE(7)
cFirma := gFirma

Box(,5,60)
	@ m_x+1, m_x+2 SAY "Firma:" GET cFirma 
	@ m_x+2, m_x+2 SAY "Datum od" GET dDatOd
	@ m_x+2, m_x+20 SAY "do" GET dDatDo 
	@ m_x+4, m_x+2 SAY "Prodavnicki konto:" GET cKonto VALID EMPTY(cKonto) .or. P_Konto(@cKonto)
	
	read
BoxC()

ESC_RETURN 0
return 1


// kalk, tops integritet podataka
function k_t_integ(dDatOd, dDatDo, cPKonto, cPOSPm, cKPath, cSPath, cFirma)
local cRoba
local nKStK
local nKStF
local nKPrK
local nKPrF
local nPStK
local nPStF
local nPPrK
local nPPrF
local cKonto

cKPath := ALLTRIM(cKPath)
AddBS(@cKPath)

cSPath := ALLTRIM(cSPath)
AddBS(@cSPath)

// da li postoji fajl
if !FILE(cKPath + "POS.DBF")
	return
endif

// otvori pos.dbf na poziciji
select 0
use (cKPath + "POS")

select (F_ROBA)
use (cSPath + "ROBA")
set order to tag "ID"

O_KALK
select kalk
set order to tag "4"
hseek cFirma + cPKonto

Box(,2,60)

@ 1+m_x, 2+m_y SAY SPACE(60)
@ 1+m_x, 2+m_y SAY "Provjera integriteta na osnovu KALK-a..."
	
do while !EOF() .and. kalk->(idfirma+pkonto) == cFirma+cPKonto
	
	cRoba := kalk->idroba
	
	if !(field->pu_i $ "1#3#5#I") .or. Empty(ALLTRIM(cRoba))
		skip
		loop
	endif
	
	
	nKStK := 0
	nKStF := 0
	nKPrK := 0
 	nKPrF := 0

	nPStK := 0
	nPStF := 0
	nPPrK := 0
 	nPPrF := 0
	
	// nivelacije
	nKNiCnt := 0
	nPNiCnt := 0
	
	// reklamacije
	nKRkCnt := 0
	nPRkCnt := 0
	
	@ 2+m_x, 2+m_y SAY SPACE(60)
	@ 2+m_x, 2+m_y SAY cPKonto + " - " + cRoba
	
	// prodji kroz KALK za cRoba
	scan_kalk(cFirma, cPKonto, cRoba, dDatOd, dDatDo, @nKStK, @nKStF, @nKPrK, @nKPrF, @nKNiCnt, @nKRkCnt)	

	// prodji kroz POS za cRoba
	scan_pos(cPosPm, cRoba, dDatOd, dDatDo, @nPStK, @nPStF, @nPPrK, @nPPrF, @nPNiCnt, @nPRkCnt)	

	select roba
	hseek cRoba
	if !FOUND() .and. (nKStK <> 0)
		AddToErrors("C", cRoba, "", "Konto: " + ALLTRIM(cPKonto) + ", TOPSK, nepostojeca sifra artikla !!!")
	endif
	select kalk

	// kolicinsko stanje ne valja!
	if ROUND(nKStK, 3) <> ROUND(nPStK, 3)
		AddToErrors("C", cRoba, "","Konto: " + ALLTRIM(cPKonto) + ",  zaliha kol. (KALK)=" + ALLTRIM(STR(ROUND(nKStK,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPStK, 3))) )
	else
		// finansijsko stanje ne valja!
		if ROUND(nKStF, 3) <> ROUND(nPStF, 3)
			cPom := "C"
			
			if nKStK <> 0 .and. ((nKStF-nPStF)/nKStK) == ABS(nKPrF-nPPrF)
				cPom := "P"
			endif
			
			AddToErrors(cPom, cRoba, "", "Konto: " + ALLTRIM(cPKonto) + ",  zaliha fin. (KALK)=" + ALLTRIM(STR(ROUND(nKStF,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPStF, 3))) )
		endif
	endif
	
	// prodaja kolicinska ne valja!
	if ROUND(nKPrK, 3) <> ROUND(nPPrK, 3)
		AddToErrors("C", cRoba, "", "Konto: " + ALLTRIM(cPKonto) + ", prodaja kol. (KALK)=" + ALLTRIM(STR(ROUND(nKPrK,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPPrK, 3))) )
	else
		// prodaja fin.stanje ne valja!
		if ( ROUND(nKPrF, 3) <> ROUND(nPPrF, 3) )
			
			cPom := "C"
			
			// ako je razlika kao i razlika zalihe
			// to nije critical
			
			if nKStK <> 0 .and. ((nKStF-nPStF)/nKStK) == ABS(nKPrF-nPPrF)
				cPom := "P"
			elseif (nKStF == nPStF) 
				// ako je f.stanje zaliha isto 
				// onda je takodjer P
				cPom := "P"
			endif

			AddToErrors(cPom, cRoba, "", "Konto: " + ALLTRIM(cPKonto) + ", prodaja fin. (KALK)=" + ALLTRIM(STR(ROUND(nKPrF,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPPrF, 3))) )
		
		endif
	endif
	
	// broj nivelacija
	// ako su stanja 0 onda to i nisu greske...
	if ( nKNiCnt <> nPNiCnt ) .and. ( nKStK + nPStK <> 0 )
		AddToErrors("W", cRoba, "", "Konto: " + ALLTRIM(cPKonto) + ", broj nivelacija (KALK)=" + ALLTRIM(STR(ROUND(nKNiCnt, 3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPNiCnt, 3))) )
	endif

	select kalk
enddo

select pos
use
select roba
use

BoxC()

return


// prodji kroz KALK za cRoba i napuni varijable...
static function scan_kalk(cFirma, cKonto, cRoba, dDatOd, dDatDo, nKStK, nKStF, nKPrK, nKPrF, nKNiCnt, nKRkCnt)	

do while !EOF() .and. kalk->(idfirma+pkonto+idroba) == cFirma+cKonto+cRoba
	
	if ( kalk->datdok > dDatDo ) .or. ( kalk->datdok < dDatOd )
		skip
		loop
	endif
		
	// ulazni dokumenti
	if kalk->pu_i == "1"
		nKStK += kalk->kolicina - kalk->gkolicina - kalk->gkolicin2
		nKStF += kalk->mpcsapp * (kalk->kolicina-kalk->gkolicina-kalk->gkolicin2)
	endif
		
	// izlazni dokumenti
	if kalk->pu_i == "5"
		// stanje
		nKStK -= kalk->kolicina
		nKStF -= kalk->kolicina * kalk->mpcsapp
		
		// prodaja
		if kalk->idvd <> "12"
			nKPrK += kalk->kolicina
			nKPrF += kalk->kolicina * kalk->mpcsapp
		endif
	endif
		
	if kalk->pu_i == "I"
		nKStK -= kalk->gkolicin2
		nKStF -= kalk->mpcsapp * kalk->gkolicin2
	endif

	// nivelacija
	if kalk->pu_i == "3"
		nKStF += kalk->mpcsapp * kalk->kolicina
		++ nKNiCnt 
	endif

	skip
enddo

return


// prodji kroz POS i napuni varijable....
static function scan_pos(cPosPm, cRoba, dDatOd,;
			dDatDo, nPStK, nPStF,;
			nPPrK, nPPrF, nPNiCnt, nPRkCnt)	

select pos
set order to tag "5"
hseek cPosPm + cRoba

do while !EOF() .and. pos->(idpos+idroba)==cPosPm+cRoba
	
	if ( pos->datum > dDatDo ) .or. ( pos->datum < dDatOd )
		skip
		loop
	endif
		
	// ulazni dokumenti
	if pos->idvd == "16"
		nPStK += pos->kolicina
		nPStF += pos->cijena * pos->kolicina
	endif
		
	// izlazni dokumenti
	if pos->idvd == "42"
		// stanje
		nPStK -= pos->kolicina
		nPStF -= pos->kolicina * pos->cijena
		// prodaja
		nPPrK += pos->kolicina
		nPPrF += pos->kolicina * pos->cijena
	endif
	
	// reklamacije
	if pos->idvd == "98"
		// stanje
		nPStK -= pos->kolicina
		nPStF -= pos->kolicina * pos->cijena
		++ nPRkCnt
	endif

	// nivelacija
	if pos->idvd == "NI"
		nPStF += pos->kolicina * (pos->ncijena - pos->cijena)
		++ nPNiCnt
	endif
	
	skip
enddo

return



