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


function GenRekap2(lK2X, cC, lPrDatOd, lVpRab, lMarkiranaRoba)
local lMagacin
local lProdavnica

if (lK2X==nil)
   lK2X:=.f.
endif

if (cC==nil)
	cC:="P"
endif

if (lVpRab == nil) 
	lVpRab := .t.
endif

if (lMarkiranaRoba==nil)
	lMarkiranaRoba:=.f.
endif

SELECT kalk

PRIVATE cFilt3:=""

cFilt3 := "("+aUsl1+".or."+aUsl2+") .and.DATDOK<="+cm2str(dDatDo)

if aUslR<>".t."
	cFilt3+=".and."+aUslR
endif

set filter to &cFilt3

GO TOP

nStavki:=0
Box(,2,70)
do while !EOF()
	if lMarkiranaRoba .and. SkLoNMark("ROBA", kalk->idroba)
		skip
		loop
	endif
	SELECT roba
	HSEEK kalk->idRoba
	
	if IsPlanika() .and. !EMPTY(cPlVrsta) .and. roba->vrsta <> cPlVrsta
		select kalk
		skip
		loop
	endif
	
	if IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9
		select kalk
		skip
		loop
	endif	
	
	lMagacin:=.t.
	SELECT rekap2

	Sca2MKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, @lMagacin, lVpRab, lPrDatOd)
	Sca2PKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, @lProdavnica, lPrDatOd)

	@ m_x+1,m_y+2 SAY ++nStavki pict "999999999999"

	SELECT kalk
	skip
enddo

GRekap22()

BoxC()

return


function Sca2MKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, lMagacin, lVpRabat, lPrDatOd)

local nPomKolicina
local nTC

if lPrDatOd == nil
	lPrDatOd := .f.
endif

if !EMPTY(kalk->mKonto) .and. (KALK->(&aUsl2) .or. kalk->mKonto==cIdKPovrata)
	cGodina:=STR(YEAR(kalk->datDok),4)
	cMjesec:=STR(MONTH(kalk->datDok),2)
	HSEEK cGodina+cMjesec+roba->k1+kalk->mKonto
	if !found()
		APPEND BLANK
		REPLACE objekat with kalk->mKonto
		REPLACE godina with VAL(cGodina)
		REPLACE mjesec with VAL(cMjesec)
		REPLACE g1 with roba->k1
	endif
else
	lMagacin:=.f.
endif

if cC=="P"
	nTC:=KALK->vpc
else
	nTC:=KALK->nc
endif

// biljezi magacin - radi zaliha
if !lMagacin

elseif (kalk->mu_i=="1" .or. (kalk->mu_i=="5" .and. kalk->idvd=="97"))
	
	// mu_i=="5" jeste izlaz iz magacina, ali ga ovdje treba prikazivati
	// kao storno ulaza
	if (kalk->mu_i=="5" .and. kalk->idvd=="97")
		nPomKolicina:= -1 * kalk->kolicina
	else
		nPomKolicina:= kalk->kolicina
	endif
	if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
		field->stanjek += nPomKolicina
	endif
	field->stanjef += nPomKolicina*nTC
	
	if (kalk->datDok<=dDatOd)
		
		if !lK2X .or. !(LEFT(roba->K2,1)=='X')
			field->zalihak += nPomKolicina
		endif
		field->zalihaf += nPomKolicina*nTC
		if (kalk->mKonto==cIdKPovrata)
			if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
				field->stanjrk += nPomKolicina
			endif
			field->stanjrf += nPomKolicina*nTC
		endif
	else
		if (kalk->mKonto==cIdKPovrata)
			// magacin rekl. robe
			if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
				field->stanjrk += nPomKolicina
			endif
			field->stanjrf += nPomKolicina*nTC
		elseif (kalk->idvd=="10")
			if (!lK2X .or. !(LEFT(roba->K2,1)=='X'))
				field->nabavk += nPomKolicina
			endif
			field->nabavf += nPomKolicina*nTC
		endif
	endif

elseif (kalk->mu_i=="5") 
	
	// izlaz iz magacina
	if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
		field->stanjek-=kalk->kolicina
	endif
	field->stanjef-=kalk->kolicina*nTC
	if kalk->datdok<=dDatOd
		if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
			field->zalihak-=kalk->kolicina
		endif
		field->zalihaf-=kalk->kolicina*nTC
		if (kalk->mKonto==cIdKPovrata)
			if !lK2X .or. !(LEFT(roba->k2,1)=='X')
				field->stanjrk-=kalk->kolicina
			endif
			field->stanjrf-=kalk->kolicina*nTC
		endif
	else
		if (kalk->mKonto==cIdKPovrata)
			if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
				field->stanjrk-=kalk->kolicina
			endif
			field->stanjrf-=kalk->kolicina*nTC
		elseif kalk->idvd=="14"
			// izlaz velepr.
			if (!lK2X .or. !(roba->K2='X'))
				field->prodajak+=kalk->kolicina
			endif
			if (cC=="P")
				if lVpRabat
					field->prodajaf+=kalk->(kolicina*nTC*(1-RabatV/100))
					field->orucf+=kalk->(kolicina*(nTC*(1-RabatV/100)-nc))
				else
					field->prodajaf+=kalk->(kolicina*nTC)
					field->orucf+=kalk->(kolicina*(nTC-nc))
				endif
			else
				field->prodajaf+=kalk->(kolicina*nTC)
			endif
		endif
	endif

