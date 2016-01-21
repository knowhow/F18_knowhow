/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

// vars
static __delimit
static __rbr
static __nalbr
static __k_kup


// ----------------------------------------
// import elba txt... glavna funkcija
// ----------------------------------------
function _imp_elba_txt( cTxt )
local nItems
local cImpView 

if cTxt == nil
	cTxt := ""
endif

// provjeri da li je priprema prazna
if __ck_pripr() > 0
	MsgBeep("Priprema mora biti prazna !!!#Ispraznite pripremu i ponovite proceduru.")
	return
endif

// uzmi parametre...
if _get_params( @cTxt, @cImpView ) == 0
	MsgBeep("Prekidam operaciju...")
	return
endif

O_FIN_PRIPR
O_NALOG

// delimiter je TAB
__delimit := CHR(9)

// kupac konto 
__k_kup := r_get_konto( "KUP_KONTO" )


// uzmi lokaciju fajla txt ako nije proslijedjeno...
if EMPTY( cTxt )
	_g_elba_file( @cTxt )
endif

// napuni pripremu sa stavkama... iz txt
nItems := _g_el_items( cTxt, cImpView )

if nItems > 0
	MsgBeep("Obradjeno: " + ALLTRIM(STR(nItems)) + " stavki.#Stavke se nalaze u pripremi.")
endif

return

// -------------------------------------------------------
// provjerava koliko zapisa postoji u pripremi
// -------------------------------------------------------
static function __ck_pripr()
local nReturn := 0
O_FIN_PRIPR
select fin_pripr
nReturn := RecCount2()
return nReturn


// -------------------------------------------
// parametri importa
// -------------------------------------------
static function _get_params( cFile, cImpView )
local nX := 1
local cImpOk := "D"
local GetList := {}

cFile := PADR( "c:\temp\elba.txt", 300 )
cFile := fetch_metric( "import_elba_lokacija_fajla", my_user(), cFile )
cImpView := "D"

Box(, 9, 65)

	@ m_x + nX, m_y + 2 SAY "Parametri importa" COLOR "BG+/B"

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Lokacija i naziv fajla za import:"

	nX += 1
	
	@ m_x + nX, m_y + 2 GET cFile PICT "@S60" VALID _file_valid( cFile )

	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Pregled importa (D/N)?" GET cImpView VALID cImpView $ "DN" PICT "@!"
	
	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Importovati podatke (D/N)?" GET cImpOk VALID cImpOk $ "DN" PICT "@!"

	read
	
BoxC()

if LastKey() == K_ESC .or. cImpOk == "N"
	return 0
endif

cFile := ALLTRIM( cFile )
set_metric( "import_elba_lokacija_fajla", my_user(), cFile )

return 1

// ------------------------------------------
// validacija fajla
// ------------------------------------------
static function _file_valid( cFile )
local lRet := .t.

cFile := ALLTRIM(cFile)

if EMPTY(cFile)
	MsgBeep("Lokacija i ime fajla moraju biti popunjeni !")
	lRet := .f.
else
	if !FILE(cFile)
		MsgBeep("Ovaj fajl ne postoji !!!")
		lRet := .f.
	endif
endif

return lRet


// -------------------------------------------------------
// vraca gdje se nalazi txt fajl za import
// -------------------------------------------------------
static function _g_elba_file( cTxt )
cTxt := EXEPATH + "elba.txt"
return


// -------------------------------------------------------
// vraca matricu napunjenu stavkama iz txt fajla...
// -------------------------------------------------------
static function _g_el_items( cTxt, cImpView )
local nItems := 0
local aHeader := {}
local aItem := {}
local cTemp := ""
local i
local cNalBr

local _o_file

private aPartArr := {}
private GetList:={}

__nalbr := ""
__rbr := 0

_o_file := TFileRead():New( cTxt )
_o_file:Open()

if _o_file:Error()
	msgbeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: ") )
	return 0
endif

Box( , 22, 70)

