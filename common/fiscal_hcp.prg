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

static _cmdok := "CMD.OK"
static _razmak1 := " "
static _answ_dir := "FROM_FP"
static _inp_dir := "TO_FP"

// trigeri
static _tr_cmd := "CMD"
static _tr_plu := "PLU"
static _tr_txt := "TXT"
static _tr_rcp := "RCP"
static _tr_cli := "clients.XML"
static _tr_foo := "footer.XML"

// min/max vrijednosti
static MAX_QT := 99999.999
static MIN_QT := 1.000
static MAX_PRICE := 999999.99
static MIN_PRICE := 0.01
static MAX_PERC := 99.99
static MIN_PERC := -99.99

// fiskalne funkcije HCP fiskalizacije 

// struktura matrice aData
//
// aData[1] - broj racuna (C)
// aData[2] - redni broj stavke (C)
// aData[3] - id roba
// aData[4] - roba naziv
// aData[5] - cijena
// aData[6] - kolicina
// aData[7] - tarifa
// aData[8] - broj racuna za storniranje
// aData[9] - roba plu
// aData[10] - plu cijena
// aData[11] - popust
// aData[12] - barkod
// aData[13] - vrsta placanja
// aData[14] - total racuna
// aData[15] - datum racuna
// aData[16] - roba jmj

// struktura matrice aKupac
// 
// aKupac[1] - idbroj kupca
// aKupac[2] - naziv
// aKupac[3] - adresa
// aKupac[4] - postanski broj
// aKupac[5] - grad stanovanja


// --------------------------------------------------------------------------
// stampa fiskalnog racuna tring fiskalizacija
// --------------------------------------------------------------------------
function hcp_rn( dev_params, items, head, storno, rn_total )
local _xml, _f_name
local _i, _ibk, _rn_broj, _footer
local _v_pl
local _total_placanje
local _rn_reklamni
local nKolicina
local nCijena
local cRoba_id
local cRoba_naz
local cRoba_jmj
local nRabat
local _customer := .f.
local _err_level := 0
local cOperacija := ""
local _cmd := ""
local _del_all := .t.

if head <> nil .and. LEN( head ) > 0
	_customer := .t.
endif

// brisi tmp fajlove ako su ostali...
hcp_delete_tmp( dev_params, _del_all )

if rn_total == nil
	rn_total := 0
endif

// ako je storno posalji pred komandu
if storno
	
	// daj mi storno komandu
	_rn_reklamni := ALLTRIM( items[1, 8] )
	_cmd := _on_storno( _rn_reklamni )
	// posalji storno komandu
	_err_level := hcp_cmd( dev_params, _cmd, _tr_cmd )	
    
	if _err_level > 0
		return _err_level
	endif

endif

// programiraj artikal prije nego izdas racun
_err_level := hcp_plu( dev_params, items )

if _err_level > 0
	return _err_level
endif

if _customer = .t.

    // dodaj kupca...
	_err_level := hcp_cli( dev_params, head )

    if _err_level > 0
	    return _err_level
    endif

	// setuj triger za izdavanje racuna sa partnerom
	_ibk := head[1, 1]
	_cmd := _on_partn( _ibk )

	_err_level := hcp_cmd( dev_params, _cmd, _tr_cmd )

	if _err_level > 0
		return _err_level
	endif

endif

// posalji komandu za reset footera...
_cmd := _off_footer() 
_err_level := hcp_cmd( dev_params, _cmd, _tr_cmd )

if _err_level > 0
	return _err_level
endif

// to je zapravo broj racuna !!!
_rn_broj := items[1, 1]
// posalji footer...
_footer := {}
AADD( _footer, { "Broj rn: " + _rn_broj })
_err_level := hcp_footer( dev_params, _footer, _tr_foo )
if _err_level > 0
	return _err_level
endif

// sredi mi naziv fajla...
_f_name := fiscal_out_filename( dev_params["out_file"], _rn_broj, _tr_rcp )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _inp_dir + SLASH + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("RECEIPT")
  
_total_placanje := 0
    
