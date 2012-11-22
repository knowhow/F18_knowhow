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


// pos komande
static F_POS_RN := "POS_RN"
static ANSW_DIR := "answer"
static POLOG_LIMIT := 100

// ocekivana matrica
// aData
//
// 1 - broj racuna
// 2 - redni broj
// 3 - id roba
// 4 - roba naziv
// 5 - cijena
// 6 - kolicina
// 7 - tarifa
// 8 - broj racuna za storniranje
// 9 - roba plu
// 10 - plu cijena - cijena iz sifranika
// 11 - popust
// 12 - barkod
// 13 - vrsta placanja
// 14 - total racuna
// 15 - datum racuna

// --------------------------------------------------------
// fiskalni racun (FPRINT)
// aData - podaci racuna
// lStorno - da li se stampa storno ili ne (.T. ili .F. )
// --------------------------------------------------------
function fprint_rn( dev_params, items, head, storno )
local _sep := ";"
local _data := {}
local _struct := {}
local _err := 0

if storno == NIL
	storno := .f.
endif

// uzmi strukturu tabele za pos racun
_struct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
_data := _fprint_rn( items, head, storno, dev_params )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], _struct, _data )

return _err






// --------------------------------------------------
// provjerava unos pologa, maksimalnu vrijednost 
// --------------------------------------------------
static function _max_polog( polog )
local _ok := .t.

if polog > POLOG_LIMIT
    if Pitanje(, "Polog je > " + ALLTRIM( STR( POLOG_LIMIT) ) + "! Da li je ovo ispravan unos ?", "N" ) == "N"
        _ok := .f.
    endif
endif

return _ok



// ----------------------------------------------------
// fprint: unos pologa u printer
// ----------------------------------------------------
function fprint_polog( dev_params, nPolog )
local cSep := ";"
local aPolog := {}
local aStruct := {}

if nPolog == nil
	nPolog := 0
endif

// ako je polog 0, pozovi formu za unos
if nPolog = 0

   Box(,1,60)
	@ m_x + 1, m_y + 2 SAY "Zaduzujem kasu za:" GET nPolog ;
		PICT "999999.99" VALID _max_polog( nPolog )
	read
   BoxC()

   if nPolog = 0
	msgbeep("Polog mora biti <> 0 !")
	return
   endif

   if LastKey() == K_ESC
	return
   endif

endif

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPolog := _fp_polog( nPolog )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aPolog )

return



// ----------------------------------------------------
// fprint: dupliciranje racuna
// ----------------------------------------------------
function fprint_double( dev_params )
local cSep := ";"
local aDouble := {}
local aStruct := {}
local dD_from := DATE()
local dD_to := dD_from
local cTH_from := "12"
local cTM_from := "30"
local cTH_to := "12"
local cTM_to := "31"
local cT_from
local cT_to
local cType := "F"


Box(,10,60)

    SET CURSOR ON
	
	@ m_x + 1, m_y + 2 SAY "Za datum od:" GET dD_from 
	@ m_x + 1, col() + 1 SAY "vrijeme od (hh:mm):" GET cTH_from
	@ m_x + 1, col() SAY ":" GET cTM_from
	
	@ m_x + 2, m_y + 2 SAY "         do:" GET dD_to
	@ m_x + 2, col() + 1 SAY "vrijeme do (hh:mm):" GET cTH_to
	@ m_x + 2, col() SAY ":" GET cTM_to

	@ m_x + 3, m_y + 2 SAY "--------------------------------------"

	@ m_x + 4, m_y + 2 SAY "A - duplikat svih dokumenata"
	@ m_x + 5, m_y + 2 SAY "F - duplikat fiskalnog racuna"
	@ m_x + 6, m_y + 2 SAY "R - duplikat reklamnog racuna"
	@ m_x + 7, m_y + 2 SAY "Z - duplikat Z izvjestaja"
	@ m_x + 8, m_y + 2 SAY "X - duplikat X izvjestaja"
	@ m_x + 9, m_y + 2 SAY "P - duplikat periodicnog izvjestaja" ;
		GET cType ;
		VALID cType $ "AFRZXP" PICT "@!"

	read
BoxC()

if LastKey() == K_ESC
	return
endif

