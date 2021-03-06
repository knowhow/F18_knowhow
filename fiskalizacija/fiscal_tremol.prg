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

STATIC _razmak1 := " "
STATIC _nema_out := -20
STATIC __zahtjev_nula := "0"

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


/*
 stampa fiskalnog racuna tring fiskalizacija
*/

FUNCTION tremol_rn( hFiskalniParams, aRacunStavke, aRnHeader, lStornoRacun, cContinue )

   LOCAL _racun_broj, _vr_plac, _total_plac, _xml, nI
   LOCAL _reklamni_broj, _kolicina, _cijena, _rabat
   LOCAL _art_id, _art_naz, _art_jmj, _tmp, _art_barkod, _art_plu, _dep, _tarifa
   LOCAL _customer := .F.
   LOCAL _err_level := 0
   LOCAL _oper := ""
   LOCAL _cmd := ""
   LOCAL _cust_id, _cust_name, _cust_addr, _cust_city
   LOCAL _fiscal_no := 0
   LOCAL _fisc_txt, _fisc_rek_txt, _fisc_cust_txt, _f_name


   tremol_delete_tmp( hFiskalniParams )  // pobrisi tmp fajlove i ostalo sto je u input direktoriju

   IF cContinue == nil
      cContinue := "0"
   ENDIF


   IF aRnHeader <> NIL .AND. Len( aRnHeader ) > 0  // ima podataka kupca
      _customer := .T.
   ENDIF


   _racun_broj := aRacunStavke[ 1, 1 ] // to je zapravo broj racuna

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], _racun_broj )

   _xml := hFiskalniParams[ "out_dir" ] + _f_name // putanja do izlaznog xml fajla


   create_xml( _xml )
   xml_head()

   _fisc_txt := 'TremolFpServer Command="Receipt"'
   _fisc_rek_txt := ''
   _fisc_cust_txt := ''

   IF cContinue == "1" // https://redmine.bring.out.ba/issues/36372
      //_fisc_txt += ' Continue="' + cContinue + '"'
   ENDIF


   IF lStornoRacun // ukljuci storno triger
      _fisc_rek_txt := ' RefundReceipt="' + AllTrim( aRacunStavke[ 1, 8 ] ) + '"'
   ENDIF

   // ukljuci kupac triger
   IF _customer

      // aKupac[1] - idbroj kupca
      // aKupac[2] - naziv
      // aKupac[3] - adresa
      // aKupac[4] - postanski broj
      // aKupac[5] - grad stanovanja

      _cust_id := AllTrim( aRnHeader[ 1, 1 ] )
      _cust_name := to_xml_encoding( AllTrim( aRnHeader[ 1, 2 ] ) )
      _cust_addr := to_xml_encoding( AllTrim( aRnHeader[ 1, 3 ] ) )
      _cust_city := to_xml_encoding( AllTrim( aRnHeader[ 1, 5 ] ) )

      _fisc_cust_txt += _razmak1 + 'CompanyID="' + _cust_id + '"'
      _fisc_cust_txt += _razmak1 + 'CompanyName="' + _cust_name + '"'
      _fisc_cust_txt += _razmak1 + 'CompanyHQ="' + _cust_city + '"'
      _fisc_cust_txt += _razmak1 + 'CompanyAddress="' + _cust_addr + '"'
      _fisc_cust_txt += _razmak1 + 'CompanyCity="' + _cust_city + '"'

   ENDIF

   // ubaci u xml
   xml_subnode( _fisc_txt + _fisc_rek_txt + _fisc_cust_txt )

   _total_plac := 0

   FOR nI := 1 TO Len( aRacunStavke )

      _art_plu := aRacunStavke[ nI, 9 ]
      _art_barkod := aRacunStavke[ nI, 12 ]
      _art_id := aRacunStavke[ nI, 3 ]
      //_art_naz := PadR( aRacunStavke[ nI, 4 ], 32 )
      _art_naz := aRacunStavke[ nI, 4 ]
      _art_jmj := _g_jmj( aRacunStavke[ nI, 16 ] )
      _cijena := aRacunStavke[ nI, 5 ]
      _kolicina := aRacunStavke[ nI, 6 ]
      _rabat := aRacunStavke[ nI, 11 ]
      _tarifa := fiscal_txt_get_tarifa( aRacunStavke[ nI, 7 ], hFiskalniParams[ "pdv" ], "TREMOL" )
      _dep := "1"

      _tmp := ""

      // naziv artikla
      _tmp += _razmak1 + 'Description="' + to_xml_encoding( _art_naz ) + '"'
      // kolicina artikla
      _tmp += _razmak1 + 'Quantity="' + AllTrim( Str( _kolicina, 12, 3 ) ) + '"'
      // cijena artikla
      _tmp += _razmak1 + 'Price="' + AllTrim( Str( _cijena, 12, 2 ) ) + '"'
      // poreska stopa
      _tmp += _razmak1 + 'VatInfo="' + _tarifa + '"'
      // odjeljenje
      _tmp += _razmak1 + 'Department="' + _dep + '"'
      // jedinica mjere
      _tmp += _razmak1 + 'UnitName="' + _art_jmj + '"'

      IF _rabat > 0
         // vrijednost popusta
         _tmp += _razmak1 + 'Discount="' + AllTrim( Str( _rabat, 12, 2 ) ) + '%"'
      ENDIF

      xml_single_node( "Item", _tmp )

   NEXT

   // vrste placanja, oznaka:
   // "GOTOVINA"
   // "CEK"
   // "VIRMAN"
   // "KARTICA"

   _vr_plac := fiscal_txt_get_vr_plac( aRacunStavke[ 1, 13 ], "TREMOL" )
   _total_plac := aRacunStavke[ 1, 14 ]

   IF aRacunStavke[ 1, 13 ] <> "0" .AND. !lStornoRacun

      _tmp := 'Type="' + _vr_plac + '"'
      _tmp += _razmak1 + 'Amount="' + AllTrim( Str( _total_plac, 12, 2 ) ) + '"'

      xml_single_node( "Payment", _tmp )

   ENDIF

   // dodatna linija, broj veznog racuna
   _tmp := 'Message="Vezni racun: ' + _racun_broj + '"'

   xml_single_node( "AdditionalLine", _tmp )

   xml_subnode( "TremolFpServer", .T. )

   close_xml()

   RETURN _err_level