for _i := 1 to LEN( items )

	nRoba_plu := items[i, 9]
	cRoba_bk := items[i, 12]
	cRoba_id := items[i, 3]
	cRoba_naz := PADR( items[i, 4], 32 )
	cRoba_jmj := _g_jmj( items[i, 16] )
	nCijena := items[i, 5]
	nKolicina := items[i, 6]
	nRabat := items[i, 11]
	cStopa := fiscal_txt_get_tarifa( items[i, 7], dev_params["pdv"], "HCP" ) 
	cDep := "0"
	cTmp := ""

	// sta ce se koristiti za 'kod' artikla
	if dev_params["plu_type"] $ "P#D"
		// PLU artikla
		_tmp := 'BCR="' + ALLTRIM(STR(nRoba_plu)) + '"'
	elseif dev_params["plu_type"] == "I"
		// ID artikla
		_tmp := 'BCR="' + ALLTRIM(cRoba_id) + '"'
	elseif dev_params["plu_type"] == "B"
		// barkod artikla
		_tmp := 'BCR="' + ALLTRIM(cRoba_bk) + '"'
	endif
	
	// poreska stopa
	_tmp += _razmak1 + 'VAT="' + cStopa + '"'
	// jedinica mjere
	_tmp += _razmak1 + 'MES="' + cRoba_jmj + '"'
	// odjeljenje
	_tmp += _razmak1 + 'DEP="' + cDep + '"'
	// naziv artikla
	_tmp += _razmak1 + 'DSC="' + to_xml_encoding( cRoba_naz ) + '"'
	// cijena artikla
	_tmp += _razmak1 + 'PRC="' + ALLTRIM( STR( nCijena, 12, 2 )) + '"'
	//  kolicina artikla 
	_tmp += _razmak1 + 'AMN="' + ALLTRIM( STR( nKolicina, 12, 2)) + '"'
	
	if nRabat > 0

		// vrijednost popusta
		_tmp += _razmak1 + 'DS_VALUE="' + ALLTRIM(STR(nRabat,12,2)) ;
			+ '"'
		// vrijednost popusta
		_tmp += _razmak1 + 'DISCOUNT="' + "true" + '"'
	
	endif

	xml_snode( "DATA", _tmp )
	
    next


    // vrste placanja, oznaka:
    //
    //   "GOTOVINA"
    //   "CEK"
    //   "VIRMAN"
    //   "KARTICA"
    // 
    // iznos = 0, ako je 0 onda sve ide tom vrstom placanja

    _v_plac := fiscal_txt_get_vr_plac( items[ 1, 13 ], "HCP" )
    _total_placanje := ABS( rn_total )

    if storno
    	// ako je storno onda je placanje gotovina i iznos 0
        _v_plac := "0"
	    _total_placanje := 0
    endif

    _tmp := 'PAY="' + _v_plac + '"'
    _tmp += _razmak1 + 'AMN="' + ALLTRIM( STR( _total_placanja ,12,2 )) + '"'

    xml_snode( "DATA", _tmp )	

xml_subnode("RECEIPT", .t.)

close_xml()

// kreiraj cmd.ok
hcp_create_cmd_ok( dev_params )

if !hcp_read_ok( dev_params, _f_name )
	// procitaj poruku greske
	_err_level := hcp_read_error( dev_params, _f_name, _tr_rcp ) 	
endif

return _err_level



// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
function hcp_delete_tmp( dev_params, del_all )
local _tmp, _f_path

if del_all == NIL
    del_all := .f.
endif

msgo("brisem tmp fajlove...")

// input direktorij...
_f_path := dev_params["out_dir"] + _inp_dir + SLASH
_tmp := "*.*"

AEVAL( DIRECTORY( _f_path + _tmp ), {|aFile| FERASE( _f_path + ;
	ALLTRIM( aFile[1]) ) })

if del_all

    // output direktorij...
    _f_path := dev_params["out_dir"] + _answ_dir + SLASH
    _tmp := "*.*"

    AEVAL( DIRECTORY( _f_path + _tmp ), {|aFile| FERASE( _f_path + ;
    	ALLTRIM( aFile[1]) ) })

endif

sleep(1)

msgc()

return


// -------------------------------------------------------------------
// hcp programiranje footer
// -------------------------------------------------------------------
function hcp_footer( dev_params, footer )
local _xml, _tmp, _i
local _err := 0