// dodaj i sekunde na kraju
cT_from := cTH_from + cTM_from + "00"
cT_to := cTH_to + cTM_to + "00"

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDouble := _fp_double( cType, dD_from, dD_to, cT_from, cT_to )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aDouble )

return



// ----------------------------------------------------
// zatvori nasilno racun sa 0.0 KM iznosom
// ----------------------------------------------------
function fprint_void( dev_params )
local cSep := ";"
local aVoid := {}
local aStruct := {}

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aVoid := _fp_void_rn()

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aVoid )

return



// ----------------------------------------------------
// print non-fiscal tekst
// ----------------------------------------------------
function fprint_nf_txt( dev_params, cTxt )
local cSep := ";"
local aTxt := {}
local aStruct := {}

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aTxt := _fp_nf_txt( to_win1250_encoding( cTxt ) )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aTxt )

return


// ----------------------------------------------------
// brisanje PLU iz uredjaja
// ----------------------------------------------------
function fprint_delete_plu( dev_params, silent )
local cSep := ";"
local aDel := {}
local aStruct := {}
local nMaxPlu := 0

if silent == NIL
	silent := .t.
endif

if !silent 
	
	if !SIGMASIF("RESET")
		return
	endif

	// daj mi vrijednost plu do koje cu resetovati...
	Box(,1,50)
		@ m_x + 1, m_y + 2 SAY "Unesi max.plu vrijednost:" GET nMaxPlu PICT "9999999999"
		read
	BoxC()

	if LastKey() == K_ESC
		return
	endif

endif

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDel := _fp_del_plu( nMaxPlu, dev_params )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aDel )

return



// ----------------------------------------------------
// zatvori racun
// ----------------------------------------------------
function fprint_rn_close( dev_params )
local cSep := ";"
local aClose := {}
local aStruct := {}

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aClose := _fp_close_rn()

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aClose )

return


// ----------------------------------------------------
// manualno zadavanje komandi
// ----------------------------------------------------
function fprint_manual_cmd( dev_params )
local cSep := ";"
local aManCmd := {}
local aStruct := {}
local nCmd := 0
local cCond := SPACE(150)
local cErr := "N"
local nErr := 0
private GetList:={}

Box(,4, 65)
	
	@ m_x+1, m_y+2 SAY "**** manuelno zadavanje komandi ****" 
	
	@ m_x+2, m_y+2 SAY "   broj komande:" GET nCmd PICT "999" ;
		VALID nCmd > 0
	@ m_x+3, m_y+2 SAY "        komanda:" GET cCond PICT "@S40"
	
	@ m_x+4, m_y+2 SAY "provjera greske:" GET cErr PICT "@!" ;
		VALID cErr $ "DN"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aManCmd := _fp_man_cmd( nCmd, cCond )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aManCmd )

if cErr == "D"
	
	// provjeri gresku
	nErr := fprint_read_error( dev_params, 0 )

	if nErr <> 0
		msgbeep("Postoji greska !!!")
	endif

endif

return



// ----------------------------------------------------
// izvjestaj o prodanim PLU
// ----------------------------------------------------
function fprint_sold_plu( dev_params )
local cSep := ";"
local aPlu := {}
local aStruct := {}
local nErr := 0
local cType := "0"

Box(,4,50)
	@ m_x + 1, m_y + 2 SAY "**** pregled artikala ****" COLOR "I"
	@ m_x + 3, m_y + 2 SAY "0 - samo u danasnjem prometu "
	@ m_x + 4, m_y + 2 SAY "1 - svi programirani          -> " GET cType ;
		VALID cType $ "01"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// pobrisi answer fajl
fprint_delete_answer( dev_params )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPlu := _fp_sold_plu( cType )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aPlu )


return



// ----------------------------------------------------
// dnevni fiskalni izvjestaj
// ----------------------------------------------------
function fprint_daily_rpt( dev_params )
local cSep := ";"
local aDaily := {}
local aStruct := {}
local nErr := 0
local cType := "0"
local _rpt_type := "Z"
local _param_date, _param_time
local _last_date, _last_time

cType := fetch_metric( "fiscal_fprint_daily_type", my_user(), cType )

