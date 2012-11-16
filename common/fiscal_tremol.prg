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

static _razmak1 := " "
static _nema_out := -20

// fiskalne funkcije TREMOL fiskalizacije 


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
// aData[14] - total
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
function tremol_rn( params, aData, aKupac, lStorno, cContinue )
local cXML
local i
local cBr_zahtjeva 
local cVr_placanja
local nVr_placanja
local cRek_rn
local nKolicina
local nCijena
local cRoba_id
local cRoba_naz
local cRoba_jmj
local nRabat
local lKupac := .f.
local nErr_no := 0
local cOperacija := ""
local cCmd := ""
local cC_id 
local cC_name
local cC_addr
local cC_city
local nFisc_no := 0

// pobrisi tmp fajlove i ostalo sto je u input direktoriju
tremol_delete_tmp( params )

if cContinue == nil
	cContinue := "0"
endif

if aKupac <> nil .and. LEN( aKupac ) > 0
	lKupac := .t.
endif

// to je zapravo broj racuna !!!
cBr_zahtjeva := aData[ 1, 1 ]

cFName := tremol_filename( cBr_zahtjeva, params["out_file"] )

// putanja do izlaznog xml fajla
cXML := cFPath + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

cOF_txt := 'TremolFpServer Command="Receipt"'
cOFR_txt := ''
cOFC_txt := ''

if cContinue == "1"
	cOF_txt += ' Continue="' + cContinue + '"'
endif

// ukljuci storno triger
if lStorno == .t.
	cOFR_txt := ' RefundReceipt="' + ALLTRIM( aData[1, 8] ) + '"'
endif

// ukljuci kupac triger
if lKupac == .t.

	// aKupac[1] - idbroj kupca
	// aKupac[2] - naziv
	// aKupac[3] - adresa
	// aKupac[4] - postanski broj
	// aKupac[5] - grad stanovanja

	cC_id := ALLTRIM( aKupac[1, 1] )
	cC_name := to_xml_encoding( ALLTRIM( aKupac[1, 2] ) )
	cC_addr := to_xml_encoding( ALLTRIM( aKupac[1, 3] ) )
	cC_city := to_xml_encoding( ALLTRIM( aKupac[1, 5] ) )

	cOFC_txt := _razmak1 + 'CompanyID="' + cC_id + '"'
	cOFC_txt += _razmak1 + 'CompanyName="' + cC_name + '"'
	cOFC_txt += _razmak1 + 'CompanyHQ="' + cC_city + '"'
	cOFC_txt += _razmak1 + 'CompanyAddress="' + cC_addr + '"'
	cOFC_txt += _razmak1 + 'CompanyCity="' + cC_city + '"'

endif

xml_subnode( cOF_txt + cOFR_txt + cOFC_txt )
  