elseif (kalk->mu_i=="3" .and. cC=="P")
	// nivelacija - samo za prod.cijenu
	if kalk->datdok<=dDatOd
		field->zalihaf+=kalk->kolicina*nTC
	endif

	if (nTC>0)
		field->povecanje+=kalk->(kolicina*nTC)
	else
		// apsolutno
		field->snizenje+=abs(kalk->(kolicina*nTC)) 
	endif

	if (kalk->mKonto==cIdKPovrata)
		field->stanjrf+=kalk->kolicina*nTC
	else
		field->stanjef+=kalk->kolicina*nTC
	endif

endif 

return


function Sca2PKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, lMagacin, lPrDatOd)

local nTC

if lPrDatOd == nil
	lPrDatOd := .f.
endif

lProdavnica:=.t.
SELECT rekap2

if !EMPTY(kalk->pkonto) .and. kalk->(&aUsl1)
	cGodina:=STR(YEAR(kalk->datDOK),4)
	cMjesec:=STR(MONTH(kalk->datDOK),2)
	HSEEK cGodina+cMjesec+roba->k1+kalk->pkonto
	if !found()
		APPEND BLANK
		replace objekat with kalk->pkonto,;
		godina with val(cGodina),;
		mjesec with val(cMjesec),;
		g1 with roba->k1
	endif
else
	lProdavnica:=.f.
endif

if cC=="P"
	nTC:=KALK->mpc
else
	nTC:=KALK->nc
endif

if !lProdavnica

elseif (kalk->pu_i=="1")
	
	// ulaz moze biti po osnovu prijema, 80 - preknjizenja
	// odnosno internog dokumenta

	if !lK2X .or. !(roba->K2='X')
		field->stanjek+=kalk->kolicina
	endif
	field->stanjef+=kalk->(kolicina*nTC)

	if kalk->datdok<=dDatOd
		if !lK2X .or. !(roba->K2='X')
			field->zalihak+=kalk->kolicina
		endif
		field->zalihaf+=kalk->(kolicina*nTC)
	else
		if kalk->idvd $ "11#12#13#81"
			if !lK2X .or. !(roba->K2='X')
			field->pnabavk += KALK->kolicina
			endif
			field->pnabavf += KALK->kolicina*nTC
		endif
		field->omprucf+=kalk->(kolicina*(nTC-nc))
	endif


elseif kalk->Pu_i=="3" .and. cC=="P" 
	
	// nivelacija - samo za prod.cijenu
	
	field->stanjef+=kalk->(kolicina*nTC)

	if kalk->datdok<=dDatOd
		field->zalihaf+=kalk->(kolicina*nTC)
	endif

	if KALK->mpcsapp>0
		field->povecanje+=kalk->(kolicina*nTC)
	else
		field->snizenje+=abs(kalk->(kolicina*nTC)) // apsolutno
	endif


elseif kalk->pu_i=="5"
	
	// izlaz iz prodavnice moze biti 42,41,11,12,13

	if !lK2X .or. !(roba->K2='X')
		field->stanjek-=kalk->kolicina
	endif
	field->stanjef-=kalk->kolicina*nTC

	if kalk->datdok <= dDatOd
		if !lK2X .or. !(roba->K2='X')
			field->zalihak-=kalk->kolicina
		endif
		field->zalihaf-=kalk->(kolicina*nTC)

	endif
	
	if lPrDatOd == .t.
		// prodaja 01.01
		if kalk->datdok >= dDatOd
			if kalk->idvd $ "41#42#43" // maloprodaja
				if !lK2X .or. !(roba->K2='X')
					field->prodajak+=kalk->kolicina
				endif
				field->prodajaf+=kalk->(kolicina*nTC)
				field->orucf+=kalk->(kolicina*(nTC-nc))
			endif
		endif
	else
		// prodaja 02.01
		if kalk->datdok > dDatOd
			if kalk->idvd $ "41#42#43" // maloprodaja
				if !lK2X .or. !(roba->K2='X')
					field->prodajak+=kalk->kolicina
				endif
				field->prodajaf+=kalk->(kolicina*nTC)
				field->orucf+=kalk->(kolicina*(nTC-nc))
			endif
		endif
	endif