_f_name := fiscal_out_filename( dev_params["out_file"], "0", _tr_foo )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _inp_dir + SLASH + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("FOOTER")

for _i := 1 to LEN( footer )
	
	_tmp := 'TEXT="' + ALLTRIM( footer[ _i, 1 ] ) + '"'
	_tmp += ' '
	_tmp += 'BOLD="false"'
	
	xml_snode( "DATA", _tmp )

next

xml_subnode("FOOTER", .t. )

close_xml()

// kreiraj triger cmd.ok
hcp_create_cmd_ok( dev_params )

if !hcp_read_ok( dev_params, _f_name )
	_err := hcp_read_error( dev_params, _f_name, _tr_foo )
endif

return _err




// -------------------------------------------------------------------
// hcp programiranje klijenti
// -------------------------------------------------------------------
function hcp_cli( dev_params, head )
local _xml, _f_name, _tmp, _i
local _err := 0

_f_name := fiscal_out_filename( dev_params["out_file"], "0", _tr_cli )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _inp_dir + SLASH + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode( "CLIENTS" )

for _i := 1 to LEN( head )
	
	_tmp := 'IBK="' + head[ _i, 1] + '"'
	_tmp += _razmak1 + 'NAME="' + ;
		ALLTRIM( to_xml_encoding( head[ _i, 2 ] ) ) + '"'
	_tmp += _razmak1 + 'ADDRESS="' + ;
		ALLTRIM( to_xml_encoding( head[ _i, 3] ) ) + '"'
	_tmp += _razmak1 + 'TOWN="' + ;
		ALLTRIM( to_xml_encoding( head[ _i, 5] ) ) + '"'
	
	xml_snode( "DATA", _tmp )

next

xml_subnode( "CLIENTS", .t. )

close_xml()

// kreiraj triger cmd.ok
hcp_create_cmd_ok( dev_params )

if !hcp_read_ok( dev_params, _f_name )
	// procitaj poruku greske
	_err := hcp_read_error( dev_params, _f_name, _tr_cli )
endif

return _err


// -------------------------------------------------------------------
// hcp programiranje PLU
// -------------------------------------------------------------------
function hcp_plu( dev_params, items )
local _xml
local _err := 0
local _i, _tmp, _f_name

_f_name := fiscal_out_filename( dev_params["out_file"], "0", _tr_plu )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _inp_dir + SLASH + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode( "PLU" )

for _i := 1 to LEN( items )
	
	nRoba_plu := items[ _i, 9 ]
	cRoba_naz := PADR( items[ _i, 4 ], 32 )
	cRoba_jmj := _g_jmj( items[ _i, 16 ] )
	nCijena := items[ _i, 5 ]
	cStopa := fiscal_txt_get_tarifa( items[ _i, 7 ], dev_params["pdv"], "HCP" )
	cDep := "0"
	nLager := 0

	_tmp := 'BCR="' + ALLTRIM(STR(nRoba_plu)) + '"'
	_tmp += _razmak1 + 'VAT="' + cStopa + '"'
	_tmp += _razmak1 + 'MES="' + cRoba_jmj + '"'
	_tmp += _razmak1 + 'DEP="' + cDep + '"'
	_tmp += _razmak1 + 'DSC="' + ALLTRIM( to_xml_encoding( cRoba_naz ) ) + '"'
	_tmp += _razmak1 + 'PRC="' + ALLTRIM(STR(nCijena, 12, 2)) + '"'
	_tmp += _razmak1 + 'LGR="' + ALLTRIM(STR(nLager, 12, 2)) + '"'
	
	xml_snode( "DATA", _tmp )

next

xml_subnode( "PLU", .t.)

close_xml()

// kreiraj triger cmd.ok
hcp_create_cmd_ok( dev_params )

if !hcp_read_ok( dev_params, _f_name )
	// procitaj poruku greske
	_err := hcp_read_error( dev_params, _f_name, _tr_plu ) 
endif

return _err



// -------------------------------------------------------------------
// ispis nefiskalnog teksta
// -------------------------------------------------------------------
function hcp_txt( dev_params, br_dok )
local _cmd := ""
local _xml, _data, _tmp
local _err_level := 0

