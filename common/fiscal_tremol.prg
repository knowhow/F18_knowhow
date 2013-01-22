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
static __zahtjev_nula := "0"

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
function tremol_rn( dev_params, items, head, storno, cont )
local _racun_broj, _vr_plac, _total_plac, _xml, _i
local _reklamni_broj, _kolicina, _cijena, _rabat
local _art_id, _art_naz, _art_jmj, _tmp, _art_barkod, _art_plu, _dep, _tarifa
local _customer := .f.
local _err_level := 0
local _oper := ""
local _cmd := ""
local _cust_id, _cust_name, _cust_addr, _cust_city
local _fiscal_no := 0

// pobrisi tmp fajlove i ostalo sto je u input direktoriju
tremol_delete_tmp( dev_params )

if cont == nil
	cont := "0"
endif

// ima podataka kupca !
if head <> NIL .and. LEN( head ) > 0
	_customer := .t.
endif

// to je zapravo broj racuna !!!
_racun_broj := items[ 1, 1 ]

_f_name := fiscal_out_filename( dev_params["out_file"], _racun_broj )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

_fisc_txt := 'TremolFpServer Command="Receipt"'
_fisc_rek_txt := ''
_fisc_cust_txt := ''

if cont == "1"
	_fisc_txt += ' Continue="' + cont + '"'
endif

// ukljuci storno triger
if storno
	_fisc_rek_txt := ' RefundReceipt="' + ALLTRIM( items[ 1, 8 ] ) + '"'
endif

// ukljuci kupac triger
if _customer
	
    // aKupac[1] - idbroj kupca
	// aKupac[2] - naziv
	// aKupac[3] - adresa
	// aKupac[4] - postanski broj
	// aKupac[5] - grad stanovanja

	_cust_id := ALLTRIM( head[ 1, 1 ] )
	_cust_name := to_xml_encoding( ALLTRIM( head[ 1, 2 ] ) )
	_cust_addr := to_xml_encoding( ALLTRIM( head[ 1, 3 ] ) )
	_cust_city := to_xml_encoding( ALLTRIM( head[ 1, 5 ] ) )

	_fisc_cust_txt += _razmak1 + 'CompanyID="' + _cust_id + '"'
	_fisc_cust_txt += _razmak1 + 'CompanyName="' + _cust_name + '"'
	_fisc_cust_txt += _razmak1 + 'CompanyHQ="' + _cust_city + '"'
	_fisc_cust_txt += _razmak1 + 'CompanyAddress="' + _cust_addr + '"'
	_fisc_cust_txt += _razmak1 + 'CompanyCity="' + _cust_city + '"'

endif

// ubaci u xml
xml_subnode( _fisc_txt + _fisc_rek_txt + _fisc_cust_txt )
  
_total_plac := 0
    
for _i := 1 to LEN( items )

	_art_plu := items[ _i, 9 ]
	_art_barkod := items[ _i, 12 ]
	_art_id := items[ _i, 3 ]
	_art_naz := PADR( items[ _i, 4 ], 32 )
	_art_jmj := _g_jmj( items[ _i, 16 ] )
	_cijena := items[ _i, 5 ]
	_kolicina := items[ _i, 6 ]
	_rabat := items[ _i, 11 ]
	_tarifa := fiscal_txt_get_tarifa( items[ _i, 7 ], dev_params["pdv"], "TREMOL" )
	_dep := "1"
	
    _tmp := ""

	// naziv artikla
	_tmp += _razmak1 + 'Description="' + to_xml_encoding( _art_naz ) + '"'
	//  kolicina artikla 
	_tmp += _razmak1 + 'Quantity="' + ALLTRIM( STR( _kolicina, 12, 3 )) + '"'
	// cijena artikla
	_tmp += _razmak1 + 'Price="' + ALLTRIM( STR( _cijena, 12, 2 )) + '"'
	// poreska stopa
	_tmp += _razmak1 + 'VatInfo="' + _tarifa + '"'
	// odjeljenje
	_tmp += _razmak1 + 'Department="' + _dep + '"'
	// jedinica mjere
	_tmp += _razmak1 + 'UnitName="' + _art_jmj + '"'
	
	if _rabat > 0
		// vrijednost popusta
		_tmp += _razmak1 + 'Discount="' + ALLTRIM( STR( _rabat, 12, 2 ) ) + '%"'
	endif

	xml_snode( "Item", _tmp )
	
    next

    // vrste placanja, oznaka:
    //   "GOTOVINA"
    //   "CEK"
    //   "VIRMAN"
    //   "KARTICA"

    _vr_plac := fiscal_txt_get_vr_plac( items[1, 13], "TREMOL" )
    _total_plac := items[ 1, 14 ]

    if items[ 1, 13 ] <> "0" .and. !storno

    	_tmp := 'Type="' + _vr_plac + '"'
    	_tmp += _razmak1 + 'Amount="' + ALLTRIM( STR( _total_plac, 12, 2 )) + '"'

    	xml_snode( "Payment", _tmp )	

    endif

    // dodatna linija, broj veznog racuna
    _tmp := 'Message="Vezni racun: ' + _racun_broj + '"'

    xml_snode( "AdditionalLine", _tmp )	

