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


function get_nivel_p()
*{
local aProd // matrica sa prodavnicama
local cProd // prodavnica
local cPKonto
local dDatDok
local cGlStanje:="D"


O_KONTO

Box(,4,70)
	cProd:=SPACE(7)
	dDatDok:=date()
	@ m_x+1,m_Y+2 SAY "Prodavnica (prazno-sve)" GET cProd VALID Empty(cProd) .or. P_Konto(@cProd)
	@ m_x+2,m_Y+2 SAY "Datum" GET dDatDok
	@ m_x+3,m_Y+2 SAY "Nivelisati samo robu na stanju (D/N)?" GET cGlStanje VALID cGlStanje $ "DN" PICT "@!"
	read
	ESC_BCR
BoxC() 

if Pitanje(,"Generisati nivelacije (D/N)?","D") == "N"
	return
endif

aProd:={}

if Empty(ALLTRIM(cProd))
	// napuni matricu sa prodavnckim kontima
	GetProdKto(@aProd)
else
	AADD(aProd, { cProd })
endif

// provjeri velicinu matrice
if LEN(aProd) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

lGlStanje := .t.

if cGlStanje == "N"
	lGlStanje := .f.
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni generisanje nivelacija
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Vrsim generisanje nivelacije za " + ALLTRIM(STR(LEN(aProd)))+ " prodavnicu..."

O_KALK_DOKS

nUvecaj := 1
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDoc(gFirma, "19", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY STR(nCnt, 3) + " Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-19-" + ALLTRIM(cBrKalk)
	
	gen_nivel_p(cPKonto, dDatDok, cBrKalk, lGlStanje)
	
	++ nUvecaj
next

BoxC()

result_nivel_p()

return



function get_zcnivel()
local aProd // matrica sa prodavnicama
local cProd // prodavnica
local cPKonto
local dDatDok

O_KONTO

Box(,4,70)
	cProd:=SPACE(7)
	dDatDok:=date()
	@ m_x+1,m_Y+2 SAY "Prodavnica (prazno-sve)" GET cProd VALID Empty(cProd) .or. P_Konto(@cProd)
	@ m_x+2,m_Y+2 SAY "Datum" GET dDatDok
	read
	ESC_BCR
BoxC() 

if Pitanje(,"Generisati nivelacije (D/N)?","D") == "N"
	return
endif

aProd:={}

if Empty(ALLTRIM(cProd))
	// napuni matricu sa prodavnckim kontima
	GetProdKto(@aProd)
else
	AADD(aProd, { cProd })
endif

// provjeri velicinu matrice
if LEN(aProd) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni generisanje nivelacija
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Vrsim generisanje nivelacije za " + ALLTRIM(STR(LEN(aProd)))+ " prodavnicu..."

O_KALK_DOKS

nUvecaj := 1
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDoc(gFirma, "19", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY STR(nCnt, 3) + " Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-19-" + ALLTRIM(cBrKalk)
	
	gen_zcnivel(cPKonto, dDatDok, cBrKalk)
	
	++ nUvecaj
next

BoxC()

result_nivel_p()

return


// --------------------------------------------------------------------
// generisanje nivalacije za prodavnicu
//  cPKonto - prodavnicki konto
//  dDatDok - datum dokumenta nivelacije
//  cBrKalk - broj dokumenta nivelacije
//  lGledajStanje - .t. - gledaj sta je na stanju pa to nivelisi
// --------------------------------------------------------------------
function gen_nivel_p(cPKonto, dDatDok, cBrKalk, lGledajStanje)
local nRbr
local cIdFirma 
local cIdVd
local cIdRoba
local nNivCijena
local nStCijena

O_PRIPT
O_KALK
O_ROBA
O_KONTO
O_KONCIJ
O_TARIFA

nRbr:=0

cIdFirma := gFirma

select koncij
seek TRIM(cPKonto)

select roba
set order to tag "ID"
go top
do while !eof()

	// provjeri polje ROBA->ZANIVEL
	// ako je prazno preskoci
	if field->tip $ "UT"
		skip
		loop
	endif
	
	if Round(field->zanivel,4) == 0
		skip
		loop
	endif
	
	cIdRoba:=field->id
	nNivCijena:=field->zanivel
	// uzmi MPC iz sifrarnika
	nStCijena:=UzmiMpcSif()

	nUlaz:=0
	nIzlaz:=0

	select kalk
	set order to tag "4"
	//"KALKi4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")
	
	seek cIdFirma + cPkonto + cIdRoba

	do while !EOF() .and. cIdFirma + cPKonto + cIdRoba == field->idFirma + field->pkonto + field->idroba
	
		if field->datdok > dDatDok  // preskoci
      			skip
			loop
  		endif

  		if pu_i=="1"
    			nUlaz+=kolicina-GKolicina-GKolicin2
		elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    			nIzlaz+=kolicina
		elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
    			nUlaz-=kolicina
		elseif pu_i=="3"    // nivelacija
    			//nMPVU+=mpcsapp*kolicina
		elseif pu_i=="I"
    			nIzlaz+=gkolicin2
  		endif
		
		skip
	enddo // po orderu 4

	// ako je Stanje <> 0 preskoci
	if Round(nUlaz-nIzlaz,4) == 0
		if lGledajStanje
			select roba
			skip
			loop
		endif
	endif

	// upisi u pript
	select pript
 	//scatter()
 	//append ncnl
	append blank
	Scatter()
 	_idfirma := cIdFirma
	_idkonto := cPKonto
	_pkonto := cPKonto
	_pu_i := "3"
 	_idroba := cIdRoba
	_idtarifa := Tarifa(cPKonto, cIdRoba, @aPorezi, roba->idtarifa)
 	_idvd := "19"
	_brdok := cBrKalk
 	_tmarza2 := "A"
	_rbr := RedniBroj(++nRbr)
 	_kolicina := nUlaz-nIzlaz
 	_datdok := dDatDok
	_datfaktp := dDatDok
	_MPCSaPP := nNivCijena - nStCijena
	_MPC := 0
	_fcj := nStCijena
	_mpc := MpcBezPor(nNivCijena, aPorezi, , _nc) - MpcBezPor(nStCijena, aPorezi, , _nc)
	
	_error := "0"
	
	Gather()

	select roba
	skip
enddo
 
return


// prebaci iz zanivel2 u zanivel
function zaniv2_zaniv()

if !SigmaSif("NIVEL")
	MsgBeep("Ne cackaj!")
	return
endif

MsgBeep("Ova opcija ce kopirati postojece vrijednosti polja N.CIJENA 2#u polje N.CIJENA 1!")

if Pitanje(,"Kopirati vrijednosti","N") == "N"
	return
endif

if !USED(F_ROBA)
	O_ROBA
endif

select roba
set order to tag "ID"
go top

Box(,3, 70)
do while !EOF()

	if ROUND(field->zaniv2, 4) == 0
		skip
		loop
	endif
	
	@ 1+m_x, 2+m_y SAY "ID roba: " + field->id
	
	replace zanivel with zaniv2
	
	@ 2+m_x, 2+m_y SAY "Update cijena " + ALLTRIM(STR(field->zanivel)) 	
	skip
enddo

BoxC()


MsgBeep("Zavrseno kopiranje !")

return



// ----------------------------------------------
// setuj mpc na osnovu postojeceg polja
// ----------------------------------------------
function set_mpc_2()
local cSetCj := "3"
local cUzCj := "1"
local nUvecaj := 0
local nZaok := 2

if !SigmaSif("SETMPC")
	MsgBeep("Ne cackaj!")
	return
endif

box(, 4, 55)
	
	@ m_x + 1, m_y + 2 SAY "        Setuj MPC (1,2,3):" GET cSetCj ;
		VALID cSetCj $ "12345"
	@ m_x + 2, m_y + 2 SAY "    Na osnovu MPC (1,2,3):" GET cUzCJ ;
		VALID cUzCj $ "12345"
	@ m_x + 3, m_y + 2 SAY "                   za (%):" GET nUvecaj ;
		PICT "999.999"
	@ m_x + 4, m_y + 2 SAY "  novu cijenu zaokruzi na:" GET nZaok ;
		PICT "9"
	read
boxc()


if nUvecaj = 0 .or. Pitanje(,"Setovati cijene","N") == "N"
	return
endif

if !USED(F_ROBA)
	O_ROBA
endif

if cUzCj == "1"
	cUField := "MPC"
else
	cUField := "MPC" + cUzCj
endif

if cSetCj == "1"
	cSField := "MPC"
else
	cSField := "MPC" + cSetCj
endif

select roba
set order to tag "ID"
go top

Box(,1, 70)

do while !EOF()

	// ako je uzorak cijena = 0 preskoci
	if &cUField = 0
		skip
		loop
	endif
	
	@ 1 + m_x, 2 + m_y SAY "ID roba: " + field->id
	
	replace &cSField with ROUND( &cUField * nUvecaj, nZaok )
	
	skip
enddo

BoxC()

MsgBeep("Zavrseno setovanje cijena!")

return




// setuj mpc iz polja zanivel nakon nivelacije
function set_mpc_iz_zanivel()
local cSetCj := "1"


if !SigmaSif("SETMPC")
	MsgBeep("Ne cackaj!")
	return
endif

MsgBeep("Ova opcija se iskljucivo pokrece#nakon obradjenih nivelacija!")


box(, 1, 55)
	@ m_x + 1, m_y + 2 SAY "Setovati MPC(1, 2, 3, 4) ?" GET cSetCj VALID cSetCj $ "12345"
	
	read
boxc()


if Pitanje(,"Setovati nove cijene","N") == "N"
	return
endif

if !USED(F_ROBA)
	O_ROBA
endif


if cSetCj == "1"
	cField := "MPC"
else
	cField := "MPC" + cSetCj
endif

select roba
set order to tag "ID"
go top

Box(,3, 70)
do while !EOF()

	if ROUND(field->zanivel, 4) == 0
		skip
		loop
	endif
	
	@ 1+m_x, 2+m_y SAY "ID roba: " + field->id
	
	// sacuvaj backup u zaniv2
	replace zaniv2 with &cField
	// prebaci iz zanivel u mpc
	replace &cField with zanivel
	
	@ 2+m_x, 2+m_y SAY "Update cijena " + ALLTRIM(STR(field->zanivel)) + " -> " + ALLTRIM(STR( &cField ))
	
	skip
enddo

BoxC()

MsgBeep("Zavrseno setovanje cijena!")

return



// generisanje nivelacije sa zadzavanjem cijena
function gen_zcnivel(cPKonto, dDatDok, cBrKalk)
*{
local nRbr
local cIdFirma 
local cIdVd
local cIdRoba
local cIdTarifa
local nNivCijena
local nStCijena

O_PRIPT
O_KALK
O_ROBA
O_KONTO
O_KONCIJ
O_TARIFA

nRbr:=0

cIdFirma := gFirma

select koncij
seek TRIM(cPKonto)


select kalk
set order to tag "4"
go top
//"KALKi4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")
	
seek cIdFirma + cPkonto

do while !EOF() .and. cIdFirma + cPKonto == field->idFirma + field->pkonto 
	
	cIdRoba:=field->idroba
	
	nUlaz:=0
	nIzlaz:=0

	do while !EOF() .and. cIdFirma + cPKonto + cIdRoba == field->idfirma + field->pkonto + field->idroba
		
		if field->datdok > dDatDok
		        // preskoci
			skip
			loop
		endif

		if pu_i=="1"
			nUlaz+=kolicina-GKolicina-GKolicin2
		elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    			nIzlaz+=kolicina
		elseif pu_i=="5"  .and. (idvd $ "12#13#22")    
		        // povrat
    			nUlaz -= kolicina
		elseif pu_i=="3"    
		        // nivelacija
    			//nMPVU+=mpcsapp*kolicina
		elseif pu_i=="I"
    			nIzlaz += gKolicin2
  		endif
		
		skip
	
	enddo 

	// ako je Stanje <> 0 preskoci
	if Round (nUlaz-nIzlaz, 4) == 0
		select kalk
		loop
	endif

	// nadji robu
	select roba
	set order to tag "ID"
	hseek cIdRoba
        cIdTarifa := roba->idtarifa
	
	// nadji tarifu
	select tarifa
	set order to tag "ID"
	hseek cIdTarifa
	nTarStopa := tarifa->opp
	
	select kalk

	// stara cijena !!!
	// ako KARTICA NE VALJA OVAJ DOKUMENT NECE VALJATI
	// prije pokretanja ove nivelacije mora se provjeriti 
	// da li ima ERR na lager listi !!!!!
	// ako ima mora se ta greska ispraviti
	nStCijena := roba->mpc
	
	// maloprodajna cijena bez poreza PP
	nMpcbpPP := nStCijena / (1 + (nTarStopa / 100))
	// maloprodajna cijena bez poreza PDV
	nMpcbpPDV := nStCijena / (1 + (17 / 100))
	
	// razlika bez poreza
	nCRazlbp := nMpcbpPDV - nMpcbpPP
	// razlika sa uracunatim porezom
	nCRazlsp := nCRazlbp * (1 + (nTarStopa / 100))
	// nova cijena je stara mpc + razlika sa porezom
	nNivCijena := nStCijena + nCRazlsp
	
	// upisi u pript
	select pript
	append blank
	Scatter()
	_idfirma := cIdFirma
	_idkonto := cPKonto
	_pkonto := cPKonto
	_pu_i := "3"
	_idroba := cIdRoba
	_idtarifa := Tarifa(cPKonto, cIdRoba, @aPorezi, cIdTarifa)
	_idvd := "19"
	_brdok := cBrKalk
	_tmarza2 := "A"
	_rbr := RedniBroj(++nRbr)
	_kolicina := nUlaz-nIzlaz
	_datdok := dDatDok
	_datfaktp := dDatDok
	//_MPCSaPP := nNivCijena - nStCijena
	//_MPC := 0
	_MPCSaPP := nCRazlsp
	_fcj := nStCijena
	//_MPC := MpcBezPor(nNivCijena, aPorezi, , _nc) - MpcBezPor(nStCijena, aPorezi, , _nc)
	_MPC := nCRazlbp 
	_error := "0"
	Gather()

	select kalk
enddo
 
return
*}




function result_nivel_p()
*{
local cVarijanta
local cKolNula

if Pitanje(,"Izvrsiti uvid u rezultate nivelacija (D/N)?", "D") == "N"
	return
endif

Box(,5, 65)
	cVarijanta := "2"
	cKolNula := "N"
	@ 1+m_x, 2+m_y SAY "Varijanta prikaza:"
	@ 2+m_x, 2+m_y SAY "  - sa detaljima (1)"
	@ 3+m_x, 2+m_y SAY "  - bez detalja  (2)" GET cVarijanta VALID !Empty(cVarijanta) .and. cVarijanta $ "12"
	@ 5+m_x, 2+m_y SAY "Prikaz kolicina 0 (D/N)" GET cKolNula VALID !Empty(cKolNula) .and. cKolNula $ "DN" PICT "@!"
	read
	ESC_BCR
BoxC()

st_res_niv_p(cVarijanta, cKolNula)

return


// -----------------------------------------
// obrada nivelacije iz PRIPT tabele
// -----------------------------------------
function obr_nivel_p()
local nRecP
local lGenFinFakt
local lStampati

if Pitanje(,"Obraditi nivelaciju iz pomocne tabele (D/N)?", "N") == "N"
	return
endif

O_PRIPT
nRecP := RecCount()

if nRecP == 0
	MsgBeep("Nije generisana nivelacija, opcija 9. !")
	return
endif

lStampati := .t.

if Pitanje(,"Stampati dokumente (D/N)","N") == "N"
	lStampati := .f.
endif

lGenFinFakt := .f.

if Pitanje(, "Generisati FIN/FAKT dokumente (D/N)", "N") == "D"
	lGenFinFakt := .t.
endif

if !lGenFinFakt
	// snimi stanje parametara
	cTmpFin := gAFin
	cTmpMat := gAMat
	cTmpFakt := gAFakt

	gAFin := "0"
	gAMat := "N"
	gAFakt := "N"
endif

// pokreni obradu pript bez asistenta
ObradiImport(0, .f., lStampati)

if !lGenFinFakt
	// vrati parametre...
	gAFin := cTmpFin
	gAMat := cTmpMat
	gAFakt := cTmpFakt
endif

return



// -----------------------------------------
// stampa rezultata - efekata nivelacije
// cVar - varijanta
// cKolNula - 
// -----------------------------------------
function st_res_niv_p(cVar, cKolNula)
local cIdFirma
local cIdVd
local cBrDok
local cIdRoba
local cRobaNaz
local cProd
local cPorez
local nUStVrbpdv
local nUStVrspdv
local nUNVrbpdv 
local nUNVrspdv 
local nURazlbpdv
local nURazlspdv

O_PRIPT
O_POBJEKTI
O_ROBA
O_TARIFA

if IsPDV()
	cPorez := "PDV"	
else
	cPorez := "PP"
endif

select pript
set order to tag "1"
go top

START PRINT CRET

?
? "Prikaz efekata nivelacije za sve prodavnice, na dan " + DToC(DATE())
?

cLine := REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 15)
cLine += SPACE(1)
cLine += REPLICATE("-", 35)
cLine += SPACE(1)
cLine += REPLICATE("-", 35)
cLine += SPACE(1)
cLine += REPLICATE("-", 35)
cLine += SPACE(1)

st_zagl(cLine)

// total varijable
nTStVrbpdv := 0
nTStVrspdv := 0
nTNVrbpdv := 0
nTNVrspdv := 0
nTRazlbpdv := 0
nTRazlspdv := 0

do while !EOF()
	
	cIdFirma := field->idfirma
	cIdVd := field->idvd
	cBrDok := field->brdok
	
	nUStVrbpdv := 0
	nUStVrspdv := 0
	nUNVrbpdv := 0
	nUNVrspdv := 0
	nURazlbpdv := 0
	nURazlspdv := 0
	
	cProd := field->pkonto
	
	do while !EOF() .and. pript->(idfirma+idvd+brdok) == cIdFirma+cIdVd+cBrDok
		cIdRoba := field->idroba
		cIdTar := field->idtarifa
		
		select roba
		set order to tag "ID"
		hseek cIdRoba
		
		select tarifa
		seek cIdTar
		
		select pript
		
		// kolicina
		nKolicina := field->kolicina
		
		// da li je kolicina 0
		if cKolNula == "N"
			if ROUND(nKolicina, 4) == 0
				skip
				loop
			endif
		endif
		
		// stara cijena sa pdv
		nSCijspdv := field->fcj
		
		// nova cijena sa pdv
		nNCijspdv := field->fcj + field->mpcsapp
		
		// RUC sa pdv
		nRazlCij := nSCijspdv - nNCijspdv
		
		// stara vrijednost sa pdv
		nStVrspdv := nKolicina * (field->fcj)

		// stara vrijednost bez pdv
		nStVrbpdv := nKolicina * (field->fcj / ( 1 + (tarifa->opp / 100) ) )
		
		// vrijednost nova cijena sa pdv
		nNVrspdv := nKolicina * nNCijspdv
		
		// vrijednost nova bez pdv
		nNVrbpdv := nKolicina * (nNCijspdv / (1 + (tarifa->opp / 100) ) )
		
		// razlika sa pdv
		nRazlspdv := nStVrspdv - nNVrspdv
		
		// razlika bez pdv
		nRazlbpdv := nStVrbpdv - nNVrbpdv
		
		if cVar == "1"
			// vidi da li treba nova strana
			nstr(cLine)
			
			// prikazi stavku
			? cIdRoba
			?? SPACE(1) 
			?? PADR(roba->naz, 15)
			
			// cijene
			@ prow(), pcol()+2 SAY ROUND(nSCijspdv, 3) PICT gPicCDem
			@ prow(), pcol()+2 SAY ROUND(nNCijspdv, 3) PICT gPicCDem
			@ prow(), pcol()+2 SAY ROUND(nRazlCij, 3) PICT gPicCDem
			// sa pdv
			@ prow(), pcol()+2 SAY ROUND(nStVrspdv, 3) PICT gPicDem
			@ prow(), pcol()+2 SAY ROUND(nNVrspdv, 3) PICT gPicDem
			@ prow(), pcol()+2 SAY ROUND(nRazlspdv, 3) PICT gPicDem
			// bez pdv
			@ prow(), pcol()+2 SAY ROUND(nStVrbpdv, 3) PICT gPicDem
			@ prow(), pcol()+2 SAY ROUND(nNVrbpdv, 3) PICT gPicDem
			@ prow(), pcol()+2 SAY ROUND(nRazlbpdv, 3) PICT gPicDem
		endif
	
		// dodaj ukupno prodavnica
		nUStVrbpdv += nStVrbpdv
		nUNVrbpdv += nNVrbpdv
		nUStVrspdv += nStVrspdv
		nUNVrspdv += nNVrspdv
		nURazlbpdv += nRazlbpdv
		nURazlspdv += nRazlspdv

		// dodaj na total
		nTStVrbpdv += nStVrbpdv
		nTNVrbpdv += nNVrbpdv
		nTStVrspdv += nStVrspdv
		nTNVrspdv += nNVrspdv
		nTRazlbpdv += nRazlbpdv
		nTRazlspdv += nRazlspdv

		skip
	enddo
	
	if cVar == "1"
		? cLine
	endif 
	
	// vidi da li treba nova strana
	nstr(cLine)
	
	// uzmi naziv objekta
	cObjNaz := g_obj_naz(cProd)
	
	? PADR("UKUPNO " + ALLTRIM(cProd) + "-" + ALLTRIM(cObjNaz), 26)
	@ prow(), pcol()+2 SAY SPACE(LEN(gPicCDem))
	@ prow(), pcol()+2 SAY SPACE(LEN(gPicCDem))
	@ prow(), pcol()+2 SAY SPACE(LEN(gPicCDem))
	// sa pdv
	@ prow(), pcol()+2 SAY ROUND(nUStVrspdv, 3) PICT gPicDem
	@ prow(), pcol()+2 SAY ROUND(nUNVrspdv, 3) PICT gPicDem
	@ prow(), pcol()+2 SAY ROUND(nURazlspdv, 3) PICT gPicDem
	// bez pdv
	@ prow(), pcol()+2 SAY ROUND(nUStVrbpdv, 3) PICT gPicDem
	@ prow(), pcol()+2 SAY ROUND(nUNVrbpdv, 3) PICT gPicDem
	@ prow(), pcol()+2 SAY ROUND(nURazlbpdv, 3) PICT gPicDem
	
	if cVar == "1"
		? cLine
	endif
enddo

// provjeri za novi red
nstr(cLine)

? cLine

// total - sve prodavnice
? PADR("SVE PRODAVNICE UKUPNO:",26)
@ prow(), pcol()+2 SAY SPACE(LEN(gPicCDem))
@ prow(), pcol()+2 SAY SPACE(LEN(gPicCDem))
@ prow(), pcol()+2 SAY SPACE(LEN(gPicCDem))
// sa pdv
@ prow(), pcol()+2 SAY ROUND(nTStVrspdv, 3) PICT gPicDem
@ prow(), pcol()+2 SAY ROUND(nTNVrspdv, 3) PICT gPicDem
@ prow(), pcol()+2 SAY ROUND(nTRazlspdv, 3) PICT gPicDem
// bez pdv
@ prow(), pcol()+2 SAY ROUND(nTStVrbpdv, 3) PICT gPicDem
@ prow(), pcol()+2 SAY ROUND(nTNVrbpdv, 3) PICT gPicDem
@ prow(), pcol()+2 SAY ROUND(nTRazlbpdv, 3) PICT gPicDem
	
? cLine


FF

ENDPRINT

return



// stampa zaglavlja
static function st_zagl(cLine)
local cHead1
local cHead2
local cSep := "*"

P_COND

? cLine

// prva linija headera
cHead1 := PADC("SIFRA", 10)
cHead1 += cSep
cHead1 += PADC("NAZIV", 15)
cHead1 += cSep
cHead1 += PADC("CIJENE SA PDV", 35)
cHead1 += cSep
cHead1 += PADC("VRIJEDNOST SA PDV", 35)
cHead1 += cSep
cHead1 += PADC("VRIJEDNOST BEZ PDV", 35)
cHead1 += cSep

// druga linija headera
cHead2 := PADC("ARTIKLA", 10)
cHead2 += cSep
cHead2 += PADC("ARTIKLA", 15)
cHead2 += cSep
cHead2 += PADC("STARA", 11)
cHead2 += cSep
cHead2 += PADC("NOVA", 11)
cHead2 += cSep
cHead2 += PADC("RAZLIKA", 11)
cHead2 += cSep
cHead2 += PADC("STARA C", 11)
cHead2 += cSep
cHead2 += PADC("NOVA C", 11)
cHead2 += cSep
cHead2 += PADC("RAZLIKA", 11)
cHead2 += cSep
cHead2 += PADC("STARA C", 11)
cHead2 += cSep
cHead2 += PADC("NOVA C", 11)
cHead2 += cSep
cHead2 += PADC("RAZLIKA", 11)
cHead2 += cSep

? cHead1
? cHead2

? cLine

return


// prelaz na novu stranicu
static function nstr(cLine)

if prow() > 58
	FF
	st_zagl(cLine)
endif

return


// obrazac o promjeni cijena za sve prodavnice
function o_pr_cijena()
local cProred
local cPodvuceno
local aDoks
local i

cProred:="N"
cPodvuceno:="N"

MsgBeep("Opcija stampa obrasce o promjeni cijena#na osnovu generisane nivelacije!")

Box(,2,60)
	@ m_x+1,m_y+2 SAY "Prikazati sa proredom:" GET cProred valid cProred $"DN" pict "@!"
 	@ m_x+2,m_y+2 SAY "Prikazati podvuceno  :" GET cPodvuceno valid cPodvuceno $ "DN" pict "@!"
	read
	ESC_BCR
BoxC()

if Lastkey()==K_ESC
	return
endif

O_PARTN
O_ROBA
O_TARIFA
O_PRIPT

// uzmi u matricu prodavnice
g_pript_doks(@aDoks)

// ima li dokumenata
if LEN(aDoks) == 0
	MsgBeep("Nema dokumenata!")
	return
endif

// prodji po dokumentima
for i:=1 to LEN(aDoks)

	// upit za stampu
	Box(,5, 60)
		cOdgovor := "D"
		@ m_x+1, m_y+2 SAY "Stampati obrazac za dokument: 19-" + ALLTRIM(aDoks[i, 1])
		@ m_x+3, m_y+2 SAY "D/N (X - prekini)" GET cOdgovor VALID cOdgovor $ "DNX" PICT "@!"
	read
	BoxC()
	
	// ako je X - izadji skroz
	if cOdgovor == "X"
		exit
	endif

	// ako je N - izadji samo iz tekuceg
	if cOdgovor == "N"
		loop
	endif
	
	// stampaj obrazac
	st_pr_cijena(gFirma, "19", aDoks[i, 1], cPodvuceno, cProred)
next


return


// vrati u matricu brojeve dokumenata
static function g_pript_doks(aArr)
aArr:={}
select pript
go top

do while !EOF()
	if ASCAN(aArr, {|xVar| xVar[1] == field->brdok }) == 0
		AADD(aArr, {field->brdok})
	endif
	skip
enddo

return 



// stampa obrasca o promjeni cijena
function st_pr_cijena(cFirma, cIdTip, cBrDok, cPodvuceno, cProred)
local nCol1:=0
local nCol2:=0
local nPom:=0

select PRIPT
set order to tag "1"
go top
seek cFirma + cIdTip + cBrDok

nStr:=0

cIdKonto:=IdKonto
cObjNaz:=g_obj_naz(cIdKonto)

START PRINT CRET

?

Preduzece()

P_10CPI
B_ON
? padl("Prodavnica: " + ALLTRIM(cIdKonto) + "-" + ALLTRIM(cObjNaz),74)
?
?
? PADC("PROMJENA CIJENA U PRODAVNICI ___________________, Datum _________",80)
?
B_OFF

P_COND

?

@ prow(), 110 SAY "Str:" + STR(++nStr, 3)

m:= "--- --------------------------------------------------- ---------- ---------- ---------- ------------- ------------- -------------"

? m

? "*R *  Sifra   *        Naziv                           *  STARA   *   NOVA   * promjena *  zaliha     *   iznos     *  ukupno    *"
? "*BR*          *                                        *  cijena  *  cijena  *  cijene  * (kolicina)  *   poreza    * promjena   *"

? m

do while !eof() .and. cFirma==pript->IdFirma .and.  cBrDok==pript->BrDok .and. cIdTip==pript->IdVD
	
	select ROBA
    	HSEEK PRIPT->IdRoba
    	
	select TARIFA
    	HSEEK PRIPT->IdTarifa
    	
	select PRIPT
    
   	DokNovaStrana(110, @nStr, IIF(cProred=="D", 2, 1))
      
      	?
	
      	if cPodvuceno=="D"
       		U_ON
      	endif
	
      	?? field->rbr + " " + field->idroba + " " + PADR(trim(LEFT(ROBA->naz,35)) + " (" + ROBA->jmj + ")", 40)
      	
	@ prow(),pcol()+1 SAY field->FCJ PICT gPicCDEM
      	@ prow(),pcol()+1 SAY field->MPCSAPP+FCJ PICT gPicCDEM
      	@ prow(),pcol()+1 SAY field->MPCSAPP PICT gPicCDEM
      	
	if cPodvuceno=="D"
       		U_OFF
      	endif
      	
	@ prow(),pcol()+1 SAY "_____________"
      	@ prow(),pcol()+1 SAY "_____________"
      	@ prow(),pcol()+1 SAY "_____________"
      	
	if cProred=="D"
        	?
      	endif
    	
	skip
enddo

DokNovaStrana(110, @nStr, 12)

? m
? " UKUPNO "
? m
?
?
?
P_10CPI

PrnClanoviKomisije()

ENDPRINT

return



