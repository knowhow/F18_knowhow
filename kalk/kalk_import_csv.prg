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

// stampanje dokumenata .t. or .f.
static __stampaj
static __partn
static __mkonto
static __trosk

// ----------------------------------------------
// Menij opcije import txt
// ----------------------------------------------
function MnuImpCSV()
private izbor:=1
private opc:={}
private opcexe:={}

__stampaj := .f.
__trosk := .f.

if gAImpPrint == "D"
	__stampaj := .t.
endif

AADD(opc, "1. import csv racun                 ")
AADD(opcexe, {|| ImpCsvDok()})
AADD(opc, "2. import csv - ostalo ")
AADD(opcexe, {|| ImpCsvOst()})
AADD(opc, "6. podesenja importa ")
AADD(opcexe, {|| aimp_setup()})

Menu_SC("ics")

return


// ----------------------------------
// podesenja importa
// ----------------------------------
static function aimp_setup()
local nX
local GetList:={}

gAImpRKonto := PADR( gAImpRKonto, 7 )

nX := 1

Box(, 10, 70)

	@ m_x + nX, m_y + 2 SAY "Podesenja importa ********"

	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Stampati dokumente pri auto obradi (D/N)" GET gAImpPrint VALID gAImpPrint $ "DN" PICT "@!"

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Automatska ravnoteza naloga na konto: " GET gAImpRKonto 
	read	
BoxC()

if LastKey() <> K_ESC
	
	O_PARAMS
	
	private cSection := "7"
	private cHistory := " "
	private aHistory := {}

	WPar("ap", gAImpPrint )
	WPar("ak", gAImpRKonto )
	
	select params
	use
	
endif

return

// ----------------------------------------
// setuj glavne parametre importa
// ----------------------------------------
static function _g_params()
local cMKto
local cPart
private GetList:={}

cMKto := PADR( "1312", 7 )
cPart := PADR( "", 6 )

O_PARAMS
	
private cSection := "8"
private cHistory := " "
private aHistory := {}

RPar("ik", @cMKto )
RPar("ip", @cPart )

Box(,5,55)
	
	@ m_x + 1, m_y + 2 SAY "*** parametri importa dokumenta" 
	
	@ m_x + 3, m_y + 2 SAY "Konto zaduzuje  :" GET cMKto VALID P_Konto(@cMKto)
	@ m_x + 4, m_y + 2 SAY "Sifra dobavljaca:" GET cPart VALID P_Firma(@cPart)
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

O_PARAMS
private cSection := "8"
private cHistory := " "
private aHistory := {}

WPar("ik", cMKto )
WPar("ip", cPart )

select params 
use

// setuj staticke varijable
__mkonto := cMKto
__partn := cPart

return 1

// -----------------------------------------------------
// import CSV fajla - ostalo, partneri npr...
// -----------------------------------------------------
function ImpCSVOst()
private cExpPath
private cImpFile

// setuj varijablu putanje exportovanih fajlova
GetExpPath(@cExpPath)

// daj mi filter za CSV fajlove
cFFilt := GetImpFilter()

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if _gFList(cFFilt, cExpPath, @cImpFile) == 0
	return
endif

// provjeri da li je fajl za import prazan
if CheckFile(cImpFile)==0
	MsgBeep("Odabrani fajl je prazan!#!!! Prekidam operaciju !!!")
	return
endif

private aDbf:={}
private aFaktEx

// setuj polja temp tabele u matricu aDbf
SetTblOST(@aDbf)

// prebaci iz txt => temp tbl
Txt2TOst(aDbf, cImpFile)

// importuj podatke u partnere
ImportOst()

TxtErase(cImpFile, .t.)

return


// --------------------------------------
// Import dokumenta iz csv fajla
// --------------------------------------
function ImpCSVDok()
private cExpPath
private cImpFile

// setuj varijablu putanje exportovanih fajlova
GetExpPath(@cExpPath)

// daj mi filter za import MP ili VP
cFFilt := GetImpFilter()

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if _gFList(cFFilt, cExpPath, @cImpFile) == 0
	return
endif

// uzmi bitne parametre importa fajla
if _g_params() == 0
	return
endif

// provjeri da li je fajl za import prazan
if CheckFile(cImpFile)==0
	MsgBeep("Odabrani fajl je prazan!#!!! Prekidam operaciju !!!")
	return
endif

private aDbf:={}
private aFaktEx

