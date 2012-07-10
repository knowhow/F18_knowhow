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


#include "fmk.ch"


// -----------------------------------------
// funkcija za labeliranje barkodova...
// -----------------------------------------
function label_bkod()
local cIBK
local cPrefix
local cSPrefix
local cBoxHead
local cBoxFoot
local lDelphi := .t.
private cKomLin
private Kol
private ImeKol

O_SIFK
O_SIFV
O_PARTN
O_ROBA
set order to tag "ID"
O_BARKOD
O_FAKT_PRIPR

SELECT FAKT_PRIPR

private aStampati := ARRAY( RECCOUNT() )

GO TOP

for i:=1 to LEN( aStampati )
	aStampati[ i ] := "D"
next

// setuj kolone za pripremu...
set_a_kol( @ImeKol, @Kol )

cBoxHead := "<SPACE> markiranje    |    <ESC> kraj"
cBoxFoot := "Priprema za labeliranje bar-kodova..."

Box(,20,50)

ObjDbedit("PLBK", 20, 50, {|| key_handler()}, cBoxHead, cBoxFoot, .t. , , , ,0)

BoxC()

if lDelphi
	print_delphi_label( aStampati )
else
	// stampanje deklaracija...
	//label_2_deklar(aStampati)
endif

close all
return


// --------------------------------
// nastimaj pointer na partnera...
// --------------------------------
function seek_partner(cPartner)
select partn
set order to tag "ID"
hseek cPartner
return


// -----------------------------------------------------
// setovanje kolone opcije pregleda labela....
// -----------------------------------------------------
static function set_a_kol( aImeKol, aKol )
local _i

aImeKol := {}
aKol := {}

AADD(aImeKol, {"IdRoba"    ,{|| IdRoba }} )
AADD(aImeKol, {"Kolicina"  ,{|| transform( Kolicina, "99999999.9" ) }} )
AADD(aImeKol, {"Stampati?" ,{|| bk_stamp_dn( aStampati[RECNO()] ) }} )

aKol:={}
for _i:=1 to LEN(aImeKol)
	AADD( aKol, _i )
next

return


// --------------------------------
// prikaz stampati ili ne stampati
// --------------------------------
static function bk_stamp_dn( cDN )
local cRet := ""

if cDN == "D"
	cRet := "-> DA <-"
else
	cRet := "      NE"
endif

return cRet



// --------------------------------
// Obrada dogadjaja u browse-u 
// tabele "Priprema za labeliranje 
// bar-kodova"
// --------------------------------
static function key_handler()

if Ch==ASC(' ')

	if aStampati[recno()]=="N"
		aStampati[recno()] := "D"
	else
		aStampati[recno()] := "N"
	endif

	return DE_REFRESH

endif

return DE_CONT



// ------------------------------------------------
// parametri labeliranja i barkod-ova
// ------------------------------------------------
function label_params()
local _box_x, _box_y
local _x := 1
local _br_dok := fetch_metric( "labeliranje_ispis_brdok", nil, "N" )
local _jmj := fetch_metric( "labeliranje_ispis_jmj", nil, "N" )
local _prefix := fetch_metric( "labeliranje_barkod_prefix", nil, SPACE(10) )
local _auto_gen := fetch_metric( "labeliranje_barkod_automatsko_generisanje", nil, "N" ) 
local _auto_formula := fetch_metric( "labeliranje_barkod_auto_formula", nil, SPACE(10) )
local _ean_code := fetch_metric( "labeliranje_barkod_auto_ean_kod", nil, SPACE(10) )
local _tb := fetch_metric( "barkod_tezinski_barkod", nil, "N" )
local _tb_prefix := PADR( fetch_metric( "barkod_prefiks_tezinskog_barkoda", nil, SPACE(100) ), 100 )
local _bk_len := fetch_metric( "barkod_tezinski_duzina_barkoda", nil, 0 )
local _tez_len := fetch_metric( "barkod_tezinski_duzina_tezina", nil, 0 )
local _tez_div := fetch_metric( "barkod_tezinski_djelitelj", nil, 10000 )