_cmd := 'TXT="POS RN: ' + ALLTRIM( br_dok ) + '"'

_f_name := fiscal_out_filename( dev_params["out_file"], "0", _tr_txt )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _inp_dir + SLASH + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("USER_TEXT")

if !EMPTY( _cmd )
	
	_data := "DATA"
	_tmp := _cmd
	
	xml_snode( _data, _tmp )

endif

xml_subnode("USER_TEXT", .t.)

close_xml()

// kreiraj triger cmd.ok
hcp_create_cmd_ok( dev_params )

if !hcp_read_ok( dev_params, _f_name )
	// procitaj poruku greske
	_err_level := hcp_read_error( dev_params, _f_name, _tr_txt ) 
endif

return _err_level



// -------------------------------------------------------------------
// hcp komanda
// -------------------------------------------------------------------
function hcp_cmd( dev_params, cmd, trig )
local _xml
local _err_level := 0
local _f_name

_f_name := fiscal_out_filename( dev_params["out_file"], "0", trig )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _inp_dir + SLASH + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("COMMAND")

if !EMPTY( cmd )
	
	_data := "DATA"
	_tmp := _cmd
	
	xml_snode( _data, _tmp )

endif

xml_subnode("COMMAND", .t.)

close_xml()

// kreiraj triger cmd.ok
hcp_create_cmd_ok( dev_params )

if !hcp_read_ok( dev_params, _f_name )
	// procitaj poruku greske
	_err_level := hcp_read_error( dev_params, _f_name, trig ) 
endif

return _err_level


// -------------------------------------------------
// ukljuci storno racuna
// -------------------------------------------------
static function _on_storno( cBrRn )
local cCmd 

cCmd := 'CMD="REFUND_ON"'
cCmd += _razmak1 + 'NUM="' + ALLTRIM(cBrRn) + '"'

return cCmd


// -------------------------------------------------
// ponistavanje footer-a
// -------------------------------------------------
static function _off_footer()
local cCmd 

cCmd := 'CMD="FOOTER_OFF"'

return cCmd


// -------------------------------------------------
// iskljuci storno racuna
// -------------------------------------------------
static function _off_storno()
local cCmd 

cCmd := 'CMD="REFUND_OFF"'

return cCmd


// -------------------------------------------------
// ukljuci racun za klijenta
// -------------------------------------------------
static function _on_partn( cIBK )
local cCmd 

cCmd := 'CMD="SET_CLIENT"'
cCmd += _razmak1 + 'NUM="' + ALLTRIM( cIBK )+ '"'

return cCmd




// ------------------------------------------
// vraca jedinicu mjere
// ------------------------------------------
static function _g_jmj( cJmj )
cF_jmj := "0"
do case
	case UPPER(ALLTRIM(cJmj)) = "KOM"
		cF_jmj := "0"
	case UPPER(ALLTRIM(cJmj)) = "LIT"
		cF_jmj := "1"
	// case 
	// ....

endcase

return cF_jmj


// -----------------------------------------------------
// dnevni fiskalni izvjestaj
// -----------------------------------------------------
function hcp_z_rpt( dev_params )
local _cmd, _err_level

_cmd := 'CMD="Z_REPORT"'
_err_level := hcp_cmd( dev_params, _cmd, _tr_cmd )


// ako se koriste dinamicki plu kodovi resetuj prodaju
// pobrisi artikle
if dev_params["plu_type"] == "D"

	msgo("resetujem prodaju...")

	// reset sold plu
	_cmd := 'CMD="RESET_SOLD_PLU"'
	_err_level := hcp_cmd( dev_params, _cmd, _tr_cmd )

	// ako su dinamicki PLU kodovi
	_cmd := 'CMD="DELETE_ALL_PLU"'
	_err_level := hcp_cmd( dev_params, _cmd, _tr_cmd )

	// resetuj PLU brojac u bazi...
	auto_plu( .t., .t., dev_params )

	msgc()

endif

// ako se koristi opcija automatskog pologa
if dev_params["auto_avans"] > 0

	msgo("Automatski unos pologa u uredjaj... sacekajte.")

	// daj malo prostora
	sleep(5)

	// unesi polog
	_err_level := hcp_polog( dev_params, .t. )

	msgc()

endif

return