// uslovi
Box(,4,50)
	@ m_x + 1, m_y + 2 SAY "**** dnevni izvjestaj ****" COLOR "I"
	@ m_x + 3, m_y + 2 SAY "0 - z-report"
	@ m_x + 4, m_y + 2 SAY "2 - x-report  -> " GET cType ;
		VALID cType $ "02"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// snimi parametar za naredni put
set_metric( "fiscal_fprint_daily_type", my_user(), cType )

if cType == "2"
    _rpt_type := "X"
endif

_param_date := "zadnji_" + _rpt_type + "_izvjestaj_datum"
_param_time := "zadnji_" + _rpt_type + "_izvjestaj_vrijeme"

// iscitaj zadnje formirane izvjestaje...
_last_date := fetch_metric( _param_date, nil, CTOD("") )
_last_time := PADR( fetch_metric( _param_time, nil, "" ), 5 )

if _rpt_type == "Z" .and. _last_date == DATE()
    MsgBeep( "Zadnji Z izvjestaj radjen: " + DTOC( _last_date ) + ", u " + _last_time )
endif

if Pitanje(,"Stampati dnevni izvjestaj ?", "D") == "N"
	return
endif

// pobrisi answer fajl
fprint_delete_answer( dev_params )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDaily := _fp_daily_rpt( cType )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aDaily )

// procitaj error
nErr := fprint_read_error( dev_params, 0 )

if nErr <> 0
	msgbeep("Postoji greska !!!")
	return
endif

// upisi u sql/db datum i vrijeme formiranja dnevnog izvjestaja
set_metric( _param_date, nil, DATE() )
set_metric( _param_time, nil, TIME() )

// pokrecem komandu za brisanje artikala iz uredjaja
// ovo je bitno za FP550 uredjaj
// MP55LD ce ignorisati, nece se nista desiti!

// ako je dinamicki PLU i tip izvjestaja "Z"
if dev_params["plu_type"] == "D" .and. _rpt_type == "Z"

	msgo("Nuliram stanje uredjaja ...")

	// ako je printer onda posalji ovu komandu !
	if dev_params["type"] == "P"

		// pobrisi answer fajl
		fprint_delete_answer( dev_params )

		// daj mu malo prostora
		sleep(10)

		// posalji komandu za reset PLU u uredjaju
		fprint_delete_plu( dev_params, .t. )

		// prekontrolisi gresku
		// ovdje cemo koristiti veci timeout
		nErr := fprint_read_error( dev_params, 0, NIL, 500 )

		if nErr <> 0
			msgbeep("Postoji greska !!!")
			return
		endif
	endif
	
	msgc()

	// setuj brojac PLU na 0 u parametrima !
	auto_plu( .t., .t., dev_params )

	msgbeep("Stanje fiskalnog uredjaju je nulirano.")

endif

// ako se koristi opcija automatskog pologa u ureðaj
if dev_params["auto_avans"] <> 0
	
	msgo("Automatski unos pologa u uredjaj... sacekajte.")
	
	// daj malo prostora
	sleep(10)
	
	// odmah pozovi i automatski polog
	fprint_polog( dev_params )
	
	msgc()

endif

return


// ----------------------------------------------------
// fiskalni izvjestaj za period
// ----------------------------------------------------
function fprint_per_rpt( dev_params )
local cSep := ";"
local aPer := {}
local aStruct := {}
local _err_level := 0
local dD_from := DATE() - 30
local dD_to := DATE()
private GetList:={}

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Za period od" GET dD_from 
	@ m_x + 1, col() + 1 SAY "do" GET dD_to
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPer := _fp_per_rpt( dD_from, dD_to )

_a_to_file( dev_params["out_dir"], dev_params["out_file"], aStruct, aPer )

// procitaj error
_err_level := fprint_read_error( dev_params, 0 )

if _err_level <> 0
	msgbeep("Postoji greska !!!")
endif

return _err_level




// ----------------------------------------
// vraca popunjenu matricu za ispis racuna
// FPRINT driver
// ----------------------------------------
static function _fprint_rn( aData, aKupac, lStorno, params )
local aArr := {}
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local i
local cRek_rn := ""
local cRnBroj
local cOperator := "1"
local cOp_pwd := "000000"
local nTotal := 0
local cVr_placanja := "0"
local _convert_852 := .t.

