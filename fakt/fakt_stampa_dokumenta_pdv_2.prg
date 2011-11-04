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


#include "fakt.ch"


function stdokpd2(cIdFirma, cIdTipDok, cBrDok)
*{
local lSamoKol:=.f. // samo kolicine

drn_create()
drn_open()
drn_empty()

// otvori tabele
if PCount()==3
	o_fakt_edit(.t.)
else
 	o_fakt_edit()
endif


// barkod artikla
private cPombk := IzFmkIni("SifRoba","PBarkod","0",SIFPATH)
private lPBarkod:=.f.

if cPombk $ "12"  // pitanje, default "N"
	lPBarkod := ( Pitanje(,"Zelite li ispis barkodova ?",iif(cPombk=="1","N","D"))=="D")
endif

if PCount()==0
 	cIdTipdok:=idtipdok
	cIdFirma:=IdFirma
	cBrDok:=BrDok
endif

seek cIdFirma+cIdTipDok+cBrDok
NFOUND CRET

if PCount()==0
	select fakt_pripr
endif

cIdFirma:=IdFirma
cBrDok:=BrDok
dDatDok:=DatDok
cIdTipDok:=IdTipDok

// prikaz samo kolicine
if cIdTipDok $ "12#19#21#26"
	if (gPSamoKol == "0" .and. Pitanje(,"Prikazati samo kolicine (D/N)", "N") == "D") .or. gPSamoKol == "D"
		lSamoKol:=.t.
	endif
endif

if VAL(podbr)=0 .and. VAL(rbr)==1
else
	Beep(2)
  	Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  	return
endif

fill_porfakt_data(cIdFirma, cIdTipDok, cBrDok, lPBarKod, lSamoKol)

pf_a4_print()

return
*}


// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
static function fill_porfakt_data(cIdFirma, cIdTipDok, cBrDok, lBarKod, lSamoKol)
*{
local cTxt1,cTxt2,cTxt3,cTxt4,cTxt5
local cIdPartner
local dDatDok
local dDatVal
local dDatIsp
local aMemo
local cIdRoba := ""
local cRobaNaz := ""
local cRbr := ""
local cPodBr := ""
local cJmj:=""
local nKol:=0
local nCjPDV:=0
local nCjBPDV:=0
local nPopust:=0 // proc popusta
local nPopNaTeretProdavca:=0
local nVPDV:=0
local nCj2PDV:=0
local nCj2BPDV:=0
local nPPDV:=0
local nRCijen:=0
local nCSum:= 0
local nTotal:= 0
local nUkBPDV:= 0
local nUkBPDVPop:=0
local nUkVPop:=0
local nVPopust:=0
local nVPopNaTeretProdavca:=0
local nUkPDV:=0
local nUkPopNaTeretProdavca:=0
local cTime:=""
local cDinDem
local nRec
local nZaokr
local nFZaokr:=0
local nDrnZaokr:=0
local cDokNaz
// ako je kupac pdv obveznik, ova varijable je .t.
local lPdvObveznik
local cOpis := ""
local cC1 := ""
local cC2 := ""
local cC3 := ""

// napuni firmine podatke
fill_firm_data()

select fakt_pripr

// napuni podatke partnera

lPdvObveznik := .f.
fill_part_data(idpartner, @lPdvObveznik)

select fakt_pripr

// vrati naziv dokumenta
get_dok_naz(@cDokNaz, idtipdok, idvrstep, lSamoKol)

select fakt_pripr

dDatDok := datdok
dDatVal := dDatDok
dDatIsp := dDatDok
cDinDem := dindem
nZaokr := zaokr

nRec:=RecNO()


do while !EOF() .and. idfirma==cIdFirma .and. idtipdok==cIdTipDok .and. brdok==cBrDok
	NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na fakt_pripr->IdRoba
	
	// nastimaj i tarifu
	select tarifa
	hseek roba->idtarifa
	select fakt_pripr
	
     	aMemo:=ParsMemo(txt)
	cIdRoba := field->idroba
	
	if roba->tip="U"
		cRobaNaz:=aMemo[1]
	else
		cRobaNaz:=ALLTRIM(roba->naz)
		if lBarKod
			cRobaNaz:=cRobaNaz + " (BK: " + roba->barkod + ")"
		endif
	endif

	// dodaj i vrijednost iz polja SERBR
	if !EMPTY(ALLTRIM(fakt_pripr->serbr))
		cRobaNaz := cRobaNaz + ", " + ALLTRIM(fakt_pripr->serbr) 
	endif

	//resetuj varijable sa cijenama
	nCjPDV := 0
	nCj2PDV := 0
	nCjBPDV := 0
	nCj2BPDV := 0
	nVPopust := 0
	
	if fakt_pripr->(FIELDPOS("C1")) <> 0
		cC1 := fakt_pripr->c1
		cC2 := fakt_pripr->c2
		cC3 := fakt_pripr->c3
		cOpis := fakt_pripr->opis
	endif

	cRbr := field->rbr
	cPodBr := field->podbr
	cJmj := roba->jmj

	// procenat pdv-a
	nPPDV := tarifa->opp
	
	// kolicina
	nKol := field->kolicina
	nRCijen := field->cijena

	nPopNaTeretProdavca := 0
	nPopust := 0
	
	// zasticena cijena, za krajnjeg kupca
	if RobaZastCijena(tarifa->id)  .and. !lPdvObveznik
		// krajnji potrosac
	   	// roba sa zasticenom cijenom
	   	nPopNaTeretProdavca := field->rabat
	   	nPopust := 0
	else
	    	// rabat - popust
	    	nPopust := field->rabat
	    	nPopNaTeretProdavca := 0
	endif
	
	// ako je 13-ka ili 27-ca
	if (field->idtipdok == "13" .and. glCij13Mpc) .or. (field->idtipdok $ "11#27" .and. gMP $ "1234567") 
		// cjena bez pdv-a
		nCjPDV:= nRCijen
		nCjBPDV := (nRCijen / (1 + nPPDV/100))
	else
		// cjena bez pdv-a
		nCjBPDV:= nRCijen
		nCjPDV := (nRCijen * (1 + nPPDV/100))
	endif
	
	nVPopust := 0

	// izracunaj vrijednost popusta
	if Round(nPopust,4) <> 0
		// vrijednost popusta
		nVPopust := (nCjBPDV * (nPopust/100))
	endif
	
	nVPopNaTeretProdavca := 0

	// izacunaj vrijednost popusta na teret prodavca
	if Round(nPopNaTeretProdavca, 4) <> 0
		// vrijednost popusta
		nVPopNaTeretProdavca := (nCjBPDV * (nPopNaTeretProdavca/100))
	endif

	// cijena sa popustom bez pdv-a
	nCj2BPDV := (nCjBPDV - nVPopust)
	// izracuna PDV na cijenu sa popustom
	nCj2PDV := (nCj2BPDV * (1 + nPPDV/100))
	// preracunaj VPDV sa popustom
	nVPDV := (nCj2BPDV * (nPPDV/100))
	// ukupno stavka
	nUkStavka := nKol * nCj2PDV

	// sumiraj vrijednosti
	nUkVPop += nKol * nVPopust
	nUkPDV += nKol * nVPDV
	nUkBPDV += nKol * nCjBPDV
	nUkBPDVPop += nKol * nCj2BPDV
	nTotal += nKol * (nCj2BPDV + nVPDV)
	nUkPopNaTeretProdavca += nKol * nVPopNaTeretProdavca 

	++ nCSum
	
	add_rn(cBrDok, cRbr, cPodBr, cIdRoba, cRobaNaz, cJmj, nKol, nCjPDV, nCjBPDV, nCj2PDV, nCj2BPDV, nPopust, nPPDV, nVPDV, nUkStavka, nPopNaTeretProdavca, nVPopNaTeretProdavca, cC1, cC2, cC3, cOpis )

	select fakt_pripr
	skip
enddo	

// zaokruzenje
//nFZaokr := ROUND(nTotal, nZaokr) - ROUND2(ROUND(nTotal, nZaokr), gFZaok)

if goModul:oDataBase:cSezona >= "2011" 
	nFZaokr := zaokr_5pf( nTotal )
	if gZ_5pf == "N"
		nFZaokr := 0
	endif
else
	nFZaokr := ROUND(nTotal, ZAO_VRIJEDNOST()) - ROUND2(ROUND(nTotal, ZAO_VRIJEDNOST()), gFZaok)
endif

if (gFZaok <> 9 .and. ROUND(nFZaokr, 4) <> 0)
	nDrnZaokr := nFZaokr
endif

nTotal := ROUND(nTotal - nDrnZaokr, nZaokr)

nUkPopNaTeretProdavca := ROUND(nUkPopNaTeretProdavca, nZaokr)
nUkBPDV := ROUND( nUkBPDV, nZaokr )
nUkVPop := ROUND( nUkVPop, nZaokr )

select fakt_pripr
go (nRec)

// nafiluj ostale podatke vazne za sam dokument
aMemo := ParsMemo(txt)
dDatDok := datdok

if LEN(aMemo) <= 5
	dDatVal := dDatDok
	dDatIsp := dDatDok
	cBrOtpr := ""
	cBrNar  := ""
else
	dDatVal := CToD(aMemo[9])
	dDatIsp := CToD(aMemo[7])
	cBrOtpr := aMemo[6]
	cBrNar  := aMemo[8]
endif


// mjesto
add_drntext("D01", gMjStr)
// naziv dokumenta
add_drntext("D02", cDokNaz)
// slovima iznos fakture
add_drntext("D04", Slovima( nTotal - nUkPopNaTeretProdavca , cDinDem))
// broj otpremnice
add_drntext("D05", cBrOtpr)
// broj narudzbenice
add_drntext("D06", cBrNar)
// DM/EURO
add_drntext("D07", cDinDem)

// tekst na kraju fakture F04, F05, F06
fill_dod_text(aMemo[2])
// potpis na kraju
fill_potpis(cIdTipDok)

// parametri generalni za stampu dokuemnta
// lijeva margina
add_drntext("P01", ALLTRIM(STR(gnLMarg)) )
// zaglavlje na svakoj stranici
add_drntext("P04", if(gZagl == "1", "D", "N"))
// prikaz dodatnih podataka 
add_drntext("P05", if(gDodPar == "1", "D", "N"))
// dodati redovi po listu 
add_drntext("P06", ALLTRIM(STR(gERedova)) )
// gornja margina
add_drntext("P07", ALLTRIM(STR(gnTMarg)) )
// da li se formira automatsko zaglavlje
add_drntext("P10", gStZagl )

// dodaj total u DRN
add_drn(cBrDok, dDatDok, dDatVal, dDatIsp, cTime, nUkBPDV, nUkVPop, nUkBPDVPop, nUkPDV, nTotal, nCSum, nUkPopNaTeretProdavca, nDrnZaokr)

return
*}


