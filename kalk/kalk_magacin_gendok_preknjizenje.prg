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


function GetPreknM()
*{
local aMag // matrica sa magacinima
local cMagKto // magacinski konto
local nUvecaj // uvecaj broj kalkulacije za
local cBrKalk // broj kalkulacije
local cMKonto
local nCnt
local cAkciznaRoba := "D"
Box(,6, 65)
	O_KONTO
	O_TARIFA
	cMagKto := SPACE(7)
	dDateOd := CToD("")
	dDateDo := DATE()
	cPTarifa := PADR("PDV17", 6)
	
	@ 1+m_x, 2+m_y SAY "Preknjizenje magacinskih konta"
	@ 3+m_x, 2+m_y SAY "Datum od" GET dDateOd 
	@ 3+m_x, col()+m_y SAY "datum do" GET dDateDo 
	@ 4+m_x, 2+m_y SAY "Magacinski konto (prazno-svi):" GET cMagKto VALID Empty(cMagKto) .or. P_Konto(@cMagKto)
	@ 5+m_x, 2+m_y SAY "Preknjizenje na tarifu:" GET cPTarifa VALID P_Tarifa(@cPTarifa)
	@ 6+m_x, 2+m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
	read
BoxC()
// prekini operaciju
if LastKey()==K_ESC
	return
endif

if Pitanje(,"Izvrsiti preknjizenje (D/N)?","D")=="N"
	return
endif

aMag:={}
if Empty(ALLTRIM(cMagKto))
	// napuni matricu sa magac kontima
	GetMagKto(@aMag)
else
	AADD(aMag, { cMagKto })
endif

// provjeri velicinu matrice
if LEN(aMag) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni preknjizenje
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Vrsim preknjizenje " + ALLTRIM(STR(LEN(aMag)))+ " magacina..."

O_KALK_DOKS

nUvecaj := 1
for nCnt:=1 to LEN(aMag)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDoc(gFirma, "16", nUvecaj)
	cMKonto:=aMag[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY "Magacin: " + ALLTRIM(cMKonto) + "   dokument: "+ gFirma + "-16-" + ALLTRIM(cBrKalk)
	
	GenPreknM(cMKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .f., DATE(), "", (cAkciznaRoba=="D") )
	++ nUvecaj
next

BoxC()

MsgBeep("Zavrseno filovanje pomocne tabele pokrecem obradu!")
// Automatska obrada dokumenata
// 0 - kreni od 0, .f. - ne pokreci asistenta
ObradiImport(0, .f., .f.)


return
*}


function GetPstPreknj()
*{
local aMag // matrica sa prodavnicama
local cMagKto // prodavnicki konto
local nUvecaj // uvecaj broj kalkulacije za
local cBrKalk // broj kalkulacije
local cMKonto
local nCnt
local cMTarifa := "PDV17 "
local cAkciznaRoba := "N"

if !IsPDV()
	MsgBeep("Opcija raspoloziva samo za PDV rezim rada !!!")
	return
endif

Box(,9, 65)
	O_KONTO
	O_TARIFA
	cMagKto := SPACE(7)
	dDateOd := CToD("")
	dDateDo := DATE()
	dDatPst := DATE()
	cSetCj := "1"
	
	@ 1+m_x, 2+m_y SAY "Generacija pocetnog stanja..."
	@ 3+m_x, 2+m_y SAY "Datum od" GET dDateOd 
	@ 3+m_x, col()+m_y SAY "datum do" GET dDateDo 
	@ 5+m_x, 2+m_y SAY "Datum pocetnog stanja" GET dDatPst 
	@ 6+m_x, 2+m_y SAY "Magacinski konto (prazno-svi):" GET cMagKto VALID Empty(cMagKto) .or. P_Konto(@cMagKto)
	@ 8+m_x, 2+m_y SAY "Ubaciti set cijena (0-nista/1/2) " GET cSetCj VALID !Empty(cSetCj) .and. cSetCj $ "01234"
	@ 9+m_x, 2+m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
	read
BoxC()
// prekini operaciju
if LastKey()==K_ESC
	return
endif

if Pitanje(,"Izvrsiti prenos poc.st. (D/N)?","D")=="N"
	return
endif

aMag:={}
if Empty(ALLTRIM(cMagKto))
	// napuni matricu sa magacinskim kontima
	GetMagKto(@aMag)
else
	AADD(aMag, { cMagKto })
endif

// provjeri velicinu matrice
if LEN(aMag) == 0
	MsgBeep("Ne postoje definisani magacini u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni preknjizenje
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Generisem pocetna stanja " + ALLTRIM(STR(LEN(aMag)))+ " magacini..."

O_KALK_DOKS


nUvecaj := 1
for nCnt:=1 to LEN(aMag)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDoc(gFirma, "16", nUvecaj)
	cMKonto:=aMag[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY "Magacin: " + ALLTRIM(cMKonto) + "   dokument: "+ gFirma + "-16-" + ALLTRIM(cBrKalk)
	// gen poc.st
	GenPreknM(cMKonto, cMTarifa, dDateOd, dDateDo, cBrKalk, .t., dDatPst, cSetCj, (cAkciznaRoba=="D") )
	
	++ nUvecaj
next

BoxC()

MsgBeep("Zavrseno filovanje pomocne tabele pokrecem obradu!")
// Automatska obrada dokumenata
ObradiImport(0, .f., .f.)

return
*}




/*! \fn GetMagKto(aMag)
 *  \brief Vrati matricu sa magacinima   
 *  \param aMag
 */
function GetMagKto(aMag)
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
	cTip := LEFT(cTip, 1) 
	// daj samo prvi karakter "M" ili "V"
	
	// ako je cTip V onda dodaj taj magacin
	if (cTip == "V") .and. !Empty(cKPath)
		AADD(aMag, { field->id })
	endif
	
	skip
enddo

return
*}


/*! \fn GenPreknM(cMKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst)
 *  \brief Opcija generisanja dokumenta preknjizenja
 *  \param cMKonto - magacinski  konto
 *  \param cPrTarifa - tarifa preknjizenja
 *  \param dDatOd - datum od kojeg se pravi preknjizenje
 *  \param dDatDo - datum do kojeg se pravi preknjizenje
 *  \param cBrKalk - broj kalkulacije
 *  \param lPst - pocetno stanje
 */
function GenPreknM(cMKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst, dDatPs, cCjSet, lAkciznaRoba)
*{
local cIdFirma
local nRbr
local fPocStanje:=.t.
local n_VpcBP_predhodna

if lPst
	O_ROBASEZ
	O_KALKSEZ
else
	O_KALK
endif

if lAkciznaRoba == NIL
	lAkciznaRoba := .f.
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

set order to tag "3"
//"4","idFirma+Mkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")
go top

HSEEK cIdfirma+cMKonto

select konto
HSEEK cMkonto
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
	cBrDok := PADR("POC.ST",10)
	// izvuci iz ovog dokumenta
 	cIzBrDok :=  PADR("PPP-PDV17",10)
	
	if lAkciznaRoba
		cBrDok := PADR("POC.ST.AK",10)
		// izbuci iz ovog dokumenta
		cIzBrDok := PADR("PPP-PDV.AK",10)
	endif
else
 	cBrDok :=  PADR("PPP-PDV17", 10)
	if lAkciznaRoba
		cBrDok := PADR("PPP-PDV.AK", 10)
	endif
endif

do while !eof() .and. cIdFirma+cMKonto==idfirma+Mkonto .and. IspitajPrekid()
	cIdRoba:=Idroba
	
	if lPst
		select robasez
	else
		select roba
	endif
	HSEEK cIdRoba

	if FIELDPOS("ZANIV2") <> 0
		nAkcizaPorez := zaniv2
	else
		nAkcizaPorez := 0
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

	nUlaz:=0
	nIzlaz:=0
	
	nVpvU:=0
	nVpvI:=0
	nNVU:=0
	nNVI:=0
	
	nRabat:=0
	
		
	do while !eof() .and. cIdFirma+cMKonto+cIdRoba==idFirma+mkonto+idroba
  		
		if  (IdVd == "16") .and. (BrFaktP == cIzBrDok) .and. (kolicina>0)
			// pozitivna stavka 16-ke
			pl_nc := nc
			pl_vpc := vpc
			pl_kolicina := kolicina
		else
			if lPst
			  SKIP
			  LOOP
			endif
		endif
			
			
		
		// provjeri datumski
		if (datdok < dDatOd) .or. (datdok > dDatDo)
      			skip
      			loop
    		endif

  		if datdok >= dDatOd  // nisu predhodni podaci

			nKol := kolicina-gkolicina-gkolicin2
			
		        if mu_i == "1" 
			    if  (idvd $ "12#22#94")
			     // povrat
		             nIzlaz += -nKol
			     nVpvI += vpc * -nKol
			     nNvI += nc * -nKol
			    else
			     nUlaz += nKol
			     nVpvU += vpc * nKol
			     nNvU += nc * nKol
			    endif
			  
                        elseif mu_i== "5"
		             
			     nIzlaz += nKol
			     nVpvI += vpc * nKol
			     nNvI += nc * nKol
		       
			elseif mu_i == "3"
			      // nivelacija
			      nVpvU += vpc * nKol

			endif
  		endif
		skip
	enddo
	
	if Round(nVpvU-nVpvI, 4) <> 0 
  		select pript

		// MPC bez poreza u + stavci
		n_VpcBP_predhodna := 0
  		if round(nUlaz-nIzlaz,4)<>0
     			if !lPst
				// prva stavka stara tarifa
				append blank
				++ nRbr
     				replace idFirma with cIdfirma
     				replace brfaktp with cBrDok
				replace idroba with cIdRoba
				replace rbr with RedniBroj(nRbr)
				replace idkonto with cMKonto
				replace pkonto with cMKonto
				replace datdok with dDatDo
				replace mu_i with "1"
				replace error with "0"
				replace idTarifa with Tarifa("", cIdRoba, @aPorezi)
				replace datfaktp with dDatDo
				// promjeni predznak kolicine
				replace kolicina with -(nUlaz-nIzlaz)
				replace idvd with "16"
				replace brdok with cBrKalk
				replace nc with (nNVU-nNVI)/(nUlaz-nIzlaz)
				
				replace vpc with (nVPVU-nVPVI)/(nUlaz-nIzlaz)
				
				replace marza with vpc-nc
				replace tMarza with "A"
				
				n_VpcBP_predhodna := vpc

				if lAkciznaRoba
				   n_VpcBP_predhodna := vpc - nAkcizaPorez
				   if (n_VpcBP_predhodna <= 0)
				   	MsgBeep( ;
					 "Akcizna roba :  " + cIdRoba + " nelogicno ##- mpc bez akciznog poreza < 0 :# VPC b.p:"+ ;
					STR( n_VpcBP_predhodna, 6, 2) + "/ AKCIZA:" +;
					STR( nAkcizaPorez, 6, 2) )
				   endif
				   
				endif
				
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
			replace idkonto with cMKonto
			replace mkonto with cMKonto
			replace mu_i with "1"
			replace error with "0"
			if lPst
				replace datdok with dDatPst
			else
				replace datdok with dDatDo
			endif
			
			replace idTarifa with Tarifa( "", cIdRoba, @aPorezi, cPrTarifa)
			
			if lPst
				replace datfaktp with dDatPst
			else
				replace datfaktp with dDatDo
			endif
			
			replace kolicina with nUlaz-nIzlaz
			replace idvd with "16"
			replace brdok with cBrKalk
			replace nc with (nNVU-nNVI)/(nUlaz-nIzlaz)

			
			if !lPst 
				replace vpc with n_VpcBP_predhodna

				if lAkciznaRoba
					// i nabavna cijena je manja
					// jer ovaj porez vise nije troskovna
					// stavka kao sto je bio u rezimu PPP-a
					replace nc with nc - nAkcizaPorez
				endif
				
			else
			        // izvuci iz 16-ke u sezonskom podrucju podatke
				if pl_kolicina > 0
				    replace vpc with pl_vpc,;
					nc with pl_nc,;
					tmarza with "A",;
					marza with pl_vpc - pl_nc,;
					kolicina with pl_kolicina
				endif
				
			endif
			
			
			if lPst
				if ROUND(pl_kolicina,4) <> 0
  				  nNVpcBezPdv := pl_vpc
			
     				  // ubaci novu vpc u sifrarnik robe
				  // ubaci novu tarifu robe

				  select roba
				  HSEEK cIdRoba
				
				  if cCjSet == "1"
					replace vpc with nNVpcBezPdv
				  endif
				
				  if cCjSet == "2"
					replace vpc2 with nNVpcBezPdv
				  endif

				  replace idtarifa with "PDV17 " 	
				endif
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