// provjeri operatera i lozinku iz podesenja...
if !EMPTY( params["op_id"] )
    cOperater := params["op_id"]
endif

if !EMPTY( params["op_pwd"] )
    cOp_pwd := params["op_pwd"]
endif

cVr_placanja := ALLTRIM( aData[1, 13] )
nTotal := aData[1, 14]

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, 
//         rek_rn, plu, plu_cijena, popust, barkod, vrsta plac, total racuna }

// prvo dodaj artikle za prodaju...
_a_fp_articles( @aArr, aData, lStorno, params )

// broj racuna
cRnBroj := ALLTRIM( aData[1,1] )

// logic je uvijek "1"
cLogic := "1"

// 1) otvaranje fiskalnog racuna

cTmp := "48"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += params["iosa"]
cTmp += cSep
cTmp += cOperator
cTmp += cSep
cTmp += cOp_pwd
cTmp += cSep

if lStorno == .t.
	
	cRek_rn := ALLTRIM( aData[ 1, 8 ] )
	cTmp += cSep
	cTmp += cRek_rn
	cTmp += cSep
else
	cTmp += cSep
endif

// dodaj ovu stavku u matricu...
AADD( aArr, { cTmp } )

// 2. prodaja stavki

for i := 1 to LEN( aData )

	cTmp := "52"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// kod PLU
	cTmp += ALLTRIM( STR( aData[i, 9] ) )
	cTmp += cSep
	
	// kolicina 0-99999.999
	cTmp += ALLTRIM(STR( aData[i, 6], 12, 3 ))
	cTmp += cSep

	// popust 0-99.99%
	if aData[i, 10] > 0
		cTmp += "-" + ALLTRIM(STR( aData[i, 11], 10, 2 ))
	endif
	cTmp += cSep

	// dodaj u matricu prodaju...
	AADD( aArr, { cTmp } )
	
next

// 3. subtotal

cTmp := "51"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )


// 4. nacin placanja
cTmp := "53"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

// 0 - cash
// 1 - card
// 2 - chek
// 3 - virman

if ( cVr_placanja <> "0" .and. !lStorno ) .or. ( cVr_placanja == "0" .and. nTotal <> 0 .and. !lStorno )
 	
	// imamo drugu vrstu placanja...
	cTmp += cVr_placanja
	cTmp += cSep
	cTmp += ALLTRIM( STR( nTotal, 12, 2 ) )
	cTmp += cSep

else

	cTmp += cSep
	cTmp += cSep

endif

AADD( aArr, { cTmp } )

// radi zaokruzenja kod virmanskog placanja 
// salje se jos jedna linija 53 ali prazna
if cVr_placanja <> "0" .and. !lStorno 
	
	cTmp := "53"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep	
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	cTmp += cSep
	cTmp += cSep

	AADD( aArr, { cTmp } )

endif

// 5. kupac - podaci
if aKupac <> NIL .and. LEN( aKupac ) > 0

	// aKupac = { idbroj, naziv, adresa, ptt, mjesto }

	// postoje podaci...
	cTmp := "55"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// 1. id broj
	cTmp += ALLTRIM( aKupac[ 1, 1 ] )
	cTmp += cSep
	
    // 2. naziv
	cTmp += ALLTRIM( PADR( to_win1250_encoding( hb_strtoutf8( aKupac[ 1, 2 ]), _convert_852 ), 36 ) )
	cTmp += cSep

	// 3. adresa
	cTmp += ALLTRIM( PADR( to_win1250_encoding( hb_strtoutf8(aKupac[ 1, 3 ]), _convert_852 ), 36 ) ) 
	cTmp += cSep
	
	// 4. ptt, mjesto
	cTmp += ALLTRIM( to_win1250_encoding( hb_strtoutf8(aKupac[ 1, 4 ]), _convert_852 ) ) + " " + ;
		ALLTRIM( to_win1250_encoding( hb_strtoutf8(aKupac[ 1, 5 ]), _convert_852 ) )

	cTmp += cSep
	cTmp += cSep
	cTmp += cSep

	AADD( aArr, { cTmp } )

endif

// 6. otvaranje ladice
cTmp := "106"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )



// 7. zatvaranje racuna
cTmp := "56"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// manualno zadavanje komandi
// ---------------------------------------------------
static function _fp_man_cmd( nCmd, cCond )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// broj komande
cTmp := ALLTRIM(STR(nCmd))

