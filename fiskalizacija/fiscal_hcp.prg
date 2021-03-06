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

STATIC _cmdok := "CMD.OK"
STATIC _razmak1 := " "
STATIC _answ_dir := "FROM_FP"
STATIC _inp_dir := "TO_FP"
STATIC __zahtjev_nula := "0"

// trigeri
STATIC _tr_cmd := "CMD"
STATIC _tr_plu := "PLU"
STATIC _tr_txt := "TXT"
STATIC _tr_rcp := "RCP"
STATIC _tr_cli := "clients.XML"
STATIC _tr_foo := "footer.XML"


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
FUNCTION hcp_rn( hFiskalniParams, items, head, storno, rn_total )

   LOCAL _xml, _f_name
   LOCAL nI, _ibk, _rn_broj, _footer
   LOCAL _v_pl
   LOCAL _total_placanje
   LOCAL _rn_reklamni
   LOCAL _kolicina, _cijena, _rabat, _art_id, _art_barkod, _art_plu
   LOCAL _art_naz, _art_jmj, _dep, _tmp
   LOCAL _oper := ""
   LOCAL _customer := .F.
   LOCAL _err_level := 0
   LOCAL _cmd := ""
   LOCAL _del_all := .T.

   IF head <> NIL .AND. Len( head ) > 0
      _customer := .T.
   ENDIF


   hcp_delete_tmp( hFiskalniParams, _del_all ) // brisi tmp fajlove ako su ostali

   IF rn_total == nil
      rn_total := 0
   ENDIF


   IF storno // ako je storno posalji pred komandu

      // daj mi storno komandu
      _rn_reklamni := AllTrim( items[ 1, 8 ] )
      _cmd := _on_storno( _rn_reklamni )
      // posalji storno komandu
      _err_level := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

      IF _err_level > 0
         RETURN _err_level
      ENDIF

   ENDIF

   // programiraj artikal prije nego izdas racun
   _err_level := hcp_plu( hFiskalniParams, items )

   IF _err_level > 0
      RETURN _err_level
   ENDIF

   IF _customer = .T.


      _err_level := hcp_cli( hFiskalniParams, head ) // dodaj kupca

      IF _err_level > 0
         RETURN _err_level
      ENDIF

      // setuj triger za izdavanje racuna sa partnerom
      _ibk := head[ 1, 1 ]
      _cmd := _on_partn( _ibk )

      _err_level := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

      IF _err_level > 0
         RETURN _err_level
      ENDIF

   ENDIF

   // posalji komandu za reset footera...
   _cmd := _off_footer()
   _err_level := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

   IF _err_level > 0
      RETURN _err_level
   ENDIF

   // to je zapravo broj racuna !!!
   _rn_broj := items[ 1, 1 ]
   // posalji footer...
   _footer := {}
   AAdd( _footer, { "Broj rn: " + _rn_broj } )
   _err_level := hcp_footer( hFiskalniParams, _footer, _tr_foo )
   IF _err_level > 0
      RETURN _err_level
   ENDIF

   // sredi mi naziv fajla...
   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], _rn_broj, _tr_rcp )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "RECEIPT" )

   _total_placanje := 0

   FOR nI := 1 TO Len( items )

      _art_plu := items[ nI, 9 ]
      _art_barkod := items[ nI, 12 ]
      _art_id := items[ nI, 3 ]
      _art_naz := PadR( items[ nI, 4 ], 32 )
      _art_jmj := _g_jmj( items[ nI, 16 ] )
      _cijena := items[ nI, 5 ]
      _kolicina := items[ nI, 6 ]
      _rabat := items[ nI, 11 ]
      _tarifa := fiscal_txt_get_tarifa( items[ nI, 7 ], hFiskalniParams[ "pdv" ], "HCP" )
      _dep := "0"

      _tmp := ""

      // sta ce se koristiti za 'kod' artikla
      IF hFiskalniParams[ "plu_type" ] $ "P#D"
         // PLU artikla
         _tmp := 'BCR="' + AllTrim( Str( _art_plu ) ) + '"'
      ELSEIF hFiskalniParams[ "plu_type" ] == "I"
         // ID artikla
         _tmp := 'BCR="' + AllTrim( _art_id ) + '"'
      ELSEIF hFiskalniParams[ "plu_type" ] == "B"
         // barkod artikla
         _tmp := 'BCR="' + AllTrim( _art_barkod ) + '"'
      ENDIF


      _tmp += _razmak1 + 'VAT="' + _tarifa + '"' // poreska stopa
      // jedinica mjere
      _tmp += _razmak1 + 'MES="' + _art_jmj + '"'
      // odjeljenje
      _tmp += _razmak1 + 'DEP="' + _dep + '"'
      // naziv artikla
      _tmp += _razmak1 + 'DSC="' + to_xml_encoding( _art_naz ) + '"'
      // cijena artikla
      _tmp += _razmak1 + 'PRC="' + AllTrim( Str( _cijena, 12, 2 ) ) + '"'
      // kolicina artikla
      _tmp += _razmak1 + 'AMN="' + AllTrim( Str( _kolicina, 12, 3 ) ) + '"'

      IF _rabat > 0

         // vrijednost popusta
         _tmp += _razmak1 + 'DS_VALUE="' + AllTrim( Str( _rabat, 12, 2 ) ) ;
            + '"'
         // vrijednost popusta
         _tmp += _razmak1 + 'DISCOUNT="' + "true" + '"'

      ENDIF

      xml_single_node( "DATA", _tmp )

   NEXT


   // vrste placanja, oznaka:
   //
   // "GOTOVINA"
   // "CEK"
   // "VIRMAN"
   // "KARTICA"
   //
   // iznos = 0, ako je 0 onda sve ide tom vrstom placanja

   _v_plac := fiscal_txt_get_vr_plac( items[ 1, 13 ], "HCP" )
   _total_placanje := Abs( rn_total )

   IF storno
      // ako je storno onda je placanje gotovina i iznos 0
      _v_plac := "0"
      _total_placanje := 0
   ENDIF

   _tmp := 'PAY="' + _v_plac + '"'
   _tmp += _razmak1 + 'AMN="' + AllTrim( Str( _total_placanje, 12, 2 ) ) + '"'

   xml_single_node( "DATA", _tmp )

   xml_subnode( "RECEIPT", .T. )

   close_xml()

   // testni rezim uredjaja
   IF hFiskalniParams[ "print_fiscal" ] == "T"
      RETURN _err_level
   ENDIF

   // kreiraj cmd.ok
   hcp_create_cmd_ok( hFiskalniParams )

   IF !hcp_read_ok( hFiskalniParams, _f_name )
      // procitaj poruku greske
      _err_level := hcp_read_error( hFiskalniParams, _f_name, _tr_rcp )
   ENDIF

   RETURN _err_level



// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
FUNCTION hcp_delete_tmp( hFiskalniParams, del_all )

   LOCAL _tmp, _f_path

   IF del_all == NIL
      del_all := .F.
   ENDIF

   MsgO( "brisem tmp fajlove..." )

   // input direktorij...
   _f_path := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH
   _tmp := "*.*"

   AEval( Directory( _f_path + _tmp ), {| aFile| FErase( _f_path + ;
      AllTrim( aFile[ 1 ] ) ) } )

   IF del_all

      // output direktorij...
      _f_path := hFiskalniParams[ "out_dir" ] + _answ_dir + SLASH
      _tmp := "*.*"

      AEval( Directory( _f_path + _tmp ), {| _file | FErase( _f_path + AllTrim( _file[ 1 ] ) ) } )

   ENDIF

   Sleep( 1 )

   MsgC()

   RETURN


// -------------------------------------------------------------------
// hcp programiranje footer
// -------------------------------------------------------------------
FUNCTION hcp_footer( hFiskalniParams, footer )

   LOCAL _xml, _tmp, nI
   LOCAL _err := 0

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula, _tr_foo )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "FOOTER" )

   FOR nI := 1 TO Len( footer )

      _tmp := 'TEXT="' + AllTrim( footer[ nI, 1 ] ) + '"'
      _tmp += ' '
      _tmp += 'BOLD="false"'

      xml_single_node( "DATA", _tmp )

   NEXT

   xml_subnode( "FOOTER", .T. )

   close_xml()

   // testni rezim uredjaja
   IF hFiskalniParams[ "print_fiscal" ] == "T"
      RETURN _err
   ENDIF

   // kreiraj triger cmd.ok
   hcp_create_cmd_ok( hFiskalniParams )

   IF !hcp_read_ok( hFiskalniParams, _f_name )
      _err := hcp_read_error( hFiskalniParams, _f_name, _tr_foo )
   ENDIF

   RETURN _err