@ m_x + 1, m_y + 2 SAY "Vrsim import podataka u pripremu ..." COLOR "BG+/B"

//for i:=1 to nFLines
while _o_file:MoreToRead()

	cTemp := hb_strtoutf8( _o_file:ReadLine() )

	if EMPTY(cTemp)
		loop
	endif

	aItem := TokToNiz( cTemp, __delimit )

	aFinItem := {}
	
	// izvuci u FIN pripr matricu aFinItem podatke za nalog
	if _g_elba_item( aItem, aHeader, @aFinItem, cTemp, nItems ) == .t.
			
		// sada ubaci elba item u pripr
		_i_elba_item( aFinItem, cImpView )
			
		++ nItems
		
		@ m_x + 3, m_y + 2 SAY PADR("", 60) COLOR "BG+/B"
		@ m_x + 3, m_y + 2 SAY "stavka " + ALLTRIM(STR( nItems )) COLOR "BG+/B"
		
	else
		
		// ovo su parametri izvoda...
		aHeader := aItem
		
		__nalbr := PADL( aHeader[1], 8 , "0" )

		@ m_x + 4, m_y + 2 SAY "Izvod broj: " + PADL(aHeader[1], 8, "0")
		
	endif
	
enddo	

_o_file:Close()

// sada uzmi pravi broj naloga i broj veze
select fin_pripr
set order to tag "0"
go top
my_flock()
do while !EOF()
	replace brnal with __nalbr
	replace brdok with __nalbr
	skip
enddo
my_unlock()
set order to tag "1"
go top

BoxC()


return nItems


// ----------------------------------------------------------------
// vraca napunjenu matricu aFin pripremljenu za import u pripr
// ----------------------------------------------------------------
static function _g_elba_item( aItem, aHeader, aFin, cLine, nLineNo )
local nItemLen := LEN(aItem)
local cFirma := gFirma
local cIdVn := "I1"

aFin := {}

// aFin[1] = idfirma
// aFin[2] = idvn
// aFin[3] = brnal
// aFin[4] = brveze
// aFin[5] = datnal
// aFin[6] = konto
// aFin[7] = partner
// aFin[8] = duguje / potrazuje
// aFin[9] = valuta
// aFin[10] = iznos
// aFin[11] = opis
// aFin[12] = naziv firme iz TXT fajla


if aItem[1] $ "+-"


	// standardna transakcija....
	if nItemLen == 12
		
		// {1} - tip transakcije (+/-)
		// {2} - datum i vrijeme "27.11.2006 15:15:02"
		// {3} - broj transakcije
		// {4} - uplata UP, ili ???
		// {5} - 2664508 ????
		// {6} - 0 ????
		// {7} - Banka naziv
		// {8} - transakcijski racun primaoca
		// {9} - naziv firme
		// {10} - opis + "/" + racun + puni naziv firme
		// {11} - valuta KM ili drugo
		// {12} - iznos

		AADD(aFin, { cFirma, ;
			cIdVn, ;
			__nalbr, ;
			__nalbr, ;
			_g_elba_date( aItem[2]), ;
			_g_konto(aItem[1], aItem[10] ), ;
			_g_partn(aItem[1], aItem[9], aItem[8] ), ;
			_g_elba_dp( aItem[1] ), ;
			aItem[11], ;
			VAL( aItem[12] ), ;
			_g_opis( aItem[10] ), ;
			ALLTRIM( aItem[9] ) })
	
	
	//elseif nItemLen == 11
	
	//	AADD(aFin, { cFirma, ;
	//		cIdVn, ;
	//		__nalbr, ;
	//		__nalbr, ;
	//		_g_elba_date( aItem[2]), ;
	//		_g_konto(aItem[1], aItem[9]), ;
	//		_g_partn(aItem[1], aItem[8], aItem[7] ), ;
	//		_g_elba_dp( aItem[1] ), ;
	//		aItem[10], ;
	//		VAL( aItem[11] ), ;
	//		_g_opis( aItem[9] ) })
	
		
	
	// naknada - transakcija
	elseif nItemLen == 9

		// matrica je sljedeca
		// aItem
		// ----------------------------------
		// {1} - tip transakcije (+/-)
		// {2} - datum i vrijeme "27.11.2006 15:15:02"
		// {3} - vrsta transakcije  (NR)
		// {4} - broj dokumenta (XXXX)
		// {5} - ???? (0)
		// {6} - primaoc racun  (005914)
		// {7} - opis stavke (obracun naknade za juli)
		// {8} - valuta (KM)
		// {9} - iznos (5)
		

		AADD(aFin, { cFirma, ;
			cIdVn, ;
			__nalbr, ;
			__nalbr, ;
			_g_elba_date( aItem[2]), ;
			_g_konto(aItem[1], aItem[3] ), ;
			_g_partn(aItem[1], aItem[5], aItem[3] ), ;
			_g_elba_dp( aItem[1] ), ;
			aItem[8], ;
			VAL( aItem[9] ), ;
			_g_opis( aItem[7] ), ;
			ALLTRIM(aItem[3]) + " - " + ALLTRIM(aItem[4]) })
	
	else
		
		msgbeep("nepoznata transakcija#broj elemenata = " + ;
			ALLTRIM(STR(LEN(aItem))) + " ???#" + ;
			"linija broj: " + ALLTRIM(STR(nLineNo)) )
		msgbeep( cLine )
		
		return .f.
		
	endif