// ostali regularni dio
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

if !EMPTY( cCond )
	// ostatak komande
	cTmp += ALLTRIM(cCond)
endif

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// printanje non-fiscal teksta na uredjaj
// ---------------------------------------------------
static function _fp_nf_txt( cTxt )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// otvori non-fiscal racun
cTmp := "38"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )


// ispisi tekst
cTmp := "42"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += ALLTRIM( PADR( cTxt, 30 ) )
cTmp += cSep

AADD( aArr, { cTmp } )


// zatvori non-fiscal racun
cTmp := "39"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// brisi artikle iz uredjaja
// ---------------------------------------------------
static function _fp_del_plu( nMaxPlu, dev_params )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
// komanda za brisanje artikala je 3
local cCmd := "3"
local cCmdType := ""
local nTArea := SELECT()
local nLastPlu := 0

if nMaxPlu <> 0
	// ovo ce biti granicni PLU za reset
	nLastPlu := nMaxPlu
else
	// uzmi zadnji PLU iz parametara
	nLastPlu := last_plu( dev_params["id"] )
endif

select (nTArea)

// brisat ces sve od plu = 1 do zadnji plu
cCmdType := "1;" + ALLTRIM( STR( nLastPlu ) )

cLogic := "1"

// brisanje PLU kodova iz uredjaja
cTmp := "107"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cCmd
cTmp += cSep
cTmp += cCmdType
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// zatvori racun
// ---------------------------------------------------
static function _fp_close_rn()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// 7. zatvaranje racuna
cTmp := "56"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr


// --------------------------------------------------------
// vraca formatiran datum za opcije izvjestaja
// --------------------------------------------------------
function _fix_date( dDate )
local cRet := ""
local nM := MONTH( dDate )
local nD := DAY( dDate )
local nY := YEAR( dDate )

// format datuma treba da bude DDMMYY
cRet := PADL( ALLTRIM(STR(nD)), 2, "0" )
cRet += PADL( ALLTRIM(STR(nM)), 2, "0" )
cRet += RIGHT( ALLTRIM(STR(nY)), 2 )

return cRet


// ---------------------------------------------------
// dnevni fiskalni izvjestaj
// ---------------------------------------------------
static function _fp_per_rpt( dD_from, dD_to )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local cD_from
local cD_to
local aArr := {}

// konvertuj datum
cD_from := _fix_date( dD_from )
cD_to := _fix_date( dD_to )

cLogic := "1"

cTmp := "79"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cD_from
cTmp += cSep
cTmp += cD_to
cTmp += cSep
cTmp += cSep
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// izvjestaj o prodanim PLU-ovima
// ---------------------------------------------------
static function _fp_sold_plu( cType )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

// 0 - samo u toku dana
// 1 - svi programirani

if cType == nil
	cType := "0"
endif

cLogic := "1"

cTmp := "111"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr




// ---------------------------------------------------
// dnevni fiskalni izvjestaj
// ---------------------------------------------------
static function _fp_daily_rpt( cType )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
// "N" - bez ciscenja prodaje
// "A" - sa ciscenjem prodaje
local cOper := "A"

// 0 - "Z"
// 2 - "X"
if cType == nil
	cType := "0"
endif

if cType == "2"
    // kod X reporta ne treba zadnji parametar
    cOper := ""
endif

cLogic := "1"

cTmp := "69"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep

// ovo se dodaje samo kod Z reporta
if !EMPTY ( cOper )
    cTmp += cOper
    cTmp += cSep
endif
	
AADD( aArr, { cTmp } )

return aArr




// ------------------------------------------------------------------
// dupliciranje dokumenta
// ------------------------------------------------------------------
static function _fp_double( cType, dD_from, dD_to, cT_from, cT_to )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
local cStart := ""
local cEnd := ""
local cParam := "0"

// sredi start i end linije
cStart := _fix_date(dD_from) + cT_from
cEnd := _fix_date(dD_to) + cT_to

cLogic := "1"

cTmp := "109"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep
cTmp += cStart
cTmp += cSep
cTmp += cEnd
cTmp += cSep
cTmp += cParam
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr

// ---------------------------------------------------
// unos pologa u printer
// ---------------------------------------------------
static function _fp_polog( nIznos )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
local cZnak := "+"

if nIznos < 0
	cZnak := ""
endif

cLogic := "1"

cTmp := "70"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cZnak + ALLTRIM(STR( nIznos ))
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr


// ---------------------------------------------------
// zatvori nasilno racun sa 0.0 iznosom
// ---------------------------------------------------
static function _fp_void_rn()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

cTmp := "301"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr


// ----------------------------------------------------
// dodaj artikle za racun
// ----------------------------------------------------
static function _a_fp_articles( aArr, aData, lStorno, dev_params )
local i
local cTmp := ""
// opcija dodavanja artikla u printer <1|2> 
// 1 - dodaj samo jednom
// 2 - mozemo dodavati vise puta
local cOp_add := "2"
// opcija promjene cijene u printeru
local cOp_ch := "4"
local cLogic
local cLogSep := ","
local cSep := ";"
local _convert_852 := .t.

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, 
//         rek_rn, plu, plu_cijena, popust }

cLogic := "1"

for i:=1 to LEN( aData )
	
	// 1. dodavanje artikla u printer
	
	cTmp := "107"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// opcija dodavanja "2"
	cTmp += cOp_add
	cTmp += cSep
	
	// poreska stopa
	cTmp += fiscal_txt_get_tarifa( aData[ i, 7 ], dev_params["pdv"], "FPRINT" )
	cTmp += cSep
	
	// plu kod 
	cTmp += ALLTRIM( STR( aData[ i, 9 ]) )
	cTmp += cSep

	// plu cijena
	cTmp += ALLTRIM(STR( aData[ i, 10 ], 12, 2 ))
	cTmp += cSep
	
	// plu naziv
	cTmp += to_win1250_encoding( ALLTRIM( PADR( hb_strtoutf8(aData[ i, 4 ]), 32 ) ), _convert_852 )
	cTmp += cSep

	AADD( aArr, { cTmp } )
	
	// 2. dodavanje stavke promjena cijene - ako postoji
	
	cTmp := "107"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// opcija dodavanja "4"
	cTmp += cOp_ch
	cTmp += cSep
	
	// plu kod 
	cTmp += ALLTRIM( STR( aData[ i, 9 ]) )
	cTmp += cSep
	
	// plu cijena
	cTmp += ALLTRIM(STR( aData[ i, 10 ], 12, 2 ))
	cTmp += cSep

	AADD( aArr, { cTmp } )

next

return




// ----------------------------------------------
// pobrisi answer fajl
// ----------------------------------------------
function fprint_delete_answer( params )
local _f_name

_f_name := params["out_dir"] + ANSW_DIR + SLASH + params["out_answer"]

if EMPTY( params["out_answer"] )
	_f_name := params["out_dir"] + ANSW_DIR + SLASH + params["out_file"]
endif

// ako postoji fajl obrisi ga
if FILE( _f_name )
	if FERASE( _f_name ) = -1
		msgbeep("Greska sa brisanjem fajla odgovora !")
	endif
endif

return


// ----------------------------------------------
// pobrisi out fajl
// ----------------------------------------------
function fprint_delete_out( file_path )

if FILE( file_path )
    if FERASE( file_path ) = -1
	    msgbeep("Greska sa brisanjem izlaznog fajla !")
    endif
endif

return


// ------------------------------------------------
// citanje gresaka za FPRINT driver
// vraca broj
// 0 - sve ok
// -9 - ne postoji answer fajl
// 
// nFisc_no - broj fiskalnog isjecka
// ------------------------------------------------
function fprint_read_error( dev_params, fiscal_no, storno, time_out )
local _err_level := 0
local _f_name
local _i
local _err_tmp
local _err_line
local _time
local _serial := dev_params["serial"]
local _o_file, _msg, _tmp

if storno == NIL
    storno := .f.
endif

if time_out == NIL
    time_out := dev_params["timeout"]
endif

// TEST rezim
if dev_params["print_fiscal"] == "T"
    // sacekaj malo, vrati fiskalni broj 100 i izadji...
    MsgO( "TEST: emulacija stampe na fiskalni uredjaj..." )
    sleep(4)
    MsgC()
    fiscal_no := 100
    return _err_level
