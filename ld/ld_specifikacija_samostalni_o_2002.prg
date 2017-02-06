/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


FUNCTION ld_specifikacija_plate_samostalni_obr_2002()

   LOCAL GetList := {}
   LOCAL aPom := {}
   LOCAL nGrupaPoslova := 5
   LOCAL nLM := 5
   LOCAL nLin
   LOCAL nPocetak
   LOCAL i := 0
   LOCAL j := 0
   LOCAL k := 0
   LOCAL nPreskociRedova
   LOCAL cLin
   LOCAL nPom
   LOCAL uNaRuke
   LOCAL aOps := {}
   LOCAL cRepSr := "N"
   LOCAL cRTipRada := " "
   LOCAL _proizvj_ini := my_home() + "proizvj.ini"
   LOCAL cMatBr := Space( 13 )
   LOCAL oReport, hRec, cKey

   PRIVATE aSpec := {}
   PRIVATE cFNTZ := "D"
   PRIVATE gPici := "9,999,999,999,999,999" + iif( gZaok > 0, PadR( ".", gZaok + 1, "9" ), "" )
   PRIVATE gPici2 := "9,999,999,999,999,999" + iif( gZaok2 > 0, PadR( ".", gZaok2 + 1, "9" ), "" )
   PRIVATE gPici3 := "999,999,999,999.99"

   FOR i := 1 TO nGrupaPoslova + 1
      AAdd( aSpec, { 0, 0, 0, 0 } )  // br.bodova, br.radnika, minuli rad, uneto
   NEXT

   cIdRJ := "  "
   qqIDRJ := ""
   qqOpSt := ""

   nBrutoOsnova := 0
   nBrutoOsBenef := 0
   nPojBrOsn := 0
   nPojBrBenef := 0
   nOstaleObaveze := 0
   uNaRuke := 0

   // prvi dan mjeseca
   nDanOd := prvi_dan_mjeseca( ld_tekuci_mjesec() )
   nMjesecOd := ld_tekuci_mjesec()
   nGodinaOd := ld_tekuca_godina()
   // posljednji dan mjeseca
   nDanDo := zadnji_dan_mjeseca( ld_tekuci_mjesec() )
   nMjesecDo := ld_tekuci_mjesec()
   nGodinaDo := ld_tekuca_godina()

   // varijable izvjestaja
   nMjesec := ld_tekuci_mjesec()
   nGodina := ld_tekuca_godina()
   cObracun := gObracun

   cDopr1 := "1X"
   cDopr2 := "2X"
   cDopr3 := "  "
   cFirmNaz := Space( 35 )
   cFirmAdresa := Space( 35 )
   cFirmOpc := Space( 35 )
   cFirmVD := Space( 50 )
   cRadn := Space( LEN_IDRADNIK )


   OSpecif()

   cFirmNaz := fetch_metric( "org_naziv", nil, cFirmNaz )
   cFirmNaz := PadR( cFirmNaz, 35 )

   cFirmAdresa := fetch_metric( "ld_firma_adresa", nil, cFirmAdresa )
   cFirmAdresa := PadR( cFirmAdresa, 35 )

   cFirmOpc := fetch_metric( "ld_firma_opcina", nil, cFirmOpc )
   cFirmOpc := PadR( cFirmOpc, 35 )

   cFirmVD := fetch_metric( "ld_firma_vrsta_djelatnosti", nil, cFirmVD )
   cFirmVD := PadR( cFirmVD, 50 )

   cDopr1 := fetch_metric( "ld_spec_samostalni_doprinos_1", nil, cDopr1 )
   cDopr2 := fetch_metric( "ld_spec_samostalni_doprinos_2", nil, cDopr2 )
   cDopr3 := fetch_metric( "ld_spec_samostalni_doprinos_3", nil, cDopr3 )

   qqIdRj := fetch_metric( "ld_specifikacija_rj", nil, qqIdRJ )
   qqOpSt := fetch_metric( "ld_specifikacija_opcine", nil, qqOpSt )

   qqIdRj := PadR( qqIdRj, 80 )
   qqOpSt := PadR( qqOpSt, 80 )

   cMatBr := fetch_metric( "ld_specifikacija_maticni_broj", nil, cMatBr )
   cMatBR := PadR( cMatBr, 13 )

   dDatIspl := Date()

   DO WHILE .T.

      Box(, 13, 75 )

      @ form_x_koord() + 1, form_y_koord() + 2 SAY "Radna jedinica (prazno-sve): " GET qqIdRJ PICT "@!S15"

      @ form_x_koord() + 2, form_y_koord() + 2 SAY "Opstina stanov.(prazno-sve): "  GET qqOpSt PICT "@!S20"

      @ form_x_koord() + 2, Col() + 1 SAY "Obr.:" GET cObracun   WHEN HelpObr( .T., cObracun ) ;
         VALID ValObr( .T., cObracun )

      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Period od:" GET nDanOd PICT "99"
      @ form_x_koord() + 3, Col() + 1 SAY "/" GET nMjesecOd PICT "99"
      @ form_x_koord() + 3, Col() + 1 SAY "/" GET nGodinaOd PICT "9999"
      @ form_x_koord() + 3, Col() + 1 SAY "do:" GET nDanDo PICT "99"
      @ form_x_koord() + 3, Col() + 1 SAY "/" GET nMjesecDo PICT "99"
      @ form_x_koord() + 3, Col() + 1 SAY "/" GET nGodinaDo PICT "9999"

      @ form_x_koord() + 4, form_y_koord() + 2 SAY " Naziv: " GET cFirmNaz
      @ form_x_koord() + 5, form_y_koord() + 2 SAY "Adresa: " GET cFirmAdresa
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Opcina: " GET cFirmOpc
      @ form_x_koord() + 7, form_y_koord() + 2 SAY "Vrsta djelatnosti: " GET cFirmVD

      @ form_x_koord() + 4, form_y_koord() + 52 SAY "ID.broj :" GET cMatBR
      @ form_x_koord() + 5, form_y_koord() + 52 SAY "Dat.ispl:" GET dDatIspl

      @ form_x_koord() + 8, form_y_koord() + 2 SAY "Poduzetnik:" GET cRadn  VALID P_RADN( @cRadn )

      @ form_x_koord() + 10, form_y_koord() + 2 SAY "          Doprinos pio (iz+na):" GET cDopr1
      @ form_x_koord() + 11, form_y_koord() + 2 SAY "    Doprinos zdravstvo (iz+na):" GET cDopr2
      @ form_x_koord() + 12, form_y_koord() + 2 SAY "Doprinos nezaposlenost (iz+na):" GET cDopr3

      READ

      clvbox()
      ESC_BCR

      BoxC()

      aUslRJ := Parsiraj( qqIdRj, "IDRJ" )
      aUslOpSt := Parsiraj( qqOpSt, "IDOPSST" )

      IF ( aUslRJ <> NIL .AND. aUslOpSt <> nil )
         EXIT
      ENDIF
   ENDDO

   set_metric( "org_naziv", nil, cFirmNaz )
   set_metric( "ld_firma_adresa", nil, cFirmAdresa )
   set_metric( "ld_firma_opcina", nil, cFirmOpc )
   set_metric( "ld_firma_vrsta_djelatnosti", nil, cFirmVD )
   set_metric( "ld_spec_samostalni_doprinos_1", nil, cDopr1 )
   set_metric( "ld_spec_samostalni_doprinos_2", nil, cDopr2 )
   set_metric( "ld_spec_samostalni_doprinos_3", nil, cDopr3 )

   qqIdRj := Trim( qqIdRj )
   qqOpSt := Trim( qqOpSt )

   set_metric( "ld_specifikacija_rj", nil, qqIdRJ )
   set_metric( "ld_specifikacija_opcine", nil, qqOpSt )
   set_metric( "ld_specifikacija_maticni_broj", nil, cMatBr )

   PoDoIzSez( nGodina, nMjesec )

   cIniName := _proizvj_ini

   hRec := hb_Hash()

   oReport := YargReport():New( "ld_obr_2002", "xlsx" )


   hRec[ "naziv" ] := cFirmNaz
   hRec[ "adresa" ] := cFirmAdresa
   hRec[ "opcina" ] :=  cFirmOpc
   hRec[ "vrsta_djelatnosti" ] :=  cFirmVD

   hRec[ "d_od_1" ] := SubStr( PadL( AllTrim( Str( nDanOd, 2 ) ), 2, "0" ), 1, 1 )
   hRec[ "d_od_2" ] := SubStr( PadL( AllTrim( Str( nDanOd, 2 ) ), 2, "0" ), 2, 1 )

   hRec[ "m_od_1" ] := SubStr( PadL( AllTrim( Str( nMjesecOd, 2 ) ), 2, "0" ), 1, 1 )
   hRec[ "m_od_2" ] := SubStr( PadL( AllTrim( Str( nMjesecOd, 2 ) ), 2, "0" ), 2, 1 )

   hRec[ "g_od_1" ] := SubStr( PadL( AllTrim( Str( nGodinaOd, 4 ) ), 4, "0" ), 1, 1 )
   hRec[ "g_od_2" ] := SubStr( PadL( AllTrim( Str( nGodinaOd, 4 ) ), 4, "0" ), 2, 1 )
   hRec[ "g_od_3" ] := SubStr( PadL( AllTrim( Str( nGodinaOd, 4 ) ), 4, "0" ), 3, 1 )
   hRec[ "g_od_4" ] := SubStr( PadL( AllTrim( Str( nGodinaOd, 4 ) ), 4, "0" ), 4, 1 )


   hRec[ "d_do_1" ] := SubStr( PadL( AllTrim( Str( nDanDo, 2 ) ), 2, "0" ), 1, 1 )
   hRec[ "d_do_2" ] := SubStr( PadL( AllTrim( Str( nDanDo, 2 ) ), 2, "0" ), 2, 1 )

   hRec[ "m_do_1" ] := SubStr( PadL( AllTrim( Str( nMjesecDo, 2 ) ), 2, "0" ), 1, 1 )
   hRec[ "m_do_2" ] := SubStr( PadL( AllTrim( Str( nMjesecDo, 2 ) ), 2, "0" ), 2, 1 )

   hRec[ "g_do_1" ] := SubStr( PadL( AllTrim( Str( nGodinaDo, 4 ) ), 4, "0" ), 1, 1 )
   hRec[ "g_do_2" ] := SubStr( PadL( AllTrim( Str( nGodinaDo, 4 ) ), 4, "0" ), 2, 1 )
   hRec[ "g_do_3" ] := SubStr( PadL( AllTrim( Str( nGodinaDo, 4 ) ), 4, "0" ), 3, 1 )
   hRec[ "g_do_4" ] := SubStr( PadL( AllTrim( Str( nGodinaDo, 4 ) ), 4, "0" ), 4, 1 )

   hRec[ "j1" ] := SubStr( cMatBR, 1, 1 )
   hRec[ "j2" ] := SubStr( cMatBR, 2, 1 )
   hRec[ "j3" ] := SubStr( cMatBR, 3, 1 )
   hRec[ "j4" ] := SubStr( cMatBR, 4, 1 )
   hRec[ "j5" ] := SubStr( cMatBR, 5, 1 )
   hRec[ "j6" ] := SubStr( cMatBR, 6, 1 )
   hRec[ "j7" ] := SubStr( cMatBR, 7, 1 )
   hRec[ "j8" ] := SubStr( cMatBR, 8, 1 )
   hRec[ "j9" ] := SubStr( cMatBR, 9, 1 )
   hRec[ "j10" ] := SubStr( cMatBR, 10, 1 )
   hRec[ "j11" ] := SubStr( cMatBR, 11, 1 )
   hRec[ "j12" ] := SubStr( cMatBR, 12, 1 )
   hRec[ "j13" ] := SubStr( cMatBR, 13, 1 )


   hRec[ "d_up_1" ] := SubStr( PadL( AllTrim( Str( Day( dDatIspl ), 2 ) ), 2, "0" ), 1, 1 )
   hRec[ "d_up_2" ] := SubStr( PadL( AllTrim( Str( Day( dDatIspl ), 2 ) ), 2, "0" ), 2, 1 )

   hRec[ "m_up_1" ] := SubStr( PadL( AllTrim( Str( Month( dDatIspl ), 2 ) ), 2, "0" ), 1, 1 )
   hRec[ "m_up_2" ] := SubStr( PadL( AllTrim( Str( Month( dDatIspl ), 2 ) ), 2, "0" ), 2, 1 )

   hRec[ "g_up_1" ] := SubStr( PadL( AllTrim( Str( Year( dDatIspl ), 4 ) ), 4, "0" ), 1, 1 )
   hRec[ "g_up_2" ] := SubStr( PadL( AllTrim( Str( Year( dDatIspl ), 4 ) ), 4, "0" ), 2, 1 )
   hRec[ "g_up_3" ] := SubStr( PadL( AllTrim( Str( Year( dDatIspl ), 4 ) ), 4, "0" ), 3, 1 )
   hRec[ "g_up_4" ] := SubStr( PadL( AllTrim( Str( Year( dDatIspl ), 4 ) ), 4, "0" ), 4, 1 )

   cObracun := Trim( cObracun )

   ld_pozicija_parobr( nMjesec, nGodina, cObracun, Left( qqIdRJ, 2 ) )

   //SELECT LD
   //SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "2" ) )

   seek_ld_2( NIL, nGodina, nMjesec )
    //  GO TOP
    //  HSEEK Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 )

   PRIVATE cFilt := ".t."

   IF !Empty( qqIdRJ )
      cFilt += ( ".and." + aUslRJ )
   ENDIF

   IF !Empty( cObracun )
      cFilt += ( ".and. OBR==" + dbf_quote( cObracun ) )
   ENDIF

   SET FILTER TO &cFilt
   GO TOP


   nUNeto := 0
   nUSati := 0
   nUNetoOsnova := 0
   nPorNaPlatu := 0
   nKoefLO := 0
   nURadnika := 0
   nULicOdbitak := 0

   DO WHILE Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 ) == Str( godina, 4, 0 ) + Str( mjesec, 2, 0 )

      IF field->idradn <> cRadn
         SKIP
         LOOP
      ENDIF

      select_o_radn( LD->idradn )

      cRTR := get_ld_rj_tip_rada( ld->idradn, ld->idrj )

      IF cRTR <> "S"
         SELECT ld
         SKIP
         LOOP
      ENDIF


      nRSpr_koef := radn->sp_koef // koeficijent propisani

      SELECT LD

      IF ! ( RADN->( &aUslOpSt ) )
         SKIP 1
         LOOP
      ENDIF

      nKoefLO := ld->ulicodb
      nULicOdbitak += nKoefLO
      nUNeto += ld->uneto
      nUSati += ld->usati
      nNetoOsn := Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )
      nUNetoOsnova += nNetoOsn


      // prvo doprinosi i bruto osnova
      nPojBrOsn := ld_get_bruto_osnova( nNetoOsn, cRTR, nKoefLO, nRSpr_koef )
      nBrutoOsnova += nPojBrOsn

      nPom := nBrutoOsnova // ukupno bruto

      hRec[ "osnovica_obracun" ] := FormNum2( nPom, 16, gPici2 )

      nPom := nUSati
      hRec[ "br_radnih_sati" ] := FormNum2( nPom, 16, gPici2 )


      select_o_dopr()
      GO TOP

      DO WHILE !Eof()

         IF DOPR->poopst == "1"

            nBOO := 0

            FOR i := 1 TO Len( aOps )
               IF ! ( DOPR->id $ aOps[ i, 2 ] )
                  nBOO += aOps[ i, 3 ]
               ENDIF
            NEXT
            nBOO := ld_get_bruto_osnova( nBOO, cRTR, nKoefLO )
         ELSE
            nBOO := nBrutoOsnova
         ENDIF

         SKIP 1
      ENDDO

      nkD1X := get_dopr( cDopr1, "S" )
      nkD2X := get_dopr( cDopr2, "S" )
      nkD3X := get_dopr( cDopr3, "S" )


      nPom := nKD1X // stope na bruto
      hRec[ "stopa_19" ] := FormNum2( nPom, 16, gPici3 ) + "%"

      nPom := nKD2X
      hRec[ "stopa_20" ] := FormNum2( nPom, 16, gPici3 ) + "%"

      nPom := nKD3X
      hRec[ "stopa_21" ] := FormNum2( nPom, 16, gPici3 ) + "%"

      nPom := nKD1X + nKD2X + nKD3X
      hRec[ "stopa_22" ] := FormNum2( nPom, 16, gPici3 ) + "%"

      nDopr1X := round2( nBrutoOsnova * nKD1X / 100, gZaok2 )
      nDopr2X := round2( nBrutoOsnova * nKD2X / 100, gZaok2 )
      nDopr3X := round2( nBrutoOsnova * nKD3X / 100, gZaok2 )

      nPojDoprIZ := round2( ( nPojBrOsn * nkD1X / 100 ), gZaok2 ) + ;
         round2( ( nPojBrOsn * nkD2X / 100 ), gZaok2 ) + ;
         round2( ( nPojBrOsn * nkD3X / 100 ), gZaok2 )


      nPom := nDopr1X // iznos doprinosa
      hRec[ "iznos_19" ] := FormNum2( nPom, 16, gPici2 )

      nPom := nDopr2X
      hRec[ "iznos_20" ] := FormNum2( nPom, 16, gPici2 )

      nPom := nDopr3X
      hRec[ "iznos_21" ] := FormNum2( nPom, 16, gPici2 )

      nPom := nDopr1X + nDopr2X + nDopr3X // ukupni doprinosi iz plate
      nUkDoprIZ := nPom
      hRec[ "iznos_22" ] := FormNum2( nPom, 16, gPici2 )

      SELECT LD

      nURadnika++

      SKIP 1

   ENDDO

   // podaci o radniku
   hRec[ "prezime_ime" ] := AllTrim( radn->ime ) + " " + AllTrim( radn->naz )
   hRec[ "adresa_2" ] := AllTrim( radn->streetname ) +  " " + AllTrim( radn->streetnum )

   hRec[ "j21" ] := SubStr( radn->matBr, 1, 1 )
   hRec[ "j22" ] := SubStr( radn->matBr, 2, 1 )
   hRec[ "j23" ] := SubStr( radn->matBr, 3, 1 )
   hRec[ "j24" ] := SubStr( radn->matBr, 4, 1 )
   hRec[ "j25" ] := SubStr( radn->matBr, 5, 1 )
   hRec[ "j26" ] := SubStr( radn->matBr, 6, 1 )
   hRec[ "j27" ] := SubStr( radn->matBr, 7, 1 )
   hRec[ "j28" ] := SubStr( radn->matBr, 8, 1 )
   hRec[ "j29" ] := SubStr( radn->matBr, 9, 1 )
   hRec[ "j210" ] := SubStr( radn->matBr, 10, 1 )
   hRec[ "j211" ] := SubStr( radn->matBr, 11, 1 )
   hRec[ "j212" ] := SubStr( radn->matBr, 12, 1 )
   hRec[ "j213" ] := SubStr( radn->matBr, 13, 1 )

   hRec[ "opcina_2" ] := Ocitaj( F_OPS, radn->idopsrad, "naz", .T. )

   hRec[ "br_zaposlenih" ] := AllTrim( Str( nURadnika, 6, 0 ) )


   nPom := nBrutoOsnova
   nUUNR := nPom

   hb_cdpSelect( "SL852" )
   FOR EACH cKey in hRec:keys()
      IF ValType( hRec[ cKey ] ) == "C"
         hRec[ cKey ] := to_xml_encoding (  hRec[ cKey ] ) // hRec[ cKey ] je cp852 string
      ENDIF
   NEXT


   my_close_all_dbf()
   oReport:aRecords := { hRec }
   oReport:run()

   RETURN .T.
