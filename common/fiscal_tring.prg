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


static LEN_KOLICINA := 8
static LEN_CIJENA := 10
static LEN_VRIJEDNOST := 12
static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_CIJENA := ""
static __zahtjev_nula := "0"

static __xml_head := 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"'

// direktorij odgovora
static _d_answer := "odgovori"

// trigeri za naziv fajla
// stampa fiskalnog racuna
static _tr_rac := "sfr"
// stampa reklamnog racuna
static _tr_rrac := "srr"
// stampa dnevnog izvjestaja
static _tr_drep := "sdi"
// stampa periodicnog izvjestaja
static _tr_prep := "spi"
// stampa nefiskalni tekst
static _tr_ntxt := "snd"
// unos novca
static _tr_p_in := "un"
// povrat novca
static _tr_p_out := "pn"
// stampa duplikata
static _tr_dbl := "dup"
// reset data on PU server
static _tr_x := "rst"
// inicijalizacija
static _tr_init := "init"
// ponisti racun
static _tr_crac := "pon"
// presjek stanja
static _tr_xrpt := "sps"

// legenda nTrig vrijednosti za trigere...
// 1 - stampa racuna
// 2 - stampa reklamnog racuna
// 3 - stampa dnevnog izvjestaja
// 4 - stampa periodicnog izvjestaja
// 5 - stampa presjeka stanja x-rep
// 6 - polog ulaz
// 7 - polog izlaz
// 8 - duplikat
// 9 - reset podataka na serveru PU
// 10 - inicijalizacija
// 11 - ponisti racun

// ocekivana matrica aData:
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
// 16 - roba jmj


// struktura matrice aKupac
// 
// aKupac[1] - idbroj kupca
// aKupac[2] - naziv
// aKupac[3] - adresa
// aKupac[4] - postanski broj
// aKupac[5] - grad stanovanja


// -------------------------------------------------------------------
// stampa fiskalnog racuna tring fiskalizacija
// -------------------------------------------------------------------
function tring_rn( dev_param, items, head, storno )
local _xml, _vrsta_zahtjeva
local _i
local _racun_broj
local _vr_plac, _total_plac
local _art_plu, _art_naz, _art_jmj, _cijena, _kolicina
local _rabat, _grupa, _plu
local _customer := .f.
local _err_level := 0
local _reklamni_racun
local _trig
local _f_name := dev_param["out_file"]
local _f_path := dev_param["out_dir"]

// stampanje racuna
_vrsta_zahtjeva := "0"

if storno
	// stampanje reklamnog racuna
	_vrsta_zahtjeva := "2"
	_reklamni_racun := ALLTRIM( items[ 1, 8 ] )
endif

PIC_KOLICINA := "9999999.99"
PIC_VRIJEDNOST := "9999999.99"
PIC_CIJENA := "9999999.99"

if head <> NIL .and. LEN( head ) > 0
	_customer := .t.
endif

// to je zapravo broj racuna !!!
_racun_broj := items[ 1, 1 ]

_trig := 1

// putanja do izlaznog xml fajla
if storno
	_f_name := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_rrac )
	_trig := 2
else
	_f_name := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_rac )
endif

// c:\tring\xml\sfr.001
_xml := _f_path + _f_name