nVr_placanja := 0
    
    for i:=1 to LEN( aData )

	nRoba_plu := aData[i, 9]
	cRoba_bk := aData[i, 12]
	cRoba_id := aData[i, 3]
	cRoba_naz := PADR( aData[i, 4], 32 )
	cRoba_jmj := _g_jmj( aData[i, 16] )
	nCijena := aData[i, 5]
	nKolicina := aData[i, 6]
	nRabat := aData[i, 11]
	cStopa := fiscal_txt_get_tarifa( aData[i, 7], params["pdv"], "TREMOL" )
	cDep := "1"
	cTmp := ""

	// naziv artikla
	cTmp += _razmak1 + 'Description="' + to_xml_encoding(cRoba_naz) + '"'
	//  kolicina artikla 
	cTmp += _razmak1 + 'Quantity="' + ALLTRIM( STR( nKolicina, 12, 3)) + '"'
	// cijena artikla
	cTmp += _razmak1 + 'Price="' + ALLTRIM( STR( nCijena, 12, 2 )) + '"'
	// poreska stopa
	cTmp += _razmak1 + 'VatInfo="' + cStopa + '"'
	// odjeljenje
	cTmp += _razmak1 + 'Department="' + cDep + '"'
	// jedinica mjere
	cTmp += _razmak1 + 'UnitName="' + cRoba_jmj + '"'
	
	if nRabat > 0

		// vrijednost popusta
		cTmp += _razmak1 + 'Discount="' + ALLTRIM(STR(nRabat,12,2)) ;
			+ '%"'
	
	endif

	xml_snode( "Item", cTmp )
	
    next

    // vrste placanja, oznaka:
    //
    //   "GOTOVINA"
    //   "CEK"
    //   "VIRMAN"
    //   "KARTICA"
    // 
    // iznos = 0, ako je 0 onda sve ide tom vrstom placanja

    cVr_placanja := _g_v_plac( VAL( aData[1, 13] ) )
    nVr_placanja := aData[1, 14]

    if aData[1, 13] <> "0" .and. !lStorno

    	cTmp := 'Type="' + cVr_placanja + '"'
    	cTmp += _razmak1 + 'Amount="' + ALLTRIM( STR(nVr_placanja,12,2)) + '"'

    	xml_snode( "Payment", cTmp )	

    endif

    // dodatna linija, broj veznog racuna
    cTmp := 'Message="Vezni racun: ' + cBr_zahtjeva + '"'

    xml_snode( "AdditionalLine", cTmp )	

xml_subnode("TremolFpServer", .t.)

close_xml()

return nErr_no





// restart tremol fp server
function tremol_restart( param )
local cScr
private cR_scr := ""

if param["restart_fiscal_service"] == "N"
	return .f.
endif

cR_scr := "start " + EXEPATH + "fp_rest.bat"

save screen to cScr
clear screen

? "Restartujem server..."
run &cR_scr

restore screen from cScr
return .f.


// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
function tremol_delete_tmp( dev_param )
local _tmp
local _f_path

msgo("brisem tmp fajlove...")

_f_path := dev_param["out_dir"]
_tmp := "*.*"

AEVAL( DIRECTORY( _f_path + _tmp ), {| aFile | FERASE( _f_path + ;
	ALLTRIM( aFile[1]) ) })

sleep(1)

msgc()

return




// -------------------------------------------------------------------
// -------------------------------------------------------------------
function tremol_polog( dev_params, auto )
local _xml
local _err := 0
local _cmd := ""
local _f_name
local _value := 0

if auto == NIL
    auto := .f.
endif

if auto
    _value := dev_params["avans"]
endif

if value = 0
    // box - daj iznos pologa
    Box(,1, 60)
	    @ m_x + 1, m_y + 2 SAY "Unosim polog od:" GET value ;
		    PICT "99999.99"
	    read
    BoxC()

    if LastKey() == K_ESC .or. value = 0
	    return
    endif

endif

if value < 0
	// polog komanda
	_cmd := 'Command="CashOut"'
else
	// polog komanda
	_cmd := 'Command="CashIn"'
endif

// izlazni fajl
_f_name := tremol_filename( "0", dev_params["out_file"] )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("TremolFpServer " + _cmd )

_cmd := 'Amount="' +  ALLTRIM(STR( ABS(value), 12, 2)) + '"'

xml_snode("Cash", _cmd )

xml_subnode("/TremolFpServer")

close_xml()

return _err




// -------------------------------------------------------------------
// tremol reset artikala
// -------------------------------------------------------------------
function tremol_reset_plu( dev_params )
local _xml
local _err := 0
local _cmd := ""

if !SigmaSif("RPLU")
	return 0
endif

_f_name := tremol_filename( "0", dev_params["out_file"] )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

_cmd := 'Command="DirectIO"'

xml_subnode("TremolFpServer " + _cmd )

_cmd := 'Command="1"'
_cmd += _razmak1 + 'Data="0"'
_cmd += _razmak1 + 'Object="K00000;F142HZ              ;0;$"'

xml_snode("DirectIO", _cmd )

xml_subnode("/TremolFpServer")

close_xml()