// -------------------------------------------------------------------
// hcp programiranje klijenti
// -------------------------------------------------------------------
FUNCTION hcp_cli( hFiskalniParams, head )

   LOCAL _xml, _f_name, _tmp, nI
   LOCAL _err := 0

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula, _tr_cli )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "CLIENTS" )

   FOR nI := 1 TO Len( head )

      _tmp := 'IBK="' + head[ nI, 1 ] + '"'
      _tmp += _razmak1 + 'NAME="' + ;
         AllTrim( to_xml_encoding( head[ nI, 2 ] ) ) + '"'
      _tmp += _razmak1 + 'ADDRESS="' + ;
         AllTrim( to_xml_encoding( head[ nI, 3 ] ) ) + '"'
      _tmp += _razmak1 + 'TOWN="' + ;
         AllTrim( to_xml_encoding( head[ nI, 5 ] ) ) + '"'

      xml_single_node( "DATA", _tmp )

   NEXT

   xml_subnode( "CLIENTS", .T. )

   close_xml()

   // testni rezim uredjaja
   IF hFiskalniParams[ "print_fiscal" ] == "T"
      RETURN _err
   ENDIF

   // kreiraj triger cmd.ok
   hcp_create_cmd_ok( hFiskalniParams )

   IF !hcp_read_ok( hFiskalniParams, _f_name )
      // procitaj poruku greske
      _err := hcp_read_error( hFiskalniParams, _f_name, _tr_cli )
   ENDIF

   RETURN _err


// -------------------------------------------------------------------
// hcp programiranje PLU
// -------------------------------------------------------------------
FUNCTION hcp_plu( hFiskalniParams, items )

   LOCAL _xml
   LOCAL _err := 0
   LOCAL nI, _tmp, _f_name
   LOCAL _art_plu, _art_naz, _art_jmj, _art_cijena, _art_tarifa
   LOCAL _dep, _lager

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula, _tr_plu )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "PLU" )

   FOR nI := 1 TO Len( items )

      _art_plu := items[ nI, 9 ]
      _art_naz := PadR( items[ nI, 4 ], 32 )
      _art_jmj := _g_jmj( items[ nI, 16 ] )
      _art_cijena := items[ nI, 5 ]
      _art_tarifa := fiscal_txt_get_tarifa( items[ nI, 7 ], hFiskalniParams[ "pdv" ], "HCP" )
      _dep := "0"
      _lager := 0

      _tmp := 'BCR="' + AllTrim( Str( _art_plu ) ) + '"'
      _tmp += _razmak1 + 'VAT="' + _art_tarifa + '"'
      _tmp += _razmak1 + 'MES="' + _art_jmj + '"'
      _tmp += _razmak1 + 'DEP="' + _dep + '"'
      _tmp += _razmak1 + 'DSC="' + to_xml_encoding( _art_naz ) + '"'
      _tmp += _razmak1 + 'PRC="' + AllTrim( Str( _art_cijena, 12, 2 ) ) + '"'
      _tmp += _razmak1 + 'LGR="' + AllTrim( Str( _lager, 12, 2 ) ) + '"'

      xml_single_node( "DATA", _tmp )

   NEXT

   xml_subnode( "PLU", .T. )

   close_xml()

   // testni rezim uredjaja
   IF hFiskalniParams[ "print_fiscal" ] == "T"
      RETURN _err
   ENDIF

   // kreiraj triger cmd.ok
   hcp_create_cmd_ok( hFiskalniParams )

   IF !hcp_read_ok( hFiskalniParams, _f_name )
      // procitaj poruku greske
      _err := hcp_read_error( hFiskalniParams, _f_name, _tr_plu )
   ENDIF

   RETURN _err