else
	return .f.
endif

return .t.



// ----------------------------------------------------
// insert stavke u pripremu
// aItem - matrica sa stavkom
// aHeader - ovo su parametri header izvoda...
// ----------------------------------------------------
static function _i_elba_item( aFinItem, cImpView )
local cFirma
local cIdVn
local cBrNal
local cOpis
local cKtoProt
local cDP
local cRbr
local cKonto
local cPartner
local cPartRule
local nIznos
local cPartOpis
local nCurr := 1

// RULES get
// ----------------------------------------------
// vraca konto protustavke - maticna banka
// recimo: 2001
cKtoProt := PADR( r_get_konto("PROT_KONTO"), 7)


// items get
// ----------------------------------------------

// firma
cFirma := aFinItem[ nCurr, 1 ]
// vrsta naloga 
cIdVn := aFinItem[ nCurr, 2 ]
// brnal
cBrNal := aFinItem[ nCurr, 3 ]
// broj veze
cBrVeze := PADR( aFinItem[ nCurr, 4 ], 10)
// datum dokumenta
dDatDok := aFinItem[ nCurr, 5 ]
// konto
cKonto := PADR(aFinItem[ nCurr, 6 ], 7)
// partner
cPartner := PADR( aFinItem[ nCurr, 7 ], 6)
// duguje/potrazuje
cDP := aFinItem[ nCurr, 8 ]
// valuta
cValuta := aFinItem[ nCurr, 9 ]
// iznos dokumenta
nIznos := aFinItem[ nCurr, 10 ]
// opis
cOpis := PADR(aFinItem[ nCurr, 11 ], 40)
// opis partnera
cPartOpis := aFinItem[ nCurr, 12 ] 

// vrati iz RULES partnera prema kontu - ako postoji !!
// i postavi to kao partnera za ovu stavku

cPartRule := r_get_kpartn( cKonto )
if !EMPTY(cPartRule) .and. ALLTRIM(cPartRule) <> "XX"
	cPartner := cPartRule
endif


// sredi redni broj stavke
++__rbr
cRbr := STR( __rbr, 4)