// setuj polja temp tabele u matricu aDbf
SetTblDok(@aDbf)

// prebaci iz txt => temp tbl
Txt2TTbl(aDbf, cImpFile)

if !CheckDok()
	MsgBeep("Prekidamo operaciju !!!#Nepostojece sifre!!!")
	return
endif

if CheckBrFakt( @aFaktEx ) == 0
	MsgBeep("Operacija prekinuta!")
	return
endif

if TTbl2Kalk() == 0
	MsgBeep("Operacija prekinuta!")
	return 
endif

// obrada dokumenata iz pript tabele
MnuObrDok()

TxtErase(cImpFile, .t.)

return


// ----------------------------------------------
// Vraca filter za naziv dokumenta 
// ----------------------------------------------
static function GetImpFilter()
local cRet := "*.csv"
return cRet


// ------------------------------------------------
// Obrada dokumenata iz pomocne tabele
// ------------------------------------------------
static function MnuObrDok()

if Pitanje(,"Obraditi automatski dokument iz pripreme (D/N)?", "N") == "D"
	ObradiDokument( nil, nil, __stampaj )
else
	MsgBeep("Dokument nije obradjen!#Obradu uradite iz pripreme!")
	close all
endif

return


// -------------------------------------------------------
// Setuj matricu sa poljima tabele dokumenata OSTALO
// -------------------------------------------------------
static function SetTblOST(aDbf)

AADD(aDbf,{"idpartner", "C", 6, 0})
AADD(aDbf,{"idrefer",   "C", 10, 0})

return

// -------------------------------------------------------
// Setuj matricu sa poljima tabele dokumenata RACUN
// -------------------------------------------------------
static function SetTblDok(aDbf)

AADD(aDbf,{"idfirma", "C", 2, 0})
AADD(aDbf,{"idtipdok", "C", 2, 0})
AADD(aDbf,{"brdok", "C", 8, 0})
AADD(aDbf,{"datdok", "D", 8, 0})
AADD(aDbf,{"idpartner", "C", 6, 0})
AADD(aDbf,{"rbr", "C", 3, 0})
AADD(aDbf,{"idroba", "C", 10, 0})
AADD(aDbf,{"nazroba", "C", 100, 0})
AADD(aDbf,{"kolicina", "N", 14, 5})
AADD(aDbf,{"cijena", "N", 14, 5})
AADD(aDbf,{"rabat", "N", 14, 5})
AADD(aDbf,{"porez", "N", 14, 5})
AADD(aDbf,{"rabatp", "N", 14, 5})
AADD(aDbf,{"datval", "D", 8, 0})
AADD(aDbf,{"trosk1", "N", 14, 5})
AADD(aDbf,{"trosk2", "N", 14, 5})
AADD(aDbf,{"trosk3", "N", 14, 5})
AADD(aDbf,{"trosk4", "N", 14, 5})
AADD(aDbf,{"trosk5", "N", 14, 5})

return