_box_x := 20
_box_y := 70

Box(, _box_x, _box_y )

	@ m_x + _x, m_y + 2 SAY "*** Barkod stampa, podesenja" 

	++ _x
	++ _x

	@ m_x + _x, m_y + 2 SAY "Prikaz broja dokumenta na naljepnici    (D/N)" GET _br_dok VALID _br_dok $ "DN" PICT "@!"

	++ _x

	@ m_x + _x, m_y + 2 SAY "Prikaz jedinice mjere kod opisa artikla (D/N)" GET _jmj VALID _jmj $ "DN" PICT "@!"

	++ _x

	@ m_x + _x, m_y + 2 SAY "Barkod prefix" GET _prefix

	++ _x

	@ m_x + _x, m_y + 2 SAY "Automatsko generisanje barkod-a (D/N)" GET _auto_gen VALID _auto_gen $ "DN" PICT "@!"

	++ _x

	@ m_x + _x, m_y + 2 SAY "Automatsko generisanje, auto formula:" GET _auto_formula
	@ m_x + _x, col() + 1 SAY "EAN:" GET _ean_code

	++ _x

	@ m_x + _x, m_y + 2 SAY "Koristenje tezinskog barkod-a (D/N)" GET _tb VALID _tb $ "DN" PICT "@!"
	
	++ _x
	
	@ m_x + _x, m_y + 2 SAY "Prefiks tezinskog barkod-a" GET _tb_prefix PICT "@S30"
	
	++ _x
	
	@ m_x + _x, m_y + 2 SAY "Tezinski: duzina barkod-a" GET _bk_len PICT "99"
	@ m_x + _x, col() + 2 SAY "duzina tezine:" GET _tez_len PICT "99"
	@ m_x + _x, col() + 2 SAY "djelitelj:" GET _tez_div PICT "99999999"
	
	read

BoxC()

if LastKey() <> K_ESC

	// save params
	set_metric( "labeliranje_ispis_brdok", nil, _br_dok )
	set_metric( "labeliranje_ispis_jmj", nil, _jmj )
	set_metric( "labeliranje_barkod_prefix", nil, _prefix )
	set_metric( "labeliranje_barkod_automatsko_generisanje", nil, _auto_gen ) 
	set_metric( "labeliranje_barkod_auto_formula", nil, _auto_formula )
	set_metric( "labeliranje_barkod_auto_ean_kod", nil, _ean_code )
	set_metric( "barkod_tezinski_barkod", nil, _tb )
	set_metric( "barkod_prefiks_tezinskog_barkoda", nil, ALLTRIM( _tb_prefix ) )
	set_metric( "barkod_tezinski_duzina_barkoda", nil, _bk_len )
	set_metric( "barkod_tezinski_duzina_tezina", nil, _tez_len )
	set_metric( "barkod_tezinski_djelitelj", nil, _tez_div )

endif

return




// -----------------------------------
// labeliranje delphi 
// -----------------------------------
static function print_delphi_label( aStampati, modul )
local nRezerva
local cIBK
local cLinija1
local cLinija2
local cPrefix
local cSPrefix
local nRobNazLen
local cIdTipDok
local lBKBrDok := .f.
local lBKJmj := .f.
local cBrDok

if modul == NIL
	modul := "FAKT"
endif

if fetch_metric( "labeliranje_ispis_jmj", nil, "N" ) == "D" 
	lBKJmj := .t.
endif

if fetch_metric( "labeliranje_ispis_brdok", nil, "N" ) == "D"
	lBKBrDok := .t.
endif

if modul == "KALK"
	cIdTipDok := "IDVD"
else
	cIdTipDok := "IDTIPDOK"
endif

nRezerva := 0