// provjeri greske...
// nErr_no := ...
	
if tremol_read_out( dev_params, _f_name, dev_params["timeout"] )
	_err := tremol_read_error( dev_params, _f_name ) 
endif

return _err



// -------------------------------------------------------------------
// tremol komanda
// -------------------------------------------------------------------
function tremol_cmd( dev_params, cmd )
local _xml
local _err := 0
local _f_name 

_f_name := tremol_filename( "0", dev_params["out_file"] )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("TremolFpServer " + cmd )

close_xml()

// provjeri greske...
if tremol_read_out( dev_params, _f_name, dev_params["timeout"] )
	// procitaj poruku greske
	_err := tremol_read_error( dev_params, _f_name ) 
else
	_err := _nema_out
endif

return _err




// ------------------------------------------------
// vraca vrstu placanja na osnovu oznake
// ------------------------------------------------
static function _g_v_plac( v_pl )
local _ret := "-"

do case 
	case v_pl = "0"
		_ret := "Gotovina"
	case v_pl = "1"
		_ret := "Cek"		
	case v_pl = "2"
		_ret := "Kartica"
	case v_pl = "3"
		_ret := "Virman"

endcase

return _ret


// ------------------------------------------
// vraca jedinicu mjere
// ------------------------------------------
static function _g_jmj( cJmj )
cF_jmj := ""
do case
	case UPPER(ALLTRIM(cJmj)) = "KOM"
		cF_jmj := ""
	case UPPER(ALLTRIM(cJmj)) = "LIT"
		cF_jmj := "l"
	case UPPER(ALLTRIM(cJmj)) = "GR"
		cF_jmj := "g"
	case UPPER(ALLTRIM(cJmj)) = "KG"
		cF_jmj := "kg"

	// case 
	// ....

endcase

return cF_jmj




// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
function tremol_filename( broj_rn, file_name )
local _ret
local _f_name := ALLTRIM( file_name )
local _rn

do case

	case "$rn" $ _f_name
		// broj racuna.xml
		_rn := PADL( ALLTRIM( broj_rn ), 8, "0" )
		// ukini znak "/" ako postoji
		_rn := STRTRAN( _rn, "/", "" )
		_ret := STRTRAN( _f_name, "$rn", _rn )
		_ret := UPPER( _ret )
	
	otherwise 
		// ono sta je navedeno u parametrima
		_ret := _f_name

endcase

return _ret



// -----------------------------------------------------
// ItemZ
// -----------------------------------------------------
function tremol_z_item( dev_param )
local _cmd, _err

_cmd := 'Command="Report" Type="ItemZ" /'
_err := tremol_cmd( dev_param, _cmd )

return _err


// -----------------------------------------------------
// ItemX
// -----------------------------------------------------
function tremol_x_item( dev_param )
local _cmd

_cmd := 'Command="Report" Type="ItemX" /'
_err := tremol_cmd( dev_param, _cmd )

return _err


// -----------------------------------------------------
// dnevni fiskalni izvjestaj
// -----------------------------------------------------
function tremol_z_rpt( dev_param )
local _cmd
local _err

if Pitanje(,"Stampati dnevni izvjestaj", "D") == "N"
	return
endif

_cmd := 'Command="Report" Type="DailyZ" /'
_err := tremol_cmd( dev_param, _cmd )

// ako se koristi opcija automatskog pologa
if dev_param["avans"] > 0
	
	msgo("Automatski unos pologa u uredjaj... sacekajte.")
	
	// daj mi malo prostora
	sleep(10)
	
	// pozovi opciju pologa
	_err := tremol_polog( dev_param, .t. )
	
	msgc()

endif

return _err


// -----------------------------------------------------
// presjek stanja
// -----------------------------------------------------
function tremol_x_rpt( dev_param )
local _cmd
local _err

_cmd := 'Command="Report" Type="DailyX" /'
_err := tremol_cmd( dev_param, _cmd )

return