if cImpView == "D"

	@ m_x + 6, m_y + 2 SAY SPACE(70)
	@ m_x + 6, m_y + 2 SAY PADR(cPartOpis, 45) + " -> partner fmk:" GET cPartner
	
	@ m_x + 7, m_y + 2 SAY "datum knjizenja:" GET dDatDok
	@ m_x + 7, col() + 2 SAY "broj veze:" GET cBrVeze
	@ m_x + 8, m_y + 2 SAY "opis knjizenja:" GET cOpis
	@ m_x + 9, m_y + 2 SAY REPLICATE("=", 60)
	
	
	@ m_x + 11, m_y + 2 SAY PADR("rbr.stavke:", 20) GET cRbr
	@ m_x + 12, m_y + 2 SAY "dug/pot:" GET cDP
	@ m_x + 12, col() + 2 SAY "konto:" GET cKonto
	@ m_x + 12, col() + 2 SAY PADR("IZNOS STAVKE:", 20, 20) GET nIznos PICT "9999999.99"

	if LastKey() <> K_ESC
		read
	endif

endif

select fin_pripr
append blank

replace idfirma with cFirma
replace idvn with cIdVn
replace brnal with cBrNal
replace brdok with cBrVeze
replace opis with cOpis
replace rbr with cRbr
replace datdok with dDatDok
replace d_p with cDP
replace idkonto with cKonto
replace idpartner with cPartner

if cValuta == "KM"
	replace iznosbhd with nIznos
else
	replace iznosdem with nIznos
endif


// druga stavka naloga, racun vb
// PROTUSTAVKA....

if cDP == "1"
	cDP := "2"
else
	cDP := "1"
endif


// sredi opet redni broj za protustavku
++__rbr
cRbr := STR(__rbr, 4)


if cImpView == "D"
	
	@ m_x + 13, m_y + 2 SAY REPLICATE("-", 60)
	@ m_x + 14, m_y + 2 SAY PADR("rbr.protustavke:", 20) GET cRbr
	@ m_x + 15, m_y + 2 SAY "dug/pot:" GET cDP
	@ m_x + 15, col() + 2 SAY "konto:" GET cKtoProt
	@ m_x + 15, col() + 2 SAY PADR("IZNOS PROTUSTAVKE:", 20) GET nIznos PICT "9999999.99"

	if lastKey() <> K_ESC
		read
	endif

endif

select fin_pripr
append blank


replace idfirma with cFirma
replace idvn with cIdVn
replace brnal with cBrNal
replace rbr with cRbr
replace datdok with dDatDok
replace d_p with cDP
replace opis with cOpis
replace brdok with cBrVeze
replace idkonto with cKtoProt
replace idpartner with ""

if ALLTRIM( cValuta ) == "KM"
	replace iznosbhd with nIznos
else
	replace iznosdem with nIznos
endif


return



// ---------------------------------------------
// vraca datum iz elba txt datumskog polja
// ---------------------------------------------
static function _g_elba_date( cDate )
local dDate 
dDate := CTOD( LEFT( cDate, 10 ) )
return dDate


// ---------------------------------------------
// vraca D/P za tip transakcije
// ---------------------------------------------
static function _g_elba_dp( cTransType )
local cRet := "1"

cTransType := ALLTRIM(cTransType)
do case
	case cTransType == "-"
		cRet := "1"
	case cTransType == "+"
		cRet := "2"
endcase

return cRet


// ---------------------------------------------
// vraca D/P za naknade
// ---------------------------------------------
static function _g_nakn_dp( cTransType )
local cRet := "1"

cTransType := ALLTRIM(cTransType)
do case
	case cTransType == "-"
		cRet := "1"
	case cTransType == "+"
		cRet := "2"
endcase

return cRet


// -----------------------------------------------
// vraca konto po pretpostavci...
// -----------------------------------------------
static function _g_konto( cTrans, cOpis )
local cKonto := "?????"
local cKtoKup := __k_kup

if "NR" $ cOpis
	cKonto := r_get_konto( "UPL_KONTO", "NR" )
	return cKonto
	
elseif "PRK" $ cOpis
	cKonto := r_get_konto( "UPL_KONTO", "PRK" )
	return cKonto
	
endif