// -------------------------------------------------------------------
// ispis nefiskalnog teksta
// -------------------------------------------------------------------
FUNCTION hcp_txt( hFiskalniParams, br_dok )

   LOCAL _cmd := ""
   LOCAL _xml, _data, _tmp
   LOCAL _err_level := 0

   _cmd := 'TXT="POS RN: ' + AllTrim( br_dok ) + '"'

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula, _tr_txt )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "USER_TEXT" )

   IF !Empty( _cmd )

      _data := "DATA"
      _tmp := _cmd

      xml_single_node( _data, _tmp )

   ENDIF

   xml_subnode( "USER_TEXT", .T. )

   close_xml()

   // testni rezim uredjaja
   IF hFiskalniParams[ "print_fiscal" ] == "T"
      RETURN _err_level
   ENDIF

   // kreiraj triger cmd.ok
   hcp_create_cmd_ok( hFiskalniParams )

   IF !hcp_read_ok( hFiskalniParams, _f_name )
      // procitaj poruku greske
      _err_level := hcp_read_error( hFiskalniParams, _f_name, _tr_txt )
   ENDIF

   RETURN _err_level



// -------------------------------------------------------------------
// hcp komanda
// -------------------------------------------------------------------
FUNCTION hcp_cmd( hFiskalniParams, cmd, trig )

   LOCAL _xml
   LOCAL _err_level := 0
   LOCAL _f_name

   _f_name := fiscal_out_filename( hFiskalniParams[ "out_file" ], __zahtjev_nula, trig )

   // putanja do izlaznog xml fajla
   _xml := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _f_name

   // otvori xml
   create_xml( _xml )

   // upisi header
   xml_head()

   xml_subnode( "COMMAND" )

   IF !Empty( cmd )

      _data := "DATA"
      _tmp := cmd

      xml_single_node( _data, _tmp )

   ENDIF

   xml_subnode( "COMMAND", .T. )

   close_xml()

   // testni rezim uredjaja
   IF hFiskalniParams[ "print_fiscal" ] == "T"
      RETURN _err_level
   ENDIF

   // kreiraj triger cmd.ok
   hcp_create_cmd_ok( hFiskalniParams )

   IF !hcp_read_ok( hFiskalniParams, _f_name )
      // procitaj poruku greske
      _err_level := hcp_read_error( hFiskalniParams, _f_name, trig )
   ENDIF

   RETURN _err_level


// -------------------------------------------------
// ukljuci storno racuna
// -------------------------------------------------
STATIC FUNCTION _on_storno( broj_rn )

   LOCAL _cmd

   _cmd := 'CMD="REFUND_ON"'
   _cmd += _razmak1 + 'NUM="' + AllTrim( broj_rn ) + '"'

   RETURN _cmd


// -------------------------------------------------
// ponistavanje footer-a
// -------------------------------------------------
STATIC FUNCTION _off_footer()

   LOCAL _cmd

   _cmd := 'CMD="FOOTER_OFF"'

   RETURN _cmd


// -------------------------------------------------
// iskljuci storno racuna
// -------------------------------------------------
STATIC FUNCTION _off_storno()

   LOCAL _cmd

   _cmd := 'CMD="REFUND_OFF"'

   RETURN _cmd