xml_subnode("TremolFpServer", .t.)

close_xml()

return _err_level




// --------------------------------------------------
// restart tremol fp server
// --------------------------------------------------
function tremol_restart( dev_params )
local _scr
private _script

if dev_params["restart_service"] == "N"
	return .f.
endif

_script := "start " + EXEPATH + "fp_rest.bat"

save screen to _scr
clear screen

? "Restartujem server..."
_err := f18_run( _scrtip )

restore screen from _scr
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
    _value := dev_params["auto_avans"]
endif

if _value = 0
    
    // box - daj iznos pologa
    
    Box(,1, 60)
	    @ m_x + 1, m_y + 2 SAY "Unosim polog od:" GET _value PICT "9999999.99"
	    read
    BoxC()

    if LastKey() == K_ESC .or. _value = 0
	    return
    endif

endif

if _value < 0
	// polog komanda
	_cmd := 'Command="CashOut"'
else
	// polog komanda
	_cmd := 'Command="CashIn"'
endif

// izlazni fajl
_f_name := fiscal_out_filename( dev_params["out_file"], __zahtjev_nula )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("TremolFpServer " + _cmd )

_cmd := 'Amount="' +  ALLTRIM( STR( ABS( _value ), 12, 2 ) ) + '"'

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

_f_name := fiscal_out_filename( dev_params["out_file"], __zahtjev_nula )

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

if tremol_read_out( dev_params, _f_name )
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

_f_name := fiscal_out_filename( dev_params["out_file"], __zahtjev_nula )

// putanja do izlaznog xml fajla
_xml := dev_params["out_dir"] + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("TremolFpServer " + cmd )

close_xml()

// provjeri greske...
if tremol_read_out( dev_params, _f_name )
	// procitaj poruku greske
	_err := tremol_read_error( dev_params, _f_name ) 
else
	_err := _nema_out
endif

return _err



// ------------------------------------------
// vraca jedinicu mjere
// ------------------------------------------
static function _g_jmj( jmj )
local _ret := ""

do case
	
    case UPPER(ALLTRIM(jmj)) = "LIT"
		_ret := "l"
	case UPPER(ALLTRIM(jmj)) = "GR"
		_ret := "g"
	case UPPER(ALLTRIM(jmj)) = "KG"
		_ret := "kg"

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
if dev_param["auto_avans"] > 0
	
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
local _cmd
local _racun_broj := SPACE(10)
local _refund := "N"

// box - daj broj racuna
Box(,2, 50)
	@ m_x + 1, m_y + 2 SAY "Broj racuna:" GET _racun_broj ;
		VALID !EMPTY( _racun_broj )
	@ m_x + 2, m_y + 2 SAY "racun je reklamni (D/N)?" GET _refund ;
		VALID _refund $ "DN" PICT "@!"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// <TremolFpServer Command="PrintDuplicate" Type="0" Document="2"/>

_cmd := 'Command="PrintDuplicate"'

if _refund == "N"
	// obicni racun
	_cmd += _razmak1 + 'Type="0"'
else
	// reklamni racun
	_cmd += _razmak1 + 'Type="1"'
endif

_cmd += _razmak1 + 'Document="' +  ALLTRIM( _racun_broj ) + '" /'

_err := tremol_cmd( dev_params, _cmd )

return





// --------------------------------------------
// cekanje na fajl odgovora
// --------------------------------------------
function tremol_read_out( dev_params, f_name, time_out )
local _out := .t.
local _tmp
local _time
local _cnt := 0

if time_out == NIL
	time_out := dev_params["timeout"]
endif

_time := time_out

// napravi mi konstrukciju fajla koji cu gledati
// replace *.xml -> *.out
// out je fajl odgovora
_tmp := dev_params["out_dir"] + STRTRAN( f_name, "xml", "out" )

Box(, 3, 60 )

// ispisi u vrhu id, naz uredjaja
@ m_x + 1, m_y + 2 SAY "Uredjaj ID: " + ALLTRIM( STR( dev_params["id"] )) + ;
                        " : " + PADR( dev_params["name"] , 40 ) 

do while _time > 0
	
	-- _time
	
	// provjeri kada bude trecina vremena...
	if _time = ( time_out * 0.7 ) .and. _cnt = 0

		if dev_params["restart_service"] == "D" .and. Pitanje(, "Restartovati server", "D" ) == "D"

			// pokreni restart proceduru
			tremol_restart( dev_params )

			// restartuj vrijeme
			_time := time_out
			++ _cnt

		endif

	endif

	// fajl se pojavio - izadji iz petlje !
	if FILE( _tmp )
		exit
	endif

	@ m_x + 3, m_y + 2 SAY PADR( "Cekam odgovor... " + ;
		ALLTRIM( STR( _time ) ), 48 )

    if _time == 0 .or. LastKey() == K_ALT_Q
        BoxC()
        return .f.
    endif

	sleep(1)