// ako je uplata na nas racun onda je to KUPAC 2120
if ALLTRIM(cTrans) == "+"
	cKonto := cKtoKup
	return cKonto
endif

cOpis := KonvZnWin( cOpis )

if ALLTRIM(cTrans) == "-"

	do case
		
		case "PROVIZIJA" $ UPPER(cOpis)
			cKonto := r_get_konto( "UPL_KONTO", "PROVIZIJA" )
		
		case "PDV" $ cOpis
			cKonto := r_get_konto( "UPL_KONTO", "PDV")
		
		otherwise 
			cKonto := r_get_konto( "UPL_KONTO")
	endcase

endif

return cKonto

// --------------------------------------------------
// uzmi partnera za stavku
// --------------------------------------------------
static function _g_partn( cTrType, cTxt, cTrRN )
local nSeek

cTxt := KonvZnWin( cTxt )


if ALLTRIM(cTrRN) $ "#PRK#NR#"
	return ""
endif

// pokusaj pronaci po matrici
nSeek := ASCAN(aPartArr, {|xVal| xVal[1] == cTxt })

if nSeek <> 0

	// nasao sam ga u matrici
	return aPartArr[ nSeek, 2 ]
	
endif

if ALLTRIM( cTrType ) == "+"
	
	// trazi partnera za uplate na zr
	_g_part_upl( cTxt )

elseif ALLTRIM( cTrType ) == "-"
	
	// trazi partnera za isplate sa zr
	_g_part_isp( cTxt, cTrRN )
endif

return


// -----------------------------------------------
// vraca id partnera za uplate na zr
// -----------------------------------------------
static function _g_part_upl( cTxt )
local nTArea := SELECT()
local cDesc := ""
local cBank := ""
local cPartnId := "?????"
local nSeek

// uzmi banku i opis ako postoji "/"
if LEFT(cTxt, 1) == "/"
	
	cDesc := ALLTRIM( SUBSTR( cTxt, 18, LEN(cTxt) ) )
	cBank := ALLTRIM( SUBSTR( cTxt, 2, 16 ) )

else

	cDesc := ALLTRIM( cTxt )
	
endif

cDesc := KonvZnWin( cDesc )

// pokusaj naci po banci...
cPartnId := _src_p_bank( cBank )

// ako nema nista, pokusaj po nazivu....
if EMPTY(cPartnId)
	cPartnId := _src_p_desc( cDesc )
endif

// ako nema nista... ???
if EMPTY(cPartnId)
	
	Msgbeep("Nepostojeci partner !!!#Opis: " + PADR(cTxt, 50) + ;
		"")
	cPartnId := PADR(cDesc, 3) + ".."
	
	// otvori sifranik..
	p_firma(@cPartnId)
	
	// setuj partneru transakcijski racun
	_set_part_bank( cPartnId, cBank )

endif


nSeek := ASCAN(aPartArr, {|xVal| xVal[2] == cPartnId }) 

if nSeek == 0
	AADD(aPartArr, { cTxt, cPartnId })
endif

select (nTArea)

return cPartnId


// -----------------------------------------------
// vraca id partnera za isplate sa zr
// -----------------------------------------------
static function _g_part_isp( cTxt, cTrRN )
local nTArea := SELECT()
local cDesc := ""
local cBank := ""
local cPartnId := "?????"
local nSeek 

// uzmi banku i opis ako postoji "/"
if LEFT(cTxt, 1) == "/"
	cDesc := ALLTRIM( SUBSTR( cTxt, 18, LEN(cTxt) ) )
else
	cDesc := ALLTRIM( cTxt )
endif

cDesc := KonvZnWin( cDesc )


// pokusaj naci po banci...
cPartnId := _src_p_bank( cTrRN )