// -----------------------------------------------------
// presjek stanja
// -----------------------------------------------------
function hcp_x_rpt( dev_params )
local _cmd, _err

_cmd := 'CMD="X_REPORT"'
_err := hcp_cmd( dev_params, _cmd, _tr_cmd )

return


// -----------------------------------------------------
// presjek stanja SUMMARY
// -----------------------------------------------------
function hcp_s_rpt( dev_params )
local _cmd
local dD_from := DATE()-30
local dD_to := DATE()
local cD_from := ""
local cD_to := ""

Box(,1,50)
	@ m_x+1, m_y+2 SAY "Datum od:" GET dD_from 
	@ m_x+1, col()+1 SAY "do:" GET dD_to
	read
BoxC()

if LastKey() == K_ESC
	return
endif

cD_from := _fix_date( dD_from )
cD_to := _fix_date( dD_to )

_cmd := 'CMD="SUMMARY_REPORT" FROM="' + cD_from + '" TO="' + cD_to + '"'
_err := hcp_cmd( dev_params, _cmd, _tr_cmd )

return



// -----------------------------------------------------
// vraca broj fiskalnog racuna
// -----------------------------------------------------
function hcp_fisc_no( dev_params, storno )
local _cmd
local _fiscal_no := 0
local _f_state := "BILL_S~1.XML"

#ifdef __PLATFORM__UNIX
	_f_state := "bill_state.xml"
#endif

// posalji komandu za stanje fiskalnog racuna
_cmd := 'CMD="RECEIPT_STATE"'
_err := hcp_cmd( dev_params, _cmd, _tr_cmd )

// ako nema gresaka, iscitaj broj racuna
if _err = 0
	// e sada iscitaj iz fajla
	_fiscal_no := hcp_read_billstate( dev_params, _f_state, storno )
endif

return _fiscal_no




// -----------------------------------------------------
// reset prodaje
// -----------------------------------------------------
function hcp_reset( dev_params )
local _cmd

_cmd := 'CMD="RESET_SOLD_PLU"'
_err := hcp_cmd( dev_params, _cmd, _tr_cmd )

return


// ---------------------------------------------------
// polog pazara
// ---------------------------------------------------
function hcp_polog( dev_param, nValue )
local cCmd

if nValue == nil
	nValue := 0
endif

if nValue = 0
  // box - daj broj racuna
  Box(,1, 60)
	@ m_x + 1, m_y + 2 SAY "Unosim polog od:" GET nValue ;
		PICT "99999.99"
	read
  BoxC()

  if LastKey() == K_ESC .or. nValue = 0
	return
  endif

endif

if nValue < 0
	// polog komanda
	cCmd := 'CMD="CASH_OUT"'
else
	// polog komanda
	cCmd := 'CMD="CASH_IN"'
endif

cCmd += _razmak1 + 'VALUE="' +  ALLTRIM(STR( ABS(nValue), 12, 2)) + '"'

nErr := hcp_cmd( dev_param, cCmd, _tr_cmd )

return




// ---------------------------------------------------
// stampa kopije racuna
// ---------------------------------------------------
function hcp_rn_copy( dev_param )
local cCmd
local cBrRn := SPACE(10)
local cRefund := "N"

// box - daj broj racuna
Box(,2, 50)
	@ m_x + 1, m_y + 2 SAY "Broj racuna:" GET cBrRn ;
		VALID !EMPTY( cBrRn )
	@ m_x + 2, m_y + 2 SAY "racun je reklamni (D/N)?" GET cRefund ;
		VALID cRefund $ "DN" PICT "@!"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

if cRefund == "N"
	// obicni racun
	cCmd := 'CMD="RECEIPT_COPY"'
else
	// reklamni racun
	cCmd := 'CMD="REFUND_RECEIPT_COPY"'
endif

cCmd += _razmak1 + 'NUM="' +  ALLTRIM(cBrRn) + '"'

nErr := hcp_cmd( dev_param, cCmd, _tr_cmd )

return



// --------------------------------------------
// cekanje na fajl odgovora
// --------------------------------------------
static function hcp_read_ok( dev_param, f_name, time_out )
local lOk := .t.
local cTmp
local nTime

if time_out == nil
	time_out := 30
