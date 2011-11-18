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



function GenRekap1(aUsl1, aUsl2, aUslR, cKartica, cVarijanta, cKesiraj, fSMark,  cK1, cK7, cK9, cIdKPovrata, aUslSez)
local nSec

if (cKesiraj=nil)
	cKesiraj:="N"
endif

if (fSMark==nil)
	fSMark:=.f.
endif

if (cK1==nil)
	cK1:="9999"
endif

if (cK7==nil)
	cK7:="N"
endif

if (cK9==nil)
	cK9:="999"
endif

if (cIdKPovrata==nil)
	cIdKPovrata:="XXXXXXXX"
endif

if (aUslSez==nil)
	aUslSez:=".t."
endif

nSec:=SECONDS()

SELECT kalk
set order to

PRIVATE cFilt1:=""

cFilt1 := "DatDok<="+cm2str(dDatDo)+".and.("+aUsl1+".or."+aUsl2+")"

if aUslr <> ".t."
	cFilt1 += ".and." + aUslR
endif

if aUslSez <> ".t."
	cFilt1 += ".and." + aUslSez
endif

SELECT kalk
set filter to &cFilt1

#ifndef CAX
	showkorner(rloptlevel()+100,1,66)
#endif

go top

nStavki:=0
Box(,2,70)
do while !EOF()
	if fSMark .and. SkLoNMark("ROBA", kalk->idroba)
		skip
		loop
	endif

	SELECT roba
	hseek kalk->(idroba)
	if cK7=="D" .and. EMPTY(roba->k7)
		SELECT kalk
		skip
		loop
	endif


	if (cK1<>"9999" .and. !Empty(cK1) .and. roba->k1<>cK1)
		select kalk
		skip
		loop
	endif

	if (cK9<>"999" .and. !Empty(cK9) .and. roba->k9<>cK9)
		select kalk
		skip
		loop
	endif
	
	SELECT rekap1
	ScanMKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)

	SELECT rekap1
	ScanPKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)

	if ((++nStavki % 100)==0)
		@ m_x+1,m_y+2 SAY nStavki pict "99999999999999"
	endif

	SELECT kalk
	skip
enddo

nStavki:=0

SELECT roba
go top   
do while !EOF()
	if roba->tip=="N" 
		// nova roba
		SELECT pobjekti
		go top  
		// za sve objekte
		do while !EOF()
			SELECT rekap1
			hseek pobjekti->idobj+roba->id
			if !found()
				APPEND BLANK
				replace objekat with pobjekti->idobj
				REPLACE idroba with roba->id
				REPLACE idtarifa with roba->idtarifa
				REPLACE g1 with roba->k1
				field->mpc:=roba->mpc
			endif
			SELECT pobjekti
			skip
		enddo
	endif
	@ m_x+1,m_y+2 SAY "***********************"
	@ m_x+1,col()+2 SAY ++nStavki pict "99999999999999"
	SELECT roba
	skip
enddo 

BoxC()

nSec:=SECONDS()-nSec
if (nSec>1)  
	// nemoj "brze izvjestaje"
	@ 23,75 SAY nSec pict "9999"
endif

return
*}

function ScanMKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)
*{
local nGGOrd
local nGGo
local nMpc
local cSeek

if EMPTY(kalk->mKonto)
	return 0
endif

hseek kalk->(mKonto+idroba) 
if !found()
	APPEND BLANK
	// radi promjene tarifa promjenio sam kalk->idtarifa u roba->idtarifa
	//replace objekat with kalk->mKonto, idroba with kalk->idroba, idtarifa with kalk->idtarifa, g1 with roba->k1
	replace objekat with kalk->mKonto, idroba with kalk->idroba, idtarifa with roba->idtarifa, g1 with roba->k1
	if (cKartica=="D")  
		// ocitaj sa kartica
		nMpc:=0
		if (cVarijanta<>"1")
			// varijanta="1" - pregled kretanja zaliha
			cSeek:=kalk->(idfirma+mKonto+idroba)
			SELECT kalk
			nGGOrd:=indexord()
			nGGo:=recno()
			SELECT koncij
			seek trim(kalk->mKonto)
			SELECT kalk
			// dan prije inventure !!!
			FaktVPC(@nmpc,cSeek,dDatDo-1)  
			dbsetorder(nGGOrd)
			go nGGo
			SELECT rekap1
			field->mpc:=nmpc
		endif
	else
		field->mpc:=roba->mpc
	endif
endif

if kalk->mu_i=="1"
	if kalk->datdok<=dDatDo  
		// stanje zalihe
		field->k2+=kalk->kolicina
	endif
	if cVarijanta<>"1"  
		// u pregledu kretanja zaliha ovo nam ne treba
		if (kalk->datdok<dDatOd) 
			// predhodno stanje
			field->k0+=kalk->kolicina
		endif
		if DInRange(kalk->datdok, dDatOd, dDatDo ) 
			// tekuci prijem
			field->k4+=kalk->kolicina
		endif
	endif
elseif kalk->mu_i=="5" 
	// izlaz iz magacina
	if cVarijanta<>"1"  
		// u pregledu kretanja zaliha ovo nam ne treba
		if (kalk->datdok<dDatOd)  
			// predhodno stanje
			field->k0-=kalk->kolicina
		endif
	endif
	if kalk->datdok<=dDatDo  
		// stanje trenutne zalihe
		field->k2-=kalk->kolicina
	endif

	if kalk->idvd $ "14#94"
		if (cVarijanta<>"1")  
			// u pregledu kretanja zaliha ovo nam ne treba
			if (kalk->datdok<=dDatDo) 
				// kumulativna prodaja
				field->k3+=kalk->kolicina
			endif
		endif
		if DInRange(kalk->datDok, dDatOd, dDatDo ) 
			// stanje trenutne prodaje
			field->k1+=kalk->kolicina
		endif
	endif

elseif (kalk->mu_i=="3") 
	// nivelacija
	if (kalk->datDok=dDatDo)  
		// dokument nivelacije na dan inventure
		if (cVarijanta<>"1")
			field->novampc:=kalk->mpcsapp+kalk->vpc
		endif
		field->mpc:=kalk->mpcsapp 
	endif
endif


return 1
*}


function ScanPKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)
*{
local nGGOrd
local nGGo
local nMpc
local cSeek
 
if EMPTY(kalk->pkonto)     
	return 0
endif

HSEEK kalk->(pkonto+idroba)
if !FOUND()
	APPEND BLANK
	replace objekat with kalk->pkonto
	REPLACE idroba with kalk->idroba
	REPLACE idtarifa with roba->idtarifa
	REPLACE g1 with roba->k1
	if (cKartica=="D")  
		// ocitaj sa kartica
		nMpc:=0
		cSeek:=kalk->(idfirma+pkonto+idroba)
		SELECT kalk
		nGGo:=recno()
		nGGOrd:=indexord()
		SELECT koncij
		seek trim(kalk->pkonto)
		SELECT kalk
		// dan prije inventure !!!
		FaktMPC(@nmpc,cSeek,dDatDo-1)  
		dbsetorder(nGGOrd)
		go nGGo
		SELECT rekap1
		field->mpc:=nMpc
	else
		field->mpc:=roba->mpc
	endif
endif

if (kalk->pu_i=="1" .and. kalk->kolicina>0)
	
	// ulaz moze biti po osnovu prijema, 80 - preknjizenja
	// odnosno internog dokumenta

	if kalk->datdok<=dDatDo  // kumulativno stanje
		field->k2+=kalk->kolicina  // zalihe
	endif
	if (cVarijanta<>"1")
		if kalk->datdok<dDatOd  
			// predhodno stanje
			field->k0+=kalk->kolicina
		endif
		if DInRange(kalk->datdok,dDatOd,dDatDo ) 
			// tekuci prijem
			field->k4+=kalk->kolicina
		endif
	else
		if DInRange(kalk->datdok,dDatOd,dDatDo ) 
			// tekuci prijem
			if kalk->idvd=="80" .and. !EMPTY(kalk->idkonto2)
				// bilo je promjena po osnovu predispozicije
				field->k4pp+=kalk->kolicina
			endif
		endif
	endif

elseif (kalk->pu_i=="3")

	// nivelacija
	if kalk->datdok=dDatDo   
		// dokument nivelacije na dan inventure
		if cVarijanta<>"1"
			field->novampc:=kalk->(Fcj+mpcsapp)
		endif
		// stara cijena
		field->mpc:=kalk->fcj

	endif

elseif kalk->pu_i=="5" .or. (kalk->pu_i=="1" .and. kalk->kolicina<0)

	// izlaz iz prodavnice moze biti 42,41,11,12,13
	// f1 - tekuca prodaja, f2 zaliha, f3 - kumulativna prodaja
	// f4 - prijem u toku mjeseca
	// f6 - izlaz iz prodavnice po ostalim osnovama
	// f5 - reklamacije u toku mjeseca, f7 - reklamacije u toku godine

	if (cVarijanta<>"1")
		if kalk->datdok<dDatOd
			if kalk->pu_i=="5"    
				// predhodno stanje
				field->k0-=kalk->kolicina
			else
				field->k0-=abs(kalk->kolicina)
			endif
		endif
	endif

	if (kalk->datdok<=dDatDo)
		if kalk->pu_i=="5"
			// zaliha
			field->k2-=kalk->kolicina       
		else
			field->k2-=abs(kalk->kolicina)
		endif
	endif

	if (kalk->idvd $ "41#42#43") 
		//prodaja
		if DInRange(kalk->datdok,dDatOd,dDatDo ) 
			// tekuca prodaja
			field->k1+=kalk->kolicina
		endif
		if (cVarijanta<>"1")
			if kalk->datdok<=dDatDo  
				// kumulativna prodaja
				field->k3+=kalk->kolicina
			endif
		endif

	else  

		// izlazi iz prodavnice po ostalim osnovima
		
		if (cVarijanta<>"1")
			if (kalk->idvd $ "11#12#13" .and. kalk->mKonto==cIdKPovrata)  
				// reklamacija
				if DInRange(kalk->datdok,dDatOd,dDatDo ) 
					// tekuce reklamacije
					// reklamacije u mjesecu
					field->k5+=abs(kalk->kolicina) 
				endif
				if kalk->datdok<=dDatDo
					// kumulativno reklamacije
					field->k7+=abs(kalk->kolicina)   
				endif
			else
				if DInRange(kalk->datdok, dDatOd, dDatDo)
					// izlaz-otprema po ostalim osnovama
					field->k6+=abs(kalk->kolicina)  
				endif
			endif
		else
			if DInRange(kalk->datdok, dDatOd, dDatDo )
				if kalk->idvd=="80" .and. !EMPTY(kalk->idkonto2)
					// bilo je promjena po osnovu predispozicije
					field->k4pp+=kalk->kolicina
				endif
			endif
		endif
	endif
endif


return 1
*}