// brisi answer
tring_delete_answer( dev_param, _trig )

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode( "RacunZahtjev " + __xml_head, .f.)

  xml_node( "BrojZahtjeva", _racun_broj )
  
  // 0 - stampa sve stavke i zatvara racun
  // 1 - stampa stavku po stavku
  // 
  // Mi cemo koristiti varijantu "0"
  xml_node( "VrstaZahtjeva", _vrsta_zahtjeva )
  
  xml_subnode( "NoviObjekat", .f. )

    // ako ima podataka o kupcu
    if _customer
    
  	    xml_subnode("Kupac", .f.)

	        xml_node("IDbroj", head[ 1, 1 ] )
	        xml_node("Naziv", to_xml_encoding( head[ 1, 2 ] ) )
	        xml_node("Adresa", to_xml_encoding( head[ 1, 3 ] ) )
	        xml_node("PostanskiBroj", head[ 1, 4 ] )
	        xml_node("Grad", to_xml_encoding( head[ 1, 5 ] ) )
  	
	    xml_subnode("Kupac", .t.)	

    endif
    
    xml_subnode("StavkeRacuna", .f.)

    for _i := 1 to LEN( items )

	    _art_id := items[ _i, 3 ]
	    _art_naz := ALLTRIM( PADR( items[ _i, 4 ], 36 ))
	    _art_jmj := items[ _i, 16 ]
	    _cijena := items[ _i, 5 ]
	    _kolicina := items[ _i, 6 ]
	    _rabat := items[ _i, 11 ]
	    _tarfa := fiscal_txt_get_tarifa( items[ _i, 7 ], dev_param["pdv"], "TRING" )
	    _grupa := ""
	    _plu := ALLTRIM( STR( items[ _i, 9 ] ))

	    xml_subnode("RacunStavka", .f.)
	
	        xml_subnode("artikal", .f.)
	
	            xml_node("Sifra", _plu )
	            xml_node("Naziv", to_xml_encoding( _art_naz ) )
	            xml_node("JM", to_xml_encoding( PADR( _art_jmj, 2 ) ) )
	            xml_node("Cijena", show_number( _cijena, PIC_CIJENA ) )
	            xml_node("Stopa", _tarifa )

	        xml_subnode("artikal", .t.)

	        xml_node("Kolicina", show_number( _kolicina, PIC_KOLICINA ) )
	        xml_node("Rabat", show_number( _rabat, PIC_VRIJEDNOST ) )

	    xml_subnode("RacunStavka", .t.)

    next

    xml_subnode("StavkeRacuna", .t.)

    // vrste placanja, oznaka:
    //   "GOTOVINA"
    //   "CEK"
    //   "VIRMAN"
    //   "KARTICA"

    if ALLTRIM( items[ 1, 13 ]) == "3" .and. storno
        _vr_plac := fiscal_txt_get_vr_plac( "2", "TRING" )
    else
        _vr_plac := fiscal_txt_get_vr_plac( "0", "TRING" )
    endif

    _total_plac := 0

    xml_subnode("VrstePlacanja", .f.)
      xml_subnode("VrstaPlacanja", .f.)

         xml_node("Oznaka", _vr_plac ) 
         xml_node("Iznos", ALLTRIM( STR( _total_plac ) ) )

      xml_subnode("VrstaPlacanja", .t.)
    xml_subnode("VrstePlacanja", .t.)

    xml_node("Napomena", "racun br: " + _racun_broj )
    
    if storno
       xml_node("BrojRacuna", _reklamni_racun )
    else
       xml_node("BrojRacuna", _racun_broj )
    endif

  xml_subnode("NoviObjekat", .t.)

xml_subnode("RacunZahtjev", .t.)

close_xml()

return _err_level


// ----------------------------------------------
// polog novca u uredjaj
// ----------------------------------------------
function tring_polog( dev_param )
local _f_name
local _xml
local _zahtjev_broj := "0"
local _zahtjev_vrsta := "7"
local _cash := 0
local _trig := 6 

Box(, 1, 50 )
	@ m_x + 1, m_y + 2 SAY "Unesi polog:" GET _cash ;
		PICT "999999.99"
	read
BoxC()

if _cash = 0 .or. LastKey() == K_ESC
	return
endif

_f_name := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_p_in )

if _cash < 0
	// ovo je povrat
	_zahtjev_vrsta := "8"
	_f_name := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_p_out )
	_trig := 7
endif

// brisi answer
tring_delete_answer( dev_param, _trig )

// c:\tring\xml\unosnovca.001
_xml := dev_param["out_dir"] + _f_name

// otvori xml
open_xml( _xml )

// upisi header
xml_head()