// -----------------------------------------------------
// Vraca podesenje putanje do exportovanih fajlova
// -----------------------------------------------------
static function GetExpPath(cPath)
cPath:=IzFmkIni("KALK", "ImportPath", "c:\liste\", PRIVPATH)
if Empty(cPath) .or. cPath == nil
	cPath := "c:\liste\"
endif
return


// --------------------------------------------------------
// Kreiranje temp tabele, te prenos zapisa iz text fajla 
// "cTextFile" u tabelu 
//  - param aDbf - struktura tabele
//  - param cTxtFile - txt fajl za import
// --------------------------------------------------------
function Txt2TOst(aDbf, cTxtFile)
local cDelimiter := ";"

// prvo kreiraj tabelu temp
close all

CreTemp(aDbf, .f.)
O_TEMP

if !File(PRIVPATH + SLASH + "TEMP.DBF")
	MsgBeep("Ne mogu kreirati fajl TEMP.DBF!")
	return
endif

// zatim iscitaj fajl i ubaci podatke u tabelu

// broj linija fajla
nBrLin:=BrLinFajla(cTxtFile)
nStart:=0

// prodji kroz svaku liniju i insertuj zapise u temp.dbf
for i:=1 to nBrLin
	
	altd()

	aFMat := SljedLin(cTxtFile, nStart)
      	
	nStart:=aFMat[2]
	
	// uzmi u cText liniju fajla
	cVar:=aFMat[1]

	if EMPTY(cVar)
		loop
	endif

	aRow := csvrow2arr( cVar, cDelimiter ) 
	
	// selektuj temp tabelu
	select temp
	// dodaj novi zapis
	append blank

	// struktura podataka u csv-u je
	// [1] - redni broj
	// [2] - broj narudzbe
	
	// pa uzimamo samo sta nam treba
	cTmp := ALLTRIM( aRow[1] )

	if LEN(cTmp) = 4
		cTmp := "10" + cTmp
	elseif LEN(cTmp) = 5
		cTmp := "1" + cTmp
	endif

	replace idpartner with cTmp
	replace idrefer with ALLTRIM( aRow[2] )
next

select temp

MsgBeep("Import txt => temp - OK")

return



// -------------------------------------------
// importuj podatke ostalo
// -------------------------------------------
static function importost()
local nTarea := SELECT()
local cPartId 
local cRefId
local nCnt := 0

O_PARTN

select temp
go top

do while !EOF()
	
	cPartId := field->idpartner
	cRefId := field->idrefer

	select partn
	go top
	seek cPartId

	if FOUND() .and. ALLTRIM( partn->idrefer ) <> ALLTRIM( cRefId )
		++ nCnt
		replace idrefer with cRefId
	endif
	
	select temp

	skip
enddo

if nCnt > 0
	msgbeep("zamjenjeno " + ALLTRIM(STR(nCnt)) + " stavki...")
endif

select (nTarea)
return


// --------------------------------------------------------
// Kreiranje temp tabele, te prenos zapisa iz text fajla 
// "cTextFile" u tabelu putem aRules pravila 
//  - param aDbf - struktura tabele
//  - param cTxtFile - txt fajl za import
// --------------------------------------------------------
function Txt2TTbl(aDbf, cTxtFile)
local cDelimiter := ";"
local cBrFakt 
local dDatDok
local dDatIsp
local dDatVal
local nTrosk1
local nTrosk2
local nTrosk3
local nTrosk4
local nTrosk5
local aFMat
local cFirstRow

// prvo kreiraj tabelu temp
close all

CreTemp(aDbf)
O_TEMP

if !File(PRIVPATH + SLASH + "TEMP.DBF")
	MsgBeep("Ne mogu kreirati fajl TEMP.DBF!")
	return
endif

// zatim iscitaj fajl i ubaci podatke u tabelu

// broj linija fajla
nBrLin:=BrLinFajla(cTxtFile)
nStart:=0


// iz prvog zapisa uzmi podatke o samoj fakturi
aFMat := SljedLin( cTxtFile, nStart )

// sljdeca pozicija od koje ce poceti da cita fajl...
nStart := aFMat[2]

// prvi red csv fajla je ovo:
cFirstRow := aFMat[1]

// napuni ga u matricu
aFirstRow := csvrow2arr( cFirstRow, cDelimiter )

// struktura bi trebala da bude ovakva:
// [1] - broj dokumenta fakture
// [2] - godina fakture "2008" npr
// [3] - datum fakture
// [4] - datum isporuke
// [5] - datum valute
// [6] - ukupno faktura u EUR
// [7]..[11] - troskovi manualno uneseni 

// setuj glavne stavke dokumenta
cBrDok := aFirstRow[1]
dDatDok := CTOD( aFirstRow[3] )
dDatIsp := CTOD( aFirstRow[4] )
dDatVal := CTOD( aFirstRow[5] )

// troskovi
nTrosk1 := 0
nTrosk2 := 0
nTrosk3 := 0
nTrosk4 := 0
nTrosk5 := 0

if LEN(aFirstRow) > 6
	nTrosk1 := _g_num( aFirstRow[7] )
endif
if LEN(aFirstRow) > 7
	nTrosk2 := _g_num( aFirstRow[8] )
endif
if LEN(aFirstRow) > 8
	nTrosk3 := _g_num( aFirstRow[9] )
endif
if LEN(aFirstRow) > 9
	nTrosk4 := _g_num( aFirstRow[10] )
endif
if LEN(aFirstRow) > 10
	nTrosk5 := _g_num( aFirstRow[11] )
endif

// provjeri hoce li se koristiti automatski troskovi
if ((nTrosk1+nTrosk2+nTrosk3+nTrosk4+nTrosk5) <> 0 )
	__trosk := .t.
endif

// prodji kroz svaku liniju i insertuj zapise u temp.dbf
for i:=1 to nBrLin

	altd()

	aFMat:=SljedLin(cTxtFile, nStart)
      	
	nStart:=aFMat[2]
	
	// uzmi u cText liniju fajla
	cVar:=aFMat[1]

	if EMPTY(cVar)
		loop
	endif

	aRow := csvrow2arr( cVar, cDelimiter ) 
	
	// selektuj temp tabelu
	select temp
	// dodaj novi zapis
	append blank

	// struktura podataka u csv-u je
	// [1] - redni broj
	// [2] - broj narudzbe
	// [3] - sifra artikla
	// [4] - zamjenska sifra artikla
	// [5] - rabatna skupina
	// [6] - naziv artikla
	// [7] - jmj
	// [8] - porijeklo
	// [9] - broj narudzbe iz torina
	// [10] - kolicina
	// [11] - tezina
	// [12] - cijena
	// [13] - ukupno stavka (kol*cijena)
	// [14] - broj hitne narudzbe 

	// pa uzimamo samo sta nam treba

	replace idfirma with gFirma
	replace idtipdok with "01"
	replace brdok with cBrDok
	replace datdok with dDatDok
	replace idpartner with "TEST"
	replace datval with dDatVal
	replace rbr with aRow[1]
	replace idroba with PADR( ALLTRIM( aRow[3] ), 10 )
	replace nazroba with ALLTRIM( aRow[6] )
	replace kolicina with _g_num( aRow[10] ) 
	replace cijena with _g_num( aRow[12] )
	replace rabat with 0
	replace porez with 0
	replace rabatp with 0
	replace trosk1 with nTrosk1
	replace trosk2 with nTrosk2
	replace trosk3 with nTrosk3
	replace trosk4 with nTrosk4
	replace trosk5 with nTrosk5
next

select temp

MsgBeep("Import txt => temp - OK")

return




// ----------------------------------------------------------------
// Kreira tabelu PRIVPATH\TEMP.DBF prema definiciji polja iz aDbf
// ----------------------------------------------------------------
static function CreTemp( aDbf, lIndex )
cTmpTbl := PRIVPATH + "TEMP"

if lIndex == nil
	lIndex := .t.
endif

if File(cTmpTbl + ".DBF") .and. FErase(cTmpTbl + ".DBF") == -1
	MsgBeep("Ne mogu izbrisati TEMP.DBF!")
    	ShowFError()
endif
if File(cTmpTbl + ".CDX") .and. FErase(cTmpTbl + ".CDX") == -1
	MsgBeep("Ne mogu izbrisati TEMP.CDX!")
    	ShowFError()
endif

DbCreate2(cTmpTbl, aDbf)

if lIndex 
	create_index("1","idfirma+idtipdok+brdok+rbr", cTmpTbl)
endif

return

// -----------------------------------------------------------------
// Provjeri da li postoji broj fakture u azuriranim dokumentima
// -----------------------------------------------------------------
static function CheckBrFakt( aFakt )

aPomFakt := FaktExist()

if LEN(aPomFakt) > 0

	START PRINT CRET
	?	
	? "Kontrola azuriranih dokumenata:"
	? "-------------------------------"
	? "Broj fakture => kalkulacija"
	? "-------------------------------"
	? 
	
	for i:=1 to LEN(aPomFakt)
		? aPomFakt[i, 1] + " => " + aPomFakt[i, 2]
	next
	
	?
	? "Kontrolom azuriranih dokumenata, uoceno da se vec pojavljuju"
	? "navedeni brojevi faktura iz fajla za import !"
	?

	FF
	END PRINT

	aFakt := aPomFakt
	return 0
	
endif

aFakt := aPomFakt

return 1

// ---------------------------------------------------------------
// Provjera da li postoje sve sifre u sifrarnicima za dokumente
// ---------------------------------------------------------------
static function CheckDok()
local aPomArt

aPomArt  := TempArtExist()

if (LEN(aPomArt) > 0 )
	
	START PRINT CRET
	
	if (LEN(aPomArt) > 0)
		? "Lista nepostojecih artikala:"
		? "-----------------------------------------"
		? 
		for ii:=1 to LEN(aPomArt)

			// sifra
			? aPomArt[ii, 1]
			
			// naziv artikla
			?? SPACE(2) + "-" + SPACE(1) + aPomArt[ii, 2]
		
		next
		?
	endif
	
	FF
	END PRINT

	return .f.
endif

return .t.


// ----------------------------------------------------------
// Vraca kalk tip dokumenta na osnovu fakt tip dokumenta
// ----------------------------------------------------------
static function GetKTipDok( cFaktTD )
local cRet:=""

if (cFaktTD == "" .or. cFaktTD == nil)
	return "XX" 
endif

do case
	// ulazni racun fakt
	// FAKT 01 -> KALK 10
	case cFaktTD == "01"
		cRet := "10"
		
endcase

return cRet


// ---------------------------------------------------------------
// vraca matricu sa parovima faktura -> pojavljuje se u azur.kalk
// ---------------------------------------------------------------
static function FaktExist()
O_DOKS

select temp
go top

aRet:={}

cDok := "XXXXXX"
do while !EOF()

	cBrFakt := ALLTRIM(temp->brdok)
	
	if cBrFakt == cDok
		skip
		loop
	endif
	
	select doks
	set order to tag "V_BRF"
	go top
	seek cBrFakt
	
	if Found()
		AADD(aRet, {cBrFakt, doks->idfirma + "-" + doks->idvd + "-" + ALLTRIM(doks->brdok)})
	endif
	
	select temp
	skip
	
	cDok := cBrFakt
enddo

return aRet


// ---------------------------------------------------------------
// kopira podatke iz pomocne tabele u tabelu KALK->PRIPT
// ---------------------------------------------------------------
static function TTbl2Kalk()

local cBrojKalk
local cTipDok
local cIdKonto
local cIdKonto2

O_PRIPR
O_KALK
O_DOKS
O_ROBA

select temp
set order to tag "1"
go top

nRbr:=0
nUvecaj:=1

// osnovni podaci ove kalkulacije
cFakt := ALLTRIM(temp->brdok)
cTDok := GetKTipDok( ALLTRIM(temp->idtipdok) )
cBrojKalk := SljBrKalk( cTDok, gFirma )

do while !EOF()

	// pronadji robu
	select roba
	cTmpArt := ALLTRIM(temp->idroba)
	go top
	seek cTmpArt

	// dodaj zapis u pripr
	select pripr
	append blank
	
	replace idfirma with gFirma
	replace rbr with STR(++nRbr, 3)
	
	// uzmi pravilan tip dokumenta za kalk
	replace idvd with cTDok
	
	replace brdok with cBrojKalk
	replace datdok with temp->datdok
	replace idpartner with __partn
	replace idtarifa with ROBA->idtarifa
	replace brfaktp with cFakt
	replace datfaktp with temp->datdok
	
	// konta:
	// =====================
	// zaduzuje
	replace idkonto with __mkonto
	replace mkonto with __mkonto
	replace mu_i with "1"

	// razduzuje
	replace idkonto2 with ""
	
	replace idzaduz2 with ""
	
	replace datkurs with temp->datdok
	replace kolicina with temp->kolicina
	replace idroba with roba->id
	
	// posto je cijena u eur-u konvertuj u KM
	// prema tekucem kursu

	nCijena := ROUND(temp->cijena * ;
		omjerval( ValDomaca(), ValPomocna(), DATE() ), 5)

	replace fcj with nCijena
	replace nc with nCijena
	replace vpc with roba->vpc
	replace rabatv with temp->rabatp
	
	// troskovi
	replace tprevoz with "R"
	replace tbanktr with "R"
	replace tspedtr with "R"
	replace tcardaz with "R"
	replace tzavtr with "R"
	
	if nRbr = 1
		replace prevoz with temp->trosk1
		replace banktr with temp->trosk2
		replace spedtr with temp->trosk3
		replace cardaz with temp->trosk4
		replace zavtr with temp->trosk5
	endif

	select temp
	skip
enddo

return 1

// ---------------------------------------------
// Obrada jednog dokumenta
// ---------------------------------------------
static function ObradiDokument( lAsPokreni, lStampaj )
local lTrosk := .f.

// 1. pokreni asistenta
// 2. azuriraj kalk
// 3. azuriraj FIN

private lAsistRadi:=.f.

if lAsPokreni == nil
	lAsPokreni := .t.
endif

if lStampaj == nil
	lStampaj := .t.
endif

if lAsPokreni
	// pozovi asistenta
	KUnos(.t.)
      	if __trosk == .t. 
		// otvori tabele
		OEdit()
		// fSilent = .t.
		RaspTrosk( .t. )
	endif
else
	OEdit()
endif

if lStampaj == .t.
	// odstampaj kalk
	StKalk( nil, nil, .t. )
endif

// azuriraj kalk
Azur( .t. )

OEdit()

return