// ako nema nista, pokusaj po nazivu....
if EMPTY(cPartnId)
	
	//cPartnId := _src_p_desc( cDesc )
	
	Msgbeep("Nepostojeci partner !!!#Opis: " + PADR(cTxt, 50) + ;
		"#" + "trans.rn: " + cTrRN )
	
	cPartnId := PADR(cDesc, 3) + ".."
	
	// otvori sifranik..
	p_firma(@cPartnId)
	
	// setuj partneru transakcijski racun
	_set_part_bank( cPartnId, cTrRN )
	
endif


nSeek := ASCAN(aPartArr, {|xVal| xVal[2] == cPartnId }) 

if nSeek == 0
	AADD(aPartArr, { cTxt, cPartnId })
endif

select (nTArea)

return cPartnId


// ------------------------------------------------
// setovanje bank racuna za partnera
// ------------------------------------------------
static function _set_part_bank( cPartn, cBank )
local cRead := ""
local nTArea := SELECT()
local cOldBank
local cNewBank

// nema banke, nista...
if EMPTY(cBank)
	select (nTArea)
	return
endif

O_SIFK
O_SIFV

cNewBank := ""

// stara banka
cOldBank := ALLTRIM( IzSifKPartn( "BANK", cPartn ) )

// dodaj staru banku ako postoji
if !EMPTY( cOldBank )
	cNewBank += cOldBank
endif

// dodaj i , posto je potrebno
if RIGHT( cNewBank, 1 ) <> ","
	cNewBank += ","
endif

// dodaj konacno novu banku...
cNewBank += cBank

USifK( "PARTN", "BANK", cPartn, Unicode():New( cNewBank, .F. ) )

select (nTArea)

return



// ------------------------------------------------------
// pretraga partnera po nazivu ili dijelu naziva
// ------------------------------------------------------
static function _src_p_desc( cDesc )
local aTemp
local cTemp := ""
local cPartner := ""

if EMPTY(cDesc)
	return cPartner
endif

aTemp := TokToNiz( cDesc, " ")

if LEN(aTemp) > 1
	
	cTemp := ALLTRIM( aTemp[1] )

	if LEN( cTemp ) < 4
		cTemp += " " + ALLTRIM( aTemp[2] )
	endif

else
	
	cTemp := ALLTRIM(aTemp[1])

endif

O_PARTN
set order to tag "naz"
go top
seek cTemp

if FOUND()
	cPartner := partn->id
endif

return cPartner


// -------------------------------------------
// pretraga po banci - SIFV
// -------------------------------------------
static function _src_p_bank( cBank )
local cPartner := ""
local nTArea := SELECT()

if EMPTY(cBank)
	return cPartner
endif

O_PARTN
O_SIFV
select sifv
set order to tag "NAZ"

go top

seek PADR("PARTN", 8) + PADR("BANK", 4) 

do while !EOF() .and. field->id == PADR("PARTN", 8) ;
		.and. field->oznaka == PADR("BANK", 4)

	
	// ako trazena banka postoji vec u bankama...
	if ( cBank $ field->naz )
	
	  cPartner := PADR( ALLTRIM( sifv->idsif ), 6)
	
	  // sada pogledaj da li taj partner postoji uopste
	  select partn
 	  go top
	  seek cPartner

	  if FOUND() .and. field->id == cPartner
		exit
	  endif
	
	endif
	
	cPartner := ""
	
	// idi dalje i vidi ima li koga...
	select sifv
	
	skip

enddo

return cPartner



// ----------------------------------------------
// vraca opis ...
// ----------------------------------------------
static function _g_opis( cOpis )
local cRet := ""
local aTemp

aTemp := TokToNiz( cOpis, "/" )

cRet := ALLTRIM( aTemp[1] )

cRet := KonvZnWin( cRet )

return PADR( cRet, 40 )


// -------------------------------------------------
// vraca broj veze...
// -------------------------------------------------
static function _g_br_veze( cTrans, dDatum, cOpis )
local cRet := ""

do case 
	case "PDV" $ cOpis
		cRet := "pdv " + PADL( ALLTRIM( STR( MONTH(dDatum) - 1 ) ), 2, "0")
endcase

return cRet