// --------------------------------------------------
// restart tremol fp server
// --------------------------------------------------
FUNCTION tremol_restart( hFiskalniParams )

   LOCAL _scr
   PRIVATE _script

   IF hFiskalniParams[ "restart_service" ] == "N"
      RETURN .F.
   ENDIF

   _script := "start " + EXEPATH + "fp_rest.bat"

   SAVE SCREEN TO _scr
   CLEAR SCREEN

   ? "Restartujem server..."
   _err := f18_run( _scrtip )

   RESTORE SCREEN FROM _scr

   RETURN .F.

// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
FUNCTION tremol_delete_tmp( dev_param )

   LOCAL _tmp
   LOCAL _f_path

   MsgO( "brisem tmp fajlove..." )

   _f_path := dev_param[ "out_dir" ]
   _tmp := "*.*"

   AEval( Directory( _f_path + _tmp ), {| aFile | FErase( _f_path + ;
      AllTrim( aFile[ 1 ] ) ) } )

   Sleep( 1 )

   MsgC()

   RETURN




// -------------------------------------------------------------------
// -------------------------------------------------------------------
FUNCTION tremol_polog( hFiskalniParams, auto )

   LOCAL _xml
   LOCAL _err := 0
   LOCAL _cmd := ""
   LOCAL _f_name
   LOCAL _value := 0

   IF auto == NIL
      auto := .F.
   ENDIF

   IF auto
      _value := hFiskalniParams[ "auto_avans" ]
   ENDIF

   IF _value = 0

      // box - daj iznos pologa

      Box(, 1, 60 )
      @ box_x_koord() + 1, box_y_koord() + 2 SAY "Unosim polog od:" GET _value PICT "9999999.99"
      READ
      BoxC()

      IF LastKey() == K_ESC .OR. _value = 0
         RETURN
      ENDIF

   ENDIF

   IF _value < 0
      // polog komanda
      _cmd := 'Command="CashOut"'
   ELSE
      // polog komanda
      _cmd := 'Command="CashIn"'
   ENDIF

   // izlazni fajl
   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "TremolFpServer " + _cmd )

   _cmd := 'Amount="' +  AllTrim( Str( Abs( _value ), 12, 2 ) ) + '"'

   xml_single_node( "Cash", _cmd )

   xml_subnode( "/TremolFpServer" )

   close_xml()

   RETURN _err