xml_subnode("RacunZahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", _zahtjev_broj )
  xml_node("VrstaZahtjeva", _zahtjev_vrsta )
  
  xml_subnode("NoviObjekat", .f. )
     
        xml_node( "Oznaka", "Gotovina" )
        xml_node( "Iznos", ALLTRIM( STR( _cash, 12, 2 ) ) )
     
  xml_subnode("NoviObjekat", .t. )
  
xml_subnode("RacunZahtjev", .t.)

close_xml()

return




// ----------------------------------------------
// prepis dokumenata
// ----------------------------------------------
function tring_double( dev_param )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "3"
local nFisc_no := 0
local nTrigg := 8

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Duplikat racuna:" GET nFisc_no
	read
BoxC()

if nFisc_no = 0 .or. LastKey() == K_ESC
	return
endif

cF_out := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_dbl )

// c:\tring\xml\stampatiperiodicniizvjestaj.001
cXML := dev_param["out_dir"] + cF_out

// brisi answer
tring_delete_answer( dev_param, nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", ALLTRIM(STR(nFisc_no)) )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
 
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// periodicni izvjestaj
// ----------------------------------------------
function tring_per_rpt( dev_param )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "5"
local cDatumOd := ""
local cDatumDo := ""
local dD_od := DATE()-30
local dD_do := DATE()
local nTrigg := 4

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Od datuma:" GET dD_od
	@ m_x + 1, col() + 1 SAY "do:" GET dD_do
	read
BoxC()

cDatumOd := _fix_date( dD_od )
cDatumDo := _fix_date( dD_do )

cF_out := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_prep )

// c:\tring\xml\stampatiperiodicniizvjestaj.001
cXML := dev_param["out_dir"] + cF_out

// brisi answer
tring_delete_answer( dev_param, nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  
  xml_subnode("Parametri", .f. )
     
     xml_subnode("Parametar", .f. )
        xml_node( "Naziv", "odDatuma" )
        xml_node( "Vrijednost", cDatumOd )
     xml_subnode("Parametar", .t. )
     
     xml_subnode("Parametar", .f. )
        xml_node( "Naziv", "doDatuma" )
        xml_node( "Vrijednost", cDatumDo )
     xml_subnode("Parametar", .t. )
    
  xml_subnode("Parametri", .t. )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return

// ----------------------------------------------
// reset zahtjeva
// ----------------------------------------------
function tring_reset( dev_param )
local cF_out
local cXml
local nTrigg := 9

cF_out := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_x )

// c:\tring\xml\reset.001
cXML := dev_param["out_dir"] + cF_out

// brisi answer
tring_delete_answer( dev_param, nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_node("boolean", "false" )

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// inicijalizacija
// ----------------------------------------------
function tring_init( dev_param, cOper, cPwd )
local cF_out
local cXml
local nTrigg := 10

cF_out := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_init )

cOper := ALLTRIM( dev_param["op_id"] )

// c:\tring\xml\inicijalizacija.001
cXML := dev_param["out_dir"] + cF_out

// brisi answer
tring_delete_answer( dev_param, nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Operator " + __xml_head, .f.)

  xml_node("BrojOperatora", cOper )
  xml_node("Lozinka", cPwd )
  
xml_subnode("Operator", .t.)

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// prekini racun
// ----------------------------------------------
function tring_close_rn( dev_param )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "9"
local nTrigg := 11

cF_out := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_crac )

// c:\tring\xml\prekiniracun.001
cXML := dev_param["out_dir"] + cF_out

// brisi out
tring_delete_answer( dev_param, nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// presjek stanja
// ----------------------------------------------
function tring_x_rpt( dev_param )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "3"
local nTrigg := 5 

cF_out := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_xrpt )

// c:\tring\xml\stampatidnevniizvjestaj.001
cXML := dev_param["out_dir"] + cF_out