endif

nTime := time_out

cTmp := dev_param["out_dir"] + _answ_dir + SLASH + STRTRAN( f_name, "XML", "OK" )

Box(,1,50)

do while nTime > 0
	
	-- nTime
	sleep(1)

	if FILE( cTmp )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam odgovor OK: " + ;
		ALLTRIM( STR(nTime) ), 48)

    if nTime == 0 .or. LastKey() == K_ALT_Q
        BoxC()
        lOk := .f.
        return lOk
    endif

enddo

BoxC()

if !FILE(cTmp)
	lOk := .f.
else
	// obrisi fajl "OK"
	FERASE( cTmp )
endif

return lOk


// ----------------------------------
// create cmd.ok file
// ----------------------------------
function hcp_create_cmd_ok( dev_params )
local _tmp

_tmp := dev_params["out_dir"] + _inp_dir + SLASH + _cmdok

// iskoristit cu postojecu funkciju za kreiranje xml fajla...
open_xml( _tmp )
close_xml()

return


// ----------------------------------
// delete cmd.ok file
// ----------------------------------
function hcp_delete_cmd_ok( dev_params )
local _tmp

_tmp := dev_params["out_dir"] + _inp_dir + SLASH + _cmdok

if FERASE( _tmp ) < 0
	// ...
	msgbeep("greska sa brisanjem fajla CMD.OK !")
endif

return


// --------------------------------------------------
// brise fajl greske
// --------------------------------------------------
function hcp_delete_error( dev_params, f_name )
local _err := 0
local _f_name

// primjer: c:\hcp\from_fp\RAC001.ERR
_f_name := dev_params["out_dir"] + _answ_dir + SLASH + STRTRAN( f_name, "XML", "ERR" )

if FERASE( _f_name ) < 0
	// ...
	msgbeep("greska sa brisanjem fajla...")
endif

return


// ------------------------------------------------
// citanje fajla bill_state.xml
// 
// nTimeOut - time out fiskalne operacije
// ------------------------------------------------
function hcp_read_billstate( dev_params, f_name, storno )
local _fisc_no
local nErr := 0
local cF_name
local i
local nBrLin
local nStart
local cErr
local aBillState
local aBillData
local nTime 
local cLine
local cScanWhat
local cMessage
local _o_file

if lStorno == nil
	lStorno := .f.
endif

nTime := dev_params["timeout"]

// primjer: c:\hcp\from_fp\bill_state.xml
cF_name := dev_params["out_dir"] + _answ_dir + SLASH + f_name

Box(,1,50)

do while nTime > 0
	
	-- nTime

	if FILE( cF_name )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam na fiskalni uredjaj: " + ;
		ALLTRIM( STR(nTime) ), 48)

    if nTime == 0 .or. LastKey() == K_ALT_Q
        BoxC()
        return -9
    endif

	sleep(1)
enddo

BoxC()

if !FILE( cF_name )
	msgbeep("Fajl " + cF_name + " ne postoji !!!")
	nErr := -9
	return nErr
endif

_fisc_no := 0

cF_name := ALLTRIM( cF_name )

_o_file := TFileRead():New( cF_name )
_o_file:Open()

if _o_file:Error()
	MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
	return -9
endif

// prodji kroz svaku liniju i procitaj zapise
while _o_file:MoreToRead()
	
	// uzmi u cLine liniju fajla
	cLine := hb_strtoutf8( _o_file:ReadLine() )

	if UPPER("xml version") $ UPPER(cLine)
		// ovo je prvi red, preskoci
		loop
	endif

	// zamjeni ove znakove...
	cLine := STRTRAN( cLine, ">", "" )
	cLine := STRTRAN( cLine, "<", "" )
	cLine := STRTRAN( cLine, "'", "" )

	aBillData := TokToNiz( cLine, " " )

    cScanWhat := "RECEIPT_NUMBER"

	if lStorno = .t.
		cScanWhat := "REFOUND_RECEIPT_NUMBER"
	endif

	nScan := ASCAN( aBillData, { |xvar| cScanWhat $ xvar } )
	
	if nScan > 0
		
		aReceipt := TokToNiz( aBillData[ nScan], "=" )
		
		_fisc_no := VAL( aReceipt[2] )

		cMessage := "Formiran "

		if lStorno = .t.
			cMessage += "rekl."
		endif
		
		cMessage += "fiskalni racun: "

		msgbeep( cMessage + ALLTRIM( STR( _fisc_no ) ))
		
		exit

	endif