// -------------------------------------------------------------------
// tremol reset artikala
// -------------------------------------------------------------------
FUNCTION tremol_reset_plu( hFiskalniParams )

   LOCAL _xml
   LOCAL _err := 0
   LOCAL _cmd := ""

   IF !spec_funkcije_sifra( "RPLU" )
      RETURN 0
   ENDIF

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   _cmd := 'Command="DirectIO"'

   xml_subnode( "TremolFpServer " + _cmd )

   _cmd := 'Command="1"'
   _cmd += _razmak1 + 'Data="0"'
   _cmd += _razmak1 + 'Object="K00000;F142HZ              ;0;$"'

   xml_single_node( "DirectIO", _cmd )

   xml_subnode( "/TremolFpServer" )

   close_xml()

   IF tremol_read_out( hFiskalniParams, _f_name )
      _err := tremol_read_error( hFiskalniParams, _f_name )
   ENDIF

   RETURN _err



// -------------------------------------------------------------------
// tremol komanda
// -------------------------------------------------------------------
FUNCTION tremol_cmd( hFiskalniParams, cmd )

   LOCAL _xml
   LOCAL _err := 0
   LOCAL _f_name

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "TremolFpServer " + cmd )

   close_xml()

   // provjeri greske...
   IF tremol_read_out( hFiskalniParams, _f_name )
      // procitaj poruku greske
      _err := tremol_read_error( hFiskalniParams, _f_name )
   ELSE
      _err := _nema_out
   ENDIF

   RETURN _err



// ------------------------------------------
// vraca jedinicu mjere
// ------------------------------------------
STATIC FUNCTION _g_jmj( jmj )

   LOCAL _ret := ""

   DO CASE

   CASE Upper( AllTrim( jmj ) ) = "LIT"
      _ret := "l"
   CASE Upper( AllTrim( jmj ) ) = "GR"
      _ret := "g"
   CASE Upper( AllTrim( jmj ) ) = "KG"
      _ret := "kg"

   ENDCASE

   RETURN _ret



// -----------------------------------------------------
// ItemZ
// -----------------------------------------------------
FUNCTION tremol_z_item( dev_param )

   LOCAL _cmd, _err

   _cmd := 'Command="Report" Type="ItemZ" /'
   _err := tremol_cmd( dev_param, _cmd )

   RETURN _err


// -----------------------------------------------------
// ItemX
// -----------------------------------------------------
FUNCTION tremol_x_item( dev_param )

   LOCAL _cmd

   _cmd := 'Command="Report" Type="ItemX" /'
   _err := tremol_cmd( dev_param, _cmd )

   RETURN _err