static function fill_potpis(cIdVD)
*{
local cPom
local cPotpis
local cStdPot

cStdPot := "                           Odobrio                     Primio "

if (cIdVd $ "01#00#19") 
	cPotpis := cStdPot
else
   	cPom:="G"+cIdVD+"STR2T"
   	cPotpis := &cPom
endif

// potpis 
add_drntext("F10", cPotpis)

return
*}


// filovanje dodatnog teksta
static function fill_dod_text(cTxt)
*{
local aLines // matrica sa linijama teksta
local nFId // polje Fnn counter od 20 pa nadalje
local nCnt // counter upisa u DRNTEXT

// slobodni tekst se upisuje u DRNTEXT od F20 -- F50

cTxt := STRTRAN(cTxt, "" + Chr(10), "")
// daj mi matricu sa tekstom line1, line2 itd...
aLines := TokToNiz(cTxt, Chr(13) + Chr(10)) 

nFId := 20
nCnt := 0

for i:=1 to LEN(aLines)
	add_drntext("F" + ALLTRIM(STR(nFId)), aLines[i] + " ")
	++ nFId
	++ nCnt
next

// dodaj i parametar koliko ima linija texta
add_drntext("P02", ALLTRIM(STR(nCnt)))

return
*}


static function fill_part_data(cId, lPdvObveznik)
*{
local cIdBroj:=""
local cPorBroj:=""
local cBrRjes:=""
local cBrUpisa:=""
local cPartNaziv:=""
local cPartAdres:=""
local cPartMjesto:=""
local cPartPTT:=""
local aMemo:={}
local lFromMemo:=.f.

if Empty(ALLTRIM(cID))
	// ako je prazan partner uzmi iz memo polja
	aMemo:=ParsMemo(txt)
	lFromMemo := .t.
else
	O_PARTN
	select partn
	set order to tag "ID"
	hseek cId
endif

if !lFromMemo .and. partn->id == cId
	// uzmi podatke iz SIFK
	cIdBroj := IzSifK("PARTN", "REGB", cId, .f.)
	cPorBroj := IzSifK("PARTN", "PORB", cId, .f.)
	cBrRjes := IzSifK("PARTN", "BRJS", cId, .f.)
	cBrUpisa := IzSifK("PARTN", "BRUP", cId, .f.)
	cPartNaziv := partn->naz
	cPartAdres := partn->adresa
	cPartMjesto := partn->mjesto
	cPartPtt := partn->ptt
else
	if LEN(aMemo) == 0
		cPartNaziv := ""
		cPartAdres := ""
		cPartMjesto := ""
	else
		cPartNaziv := aMemo[3]
		cPartAdres := aMemo[4]
		cPartMjesto := aMemo[5]
	endif
endif

// naziv
add_drntext("K01", cPartNaziv)
// adresa
add_drntext("K02", cPartAdres)
// mjesto
add_drntext("K10", cPartMjesto)
// ptt
add_drntext("K11", cPartPTT)
// idbroj
add_drntext("K03", cIdBroj)
// porbroj
add_drntext("K05", cPorBroj)

if !EMPTY(cIdBroj) 
	if LEN(ALLTRIM(cIdBroj)) == 12
		lPdvObveznik := .t.
	else
		lPdvObveznik := .f.
	endif
else
	lPdvObveznik := .f.
endif
	
// brrjes
add_drntext("K06", cBrRjes)
// brupisa
add_drntext("K07", cBrUpisa)

return
*}

static function fill_firm_data()
*{
// opci podaci
add_drntext("I01", gFNaziv)
add_drntext("I02", gFAdresa)
add_drntext("I03", gFIdBroj)
// 4. se koristi za id prod.mjesto u pos
add_drntext("I10", ALLTRIM(gFTelefon))
add_drntext("I11", ALLTRIM(gFEmailWeb))

// banke
add_drntext("I09", ALLTRIM(gFBanka1) + "; " + ALLTRIM(gFBanka2) + "; " + ALLTRIM(gFBanka3) + "; " + ALLTRIM(gFBanka4) + "; " + ALLTRIM(gFBanka5) )

// dodatni redovi
add_drntext("I12", ALLTRIM(gFText1))
add_drntext("I13", ALLTRIM(gFText2))
add_drntext("I14", ALLTRIM(gFText3))

return
*}