cLinija1 := PADR( "Proizvoljan tekst", 45 )
cLinija2 := PADR( "Uvoznik:" + ALLTRIM( gNFirma ), 45 )

Box(, 4, 75 )

	@ m_x+0, m_y+25 SAY " LABELIRANJE BAR KODOVA "

	@ m_x+2, m_y+ 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva>=0 PICT "99"

	if !lBKBrDok
		@ m_x+3, m_y+2 SAY "Linija 1  :" GET cLinija1
	endif

	@ m_x+4, m_y+ 2 SAY "Linija 2  :" GET cLinija2

	READ

	ESC_BCR

BoxC()

cPrefix := ALLTRIM( fetch_metric( "labeliranje_barkod_prefix", nil, "" ) )
cSPrefix := "N"

if !EMPTY( cPrefix )
	cSPrefix := Pitanje(, "Stampati barkodove koji NE pocinju sa +'" + cPrefix + "' ?", "N" )
endif

SELECT BARKOD
ZAP

SELECT FAKT_PRIPR
GO TOP

do while !EOF()

	if aStampati[ RECNO() ] == "N"
		SKIP 1
		loop
	endif
	
	SELECT ROBA
	HSEEK FAKT_PRIPR->idroba
	
	if EMPTY( field->barkod ) .and. fetch_metric( "labeliranje_barkod_automatsko_generisanje", nil, "N" ) 
		
		private cPom := ALLTRIM( fetch_metric( "labeliranje_barkod_auto_formula", nil, "" ) )
		
		// kada je barkod prazan, onda formiraj sam interni barkod
		cIBK := ALLTRIM( fetch_metric( "labeliranje_barkod_prefix", nil, "" ) ) + &cPom 
		
		if ALLTRIM( fetch_metric( "labeliranje_barkod_auto_ean_kod", nil, "" ) ) == "13"
			cIBK := NoviBK_A()
		endif
		
		PushWa()
		
		set order to tag "BARKOD"
		seek cIBK
		
		if found()
			PopWa()
			MsgBeep("Prilikom formiranja internog barkoda##vec postoji kod: "+cIBK+"??##"+"Moracete za artikal " + fakt_pripr->idroba + " sami zadati jedinstveni barkod !")
			replace barkod with "????"
		else
			PopWa()
			replace barkod with cIBK
		endif
	endif
	
	if cSprefix == "N"
		// ne stampaj koji nemaju isti prefix
		if LEFT( field->barkod, LEN( cPrefix )) != cPrefix
			select fakt_pripr
			skip
			loop
		endif
	endif

	SELECT BARKOD

	for i := 1 to fakt_pripr->kolicina + IF( fakt_pripr->kolicina > 0, nRezerva, 0 )
		
		APPEND BLANK
		REPLACE id WITH ( fakt_pripr->idRoba )
		
		if lBKBrDok
			cBrDok := TRIM( fakt_pripr->(idfirma + "-" + &cIdTipDok + "-" + brdok))
			REPLACE l1 WITH ( DTOC(fakt_pripr->datdok) + ", " + cBrDok )
		else
			REPLACE l1 WITH (cLinija1)
		endif
		
		REPLACE l2 WITH (cLinija2)
		
		REPLACE vpc WITH ROBA->vpc
		REPLACE mpc WITH ROBA->mpc
		REPLACE barkod WITH roba->barkod
	
		nRobNazLen := LEN(roba->naz)
		
		if !lBKJmj
			REPLACE naziv WITH (TRIM(LEFT(ROBA->naz, nRobNazLen)))
		else
			REPLACE naziv WITH (TRIM(LEFT(ROBA->naz, nRobNazLen)) + " ("+TRIM(ROBA->jmj)+")")
		endif
	next

	SELECT FAKT_PRIPR
	SKIP 1

enddo

select (F_BARKOD)
use

close all

f18_rtm_print( "barkod", "barkod", "1" )

return