tring_delete_answer( dev_param, nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// dnevni izvjestaj
// ----------------------------------------------
function tring_daily_rpt( dev_param )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "4"
local nTrigg := 3
local _param_date, _param_time
local _rpt_type := "Z"

if Pitanje(,"Stampati dnevni izvjestaj", "D") == "N"
	return
endif

_param_date := "zadnji_" + _rpt_type + "_izvjestaj_datum"
_param_time := "zadnji_" + _rpt_type + "_izvjestaj_vrijeme"

// iscitaj zadnje formirane izvjestaje...
_last_date := fetch_metric( _param_date, NIL, CTOD("") )
_last_time := PADR( fetch_metric( _param_time, NIL, "" ), 5 )

if DATE() == _last_date
    MsgBeep( "Zadnji dnevni izvjestaj radjen " + DTOC( _last_date) + " u " + _last_time )
endif

cF_out := fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _tr_drep )

// c:\tring\xml\stampatidnevniizvjestaj.001
cXML := dev_param["out_dir"] + cF_out

tring_delete_answer( dev_param, nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

// upisi zadnji dnevni izvjestaj
set_metric( _param_date, NIL, DATE() )
set_metric( _param_time, NIL, TIME() )

// nakon ovoga provjeri
return


// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
function tring_delete_out( dev_param, trig )
local _trig := trg_trig( trig )
local _file

_file := dev_param["out_dir"] + fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _trig )

if FILE( _file )
	FERASE( _file )
endif

return


// ----------------------------------------------
// brise fajlove iz direktorija odgovora
// ----------------------------------------------
function tring_delete_answer( dev_param, trig )
local _trig := trg_trig( trig )
local _file

_file := dev_param["out_dir"] + _d_answer + SLASH + ;
            fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _trig )

if FILE( _file )
    FERASE( _file )
endif

return


// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
function tring_delete_tmp( dev_param, cPodDir )
local cTmp 

if cPodDir == nil
	cPodDir := ""
endif

msgo("brisem tmp fajlove...")

cF_path := dev_param["out_dir"]

if !EMPTY(cPoddir)
	cF_path += cPodDir + SLASH
endif

cTmp := "*.*"

AEVAL( DIRECTORY(cF_path + cTmp), {|aFile| FERASE( cF_path + ;
	ALLTRIM( aFile[1]) ) })

sleep(1)

msgc()

return




// ---------------------------------------------
// fiksiraj datum za xml
// ---------------------------------------------
static function _fix_date( dDate , cPattern )
local cRet := ""
local nYear := YEAR( dDate )
local nMonth := MONTH ( dDate )
local nDay := DAY ( dDate )

if cPattern == nil
	cPattern := ""
endif

if Empty( cPattern )

	cRet := ALLTRIM( STR ( nDay ) ) + "." + ;
		ALLTRIM( STR( nMonth) ) + "." + ;
		ALLTRIM( STR( nYear ) )
	
	return cRet

endif

// MM.DD.YYYY

cPattern := STRTRAN( cPattern, "MM", ALLTRIM(STR(nMonth))) 
cPattern := STRTRAN( cPattern, "DD", ALLTRIM(STR(nDay))) 
cPattern := STRTRAN( cPattern, "YYYY", ALLTRIM(STR(nYear))) 
// if .YY in pattern
cPattern := STRTRAN( cPattern, "YY", ALLTRIM(PADL(STR(nYear),2))) 

cRet := cPattern

return cRet




// ------------------------------------------
// procitaj gresku
// ------------------------------------------
function tring_read_error( dev_param, fisc_no, trig )
local _err := 0
local _trig := trg_trig( trig )
local _f_name
local _i, _time
local _err_data, _scan, _err_txt
local _ok
local _o_file

_time := dev_param["timeout"]

// primjer: c:\tring\xml\odgovori\sfr.001
_f_name := dev_param["out_dir"] + ;
            _d_answer + ;
            SLASH + ;
            fiscal_out_filename( dev_param["out_file"], __zahtjev_nula, _trig )

_err_data := {}

Box(, 3, 60 )

@ m_x + 1, m_y + 2 SAY "Uredjaj ID: " + ALLTRIM( STR( dev_param["id"] ) ) + ;
                    " : " + PADR( dev_param["name"], 40 )

do while _time > 0
	
	-- _time

	if FILE( _f_name )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 3, m_y + 2 SAY PADR( "Cekam na fiskalni uredjaj: " + ALLTRIM( STR( _time ) ), 48)

	sleep(1)