enddo

BoxC()

if !FILE( _tmp )
	MsgBeep( "Ne postoji fajl odgovora (OUT) !!!!" )
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
local _o_file, _fisc_txt, _err_txt, _linija, _m, _tmp
local _a_err := {}
local _a_tmp2 := {}
local _scan
local _err := 0
local _f_name 

// primjer: c:\fiscal\00001.out
_f_name := ALLTRIM( dev_params["out_dir"] + STRTRAN( f_name, "xml", "out" ) )

fisc_no := 0

_o_file := TFileRead():New( _f_name )
_o_file:Open()

if _o_file:Error()
	MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " + _f_name ) )
	return -9
endif

_fisc_txt := ""

// prodji kroz svaku liniju i procitaj zapise
// 1 liniju preskoci zato sto ona sadrzi 
// <?xml version="1.0"...>
while _o_file:MoreToRead()

	// uzmi u cErr liniju fajla
	_err_txt := hb_strtoutf8( _o_file:ReadLine()  )

	// skloni "<" i ">" itd...
	_err_txt := STRTRAN( _err_txt, '<?xml version="1.0" ?>', "" )
	_err_txt := STRTRAN( _err_txt, ">", "" )
	_err_txt := STRTRAN( _err_txt, "<", "" )
	_err_txt := STRTRAN( _err_txt, "/", "" )
	_err_txt := STRTRAN( _err_txt, '"', "" )
	_err_txt := STRTRAN( _err_txt, "TremolFpServerOutput", "" )
	_err_txt := STRTRAN( _err_txt, "Output Change", "OutputChange" )
	_err_txt := STRTRAN( _err_txt, "Output Total", "OutputTotal" )

    #ifdef __PLATFORM__LINUX
        // ovo je novi red na linux-u
	    _err_txt := STRTRAN( _err_txt, CHR(10), "" )
	    _err_txt := STRTRAN( _err_txt, CHR(9), " " )
    #endif

	// dobijamo npr.
	//
	// ErrorCode=0 ErrorOPOS=OPOS_SUCCESS ErrorDescription=Uspjesno kreiran
	// Output Change=0.00 ReceiptNumber=00552 Total=51.20

	_linija := TokToNiz( _err_txt, SPACE(1) )

	// dobit cemo
	// 
	// aLinija[1] = "ErrorCode=0"
	// aLinija[2] = "ErrorOPOS=OPOS_SUCCESS"
	// ...
	
	// dodaj u generalnu matricu _a_err
	for _m := 1 to LEN( _linija )
		AADD( _a_err, _linija[ _m ] )
	next

enddo

_o_file:Close()

// potrazimo gresku...
#ifdef __PLATFORM__LINUX
    _scan := ASCAN( _a_err, {| val | "ErrorFP=0" $ val } )
#else
    _scan := ASCAN( _a_err, {| val | "OPOS_SUCCESS" $ val } )
#endif

if _scan > 0

	// nema greske, komanda je uspjela !
	// ako je rijec o racunu uzmi broj fiskalnog racuna
        	
	_scan := ASCAN( _a_err, {| val | "ReceiptNumber" $ val } )
	
	if _scan <> 0
		
		// ReceiptNumber=241412
		_a_tmp2 := {}
		_a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )
		
		// ovo ce biti broj racuna
		_tmp := ALLTRIM( _a_tmp2[ 2 ] )
		
		if !EMPTY( _tmp )
			fisc_no := VAL( _tmp )
		endif

	endif
	
	// pobrisi fajl, izdaji
	FERASE( _f_name )

	return _err
	
endif

// imamo gresku !!! ispisi je
_tmp := ""

_scan := ASCAN( _a_err, {| val | "ErrorCode" $ val } )
	
if _scan <> 0
		
	// ErrorCode=241412
	_a_tmp2 := {}
	_a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )
		
	_tmp += "ErrorCode: " + ALLTRIM( _a_tmp2[ 2 ] )
		
	// ovo je ujedino i error kod
	_err := VAL( _a_tmp2[ 2 ] )

endif

_tmp := "ErrorOPOS"

#ifdef __PLATFORM__LINUX
    _tmp := "ErrorFP"
#endif
	
_scan := ASCAN( _a_err, {| val | _tmp $ val } )

if _scan <> 0
		
	// ErrorOPOS=xxxxxxx
	_a_tmp2 := {}
	_a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )
	
	_tmp += " ErrorOPOS: " + ALLTRIM( _a_tmp2[ 2 ] )

endif
	
_scan := ASCAN( _a_err, {| val | "ErrorDescription" $ val } )

if _scan <> 0
		
	// ErrorDescription=xxxxxxx
	_a_tmp2 := {}
	_a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )
	_tmp += " Description: " + ALLTRIM( _a_tmp2[2] )

endif

if !EMPTY( _tmp )
	msgbeep( _tmp )
endif

// obrisi fajl out na kraju !!!
FERASE( _f_name )

return _err