// -------------------------------------------------
// ukljuci racun za klijenta
// -------------------------------------------------
STATIC FUNCTION _on_partn( ibk )

   LOCAL _cmd

   _cmd := 'CMD="SET_CLIENT"'
   _cmd += _razmak1 + 'NUM="' + AllTrim( ibk ) + '"'

   RETURN _cmd




// ------------------------------------------
// vraca jedinicu mjere
// ------------------------------------------
STATIC FUNCTION _g_jmj( jmj )

   LOCAL _ret := "0"

   DO CASE
   CASE Upper( AllTrim( jmj ) ) = "KOM"
      _ret := "0"
   CASE Upper( AllTrim( jmj ) ) = "LIT"
      _ret := "1"
   ENDCASE

   RETURN _ret




// -----------------------------------------------------
// dnevni fiskalni izvjestaj
// -----------------------------------------------------
FUNCTION hcp_z_rpt( hFiskalniParams )

   LOCAL _cmd, _err_level
   LOCAL _param_date, _param_time
   LOCAL _rpt_type := "Z"

   _param_date := "zadnji_" + _rpt_type + "_izvjestaj_datum"
   _param_time := "zadnji_" + _rpt_type + "_izvjestaj_vrijeme"

   // iscitaj zadnje formirane izvjestaje...
   _last_date := fetch_metric( _param_date, NIL, CToD( "" ) )
   _last_time := PadR( fetch_metric( _param_time, NIL, "" ), 5 )

   IF Date() == _last_date
      MsgBeep( "Zadnji dnevni izvjestaj radjen " + DToC( _last_date ) + " u " + _last_time )
   ENDIF

   _cmd := 'CMD="Z_REPORT"'
   _err_level := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

   // upisi zadnji dnevni izvjestaj
   set_metric( _param_date, NIL, Date() )
   set_metric( _param_time, NIL, Time() )

   // ako se koriste dinamicki plu kodovi resetuj prodaju
   // pobrisi artikle
   IF hFiskalniParams[ "plu_type" ] == "D"

      MsgO( "resetujem prodaju..." )

      // reset sold plu
      _cmd := 'CMD="RESET_SOLD_PLU"'
      _err_level := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

      // ako su dinamicki PLU kodovi
      _cmd := 'CMD="DELETE_ALL_PLU"'
      _err_level := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

      // resetuj PLU brojac u bazi...
      auto_plu( .T., .T., hFiskalniParams )

      MsgC()

   ENDIF

   // ako se koristi opcija automatskog pologa
   IF hFiskalniParams[ "auto_avans" ] > 0

      MsgO( "Automatski unos pologa u uredjaj... sacekajte." )

      // daj malo prostora
      Sleep( 5 )

      // unesi polog vrijednosti iz parametra
      _err_level := hcp_polog( hFiskalniParams, hFiskalniParams[ "auto_avans" ] )

      MsgC()

   ENDIF

   RETURN


// -----------------------------------------------------
// presjek stanja
// -----------------------------------------------------
FUNCTION hcp_x_rpt( hFiskalniParams )

   LOCAL _cmd, _err

   _cmd := 'CMD="X_REPORT"'
   _err := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

   RETURN