// -----------------------------------------------------
// dnevni fiskalni izvjestaj
// -----------------------------------------------------
FUNCTION tremol_z_rpt( dev_param )

   LOCAL _cmd
   LOCAL _err
   LOCAL _param_date, _param_time
   LOCAL _rpt_type := "Z"

   IF Pitanje(, "Stampati dnevni izvjestaj", "D" ) == "N"
      RETURN
   ENDIF

   _param_date := "zadnji_" + _rpt_type + "_izvjestaj_datum"
   _param_time := "zadnji_" + _rpt_type + "_izvjestaj_vrijeme"

   // iscitaj zadnje formirane izvjestaje...
   _last_date := fetch_metric( _param_date, NIL, CToD( "" ) )
   _last_time := PadR( fetch_metric( _param_time, NIL, "" ), 5 )

   IF Date() == _last_date
      MsgBeep( "Zadnji dnevni izvjestaj radjen " + DToC( _last_date ) + " u " + _last_time )
   ENDIF

   _cmd := 'Command="Report" Type="DailyZ" /'
   _err := tremol_cmd( dev_param, _cmd )

   // upisi zadnji dnevni izvjestaj
   set_metric( _param_date, NIL, Date() )
   set_metric( _param_time, NIL, Time() )

   // ako se koristi opcija automatskog pologa
   IF dev_param[ "auto_avans" ] > 0

      MsgO( "Automatski unos pologa u uredjaj... sacekajte." )

      // daj mi malo prostora
      Sleep( 10 )

      // pozovi opciju pologa
      _err := tremol_polog( dev_param, .T. )

      MsgC()

   ENDIF

   RETURN _err


// -----------------------------------------------------
// presjek stanja
// -----------------------------------------------------
FUNCTION tremol_x_rpt( dev_param )

   LOCAL _cmd
   LOCAL _err

   _cmd := 'Command="Report" Type="DailyX" /'
   _err := tremol_cmd( dev_param, _cmd )

   RETURN


