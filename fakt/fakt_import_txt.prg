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

// -------------------------------------------------------
// import dokumenta iz txt fajla sa barkod terminala
// -------------------------------------------------------
function imp_bterm()
local nRet
local cFile

// importuj podatke u pomocnu tabelu TEMP.DBF
nRet := iBTerm_data( @cFile )

if nRet = 0
	return
endif

// prebaci podatke u pripremu FAKT
bterm_to_pripr()

// pobrisi txt fajl
TxtErase( cFile, .t. )

return


// ----------------------------------------
// export podataka za terminal
// ----------------------------------------
function exp_bterm()
local nRet

nRet := eBTerm_data()

return


// -----------------------------------------------
// kopira TEMP.DBF -> PRIPR.DBF
// -----------------------------------------------
static function bterm_to_pripr()
local aParams := {}
local nCnt := 0
local cSave

private cTipVPC := "1"

O_FAKT_DOKS
O_FAKT_PRIPR
O_FAKT
O_ROBA
O_RJ
O_PARTN
O_TEMP

if _gForm( @aParams ) = 0
	return 0
endif

// sacuvaj parametar cijene
cSave := g13dcij

// setuj tip cijene koja se koristi
g13dcij := ALLTRIM( aParams[12] )

select temp
// idroba
set order to tag "1"
go top

do while !EOF()
	
	cTrm_roba := field->idroba
	nTrm_qtty := 0
	
	// saberi iste artikle
	do while !EOF() .and. field->idroba == cTrm_roba
		nTrm_qtty += field->kolicina
		skip
	enddo

	// imam konacan artikal
	select fakt_pripr
	append blank

	scatter()

	_idfirma := aParams[2]
	_idtipdok := aParams[3]
	_brdok := aParams[4]
	_datdok := aParams[5]
	_rbr := STR(++nCnt, 3)
	_idroba := cTrm_roba
	_kolicina := nTrm_qtty
	_idpartner := aParams[8]
	_dindem := "KM "
	_zaokr := 2
	_txt := ""

	// ovo setuje cijenu
	v_kolicina( "1" )
	select fakt_pripr

	// 1 roba tip U - nista
	a_to_txt( "", .t. )
	// 2 dodatni tekst otpremnice - nista
	a_to_txt( "", .t. )
	// 3 naziv partnera
	a_to_txt( aParams[9] , .t. )
	// 4 adresa
	a_to_txt( aParams[10] , .t. )
	// 5 ptt i mjesto
	a_to_txt( aParams[11] , .t. )
	// 6 broj otpremnice
	a_to_txt( "" , .t. )
	// 7 datum  otpremnice
	a_to_txt( DTOC( aParams[6] ) , .t. )
	// 8 broj ugovora - nista
	a_to_txt( "", .t. )
	// 9 datum isporuke - nista
	a_to_txt( DTOC( aParams[7] ), .t. )
	// 10 datum valute - nista
	a_to_txt( "", .t. )

	gather()

	select temp
enddo

// vrati parametar cijene
g13dcij := cSave

msgbeep("Kreiran je novi dokument i nalazi se u pripremi.")

return 1



// -----------------------------------------------
// forma uslova prenosa
// -----------------------------------------------
static function _gForm( aParam )
local GetList := {}
local nX := 1
local cVpMp := "1"
local cFirma := gFirma
local cTipDok := SPACE(2)
local cBrDok := SPACE(8)
local cPartner := SPACE(6)
local dDatdok := DATE()
local dDatOtpr := DATE()
local dDatIsp := DATE()
local nTArea := SELECT()
local cGen := "D"
local cMPCSet := " "

Box(, 15, 67 )
	
	@ m_x + nX, m_y + 2 SAY "Generisanje podataka iz barkod terminala:"

	++nX
	++nX

	@ m_x + nX, m_y + 2 SAY "(1) Veleprodaja"
	
	++nX
	
	@ m_x + nX, m_y + 2 SAY "(2) Maloprodaja" GET cVpMp ;
		VALID cVpMp $ "12"

	read

	++ nX
	++ nX

	// datum dokumenta
	
	@ m_x + nX, m_y + 2 SAY "Datum dok.:" GET dDatDok
	@ m_x + nX, col()+1 SAY "Datum otpr.:" GET dDatOtpr
	@ m_x + nX, col()+1 SAY "Datum isp.:" GET dDatIsp

	++ nX
	++ nX

	// vrsta i broj dokumenta
	
	// koji je tip dokumenta
	cTipDok := _gtdok( cVpMp )

	@ m_x + nX, m_y + 2 SAY "Dokument broj:" GET cFirma
	@ m_x + nX, col()+1 SAY "-" GET cTipDok ;
		VALID _nBrDok( cFirma, cTipDok, @cBrDok )
	@ m_x + nX, col()+1 SAY "-" GET cBrDok 
	
	++nX
	++nX

	// partner
	@ m_x + nX, m_y + 2 SAY "Partner:" GET cPartner ;
		VALID EMPTY(cPartner) .or. p_firma(@cPartner)

	++ nX
	++ nX

	if cVpMp == "2"

		// tip cijena
		@ m_x + nX, m_y + 2 SAY "Koristiti MPC ( /1/2/3...)" ;
			GET cMPCSet ;
			VALID cMPCSet $ " 123456"
	
		++ nX
		++ nX
	
	endif

	@ m_x + nX, m_y + 2 SAY "Izvrsiti transfer (D/N)?" GET cGen ;
		VALID cGen $ "DN" PICT "@!"

	read
BoxC()

if cGen == "N"
	return 0
endif

if LastKey() <> K_ESC

	// snimi parametre
	// [1]
	AADD( aParam, cVpMp )
	// [2]
	AADD( aParam, cFirma )
	// [3]
	AADD( aParam, cTipDok )
	// [4]
	AADD( aParam, cBrDok )
	// [5]
	AADD( aParam, dDatDok )
	// [6]
	AADD( aParam, dDatOtpr )
	// [7]
	AADD( aParam, dDatIsp )
	// [8]
	AADD( aParam, cPartner )

	select partn
	go top
	seek cPartner

	// [9]
	AADD( aParam, ALLTRIM(field->naz) )
	// [10]
	AADD( aParam, ALLTRIM(field->adresa) )
	// [11]
	AADD( aParam, ALLTRIM(field->ptt) )

	// [12]
	AADD( aParam, cMPCSet )

else
	return 0
endif

select (nTArea)

return 1


// -------------------------------------------------
// vraca tip dokumenta na osnovu tipa importa
// -------------------------------------------------
static function _gTdok( cTip )
local cRet := ""
do case
	case cTip == "1" 
		// veleprodaja - direktno racun
		cRet := "10"
	case cTip == "2"
		// maloprodaja
		cRet := "13"
endcase
return cRet