// -----------------------------------------------------
// presjek stanja SUMMARY
// -----------------------------------------------------
FUNCTION hcp_s_rpt( hFiskalniParams )

   LOCAL _cmd
   LOCAL _date_from := Date() -30
   LOCAL _date_to := Date()
   LOCAL _txt_date_from := ""
   LOCAL _txt_date_to := ""

   Box(, 1, 50 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Datum od:" GET _date_from
   @ box_x_koord() + 1, Col() + 1 SAY "do:" GET _date_to
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   _txt_date_from := fprint_formatiranje_datuma( _date_from )
   _txt_date_to := fprint_formatiranje_datuma( _date_to )

   _cmd := 'CMD="SUMMARY_REPORT" FROM="' + _txt_date_from + '" TO="' + _txt_date_to + '"'
   _err := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

   RETURN



// -----------------------------------------------------
// vraca broj fiskalnog racuna
// -----------------------------------------------------
FUNCTION hcp_fisc_no( hFiskalniParams, storno )

   LOCAL _cmd
   LOCAL _fiscal_no := 0
   LOCAL _f_state := "BILL_S~1.XML"

#ifdef __PLATFORM__UNIX

   _f_state := "bill_state.xml"
#endif

   // posalji komandu za stanje fiskalnog racuna
   _cmd := 'CMD="RECEIPT_STATE"'
   _err := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

   // testni rezim uredjaja
   IF hFiskalniParams[ "print_fiscal" ] == "T"
      RETURN _fiscal_no := 999
   ENDIF

   // ako nema gresaka, iscitaj broj racuna
   IF _err = 0
      // e sada iscitaj iz fajla
      _fiscal_no := hcp_read_billstate( hFiskalniParams, _f_state, storno )
   ENDIF

   RETURN _fiscal_no





// -----------------------------------------------------
// reset prodaje
// -----------------------------------------------------
FUNCTION hcp_reset( hFiskalniParams )

   LOCAL _cmd

   _cmd := 'CMD="RESET_SOLD_PLU"'
   _err := hcp_cmd( hFiskalniParams, _cmd, _tr_cmd )

   RETURN





// ---------------------------------------------------
// polog pazara
// ---------------------------------------------------
FUNCTION hcp_polog( dev_param, value )

   LOCAL _cmd

   IF value == nil
      value := 0
   ENDIF

   IF value = 0

      // box - daj broj racuna
      Box(, 1, 60 )
      @ box_x_koord() + 1, box_y_koord() + 2 SAY "Unosim polog od:" GET value PICT "99999.99"
      READ
      BoxC()

      IF LastKey() == K_ESC .OR. value = 0
         RETURN
      ENDIF

   ENDIF

   IF value < 0
      // polog komanda
      _cmd := 'CMD="CASH_OUT"'
   ELSE
      // polog komanda
      _cmd := 'CMD="CASH_IN"'
   ENDIF

   _cmd += _razmak1 + 'VALUE="' +  AllTrim( Str( Abs( value ), 12, 2 ) ) + '"'

   _err := hcp_cmd( dev_param, _cmd, _tr_cmd )

   RETURN




// ---------------------------------------------------
// stampa kopije racuna
// ---------------------------------------------------
FUNCTION hcp_rn_copy( dev_param )

   LOCAL _cmd
   LOCAL _broj_rn := Space( 10 )
   LOCAL _refund := "N"
   LOCAL _err := 0

   // box - daj broj racuna
   Box(, 2, 50 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Broj racuna:" GET _broj_rn ;
      VALID !Empty( _broj_rn )
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "racun je reklamni (D/N)?" GET _refund ;
      VALID _refund $ "DN" PICT "@!"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF _refund == "N"
      // obicni racun
      _cmd := 'CMD="RECEIPT_COPY"'
   ELSE
      // reklamni racun
      _cmd := 'CMD="REFUND_RECEIPT_COPY"'
   ENDIF

   _cmd += _razmak1 + 'NUM="' +  AllTrim( _broj_rn ) + '"'

   _err := hcp_cmd( dev_param, _cmd, _tr_cmd )

   RETURN



// --------------------------------------------
// cekanje na fajl odgovora
// --------------------------------------------
STATIC FUNCTION hcp_read_ok( dev_param, f_name, time_out )

   LOCAL _ok := .T.
   LOCAL _tmp
   LOCAL _time

   IF time_out == nil
      time_out := 30
   ENDIF

   _time := time_out

   _tmp := dev_param[ "out_dir" ] + _answ_dir + SLASH + StrTran( f_name, "XML", "OK" )

   Box(, 3, 60 )

   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Uredjaj ID: " + AllTrim( Str( dev_param[ "id" ] ) ) + ;
      " : " + PadR( dev_param[ "name" ], 40 )

   DO WHILE _time > 0

      -- _time

      Sleep( 1 )

      IF File( _tmp )
         // fajl se pojavio - izadji iz petlje !
         EXIT
      ENDIF

      @ box_x_koord() + 3, box_y_koord() + 2 SAY PadR( "Cekam odgovor OK: " + AllTrim( Str( _time ) ), 48 )

      IF _time == 0 .OR. LastKey() == K_ALT_Q
         BoxC()
         _ok := .F.
         RETURN _ok
      ENDIF

   ENDDO

   BoxC()

   IF !File( _tmp )
      _ok := .F.
   ELSE
      // obrisi fajl "OK"
      FErase( _tmp )
   ENDIF

   RETURN _ok




// ----------------------------------
// create cmd.ok file
// ----------------------------------
FUNCTION hcp_create_cmd_ok( hFiskalniParams )

   LOCAL _tmp

   _tmp := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _cmdok

   // iskoristit cu postojecu funkciju za kreiranje xml fajla...
   create_xml( _tmp )
   close_xml()

   RETURN



// ----------------------------------
// delete cmd.ok file
// ----------------------------------
FUNCTION hcp_delete_cmd_ok( hFiskalniParams )

   LOCAL _tmp

   _tmp := hFiskalniParams[ "out_dir" ] + _inp_dir + SLASH + _cmdok

   IF FErase( _tmp ) < 0
      MsgBeep( "greska sa brisanjem fajla CMD.OK !" )
   ENDIF

   RETURN





// --------------------------------------------------
// brise fajl greske
// --------------------------------------------------
FUNCTION hcp_delete_error( hFiskalniParams, f_name )

   LOCAL _err := 0
   LOCAL _f_name

   // primjer: c:\hcp\from_fp\RAC001.ERR
   _f_name := hFiskalniParams[ "out_dir" ] + _answ_dir + SLASH + StrTran( f_name, "XML", "ERR" )
   IF FErase( _f_name ) < 0
      MsgBeep( "greska sa brisanjem fajla..." )
   ENDIF

   RETURN






// ------------------------------------------------
// citanje fajla bill_state.xml
//
// nTimeOut - time out fiskalne operacije
// ------------------------------------------------
FUNCTION hcp_read_billstate( hFiskalniParams, f_name, storno )

   LOCAL _fisc_no
   LOCAL _o_file, _time, _f_name
   LOCAL _err := 0
   LOCAL _bill_data, _line, _scan_txt, _scan
   LOCAL _receipt, _msg

   IF storno == nil
      storno := .F.
   ENDIF

   _time := hFiskalniParams[ "timeout" ]

   // primjer: c:\hcp\from_fp\bill_state.xml
   _f_name := hFiskalniParams[ "out_dir" ] + _answ_dir + SLASH + f_name

   Box(, 3, 60 )

   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Uredjaj ID: " + AllTrim( Str( hFiskalniParams[ "id" ] ) ) + ;
      " : " + PadR( hFiskalniParams[ "name" ], 40 )
   DO WHILE _time > 0

      -- _time

      IF File( _f_name )
         // fajl se pojavio - izadji iz petlje !
         EXIT
      ENDIF

      @ box_x_koord() + 3, box_y_koord() + 2 SAY PadR( "Cekam na fiskalni uredjaj: " + AllTrim( Str( _time ) ), 48 )

      IF _time == 0 .OR. LastKey() == K_ALT_Q
         BoxC()
         RETURN -9
      ENDIF

      Sleep( 1 )

   ENDDO

   BoxC()

   IF !File( _f_name )
      MsgBeep( "Fajl " + _f_name + " ne postoji !!!" )
      _err := -9
      RETURN _err
   ENDIF

   _fisc_no := 0

   _f_name := AllTrim( _f_name )

   _o_file := TFileRead():New( _f_name )
   _o_file:Open()

   IF _o_file:Error()
      MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " + _f_name ) )
      RETURN -9
   ENDIF

   // prodji kroz svaku liniju i procitaj zapise
   WHILE _o_file:MoreToRead()

      // uzmi u cLine liniju fajla
      _line := hb_StrToUTF8( _o_file:ReadLine() )

      IF Upper( "xml version" ) $ Upper( _line )
         // ovo je prvi red, preskoci
         LOOP
      ENDIF

      // zamjeni ove znakove...
      _line := StrTran( _line, ">", "" )
      _line := StrTran( _line, "<", "" )
      _line := StrTran( _line, "'", "" )

      _bill_data := TokToNiz( _line, " " )

      _scan_txt := "RECEIPT_NUMBER"

      IF storno
         _scan_txt := "REFOUND_RECEIPT_NUMBER"
      ENDIF

      _scan := AScan( _bill_data, {| val | _scan_txt $ val } )

      IF _scan > 0

         _receipt := TokToNiz( _bill_data[ _scan ], "=" )
         _fisc_no := Val( _receipt[ 2 ] )

         _msg := "Formiran "

         IF storno
            _msg += "rekl."
         ENDIF

         _msg += "fiskalni racun: "

         MsgBeep( _msg + AllTrim( Str( _fisc_no ) ) )

         EXIT

      ENDIF

   ENDDO

   _o_file:Close()

   // brisi fajl odgovora
   IF _fisc_no > 0
      FErase( _f_name )
   ENDIF

   RETURN _fisc_no



// ------------------------------------------------
// citanje gresaka za HCP driver
//
// nTimeOut - time out fiskalne operacije
// nFisc_no - broj fiskalnog isjecka
// ------------------------------------------------
FUNCTION hcp_read_error( hFiskalniParams, f_name, trig )

   LOCAL _err := 0
   LOCAL _f_name, nI, _time
   LOCAL _fiscal_no, _line, _o_file
   LOCAL _err_code, _err_descr

   _time := hFiskalniParams[ "timeout" ]

   // primjer: c:\hcp\from_fp\RAC001.ERR
   _f_name := hFiskalniParams[ "out_dir" ] + _answ_dir + SLASH + StrTran( f_name, "XML", "ERR" )

   Box(, 3, 60 )

   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Uredjaj ID: " + AllTrim( Str( hFiskalniParams[ "id" ] ) ) + ;
      " : " + PadR( hFiskalniParams[ "name" ], 40 )

   DO WHILE _time > 0

      -- _time

      IF File( _f_name )
         // fajl se pojavio - izadji iz petlje !
         EXIT
      ENDIF

      @ box_x_koord() + 3, box_y_koord() + 2 SAY PadR( "Cekam na fiskalni uredjaj: " + AllTrim( Str( _time ) ), 48 )

      IF _time == 0 .OR. LastKey() == K_ESC
         BoxC()
         RETURN -9
      ENDIF

      Sleep( 1 )

   ENDDO

   BoxC()

   IF !File( _f_name )
      MsgBeep( "Fajl " + _f_name + " ne postoji !!!" )
      _err := -9
      RETURN _err
   ENDIF

   _fiscal_no := 0

   _o_file := TFileRead():New( _f_name )
   _o_file:Open()

   IF _o_file:Error()
      MsgBeep( _o_file:ErrorMsg( "Problem sa otvaranjem fajla: " + _f_name ) )
      RETURN -9
   ENDIF

   _err_code := ""

   // prodji kroz svaku liniju i procitaj zapise
   WHILE _o_file:MoreToRead()

      // uzmi u cLine liniju fajla
      _line := hb_StrToUTF8( _o_file:ReadLine() )
      _a_err := TokToNiz( _line, "-" )

      // ovo je kod greske, npr. 1
      _err_code := AllTrim( _a_err[ 1 ] )
      _err_descr := AllTrim( _a_err[ 2 ] )

      IF !Empty( _err_code )
         EXIT
      ENDIF

   ENDDO

   _o_file:Close()


   IF !Empty( _err_code )
      MsgBeep( "Greska: " + _err_code + " - " + _err_descr )
      _err := Val( _err_code )
      FErase( _f_name )
   ENDIF

   RETURN _err