endif 

return


static function GRekap22()
*{

// REKAP2 je gotova, formirati REKA22

nStavki:=0
SELECT rekap2
//g1+str(godina)+str(mjesec)
set order to TAG "3"

GO TOP
do while !EOF()
	
	cG1:=g1
	nZalihaF:=0
	nZalihaK:=0
	nNabavF:=0
	nNabavK:=0
	nPNabavF:=0
	nPNabavK:=0
	nProdajaF:=0
	nProdajaK:=0

	// matrica zaliha
	aZalihe:={}  
	nProdKumF:=0 
	nProdKumK:=0
	nPovecanje:=0
	nSnizenje:=0
	nStanjRF:=0
	nStanjRK:=0
	nORucF:=0
	nOMPRucF:=0
	nStanjeF:=0
	nStanjeK:=0
	
	SELECT rekap2

	do while (!EOF() .and. rekap2->g1==cG1)
		
		SELECT rekap2
		nMjesec:=rekap2->mjesec
		nGodina:=rekap2->godina
		
		do while ((!EOF() .and. rekap2->g1==cG1  .and. nMjesec==rekap2->mjesec .and. nGodina==rekap2->godina))
			
			if (YEAR(dDatOd)==Godina .and. MONTH(dDatOd)==mjesec)
				// samo je 01.98 mjesec poc zalihe
				nZalihaf+=zalihaf
				nZalihak+=zalihak
			endif
			
			nNabavF+=nabavf
			nNabavK+=nabavk
			nPNabavF+=pnabavf
			nPNabavK+=pnabavk
			nProdajaF+=prodajaf 
			nProdajaK+=prodajak
			nProdKumF+=ProdajaF
			nProdKumK+=Prodajak
			nStanjeF+=StanjeF
			nStanjeK+=StanjeK
			nStanjRF+=StanjRF
			nStanjRK+=StanjRK
			nPovecanje+=povecanje
			nSnizenje+=snizenje
			nORucF+=orucf
			nOMPRucF+=omprucf
			
			SELECT rekap2
			SKIP
			
		enddo

		if (YEAR(dDatOd)==rekap2->godina .and. MONTH(dDatOd)==rekap2->mjesec)
			if (round(nZalihaF,4)<>0 .and. IzFmkIni("Planika","ProsZalihaBezPocZalihe","D",KUMPATH)=="N")
				AADD(AZalihe,{nZalihaF,nZalihaK})  // poc zaliha
			endif
		endif
		if ROUND(nStanjef,4)<>0
			AADD(AZalihe,{nStanjeF,nStanjeK})
		endif
		
		// 01.01 - 30.09
		// znaci imamo 10 uzoraka: 01.01, 31.01, 31.02, ..., 30.09

	enddo
	
	SELECT reka22
	APPEND BLANK
	nProszalf:=0
	nProszalk:=0
	nKObrDan:=0
	nGKObr:=0

	if LEN(aZalihe)<>0
		for i:=1 to LEN(aZalihe)
			nProsZalf+=aZalihe[i,1]
			nProsZalk+=aZalihe[i,2]
		next
		nProsZalF:=nProsZalf/LEN(aZalihe)
		nProsZalk:=nProsZalk/LEN(aZalihe)
		if nProsZalF<>0
			nKobrDan := nProdKumf/nProsZalf
			nGKObr   := nKObrDan*12/LEN(aZalihe)
		endif
	endif

	REPLACE  g1 with cG1
	REPLACE zalihaf   with nZalihaF
	REPLACE nabavF   with nNabavF
	REPLACE pnabavF   with nPNabavF
	REPLACE prodajaF  with nProdajaF
	REPLACE stanjeF  with nStanjeF
	REPLACE stanjrF   with nStanjRF
	REPLACE orucf    with nORucf
	REPLACE omprucf   with nOMPRucf
	REPLACE proszalF  with nProsZalF
	REPLACE prodKumF with nProdKumF
	REPLACE povecanje with nPovecanje
	REPLACE snizenje with nSnizenje
	REPLACE KObrDan   with nKObrDan
	if (ABS(nGKObr) > 99999)
		MsgBeep("G. Koef obracuna za "+cG1+" "+STR(nGKOBr)+" ???")
		REPLACE GKObr  with 0
	else
		REPLACE GKObr    with nGKObr
	endif
	REPLACE zalihak   with nZalihak
	REPLACE nabavk   with nNabavk
	REPLACE pnabavk   with nPNabavk
	REPLACE prodajak  with nProdajak
	REPLACE stanjek  with nStanjek
	REPLACE stanjrk   with nStanjRk
	REPLACE prodKumk with nProdKumk
	REPLACE proszalk  with nProsZalK

	SELECT rekap2
enddo


return
*}
