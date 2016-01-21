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


#include "f18.ch"

*array
static aPorezi:={}
*;


function GetPreknj()
*{
local aProd // matrica sa prodavnicama
local cProdKto // prodavnicki konto
local nUvecaj // uvecaj broj kalkulacije za
local cBrKalk // broj kalkulacije
local cPKonto
local nCnt
local cAkciznaRoba := "N"
local cZasticeneCijene := "N"
Box(,7, 65)
	O_KONTO
	O_TARIFA
	cProdKto := SPACE(7)
	dDateOd := CToD("")
	dDateDo := DATE()
	cPTarifa := PADR("PDV17", 6)
	
	@ 1+m_x, 2+m_y SAY "Preknjizenje prodavnickih konta"
	@ 3+m_x, 2+m_y SAY "Datum od" GET dDateOd 
	@ 3+m_x, col()+m_y SAY "datum do" GET dDateDo 
	@ 4+m_x, 2+m_y SAY "Prodavnicki konto (prazno-svi):" GET cProdKto VALID Empty(cProdKto) .or. P_Konto(@cProdKto)
	@ 5+m_x, 2+m_y SAY "Preknjizenje na tarifu:" GET cPTarifa VALID P_Tarifa(@cPTarifa)
	@ 6+m_x, 2+m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
	@ 7+m_x, 2+m_y SAY "Artikli sa zasticenim cijenama " GET cZasticeneCijene VALID cZasticeneCijene $ "DN" PICT "@!"
	read
BoxC()
// prekini operaciju
if LastKey()==K_ESC
	return
endif

if Pitanje(,"Izvrsiti preknjizenje (D/N)?","D")=="N"
	return
endif

aProd:={}
if Empty(ALLTRIM(cProdKto))
	// napuni matricu sa prodavnckim kontima
	GetProdKto(@aProd)
else
	AADD(aProd, { cProdKto })
endif

// provjeri velicinu matrice
if LEN(aProd) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni preknjizenje
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Vrsim preknjizenje " + ALLTRIM(STR(LEN(aProd)))+ " prodavnice..."

O_KALK_DOKS

nUvecaj := 1
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDoc(gFirma, "80", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY "Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-80-" + ALLTRIM(cBrKalk)
	
	GenPreknj(cPKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .f., DATE(), "", (cAkciznaRoba=="D"), (cZasticeneCijene=="D") )
	++ nUvecaj
next

BoxC()

MsgBeep("Zavrseno filovanje pomocne tabele pokrecem obradu!")
// Automatska obrada dokumenata
// 0 - kreni od 0, .f. - ne pokreci asistenta
ObradiImport(0, .f., .f.)


return
*}


function GetPstPDV()
*{
local aProd // matrica sa prodavnicama
local cProdKto // prodavnicki konto
local nUvecaj // uvecaj broj kalkulacije za
local cBrKalk // broj kalkulacije
local cPKonto
local nCnt
local cPTarifa := "PDV17 "
local cAkciznaRoba := "N"
local cZasticeneCijene := "N"

if !IsPDV()
	MsgBeep("Opcija raspoloziva samo za PDV rezim rada !!!")
	return
endif

Box(,10, 65)
	O_KONTO
	O_TARIFA
	cProdKto := SPACE(7)
	dDateOd := CToD("")
	dDateDo := DATE()
	dDatPst := DATE()
	cSetCj := "1"
	
	@ 1+m_x, 2+m_y SAY "Generacija pocetnog stanja..."
	@ 3+m_x, 2+m_y SAY "Datum od" GET dDateOd 
	@ 3+m_x, col()+m_y SAY "datum do" GET dDateDo 
	@ 5+m_x, 2+m_y SAY "Datum pocetnog stanja" GET dDatPst 
	@ 6+m_x, 2+m_y SAY "Prodavnicki konto (prazno-svi):" GET cProdKto VALID Empty(cProdKto) .or. P_Konto(@cProdKto)
	@ 8+m_x, 2+m_y SAY "Ubaciti set cijena (0-nista/1-mpc/2-mpc2) " GET cSetCj VALID !Empty(cSetCj) .and. cSetCj $ "0123"
	@ 9+m_x, 2+m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
	@ 10+m_x, 2+m_y SAY "Artikli sa zasticenim cijenama " GET cZasticeneCijene VALID cZasticeneCijene $ "DN" PICT "@!"
	read
BoxC()
// prekini operaciju
if LastKey()==K_ESC
	return
endif

if Pitanje(,"Izvrsiti prenos poc.st. (D/N)?","D")=="N"
	return
endif

aProd:={}
if Empty(ALLTRIM(cProdKto))
	// napuni matricu sa prodavnckim kontima
	GetProdKto(@aProd)
else
	AADD(aProd, { cProdKto })
endif

// provjeri velicinu matrice
if LEN(aProd) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni preknjizenje
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Generisem pocetna stanja " + ALLTRIM(STR(LEN(aProd)))+ " prodavnice..."

O_KALK_DOKS


nUvecaj := 1
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDoc(gFirma, "80", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY "Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-80-" + ALLTRIM(cBrKalk)
	// gen poc.st
	GenPreknj(cPKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .t., dDatPst, cSetCj, (cAkciznaRoba=="D"), (cZasticeneCijene=="D") )
	
	++ nUvecaj
next

BoxC()

MsgBeep("Zavrseno filovanje pomocne tabele pokrecem obradu!")
// Automatska obrada dokumenata
ObradiImport(0, .f., .f.)

return
*}




/*! \fn GetProdKto(aProd)
 *  \brief Vrati matricu sa prodavnicama
 *  \param aProd
 */
function GetProdKto(aProd)
*{
local cTip
local cKPath

// KONCIJ polja za provjeru
// ============
// ID - konto
// NAZ - tip M1, M2
// KUMTOPS - lokacija kumulativa tops

O_KONCIJ
select koncij
go top
do while !EOF()
	cTip := ALLTRIM(field->naz)
	cTip := LEFT(cTip, 1) // daj samo prvi karakter "M" ili "V"
	cKPath := ALLTRIM(field->KUMTOPS)
	
	// ako je cTip M onda dodaj tu prodavnicu
	if (cTip == "M") .and. !Empty(cKPath)
		AADD(aProd, { field->id })
	endif
	
	skip
enddo

return
*}


function roba_pdv17()
*{
if !IsPDV()
	MsgBeep("Opcija raspoloziva samo za PDV rezim!")
	return
endif

MsgO("Setujem tarifa PDV17...")
O_ROBA
SET ORDER TO
go TOP
do while !eof()
   if IsPDV() 
   	// prelazak na PDV 01.01.2006
	replace IDTARIFA with "PDV17"
   endif
   
   SKIP
enddo
MsgC()
return
*}


/*! \fn GenPreknj(cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst)
 *  \brief Opcija generisanja dokumenta preknjizenja
 *  \param cPKonto - prodavnicki konto
 *  \param cPrTarifa - tarifa preknjizenja
 *  \param dDatOd - datum od kojeg se pravi preknjizenje
 *  \param dDatDo - datum do kojeg se pravi preknjizenje
 *  \param cBrKalk - broj kalkulacije
 *  \param lPst - pocetno stanje
 */
function GenPreknj(cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst, dDatPs, cCjSet, lAkciznaRoba, lZasticeneCijene)
*{
local cIdFirma
local nRbr
local fPocStanje:=.t.
local n_MpcBP_predhodna
local nAkcizaPorez
local nZasticenaCijena

if lPst
	O_ROBASEZ
	O_KALKSEZ
else
	O_KALK
endif

if lAkciznaRoba == NIL
	lAkciznaRoba := .f.
endif
if lZasticeneCijene == NIL
	lZasticeneCijene := .f.
endif


O_ROBA
O_KONTO
O_KONCIJ
O_TARIFA
O_PRIPT // pomocna tabela pript

cIdFirma:=gFirma

if lPst
	select kalksez
else
	select kalk
endif

set order to tag "4"
//"4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")
go top

hseek cIdfirma+cPKonto

select konto
hseek cPKonto
if lPst
	select kalksez
else
	select kalk
endif

nTUlaz:=0
nTIzlaz:=0
nTPKol:=0
nTMPVU:=0
nTMPVI:=0
nTNVU:=0
nTNVI:=0
nRbr:=0


//nemoguca kombinacija
cIzBrDok := "#X43432032032$#$#"

if lPst
	cBrDok := PADR("POC.ST", 10)
	// izvuci iz ovog dokumenta
 	cIzBrDok :=  PADR("PPP-PDV17", 10)
	
	if lAkciznaRoba
		cBrDok := PADR("POC.ST.AK", 10)
		// izbuci iz ovog dokumenta
		cIzBrDok := PADR("PPP-PDV.AK", 10)
	endif

	if lZasticeneCijene
		cBrDok := PADR("POC.ST.AZ", 10)
		// izbuci iz ovog dokumenta
		cIzBrDok := PADR("PPP-PDV.AZ", 10)
	endif

else
 	cBrDok :=  PADR("PPP-PDV17", 10)
	if lAkciznaRoba
		cBrDok := PADR("PPP-PDV.AK", 10)
	endif

	if lZasticeneCijene
		cBrDok := PADR("PPP-PDV.AZ", 10)
	endif
endif

do while !eof() .and. cIdFirma+cPKonto==idfirma+pkonto .and. IspitajPrekid()
	cIdRoba:=Idroba
	
	if lPst
		select robasez
	else
		select roba
	endif
	hseek cIdRoba

	if FIELDPOS("ZANIV2") <> 0
		nAkcizaPorez := zaniv2
	else
		nAkcizaPorez := 0
	endif
	
	if FIELDPOS("ZANIVEL") <> 0
		nZasticenaCijena := zanivel
	else
		nZasticenaCijena := 0
	endif

	if lZasticeneCijene 
		if (nZasticenaCijena == 0)
			// ovo nije zasticeni artikal
			// posto mu nije setovana zasticena cijena
			//
			if lPst
				select kalksez
			else
				select kalk
			endif
			skip
			loop
		endif

	else
		if (nZasticenaCijena <> 0)
			// ovo je zasticeni artikal
			// a mi sada ne zelimo preknjizenje ovih artikala
			if lPst
				select kalksez
			else
				select kalk
			endif
			skip
			loop
		endif

	endif


	if lPst
		select kalksez
	else
		select kalk
	endif


	if lAkciznaRoba
		if (nAkcizaPorez == 0)
			// samo akcizna roba
			skip
			loop
		endif
	else
		if (nAkcizaPorez <> 0)
			// necemo akciznu robu
			skip
			loop
		endif
		
	endif

	nPKol:=0
	nPNV:=0
	nPMPV:=0
	nUlaz:=0
	nIzlaz:=0
	nMPVU:=0
	nMPVI:=0
	nNVU:=0
	nNVI:=0
	nRabat:=0
	
	// usluge
	if lPst
		if robasez->tip $ "TU"
			skip
			loop
		endif
	else
		if roba->tip $ "TU"
			skip
			loop
		endif
	endif
		
	do while !eof() .and. cIdFirma+cPKonto+cIdRoba==idFirma+pkonto+idroba
  		
		if  (IdVd == "80") .and. (BrFaktP == cIzBrDok) .and. (kolicina>0)
			// pozitivna stavka 80-ke
			pl_mpc := mpc
			pl_mpcSaPP := mpcSaPP
			pl_kolicina := kolicina
			pl_nc := nc
		endif
			
			
		
		// provjeri datumski
		if (field->datdok < dDatOd) .or. (field->datdok > dDatDo)
      			skip
      			loop
    		endif

  		if lPst
			if robasez->tip $ "TU"
				skip
				loop
			endif
		else
			if roba->tip $ "TU"
  				skip
				loop
  			endif
		endif
		
  		if field->datdok >= dDatOd  // nisu predhodni podaci
  			if field->pu_i=="1"
    				SumirajKolicinu(kolicina, 0, @nUlaz, 0, .t.)
    				nMPVU += mpcsapp*kolicina
    				nNVU += nc*(kolicina)
				
  			elseif field->pu_i=="5"
    				if idvd $ "12#13"
     					SumirajKolicinu(-kolicina, 0, @nUlaz, 0, .t.)
     					nMPVU -= mpcsapp*kolicina
     					nNVU -= nc*kolicina
    				else
     					SumirajKolicinu(0, kolicina, 0, @nIzlaz, .t.)
     					nMPVI += mpcsapp*kolicina
     					nNVI += nc*kolicina
    				endif

  			elseif field->pu_i=="3"   
			        // nivelacija
    				nMPVU += mpcsapp*kolicina
  			elseif field->pu_i=="I"
    				SumirajKolicinu(0, gkolicin2, 0, @nIzlaz, .t.)
    				nMPVI += mpcsapp*gkolicin2
    				nNVI += nc*gkolicin2
			endif
  		endif
		skip
	enddo
	
	if Round(nMPVU-nMPVI+nPMPV,4) <> 0 
  		select pript

		// MPC bez poreza u + stavci
		n_MpcBP_predhodna := 0
  		if round(nUlaz-nIzlaz,4)<>0
     			if !lPst
				// prva stavka stara tarifa
				append blank
				++ nRbr
     			replace idFirma with cIdfirma
     			replace brfaktp with cBrDok
				replace idroba with cIdRoba
				replace rbr with RedniBroj(nRbr)
				replace idkonto with cPKonto
				replace pkonto with cPKonto
				replace datdok with dDatDo
				replace pu_i with "1"
				replace error with "0"
				replace idTarifa with Tarifa(cPKonto, cIdRoba, @aPorezi)
				replace datfaktp with dDatDo
				// promjeni predznak kolicine
				replace kolicina with -(nUlaz-nIzlaz)
				replace idvd with "80"
				replace brdok with cBrKalk
				replace nc with (nNVU-nNVI+nPNV)/(nUlaz-nIzlaz+nPKol)
				//replace mpcsapp with nStCijena
				replace mpcsapp with (nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol)
				replace vpc with nc
				replace TMarza2 with "A"
				// setuj marzu i mpc
				Scatter()
				if WMpc_lv(nil, nil, aPorezi)
					VMpc_lv(nil, nil, aPorezi)
					VMpcSaPP_lv(nil, nil, aPorezi, .f.)
				endif
				
				// uzmi cijenu bez poreza za + stavku
				n_MpcBP_predhodna := _mpc

				if lAkciznaRoba 
				   n_MpcBP_predhodna := _mpc - nAkcizaPorez
				   if (n_MpcBP_predhodna <= 0)
				   	MsgBeep( ;
					 "Akcizna roba :  " + cIdRoba + " nelogicno ##- mpc bez akciznog poreza < 0 :# MPC b.p:"+ ;
					STR( n_MpcBP_predhodna, 6, 2) + "/ AKCIZA:" +;
					STR( nAkcizaPorez, 6, 2) )
				   endif
				   
				endif
				
				Gather()
				
			endif
			
			// resetuj poreze
			aPorezi := {}	
			
			// kontra stavka PDV tarifa
			append blank
			++nRbr
     			replace idFirma with cIdfirma

			
 			replace brfaktp with cBrDok
			replace idroba with cIdRoba
			replace rbr with RedniBroj(nRbr)
			replace idkonto with cPKonto
			replace pkonto with cPKonto
			replace pu_i with "1"
			replace error with "0"
			if lPst
				replace datdok with dDatPst
			else
				replace datdok with dDatDo
			endif
			
			replace idTarifa with Tarifa(cPKonto, cIdRoba, @aPorezi, cPrTarifa)
			
			if lPst
				replace datfaktp with dDatPst
			else
				replace datfaktp with dDatDo
			endif
			
			replace kolicina with nUlaz-nIzlaz
			replace idvd with "80"
			replace brdok with cBrKalk
			replace nc with (nNVU-nNVI+nPNV)/(nUlaz-nIzlaz+nPKol)

			
			if !lPst 
				//replace mpc with n_MpcBP_predhodna := _mpc
				_mpc := n_MpcBP_predhodna
				replace mpc with _mpc

				if lAkciznaRoba
					// i nabavna cijena je manja
					// jer ovaj porez vise nije troskovna
					// stavka kao sto je bio u rezimu PPP-a
					replace nc with nc - nAkcizaPorez
				endif

				// formiraj mpc bez poreza na osnovu
				// zasticene cijene
				if lZasticeneCijene
					replace mpcSapp with nZasticenaCijena, ;
						mpc with 0
				endif
					
				
			else
				// "sasin" algoritam - ispocetka racunaj poc.st
				if !lAkciznaRoba
			 		replace mpcsapp with (nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol)
				else
				        // izvuci iz 80-ke u seznoskom podrucju podatke
					_mpc := pl_mpc
					_mpcSaPP := pl_mpcSaPP
					_nc := pl_nc
					_kolicina := pl_kolicina
					
					replace mpcsapp with pl_mpcSaPP,;
						mpc with pl_mpc,;
						nc with pl_nc,;
						kolicina with pl_kolicina
				
				endif
			endif
			
			replace vpc with nc
			replace TMarza2 with "A"
			// setuj marzu i MPC
			Scatter()
			if WMpc_lv(nil, nil, aPorezi)
				VMpc_lv(nil, nil, aPorezi)
				VMpcSaPP_lv(nil, nil, aPorezi, .f.)
			endif
			
			if lPst
				nNMpcSaPDV := _mpcsapp
			endif
			
			Gather()
			
			// ubaci novu mpc u sifrarnik robe
			// ubaci novu tarifu robe

			if lPst
				select roba
				hseek cIdRoba

				if cCjSet == "0"
					// nista - cijene se ne diraju		
				endif
				
				if cCjSet == "1"
					replace mpc with nNMpcSaPDV
				endif
				
				if cCjSet == "2"
					replace mpc2 with nNMpcSaPDV
				endif

				if cCjSet == "3"
					replace mpc3 with nNMpcSaPDV
				endif
				
				replace idtarifa with "PDV17 " 	
			endif
			
		endif
  		
		if lPst
			select kalksez
		else
			select kalk
		endif
	endif
	
	if lPst
		select kalksez
	else
		select kalk
	endif
	
enddo

return
*}