endif

_time := time_out

// primjer: c:\fprint\answer\answer.txt
_f_name := dev_params["out_dir"] + ANSW_DIR + SLASH + dev_params["out_answer"]

// ako se koristi isti answer kao i input fajl
if EMPTY( ALLTRIM( dev_params["out_answer"] ) )
	_f_name := dev_params["out_dir"] + ANSW_DIR + SLASH + dev_params["out_file"]
endif

Box( , 3, 60 ) 

@ m_x + 1, m_y + 2 SAY hb_utf8tostr("Uređaj ID:") + ALLTRIM( STR( dev_params["id"] ) ) + ;
    " : " + PADR( dev_params["name"], 40 )

do while _time > 0
	
	-- _time
    
	@ m_x + 3, m_y + 2 SAY PADR( hb_Utf8ToStr("Čekam odgovor fiskalnog uređaja: ") + ;
		ALLTRIM( STR( _time ) ), 48)

	sleep(1)

#ifdef TEST
    if .t.
#else
    if FILE( _f_name )
#endif
		// fajl se pojavio - izadji iz petlje !
        log_write("FISC: fajl odgovora se pojavio", 7)
		exit
	endif

    if _time == 0 .or. LastKey() == K_ALT_Q
        log_write("FISC ERR: timeout !", 2)
        BoxC()

        fiscal_no := 0
        return -9
    endif

enddo

BoxC()

#ifndef TEST
if !FILE( _f_name )

	msgbeep("Fajl " + _f_name + " ne postoji !!!")
	fiscal_no := 0
	_err_level := -9
	return _err_level

endif
#endif

fiscal_no := 0
_fiscal_txt := ""

_f_name := ALLTRIM( _f_name )

_o_file := TFileRead():New( _f_name )
_o_file:Open()

if _o_file:Error()

	_err_tmp := "FISC ERR: " + _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " )
    log_write( _err_tmp, 2 )
    MsgBeep( _err_tmp )
    _err_level := -9
	return _err_level

endif

_tmp := ""

// prodji kroz svaku liniju i procitaj zapise
while _o_file:MoreToRead()
	
	// uzmi u cErr liniju fajla
	_err_line := hb_strtoutf8( _o_file:ReadLine() )

    _tmp += _err_line + " ## "

	// ovo je dodavanje artikla
	if ( "107,1," + _serial ) $ _err_line
		// preskoci
		loop
	endif
	
	// ovu liniju zapamti, sadrzi fiskalni racun broj
	// komanda 56, zatvaranje racuna
	if ( "56,1," + _serial ) $ _err_line
		_fiscal_txt := _err_line
	endif

	// ima neka greska !
	if "Er;" $ _err_line

		_err_tmp := "FISC ERR:" + ALLTRIM( _err_line )
        log_write( _err_tmp, 2 )
        MsgBeep( _err_tmp )

		_err_level := 1
		return _err_level

	endif
	
enddo

_o_file:Close()

log_write("FISC ANSWER fajl sadrzaj: " + _tmp, 5)

if EMPTY( _fiscal_txt )
    log_write( "ERR FISC nema komande 56,1," + _serial + " - broj fiskalnog racuna, mozda vam nije dobar serijski broj !", 1)
else
    // ako je sve ok, uzmi broj fiskalnog isjecka 
    fiscal_no := _g_fisc_no( _fiscal_txt, storno )
endif

return _err_level




// ------------------------------------------------
// vraca broj fiskalnog isjecka
// ------------------------------------------------
static function _g_fisc_no( txt, storno )
local _fiscal_no := 0
local _a_tmp := {}
local _a_fisc := {}
local _fisc_txt := ""
local _n_pos := 2


if storno == NIL
    storno := .f.
endif

// pozicija u odgovoru
// 3 - regularni racun
// 4 - storno racun

if storno
    _n_pos := 3
endif

_a_tmp := toktoniz( txt, ";" )
_fisc_txt := _a_tmp[2]

_a_fisc := toktoniz( _fisc_txt, "," )

_fiscal_no := VAL( _a_fisc[ _n_pos ] )

log_write( "FISC RN: " + ALLTRIM( STR( _fiscal_no ) ), 3 )

return _fiscal_no