enddo

BoxC()

if !FILE( _f_name )
	msgbeep("Fajl " + _f_name + " ne postoji !!!")
    fisc_no := 0
	_err := -9
	return _err
endif

fisc_no := 0

_o_file := TFileRead():New( _f_name )
_o_file:Open()

if _o_file:Error()
	MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " + _f_name ) )
	return -9
endif

_fisc_txt := ""
_ok := .f.

// prodji kroz svaku liniju i procitaj zapise
while _o_file:MoreToRead()
	
	// uzmi u cErr liniju fajla
	_err_txt := hb_strtoutf8( _o_file:ReadLine() )

	// ovo je dodavanje artikla
	if ( "<?xml" $ _err_txt ) .or. ;
		( "<KasaOdgovor" $ _err_txt ) .or. ; 
		( "</KasaOdgovor" $ _err_txt ) .or. ;
		( "<Odgovor" $ _err_txt ) .or. ;
		( "</Odgovor" $ _err_txt )
		// preskoci
		loop
	endif

	AADD( _err_data, _err_txt )	

enddo

_o_file:Close()

// sad imam matricu sa linijama
// aErr_data[1, "<Naziv>OK</Naziv>"]
// aErr_data[2, "<Vrijednost></Vrijednost>"]
// aErr_data[3, "<Naziv>BrojFiskalnogRacuna</Naziv>"]
// aErr_data[4, "<Vrijednost>5</Vrijednost>"]
// ... itd...

// prvo provjeri da li je komanda ok
_scan := ASCAN( _err_data, {| val | "<VrstaOdgovora>OK" $ val })
if _scan <> 0
	// ovo je ok racun ili bilo koja komanda
	_ok := .t.
endif

if _ok == .f.
	// nije ispravna komanda
	_err := 1
	return _err
endif

// sada cemo potraziti broj fiskalnog racuna
_scan := ASCAN( _err_data, ;
	{| val | "<Naziv>BrojFiskalnogRacuna" $ val })

if _scan <> 0
	// imamo racun
	// ali se krije na sljedecoj liniji
	// zato + 1
	fisc_no := _g_fisc_no( _err_data[ _scan + 1 ] )
endif

return _err




// ------------------------------------------------------
// vraca broj fiskalnog racuna iz linije fajla
// ------------------------------------------------------
static function _g_fisc_no( row )
local _fiscal_no := 0
row := STRTRAN( row, '<Vrijednost xsi:type="xsd:long">', '' )
row := STRTRAN( row, '</Vrijednost>', '' )
// ostatak bi trebao da bude samo broj fiskalnog racuna :)
if !EMPTY( row )
	_fiscal_no := VAL( ALLTRIM( row ) )
endif
return _fiscal_no





// ------------------------------------------
// vraca triger za tring filename
// ------------------------------------------
function trg_trig( nTrig )
local cTrig := ""

do case
	case nTrig = 1
		// stampa racuna
		cTrig := _tr_rac
	case nTrig = 2
		// stampa reklamnog racuna
		cTrig := _tr_rrac
	case nTrig = 3
		// stampa dnevnog izvjestaja
		cTrig := _tr_drep
	case nTrig = 4
		// stampa periodicnog izvjestaja
		cTrig := _tr_prep
	case nTrig = 5
		// stampa presjeka stanja
		cTrig := _tr_xrep
	case nTrig = 6
		// polog in
		cTrig := _tr_p_in
	case nTrig = 7
		// polog out
		cTrig := _tr_p_out
	case nTrig = 8
		// duplikat
		cTrig := _tr_dbl
	case nTrig = 9
		// reset podataka na serveru
		cTrig := _tr_x
	case nTrig = 10
		// inicijalizacija
		cTrig := _tr_init
	case nTrig = 11
		// ponisti racun
		cTrig := _tr_crac
	otherwise
		// u drugom slucaju nema trigera
		cTrig := "xxx"
endcase

return cTrig