// -----------------------------------------------------
// periodicni izvjestaj
// -----------------------------------------------------
FUNCTION tremol_per_rpt( dev_param )

   LOCAL _cmd, _err
   LOCAL _start
   LOCAL _end
   LOCAL _date_start := Date() -30
   LOCAL _date_end := Date()

   IF Pitanje(, "Stampati periodicni izvjestaj", "D" ) == "N"
      RETURN
   ENDIF

   Box(, 1, 60 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Od datuma:" GET _date_start
   @ box_x_koord() + 1, Col() + 1 SAY "do datuma:" GET _date_end
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // 2010-10-01 : YYYY-MM-DD je format datuma
   _start := _tfix_date( _date_start )
   _end := _tfix_date( _date_end )

   _cmd := 'Command="Report" Type="Date" Start="' + _start + ;
      '" End="' + _end + '" /'

   _err := tremol_cmd( dev_param, _cmd )

   RETURN _err


// ------------------------------------------------
// sredjuje datum za tremol uredjaj xml
// ------------------------------------------------
STATIC FUNCTION _tfix_date( dDate )

   LOCAL xRet := ""
   LOCAL cTmp

   cTmp := AllTrim( Str( Year( dDate ) ) )

   xRet += cTmp
   xRet += "-"

   cTmp := PadL( AllTrim( Str( Month( dDate ) ) ), 2, "0" )

   xRet += cTmp
   xRet += "-"

   cTmp := PadL( AllTrim( Str( Day( dDate ) ) ), 2, "0" )
   xRet += cTmp

   RETURN xRet




// ---------------------------------------------------
// stampa kopije racuna
// ---------------------------------------------------
FUNCTION tremol_rn_copy( hFiskalniParams )

   LOCAL _cmd
   LOCAL _racun_broj := Space( 10 )
   LOCAL _refund := "N"

   // box - daj broj racuna
   Box(, 2, 50 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Broj racuna:" GET _racun_broj ;
      VALID !Empty( _racun_broj )
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "racun je reklamni (D/N)?" GET _refund ;
      VALID _refund $ "DN" PICT "@!"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // <TremolFpServer Command="PrintDuplicate" Type="0" Document="2"/>

   _cmd := 'Command="PrintDuplicate"'

   IF _refund == "N"
      // obicni racun
      _cmd += _razmak1 + 'Type="0"'
   ELSE
      // reklamni racun
      _cmd += _razmak1 + 'Type="1"'
   ENDIF

   _cmd += _razmak1 + 'Document="' +  AllTrim( _racun_broj ) + '" /'

   _err := tremol_cmd( hFiskalniParams, _cmd )

   RETURN





// --------------------------------------------
// cekanje na fajl odgovora
// --------------------------------------------
FUNCTION tremol_read_out( hFiskalniParams, f_name, time_out )

   LOCAL _out := .T.
   LOCAL _tmp
   LOCAL _time
   LOCAL _cnt := 0

   IF time_out == NIL
      time_out := hFiskalniParams[ "timeout" ]
   ENDIF

   _time := time_out

   // napravi mi konstrukciju fajla koji cu gledati
   // replace *.xml -> *.out
   // out je fajl odgovora
   _tmp := hFiskalniParams[ "out_dir" ] + StrTran( f_name, "xml", "out" )

   Box(, 3, 60 )

   // ispisi u vrhu id, naz uredjaja
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Uredjaj ID: " + AllTrim( Str( hFiskalniParams[ "id" ] ) ) + ;
      " : " + PadR( hFiskalniParams[ "name" ], 40 )

   DO WHILE _time > 0

      -- _time

      // provjeri kada bude trecina vremena...
      IF _time = ( time_out * 0.7 ) .AND. _cnt = 0

         IF hFiskalniParams[ "restart_service" ] == "D" .AND. Pitanje(, "Restartovati server", "D" ) == "D"

            // pokreni restart proceduru
            tremol_restart( hFiskalniParams )

            // restartuj vrijeme
            _time := time_out
            ++ _cnt

         ENDIF

      ENDIF

      // fajl se pojavio - izadji iz petlje !
      IF File( _tmp )
         EXIT
      ENDIF

      @ box_x_koord() + 3, box_y_koord() + 2 SAY PadR( "Cekam odgovor... " + ;
         AllTrim( Str( _time ) ), 48 )

      IF _time == 0 .OR. LastKey() == K_ALT_Q
         BoxC()
         RETURN .F.
      ENDIF

      Sleep( 1 )

   ENDDO

   BoxC()

   IF !File( _tmp )
      MsgBeep( "Ne postoji fajl odgovora (OUT) !!!!" )
      _out := .F.
   ENDIF

   RETURN _out





// ------------------------------------------------------------
// citanje gresaka za TREMOL driver
//
// nFisc_no - broj fiskalnog isjecka
//
// ------------------------------------------------------------
FUNCTION tremol_read_error( hFiskalniParams, f_name, fisc_no )

   LOCAL _o_file, _fisc_txt, _err_txt, _linija, _m, _tmp
   LOCAL _a_err := {}
   LOCAL _a_tmp2 := {}
   LOCAL _scan
   LOCAL _err := 0
   LOCAL _f_name

   // primjer: c:\fiscal\00001.out
   _f_name := AllTrim( hFiskalniParams[ "out_dir" ] + StrTran( f_name, "xml", "out" ) )

   fisc_no := 0

   _o_file := TFileRead():New( _f_name )
   _o_file:Open()

   IF _o_file:Error()
      MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " + _f_name ) )
      RETURN -9
   ENDIF

   _fisc_txt := ""

   // prodji kroz svaku liniju i procitaj zapise
   // 1 liniju preskoci zato sto ona sadrzi
   // <?xml version="1.0"...>
   WHILE _o_file:MoreToRead()

      // uzmi u cErr liniju fajla
      _err_txt := hb_StrToUTF8( _o_file:ReadLine()  )

      // skloni "<" i ">" itd...
      _err_txt := StrTran( _err_txt, '<?xml version="1.0" ?>', "" )
      _err_txt := StrTran( _err_txt, ">", "" )
      _err_txt := StrTran( _err_txt, "<", "" )
      _err_txt := StrTran( _err_txt, "/", "" )
      _err_txt := StrTran( _err_txt, '"', "" )
      _err_txt := StrTran( _err_txt, "TremolFpServerOutput", "" )
      _err_txt := StrTran( _err_txt, "Output Change", "OutputChange" )
      _err_txt := StrTran( _err_txt, "Output Total", "OutputTotal" )

#ifdef __PLATFORM__LINUX
      // ovo je novi red na linux-u
      _err_txt := StrTran( _err_txt, Chr( 10 ), "" )
      _err_txt := StrTran( _err_txt, Chr( 9 ), " " )
#endif

      // dobijamo npr.
      //
      // ErrorCode=0 ErrorOPOS=OPOS_SUCCESS ErrorDescription=Uspjesno kreiran
      // Output Change=0.00 ReceiptNumber=00552 Total=51.20

      _linija := TokToNiz( _err_txt, Space( 1 ) )

      // dobit cemo
      //
      // aLinija[1] = "ErrorCode=0"
      // aLinija[2] = "ErrorOPOS=OPOS_SUCCESS"
      // ...

      // dodaj u generalnu matricu _a_err
      FOR _m := 1 TO Len( _linija )
         AAdd( _a_err, _linija[ _m ] )
      NEXT

   ENDDO

   _o_file:Close()

   // potrazimo gresku...
#ifdef __PLATFORM__LINUX
   _scan := AScan( _a_err, {| val | "ErrorFP=0" $ val } )
#else
   _scan := AScan( _a_err, {| val | "OPOS_SUCCESS" $ val } )
#endif

   IF _scan > 0

      // nema greske, komanda je uspjela !
      // ako je rijec o racunu uzmi broj fiskalnog racuna

      _scan := AScan( _a_err, {| val | "ReceiptNumber" $ val } )

      IF _scan <> 0

         // ReceiptNumber=241412
         _a_tmp2 := {}
         _a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )

         // ovo ce biti broj racuna
         _tmp := AllTrim( _a_tmp2[ 2 ] )

         IF !Empty( _tmp )
            fisc_no := Val( _tmp )
         ENDIF

      ENDIF

      // pobrisi fajl, izdaji
      FErase( _f_name )

      RETURN _err

   ENDIF

   // imamo gresku !!! ispisi je
   _tmp := ""

   _scan := AScan( _a_err, {| val | "ErrorCode" $ val } )

   IF _scan <> 0

      // ErrorCode=241412
      _a_tmp2 := {}
      _a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )

      _tmp += "ErrorCode: " + AllTrim( _a_tmp2[ 2 ] )

      // ovo je ujedino i error kod
      _err := Val( _a_tmp2[ 2 ] )

   ENDIF

   _tmp := "ErrorOPOS"

#ifdef __PLATFORM__LINUX
   _tmp := "ErrorFP"
#endif

   _scan := AScan( _a_err, {| val | _tmp $ val } )

   IF _scan <> 0

      // ErrorOPOS=xxxxxxx
      _a_tmp2 := {}
      _a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )

      _tmp += " ErrorOPOS: " + AllTrim( _a_tmp2[ 2 ] )

   ENDIF

   _scan := AScan( _a_err, {| val | "ErrorDescription" $ val } )

   IF _scan <> 0

      // ErrorDescription=xxxxxxx
      _a_tmp2 := {}
      _a_tmp2 := TokToNiz( _a_err[ _scan ], "=" )
      _tmp += " Description: " + AllTrim( _a_tmp2[ 2 ] )

   ENDIF

   IF !Empty( _tmp )
      MsgBeep( _tmp )
   ENDIF

   // obrisi fajl out na kraju !!!
   FErase( _f_name )

   RETURN _err