// -----------------------------------------------------
// periodicni izvjestaj
// -----------------------------------------------------
function tremol_per_rpt( dev_param )
local _cmd, _err
local _start
local _end
local _date_start := DATE()-30
local _date_end := DATE()

if Pitanje(,"Stampati periodicni izvjestaj", "D") == "N"
	return
endif

Box(,1,60)
	@ m_x+1, m_y+2 SAY "Od datuma:" GET _date_start
	@ m_x+1, col()+1 SAY "do datuma:" GET _date_end
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// 2010-10-01 : YYYY-MM-DD je format datuma
_start := _tfix_date( _date_start )
_end := _tfix_date( _date_end )

_cmd := 'Command="Report" Type="Date" Start="' + _start + ;
	'" End="' + _end + '" /'

_err := tremol_cmd( dev_param, _cmd )

return _err


// ------------------------------------------------
// sredjuje datum za tremol uredjaj xml
// ------------------------------------------------
static function _tfix_date( dDate )
local xRet := ""
local cTmp

cTmp := ALLTRIM( STR( YEAR( dDate ) ))

xRet += cTmp
xRet += "-"

cTmp := PADL( ALLTRIM( STR( MONTH( dDate )) ), 2, "0" )

xRet += cTmp
xRet += "-"

cTmp := PADL( ALLTRIM( STR( DAY( dDate )) ), 2, "0" )
xRet += cTmp

return xRet





// ---------------------------------------------------
// stampa kopije racuna
// ---------------------------------------------------
function tremol_rn_copy( dev_params )
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

// <TremolFpServer Command="PrintDuplicate" Type="0" Document="2"/>

cCmd := 'Command="PrintDuplicate"'

if cRefund == "N"
	// obicni racun
	cCmd += _razmak1 + 'Type="0"'
else
	// reklamni racun
	cCmd += _razmak1 + 'Type="1"'
endif

cCmd += _razmak1 + 'Document="' +  ALLTRIM(cBrRn) + '" /'

nErr := tremol_cmd( dev_params, cCmd )

return





// --------------------------------------------
// cekanje na fajl odgovora
// --------------------------------------------
function tremol_read_out( dev_params, f_name, time_out )
local _out := .t.
local _tmp
local _time
local _cnt := 0

if time_out == nil
	time_out := dev_params["timeout"]
endif

_time := time_out
_tmp := dev_params["out_dir"] + STRTRAN( f_name, "xml", "out" )

Box(,1,50)

do while _time > 0
	
	-- _time
	
	// provjeri kada bude trecina vremena...
	if _time = ( dev_params["timeout"] * 0.7 ) .and. _cnt = 0
		if Pitanje(,"Restartovati server", "D") == "D"
			// pokreni restart proceduru
			tremol_restart( dev_params )
			// restartuj vrijeme
			_time := dev_params["timeout"]
			++ _cnt
		endif
	endif

	if FILE( _tmp )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam odgovor... " + ;
		ALLTRIM( STR( _time ) ), 48)

    if _time == 0 .or. LastKey() == K_ALT_Q
        BoxC()
        return .f.
    endif

	sleep(1)

enddo

BoxC()

if !FILE( _tmp )
	msgbeep("Ne postoji fajl odgovora (OUT) !!!!")
	_out := .f.
endif

return _out



// ------------------------------------------------------------
// citanje gresaka za TREMOL driver
// 
// nFisc_no - broj fiskalnog isjecka
//
// ------------------------------------------------------------
function tremol_read_error( dev_params, f_name, fisc_no )
local nErr := 0
local cF_name
local i
local n
local x
local cErr
local aLinija 
local aErr := {}
local aErr2
local aErr_read
local aErr_data
local aF_err := {}
local cErrCode := ""
local cErrDesc := ""
local _o_file

// primjer: c:\fiscal\00001.out
f_name := ALLTRIM( dev_params["out_dir"] + STRTRAN( f_name, "xml", "out" ) )

// ova opcija podrazumjeva da je ukljuèena opcija 
// prikaza greske tipa OUT fajlovi...