enddo

_o_file:Close()

// brisi fajl odgovora
if _fisc_no > 0
	FERASE( cF_name )
endif

return _fisc_no



// ------------------------------------------------
// citanje gresaka za HCP driver
// 
// nTimeOut - time out fiskalne operacije
// nFisc_no - broj fiskalnog isjecka
// ------------------------------------------------
function hcp_read_error( dev_params, cFName, cTriger )
local nErr := 0
local cF_name
local i
local nBrLin
local nStart
local cErr
local aErr_read
local aErr_data
local nTime 
local cErrCode := ""
local cErrDesc := ""

nTime := dev_params["timeout"]

// primjer: c:\hcp\from_fp\RAC001.ERR
cF_name := dev_params["out_dir"] + _answ_dir + SLASH + STRTRAN( cFName, "XML", "ERR" )

// ova opcija podrazumjeva da je ukljuèena opcija 
// prikaza greske tipa ER,OK...

Box(,1,50)

do while nTime > 0
	
	-- nTime

	if FILE( cF_name )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam na fiskalni uredjaj: " + ;
		ALLTRIM( STR(nTime) ), 48)

    if nTime == 0 .or. LastKey() == K_ESC
        BoxC()
        return -9
    endif

	sleep(1)
enddo

BoxC()

if !FILE( cF_name )
	msgbeep("Fajl " + cF_name + " ne postoji !!!")
	nErr := -9
	return nErr
endif

nFisc_no := 0
nBrLin := BrLinFajla( cF_name )
nStart := 0

cFisc_txt := ""

// prodji kroz svaku liniju i procitaj zapise
for i:=1 to nBrLin
	
	aErr_read := SljedLin( cF_name, nStart )
      	nStart := aErr_read[ 2 ]

	// uzmi u cErr liniju fajla
	cErr := aErr_read[ 1 ]

	aErr := TokToNiz( cErr, "-" )

	// ovo je kod greske, npr. 1
	cErrCode := ALLTRIM( aErr[1] )
	cErrDesc := ALLTRIM( aErr[2] )

	if !EMPTY( cErrCode )
		exit
	endif

next

if !EMPTY( cErrCode )
	msgbeep("Greska: " + cErrCode + " - " + cErrDesc )
	nErr := VAL( cErrCode )
	FERASE( cF_name )
endif



return nErr


// ---------------------------------------------------------
// vrsi provjeru vrijednosti cijena, kolicina itd...
// ---------------------------------------------------------
function hcp_check( aData )
local nRet := 0
local nCijena := 0
local nPluCijena := 0
local nKolicina := 0
local cNaziv := ""
local nFix := 0

// aData[4] - naziv
// aData[5] - cijena
// aData[10] - plu cijena
// aData[6] - kolicina

for i:=1 to LEN( aData )

	nCijena := aData[ i, 5 ]	
	nPluCijena := aData[i, 10 ]
	nKolicina := aData[ i, 6 ]	
	cNaziv := aData[i, 4]

	if ( !_chk_qtty( nKolicina ) .or. !_chk_price( nCijena ) ) ;
		.or. !_chk_price( nPluCijena )
		
		if gFc_chk > "1"
			
			// popravi kolicine, cijene
			_fix_qtty( @nKolicina, @nCijena, @nPluCijena, @cNaziv )
			
			// promjeni u matrici podatke takodjer
			aData[i, 5] := nCijena
			aData[i, 10] := nPluCijena
			aData[i, 6] := nKolicina
			aData[i, 4] := cNaziv
		
		endif

		++ nFix

	endif

next

if nFix > 0 .and. gFc_chk > "1"

	msgbeep("Pojedini artikli na racunu su prepakovani na 100 kom !")

elseif nFix > 0 .and. gFc_chk == "1"
	
	nRet := -99
	msgbeep("Pojedinim artiklima je kolicina/cijena van dozvoljenog ranga#Prekidam operaciju !!!!")

endif

return nRet