fisc_no := 0

_o_file := TFileRead():New( f_name )
_o_file:Open()

if _o_file:Error()
	MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
	return -9
endif

cFisc_txt := ""

// prodji kroz svaku liniju i procitaj zapise
// 1 liniju preskoci zato sto ona sadrzi 
// <?xml version="1.0"...>
while _o_file:MoreToRead()

	// uzmi u cErr liniju fajla
	cErr := hb_strtoutf8( _o_file:ReadLine()  )

	if "?xml" $ cErr
		// prvu liniju preskoci !
		loop
	endif

	// skloni "<" i ">"
	cErr := STRTRAN( cErr, ">", "" )
	cErr := STRTRAN( cErr, "<", "" )
	cErr := STRTRAN( cErr, "/", "" )
	cErr := STRTRAN( cErr, '"', "" )
	cErr := STRTRAN( cErr, "TremolFpServerOutput", "" )
	cErr := STRTRAN( cErr, "Output Change", "OutputChange" )

	// dobijamo npr.
	//
	// ErrorCode=0 ErrorPOS=OPOS_SUCCESS ErrorDescription=Uspjesno kreiran
	// Output Change=0.00 ReceiptNumber=00552 Total=51.20

	aLinija := TokToNiz( cErr, SPACE(1) )

	// dobit cemo
	// 
	// aLinija[1] = "ErrorCode=0"
	// aLinija[2] = "ErrorPOS=OPOS_SUCCESS"
	// ...
	
	// dodaj u generalnu matricu aErr
	for m := 1 to LEN( aLinija )
		AADD( aErr, aLinija[m] )
	next

enddo

_o_file:Close()

// potrazimo gresku...
nScan := ASCAN( aErr, {|xVal| "OPOS_SUCCESS" $ xVal } )

if nScan > 0

	// nema greske, komanda je uspjela !
	// ako je rijec o racunu uzmi broj fiskalnog racuna
        	
	nScan := ASCAN( aErr, {|xVal| "ReceiptNumber" $ xVal } )
	
	if nScan <> 0
		
		// ReceiptNumber=241412
		aTmp2 := {}
		aTmp2 := TokToNiz( aErr[ nScan ], "=" )
		
		// ovo ce biti broj racuna
		cTmp := ALLTRIM( aTmp2[2] )
		
		if !EMPTY( cTmp )
			fisc_no := VAL( cTmp )
		endif

	endif
	
	// pobrisi fajl, izdaji
	FERASE( cF_name )
	return nErr
	
endif

// imamo gresku !!! ispisi je
cTmp := ""

nScan := ASCAN( aErr, {|xVal| "ErrorCode" $ xVal } )
	
if nScan <> 0
		
	// ErrorCode=241412
	aTmp2 := {}
	aTmp2 := TokToNiz( aErr[ nScan ], "=" )
		
	cTmp += "ErrorCode: " + ALLTRIM( aTmp2[2] )
		
	// ovo je ujedino i error kod
	nErr := VAL( aTmp2[2] )

endif
	
nScan := ASCAN( aErr, {|xVal| "ErrorOPOS" $ xVal } )
if nScan <> 0
		
	// ErrorOPOS=xxxxxxx
	aTmp2 := {}
	aTmp2 := TokToNiz( aErr[ nScan ], "=" )
	
	cTmp += " ErrorOPOS: " + ALLTRIM( aTmp2[2] )

endif
	
nScan := ASCAN( aErr, {|xVal| "ErrorDescription" $ xVal } )
if nScan <> 0
		
	// ErrorDescription=xxxxxxx
	aTmp2 := {}
	aTmp2 := TokToNiz( aErr[ nScan ], "=" )
	cTmp += " Description: " + ALLTRIM( aTmp2[2] )

endif

if !EMPTY( cTmp )
	msgbeep( cTmp )
endif

// obrisi fajl out na kraju !!!
FERASE( f_name )

return nErr




