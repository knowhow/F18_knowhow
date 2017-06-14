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

STATIC s_cDirF18Template
STATIC s_cTemplateName := "ld_obr_2001.xlsx"
STATIC s_cUrl
STATIC s_cSHA256sum := "903ddeb99969e4e5d0e59c09873029b60daa9a803366b8e2a53a200d3b7a2c13"



FUNCTION ld_specifikacija_plate_obr_2001()

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
   LOCAL aOps := {}
   LOCAL cRepSr := "N"
   LOCAL cRTipRada := " "
   LOCAL cMatBr := Space( 13 )
   LOCAL oReport, hRec, cKey

   // PRIVATE gPici := "9,999,999,999,999,999" + iif( gZaok > 0, PadR( ".", gZaok + 1, "9" ), "" )
   LOCAL cPictureIznos := "9,999,999,999,999,999.99" // + iif( gZaok2 > 0, PadR( ".", gZaok2 + 1, "9" ), "" )
   LOCAL cPictureStopa := "999,999,999,999.99"
   LOCAL cIdRj
   LOCAL cUslovIdRj, cUslovOpstStan
   LOCAL cFilterRj, cFilterOpstStan
   LOCAL nDanOd, nDanDo, nMjesecOd, nGodinaOd, nMjesecDo, nGodinaDo
   LOCAL nBrutoOsnova := 0
   LOCAL nBrutoOsBenef := 0
   LOCAL nPojBrOsn := 0
   LOCAL nPojBrBenef := 0
   LOCAL nOstaleObaveze := 0
   LOCAL uNaRuke := 0
   LOCAL cFirmNaz := PadR( fetch_metric( "org_naziv", NIL, Space( 35 ) ), 35 )
   LOCAL cFirmAdresa := PadR( fetch_metric( "ld_firma_adresa", NIL, Space( 35 ) ), 35 )
   LOCAL cFirmOpc := PadR( fetch_metric( "ld_firma_opcina", NIL, Space( 35 ) ), 35 )
   LOCAL cFirmVD := PadR( fetch_metric( "ld_firma_vrsta_djelatnosti", NIL, Space( 50 ) ), 50 )
   LOCAL cRadn := Space( LEN_IDRADNIK )
   LOCAL dDatIspl
   LOCAL cMRad := fetch_metric( "ld_specifikacija_minuli_rad", NIL, cMRad )
   LOCAL cPrimDobra := fetch_metric( "ld_specifikacija_primanja_dobra", NIL, cPrimDobra )
   LOCAL cDopr1 := fetch_metric( "ld_specifikacija_doprinos_1", NIL, "1X" )
   LOCAL cDopr2 := fetch_metric( "ld_specifikacija_doprinos_2", NIL, "2X" )
   LOCAL cDopr3 := fetch_metric( "ld_specifikacija_doprinos_3", NIL, "  " )
   LOCAL cDopr5 := fetch_metric( "ld_specifikacija_doprinos_5", NIL, cDopr5 )
   LOCAL cDopr6 := fetch_metric( "ld_specifikacija_doprinos_6", NIL, cDopr6 )
   LOCAL cDopr7 := fetch_metric( "ld_specifikacija_doprinos_7", NIL, cDopr7 )
   LOCAL cDDoprPio := fetch_metric( "ld_specifikacija_doprinos_pio", NIL, cDDoprPio )
   LOCAL cDDoprZdr := fetch_metric( "ld_specifikacija_doprinos_zdr", NIL, cDDoprZdr )
   LOCAL cCOO1 := fetch_metric( "ld_specifikacija_c1", NIL, Space( 20 ) )
   LOCAL cCOO2 := fetch_metric( "ld_specifikacija_c2", NIL, Space( 20 ) )
   LOCAL cCOO3 := fetch_metric( "ld_specifikacija_c3", NIL, Space( 20 ) )
   LOCAL cCOO4 := fetch_metric( "ld_specifikacija_c4", NIL, Space( 20 ) )
   LOCAL cNOO1 := fetch_metric( "ld_specifikacija_n1", NIL, Space( 20 ) )
   LOCAL cNOO2 := fetch_metric( "ld_specifikacija_n2", NIL, Space( 20 ) )
   LOCAL cNOO3 := fetch_metric( "ld_specifikacija_n3", NIL, Space( 20 ) )
   LOCAL cNOO4 := fetch_metric( "ld_specifikacija_n4", NIL, Space( 20 ) )
   LOCAL nMjesec := ld_tekuci_mjesec()
   LOCAL nGodina := ld_tekuca_godina()
   LOCAL cObracun := gObracun
   LOCAL nOmjerZdravstvo := fetch_metric( "ld_specifikacija_omjer_dopr_zdr", NIL, 10.2 )
   LOCAL nOmjerNezaposlenost := fetch_metric( "ld_specifikacija_omjer_dopr_nezap", NIL, 30 )
   LOCAL cIsplata := fetch_metric( "ld_specifikacija_vrsta_isplate", NIL, "A" )
   LOCAL cFilt := ".t."

   LOCAL cDoprOO1
   LOCAL cDoprOO2
   LOCAL cDoprOO3
   LOCAL cDoprOO4
   LOCAL cDodDoprP
   LOCAL cDodDoprZ

   download_template()

   cIdRJ := "  "
   cUslovIdRj := ""
   cUslovOpstStan := ""

   // prvi dan mjeseca
   nDanOd := prvi_dan_mjeseca( ld_tekuci_mjesec() )
   nMjesecOd := ld_tekuci_mjesec()
   nGodinaOd := ld_tekuca_godina()
   // posljednji dan mjeseca
   nDanDo := zadnji_dan_mjeseca( ld_tekuci_mjesec() )
   nMjesecDo := ld_tekuci_mjesec()
   nGodinaDo := ld_tekuca_godina()

   ld_specifikacije_otvori_tabele()

   cUslovIdRj := fetch_metric( "ld_specifikacija_rj", NIL, cUslovIdRj )
   cUslovOpstStan := fetch_metric( "ld_specifikacija_opcine", NIL, cUslovOpstStan )
   cUslovIdRj := PadR( cUslovIdRj, 100 )
   cUslovOpstStan := PadR( cUslovOpstStan, 100 )

   dDatIspl := Date()

   DO WHILE .T.
      Box(, 22 + iif( gVarSpec == "1", 0, 1 ), 75 )

      @ form_x_koord() + 1, form_y_koord() + 2 SAY "Radna jedinica (prazno-sve): " ;
         GET cUslovIdRj PICT "@!S15"
      @ form_x_koord() + 1, Col() + 1 SAY "Djelatnost" GET cRTipRada ;
         VALID val_tiprada( cRTipRada ) PICT "@!"
      @ form_x_koord() + 1, Col() + 1 SAY "Spec.za RS" GET cRepSr ;
         VALID cRepSr $ "DN" PICT "@!"

      @ form_x_koord() + 2, form_y_koord() + 2 SAY "Opstina stanov.(prazno-sve): " ;
         GET cUslovOpstStan PICT "@!S20"

      IF ld_vise_obracuna()
         @ form_x_koord() + 2, Col() + 1 SAY "Obr.:" GET cObracun ;
            WHEN HelpObr( .T., cObracun ) ;
            VALID ValObr( .T., cObracun )
      ENDIF

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


      @ form_x_koord() + 9, form_y_koord() + 2 SAY "Prim.u usl.ili dobrima (npr: 12;14;)" ;
         GET cPrimDobra  PICT "@!S20"

      @ form_x_koord() + 10, form_y_koord() + 2 SAY "Dopr.pio (iz)" GET cDopr1
      @ form_x_koord() + 10, Col() + 2 SAY "Dopr.pio (na)" GET cDopr5
      @ form_x_koord() + 11, form_y_koord() + 2 SAY "Dopr.zdr (iz)" GET cDopr2
      @ form_x_koord() + 11, Col() + 2 SAY "Dopr.zdr (na)" GET cDopr6
      @ form_x_koord() + 11, Col() + 1 SAY "Omjer dopr.zdr (%):" GET nOmjerZdravstvo PICT "999.99999"
      @ form_x_koord() + 12, form_y_koord() + 2 SAY "Dopr.nez (iz)" GET cDopr3
      @ form_x_koord() + 12, Col() + 2 SAY "Dopr.nez (na)" GET cDopr7
      @ form_x_koord() + 12, Col() + 1 SAY "Omjer dopr.nez (%):" GET nOmjerNezaposlenost PICT "999.99999"

      @ form_x_koord() + 13, form_y_koord() + 2 SAY "Dod.dopr.pio" GET cDDoprPio PICT "@S35"
      @ form_x_koord() + 14, form_y_koord() + 2 SAY "Dod.dopr.zdr" GET cDDoprZdr PICT "@S35"

      @ form_x_koord() + 15, form_y_koord() + 2 SAY "Ost.obaveze: NAZIV                  USLOV"
      @ form_x_koord() + 16, form_y_koord() + 2 SAY " 1." GET cCOO1
      @ form_x_koord() + 16, form_y_koord() + 30 GET cNOO1
      @ form_x_koord() + 17, form_y_koord() + 2 SAY " 2." GET cCOO2
      @ form_x_koord() + 17, form_y_koord() + 30 GET cNOO2
      @ form_x_koord() + 18, form_y_koord() + 2 SAY " 3." GET cCOO3
      @ form_x_koord() + 18, form_y_koord() + 30 GET cNOO3
      @ form_x_koord() + 19, form_y_koord() + 2 SAY " 4." GET cCOO4
      @ form_x_koord() + 19, form_y_koord() + 30 GET cNOO4

      @ form_x_koord() + 21, form_y_koord() + 2 SAY "Isplata: 'A' doprinosi+porez, 'B' samo doprinosi, 'C' samo porez" GET cIsplata VALID cIsplata $ "ABC" PICT "@!"

      READ
      clvbox()
      ESC_BCR
      BoxC()

      cFilterRj := Parsiraj( cUslovIdRj, "IDRJ" )
      cFilterOpstStan := Parsiraj( cUslovOpstStan, "IDOPSST" )
      IF ( cFilterRj <> NIL .AND. cFilterOpstStan <> NIL )
         EXIT
      ENDIF
   ENDDO

   set_metric( "org_naziv", NIL, cFirmNaz )
   set_metric( "ld_firma_adresa", NIL, cFirmAdresa )
   set_metric( "ld_firma_opcina", NIL, cFirmOpc )
   set_metric( "ld_firma_vrsta_djelatnosti", NIL, cFirmVD )
   set_metric( "ld_specifikacija_minuli_rad", NIL, cMRad )
   set_metric( "ld_specifikacija_primanja_dobra", NIL, cPrimDobra )
   set_metric( "ld_specifikacija_doprinos_1", NIL, cDopr1 )
   set_metric( "ld_specifikacija_doprinos_2", NIL, cDopr2 )
   set_metric( "ld_specifikacija_doprinos_3", NIL, cDopr3 )
   set_metric( "ld_specifikacija_doprinos_5", NIL, cDopr5 )
   set_metric( "ld_specifikacija_doprinos_6", NIL, cDopr6 )
   set_metric( "ld_specifikacija_doprinos_7", NIL, cDopr7 )
   set_metric( "ld_specifikacija_doprinos_pio", NIL, cDDoprPio )
   set_metric( "ld_specifikacija_doprinos_zdr", NIL, cDDoprZdr )
   set_metric( "ld_specifikacija_c1", NIL, cCOO1 )
   set_metric( "ld_specifikacija_c2", NIL, cCOO2 )
   set_metric( "ld_specifikacija_c3", NIL, cCOO3 )
   set_metric( "ld_specifikacija_c4", NIL, cCOO4 )
   set_metric( "ld_specifikacija_n1", NIL, cNOO1 )
   set_metric( "ld_specifikacija_n2", NIL, cNOO2 )
   set_metric( "ld_specifikacija_n3", NIL, cNOO3 )
   set_metric( "ld_specifikacija_n4", NIL, cNOO4 )
   set_metric( "ld_specifikacija_vrsta_isplate", NIL, cIsplata )
   set_metric( "ld_specifikacija_omjer_dopr_zdr", NIL, nOmjerZdravstvo )
   set_metric( "ld_specifikacija_omjer_dopr_nezap", NIL, nOmjerNezaposlenost )

   cUslovIdRj := Trim( cUslovIdRj )
   cUslovOpstStan := Trim( cUslovOpstStan )

   set_metric( "ld_specifikacija_rj", NIL, cUslovIdRj )
   set_metric( "ld_specifikacija_opcine", NIL, cUslovOpstStan )

   set_metric( "ld_specifikacija_maticni_broj", NIL, cMatBr )

   ld_porezi_i_doprinosi_iz_sezone( nGodina, nMjesec )


   hRec := hb_Hash()

   oReport := YargReport():New( "ld_obr_2001", "xlsx" )


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

   ld_pozicija_parobr( nMjesec, nGodina, cObracun, Left( cUslovIdRj, 2 ) )

   // SELECT LD
   // SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "2" ) )

   seek_ld_2( NIL, nGodina, nMjesec )
   // GO TOP
   // HSEEK Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 )


   IF !Empty( cUslovIdRj )
      cFilt += ( ".and." + cFilterRj )
   ENDIF

   IF !Empty( cObracun )
      cFilt += ( ".and. OBR==" + dbf_quote( cObracun ) )
   ENDIF

   SET FILTER TO &cFilt
   GO TOP


   cObracun := Trim( cObracun )

   cDoprOO1 := ld_izrezi_string( "D->", 2, @cNOO1 )
   cDoprOO2 := ld_izrezi_string( "D->", 2, @cNOO2 )
   cDoprOO3 := ld_izrezi_string( "D->", 2, @cNOO3 )
   cDoprOO4 := ld_izrezi_string( "D->", 2, @cNOO4 )

   cDodDoprP := ld_izrezi_string( "D->", 2, @cDDoprPio )
   cDodDoprZ := ld_izrezi_string( "D->", 2, @cDDoprZdr )

   ld_pozicija_parobr( nMjesec, nGodina, cObracun, Left( cUslovIdRj, 2 ) )

   // SELECT LD
   // SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "2" ) )
   // HSEEK Str( nGodina, 4 ) + Str( nMjesec, 2 )
   seek_ld_2( NIL, nGodina, nMjesec )


   IF !Empty( cUslovIdRj )
      cFilt += ( ".and." + cFilterRj )
   ENDIF

   IF !Empty( cObracun )
      cFilt += ( ".and. OBR==" + dbf_quote( cObracun ) )
   ENDIF

   SET FILTER TO &cFilt
   GO TOP


   IF Eof()
      MsgBeep( "Obračun za ovaj mjesec ne postoji !" )
      // my_close_all_dbf()
      RETURN .T.
   ENDIF

   nUNeto := 0
   nUNetoOsnova := 0
   nPorNaPlatu := 0
   nKoefLO := 0
   nURadnika := 0
   nULicOdbitak := 0
   nDodDoprZ := 0
   nDodDoprP := 0

   DO WHILE Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 ) == Str( godina, 4, 0 ) + Str( mjesec, 2, 0 )

      select_o_radn( LD->idradn )
      cRTR := get_ld_rj_tip_rada( ld->idradn, ld->idrj )
      nRSpr_koef := 0
      IF cRTR == "S"
         nRSpr_koef := radn->sp_koef
      ENDIF

      IF cRTR $ "I#N" .AND. Empty( cRTipRada )
      ELSEIF cRTipRada <> cRTR
         SELECT ld
         SKIP
         LOOP
      ENDIF

      IF cRepSr == "N"
         IF radnik_iz_rs( radn->idopsst, radn->idopsrad )
            SELECT ld
            SKIP
            LOOP
         ENDIF
      ELSE
         IF !radnik_iz_rs( radn->idopsst, radn->idopsrad )
            SELECT ld
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT LD

      IF !( RADN->( &cFilterOpstStan ) )
         SKIP 1
         LOOP
      ENDIF

      nKoefLO := ld->ulicodb
      nULicOdbitak += nKoefLO
      nP77 := IF( !Empty( cMRad ), LD->&( "I" + cMRad ), 0 )
      nP78 := IF( !Empty( cPorOl ), LD->&( "I" + cPorOl ), 0 )
      nP79 := 0

      IF !Empty( cBolPr ) .OR. !Empty( cBolPr )
         FOR t := 1 TO 99
            cPom := IF( t > 9, Str( t, 2 ), "0" + Str( t, 1 ) )
            IF LD->( FieldPos( "I" + cPom ) ) <= 0
               EXIT
            ENDIF
            nP79 += IF( cPom $ cBolPr, LD->&( "I" + cPom ), 0 )
         NEXT
      ENDIF

      nP80 := nP81 := nP82 := nP83 := nP84 := nP85 := 0

      IF LD->uneto > 0  // zbog npr.bol.preko 42 dana koje ne ide u neto
         IF Len( aPom ) < 1 .OR. ( nPom := AScan( aPom, {| x | x[ 1 ] == LD->brbod } ) ) == 0
            AAdd( aPom, { LD->brbod, 1, nP77, LD->uneto } )
         ELSE
            IF !( ld_vise_obracuna() .AND. Empty( cObracun ) .AND. LD->obr $ "23456789" )
               aPom[ nPom, 2 ] += 1  // broj radnika
            ENDIF
            aPom[ nPom, 3 ] += nP77  // minuli rad
            aPom[ nPom, 4 ] += LD->uneto // neto
         ENDIF
      ENDIF

      nPrDobra := 0
      IF !Empty( cPrimDobra )
         FOR t := 1 TO 99
            cPom := IF( t > 9, Str( t, 2 ), "0" + Str( t, 1 ) )
            IF LD->( FieldPos( "I" + cPom ) ) <= 0
               EXIT
            ENDIF
            nPrDobra += IF( cPom $ cPrimDobra, LD->&( "I" + cPom ), 0 )
         NEXT
      ENDIF

      nUNeto += ld->uneto
      nNetoOsn := Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )
      nUNetoOsnova += nNetoOsn

      // prvo doprinosi i bruto osnova ....
      nPojBrOsn := ld_get_bruto_osnova( nNetoOsn, cRTR, nKoefLO, nRSpr_koef )

      // pojedinacni bruto - dobra ili usluge
      nPojBrDobra := 0
      IF nPrDobra > 0
         nPojBrDobra := ld_get_bruto_osnova( nPrDobra, cRTR, nKoefLO, nRSpr_koef )
      ENDIF

      nMPojBrOsn := nPojBrOsn

      IF calc_mbruto()
         // minimalni bruto
         nMPojBrOsn := min_bruto( nPojBrOsn, field->usati )
      ENDIF

      nBrutoOsnova += nPojBrOsn
      nBrutoDobra += nPojBrDobra
      nMBrutoOsnova += nMPojBrOsn

      // reset matrice
      _a_benef := {}

      // beneficirani radnici
      IF is_radn_k4_bf_ide_u_benef_osnovu()

         cFFTmp := gBFForm
         gBFForm := StrTran( gBFForm, "_", "" )

         nPojBrBenef := ld_get_bruto_osnova( nNetoOsn - IF( !Empty( gBFForm ), &gBFForm, 0 ), cRTR, nKoefLO, nRSpr_koef )

         nBrutoOsBenef += nPojBrBenef

         _benef_st := BenefStepen()
         add_to_a_benef( @_a_benef, AllTrim( radn->k3 ), _benef_st, nPojBrBenef )

         gBFForm := cFFtmp

      ENDIF

      nPom := nMBrutoOsnova

      nkDopZX := 0
      nkDopPX := 0

      UzmiIzIni( cIniName, 'Varijable', 'U017', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

      select_o_dopr()
      GO TOP

      DO WHILE !Eof()

         IF DOPR->poopst == "1" .AND. lPDNE
            nBOO := 0
            FOR i := 1 TO Len( aOps )
               IF !( DOPR->id $ aOps[ i, 2 ] )
                  nBOO += aOps[ i, 3 ]
               ENDIF
            NEXT
            nBOO := ld_get_bruto_osnova( nBOO, cRTR, nKoefLO )
         ELSE
            nBOO := nMBrutoOsnova
         ENDIF

         IF ID $ cDodDoprP
            nkDopPX += iznos
            IF !Empty( field->idkbenef )
               nDodDoprP += ROUND2( Max( DLIMIT, get_benef_osnovica( _a_benef, field->idkbenef ) * iznos / 100 ), gZaok2 )
            ELSE
               nDodDoprP += ROUND2( Max( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
            ENDIF
         ENDIF

         IF ID $ cDodDoprZ
            nkDopZX += iznos
            IF !Empty( field->idkbenef )
               // beneficirani
               nDodDoprZ += ROUND2( Max( DLIMIT, get_benef_osnovica( _a_benef, field->idkbenef ) * iznos / 100 ), gZaok2 )
            ELSE
               nDodDoprZ += ROUND2( Max( DLIMIT, nBOO * iznos / 100 ), gZaok2 )
            ENDIF
         ENDIF

         SKIP 1

      ENDDO

      nkD1X := Ocitaj( F_DOPR, cDopr1, "iznos", .T. )
      nkD2X := Ocitaj( F_DOPR, cDopr2, "iznos", .T. )
      nkD3X := Ocitaj( F_DOPR, cDopr3, "iznos", .T. )
      nkD5X := Ocitaj( F_DOPR, cDopr5, "iznos", .T. )
      nkD6X := Ocitaj( F_DOPR, cDopr6, "iznos", .T. )
      nkD7X := Ocitaj( F_DOPR, cDopr7, "iznos", .T. )

      nPom := nKD1X + nKD2X + nKD3X
      UzmiIzIni( cIniName, 'Varijable', 'D11B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD1X
      UzmiIzIni( cIniName, 'Varijable', 'D11_1B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD2X
      UzmiIzIni( cIniName, 'Varijable', 'D11_2B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD3X
      UzmiIzIni( cIniName, 'Varijable', 'D11_3B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )

      nPom := nKD5X + nKD6X + nKD7X + nkDopZX + nkDopPX
      UzmiIzIni( cIniName, 'Varijable', 'D12B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD5X
      UzmiIzIni( cIniName, 'Varijable', 'D12_1B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD6X
      UzmiIzIni( cIniName, 'Varijable', 'D12_2B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD7X
      UzmiIzIni( cIniName, 'Varijable', 'D12_3B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )

      nPom := nkDopPX
      UzmiIzIni( cIniName, 'Varijable', 'D12_4B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )

      nPom := nkDopZX
      UzmiIzIni( cIniName, 'Varijable', 'D12_5B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )

      nDopr1X := round2( nMBrutoOsnova * nkD1X / 100, gZaok2 )
      nDopr2X := round2( nMBrutoOsnova * nkD2X / 100, gZaok2 )
      nDopr3X := round2( nMBrutoOsnova * nkD3X / 100, gZaok2 )
      nDopr5X := round2( nMBrutoOsnova * nkD5X / 100, gZaok2 )
      nDopr6X := round2( nMBrutoOsnova * nkD6X / 100, gZaok2 )
      nDopr7X := round2( nMBrutoOsnova * nkD7X / 100, gZaok2 )

      nPojDoprIZ := round2( ( nMPojBrOsn * nkD1X / 100 ), gZaok2 ) + ;
         round2( ( nMPojBrOsn * nkD2X / 100 ), gZaok2 ) + ;
         round2( ( nMPojBrOsn * nkD3X / 100 ), gZaok2 )

      nPom := nDopr1X + nDopr2X + nDopr3X

      nUkDoprIZ := nPom

      UzmiIzIni( cIniName, 'Varijable', 'D11I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
      nPom := nDopr1X
      UzmiIzIni( cIniName, 'Varijable', 'D11_1I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
      nPom := nDopr2X
      UzmiIzIni( cIniName, 'Varijable', 'D11_2I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
      nPom := nDopr3X
      UzmiIzIni( cIniName, 'Varijable', 'D11_3I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

      nPom := nDopr5X + nDopr6X + nDopr7X + nDodDoprP + nDodDoprZ
      UzmiIzIni( cIniName, 'Varijable', 'D12I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
      nPom := nDopr5X
      UzmiIzIni( cIniName, 'Varijable', 'D12_1I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
      nPom := nDopr6X
      UzmiIzIni( cIniName, 'Varijable', 'D12_2I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
      nPom := nDopr7X
      UzmiIzIni( cIniName, 'Varijable', 'D12_3I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

      // dodatni doprinos zdr i pio
      nPom := nDodDoprP
      UzmiIzIni( cIniName, 'Varijable', 'D12_4I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

      nPom := nDodDoprZ
      UzmiIzIni( cIniName, 'Varijable', 'D12_5I', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

      nPojPorOsn := ( nPojBrOsn - nPojDoprIz ) - nKoefLO

      IF nPojPorOsn >= 0 .AND. radn_oporeziv( radn->id, ld->idrj )
         // osnovica za porez na platu
         // nPorOsnovica := ( nBrutoOsnova - nUKDoprIZ ) - nULicOdbitak
         nPorOsnovica += nPojPorOsn
      ENDIF

      // osnovica mora biti veca od 0
      IF nPorOsnovica < 0
         nPorOsnovica := 0
      ENDIF

      // resetuj varijable
      nPorNaPlatu := 0
      nPorezOstali := 0

      // porez na platu i ostali porez
      select_o_por()
      GO TOP

      DO WHILE !Eof()

         PozicOps( POR->poopst )

         IF !ImaUOp( "POR", POR->id )
            SKIP 1
            LOOP
         ENDIF
         IF por->por_tip == "B"
            nPorNaPlatu  += POR->iznos * Max( nPorOsnovica, PAROBR->prosld * gPDLimit / 100 ) / 100
         ENDIF
         SKIP 1
      ENDDO

      SELECT LD

      nURadnika++
      nPorOlaksice += nP78
      nBolPreko += nP79
      nObustave += nP80
      nOstaleObaveze += nP81
      nOstOb1 += nP82
      nOstOb2 += nP83
      nOstOb3 += nP84
      nOstOb4 += nP85

      IF lPDNE
         nOps := AScan( aOps, {| x | x[ 1 ] == RADN->idopsst } )
         IF nOps > 0
            aOps[ nOps, 3 ] += Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )
         ELSE
            AAdd( aOps, { RADN->idopsst, "", Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 ) } )
         ENDIF
      ENDIF

      ++nObrCount

      SKIP 1

   ENDDO

   IF nObrCount == 0
      MsgBeep( "Štampa specifikacije nije moguća, nema obračuna !" )
      RETURN .T.
   ENDIF

   nPorNaPlatu := round2( nPorNaPlatu, gZaok2 )

   // obustave iz place
   UzmiIzIni( cIniName, 'Varijable', 'O18I', FormNum2( - nObustave, 16, gPici2 ), 'WRITE' )

   // Ostale obaveze = OstaleObaveze.1

   ASort( aPom, , , {| x, y | x[ 1 ] > y[ 1 ] } )
   FOR i := 1 TO Len( aPom )
      IF gVarSpec == "1"
         IF i <= nGrupaPoslova
            aSpec[ i, 1 ] := aPom[ i, 1 ]; aSpec[ i, 2 ] := aPom[ i, 2 ]; aSpec[ i, 3 ] := aPom[ i, 3 ]
            aSpec[ i, 4 ] := aPom[ i, 4 ]
         ELSE
            aSpec[ nGrupaPoslova, 2 ] += aPom[ i, 2 ]; aSpec[ nGrupaPoslova, 3 ] += aPom[ i, 3 ]
            aSpec[ nGrupaPoslova, 4 ] += aPom[ i, 4 ]
         ENDIF
      ELSE     // gVarSpec=="2"
         DO CASE
         CASE aPom[ i, 1 ] <= nLimG5
            aSpec[ 5, 1 ] := aPom[ i, 1 ]; aSpec[ 5, 2 ] += aPom[ i, 2 ]
            aSpec[ 5, 3 ] += aPom[ i, 3 ]; aSpec[ 5, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG4
            aSpec[ 4, 1 ] := aPom[ i, 1 ]; aSpec[ 4, 2 ] += aPom[ i, 2 ]
            aSpec[ 4, 3 ] += aPom[ i, 3 ]; aSpec[ 4, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG3
            aSpec[ 3, 1 ] := aPom[ i, 1 ]; aSpec[ 3, 2 ] += aPom[ i, 2 ]
            aSpec[ 3, 3 ] += aPom[ i, 3 ]; aSpec[ 3, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG2
            aSpec[ 2, 1 ] := aPom[ i, 1 ]; aSpec[ 2, 2 ] += aPom[ i, 2 ]
            aSpec[ 2, 3 ] += aPom[ i, 3 ]; aSpec[ 2, 4 ] += aPom[ i, 4 ]
         CASE aPom[ i, 1 ] <= nLimG1
            aSpec[ 1, 1 ] := aPom[ i, 1 ]; aSpec[ 1, 2 ] += aPom[ i, 2 ]
            aSpec[ 1, 3 ] += aPom[ i, 3 ]; aSpec[ 1, 4 ] += aPom[ i, 4 ]
         ENDCASE
      ENDIF
      aSpec[ nGrupaPoslova + 1, 2 ] += aPom[ i, 2 ]; aSpec[ nGrupaPoslova + 1, 3 ] += aPom[ i, 3 ]
      aSpec[ nGrupaPoslova + 1, 4 ] += aPom[ i, 4 ]
   NEXT

   // ukupno radnika
   UzmiIzIni( cIniName, 'Varijable', 'U016', Str( nURadnika, 0 ), 'WRITE' )
   // ukupno neto
   UzmiIzIni( cIniName, 'Varijable', 'U018', FormNum2( nUNETO, 16, gPici2 ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', 'D13N', " ", 'WRITE' )

   select_o_por()
   SEEK "01"

   UzmiIzIni( cIniName, 'Varijable', 'D13_1N', FormNum2( POR->IZNOS, 16, gpici3 ) + "%", 'WRITE' )

   nPom = nPorNaPlatu - nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'D13I', FormNum2( _ispl_p( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
   nPom = nPorNaPlatu
   UzmiIzIni( cIniName, 'Varijable', 'D13_1I', FormNum2( _ispl_p( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
   nPom := nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'D13_2I', FormNum2( _ispl_p( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )
   nPom := nBolPreko
   UzmiIzIni( cIniName, 'Varijable', 'N17I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   nPorOlaksice   := Abs( nPorOlaksice   )
   nBolPreko      := Abs( nBolPreko      )
   nObustave      := Abs( nObustave      )
   nOstOb1        := Abs( nOstOb1        )
   nOstOb2        := Abs( nOstOb2        )
   nOstOb3        := Abs( nOstOb3        )
   nOstOb4        := Abs( nOstOb4        )
   nOstaleObaveze := Abs( iif( nOstaleObaveze == 0, nOstOb1 + nOstOb2 + nOstOb3 + nOstOb4, nOstaleObaveze ) )

   IF cIsplata == "A"
      // sve obaveze
      nPom := nDopr1X + nDopr2x + nDopr3x + nDopr5x + nDopr6x + nDopr7x + nPorNaPlatu + nPorezOstali - nPorOlaksice + nOstaleOBaveze + nDodDoprP + nDodDoprZ

   ELSEIF cIsplata == "B"
      // samo doprinosi
      nPom := nDopr1X + nDopr2x + nDopr3x + nDopr5x + nDopr6x + nDopr7x + nDodDoprP + nDodDoprZ

   ELSEIF cIsplata == "C"
      // samo porez
      nPom := nPorNaPlatu + nPorezOstali - nPorOlaksice + nOstaleOBaveze

   ENDIF

   // ukupno obaveze
   UzmiIzIni( cIniName, 'Varijable', 'U15I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   nPom := nMBrutoOsnova - nBrutoDobra
   nUUNR := nPom
   UzmiIzIni( cIniName, 'Varijable', 'UNR', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // ukupno ostalo
   nPom := nBrutoDobra
   nUUsluge := nPom
   UzmiIzIni( cIniName, 'Varijable', 'UNUS', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // ukupno ostalo
   nPom := nUUNR + nUUsluge
   UzmiIzIni( cIniName, 'Varijable', 'UNUK', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // ukupno placa_i_obaveze = obaveze + ukupno_neto + poreskeolaksice
   nPom := nPom + nUNETO + nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'U16I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // obustave
   nPom := nObustave
   UzmiIzIni( cIniName, 'Varijable', 'O18I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // neto za isplatu  = neto  + nPorOlaksice
   // -----------------------------------------
   // varijanta D - specificno za FEB jer treba da izbazi bol.preko.42
   // dana iz neta za isplatu na specifikaciji, vec je uracunat u netu.

   IF my_get_from_ini( 'LD', 'BolPreko42IzbaciIz19', 'N', KUMPATH ) == 'D'
      nPom := nUNETO + nPorOlaksice - nObustave
   ELSE
      nPom := nUNETO + nBolPreko + nPorOlaksice - nObustave
   ENDIF

   UzmiIzIni( cIniName, 'Varijable', 'N19I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   // PIO iz + PIO na placu
   nPom := nDopr1x + nDopr5x + nDodDoprP
   UzmiIzIni( cIniName, 'Varijable', 'D20', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   // zdravsveno iz + zdravstveno na placu
   nPom := nDopr2x + nDopr6x + nDodDoprZ
   nPom2 := nPom
   UzmiIzIni( cIniName, 'Varijable', 'D21', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   // zdravstvo za RS
   nPom := nPom2 * ( nOmjerZdravstvo / 100 )
   nD21a := nPom
   UzmiIzIni( cIniName, 'Varijable', 'D21a', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   // nezaposlenost iz + nezaposlenost na placu
   nPom := nDopr3x + nDopr7x
   nPom2 := nPom
   UzmiIzIni( cIniName, 'Varijable', 'D22', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   // nezaposlenost za RS
   nPom := nPom2 * ( nOmjerNezaposlenost / 100 )
   nD22a := nPom
   UzmiIzIni( cIniName, 'Varijable', 'D22a', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   nPom = nPorNaPlatu - nPorOlaksice
   UzmiIzIni( cIniName, 'Varijable', 'P23', FormNum2( _ispl_p( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   nPom = nPorezOstali
   UzmiIzIni( cIniName, 'Varijable', 'O14_1I', FormNum2( _ispl_p( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   nPom = nOstaleObaveze + nPorezOstali
   UzmiIzIni( cIniName, 'Varijable', 'O14I', FormNum2( _ispl_p( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   // ukupno za RS obaveze

   IF cIsplata == "A"

      nPom := nDopr1x + nDopr5x + nD21a + nD22a + nPorNaPlatu

   ELSEIF cIsplata == "B"

      nPom := nDopr1x + nDopr5x + nD21a + nD22a

   ELSEIF cIsplata == "C"

      nPom := nPorNaPlatu

   ENDIF

   UzmiIzIni( cIniName, 'Varijable', 'URSOB', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   IniRefresh()

   my_close_all_dbf()

   IF LastKey() != K_ESC

      cSpecRtm := "spec"

      IF cRepSr == "D"
         cSpecRtm := cSpecRtm + "rs"
      ELSE
         cSpecRtm := cSpecRtm + "b"
      ENDIF

      IF cRTipRada $ "I#N"
         cRTipRada := ""
      ENDIF

      // "SPECBN", "SPECBR" ...
      // cSpecRtm := cSpecRtm + cRTipRada


   ENDIF


/* -------------------------------------
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

      IF !( RADN->( &cFilterOpstStan ) )
         SKIP 1
         LOOP
      ENDIF

      nKoefLO := ld->ulicodb
      nULicOdbitak += nKoefLO
      nUNeto += ld->uneto
      nUSati += ld->usati
      nNetoOsn := Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )
      nUNetoOsnova += nNetoOsn



      nPojBrOsn := ld_get_bruto_osnova( nNetoOsn, cRTR, nKoefLO, nRSpr_koef )  // prvo doprinosi i bruto osnova
      nBrutoOsnova += nPojBrOsn

      nPom := nBrutoOsnova // ukupno bruto

      hRec[ "osnovica_obracun" ] := FormNum2( nPom, 16, cPictureIznos )

      nPom := nUSati
      hRec[ "br_radnih_sati" ] := FormNum2( nPom, 16, cPictureIznos )


      select_o_dopr()
      GO TOP

      DO WHILE !Eof()

         IF DOPR->poopst == "1"

            nBOO := 0

            FOR i := 1 TO Len( aOps )
               IF !( DOPR->id $ aOps[ i, 2 ] )
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
      hRec[ "stopa_19" ] := FormNum2( nPom, 16, cPictureStopa ) + "%"

      nPom := nKD2X
      hRec[ "stopa_20" ] := FormNum2( nPom, 16, cPictureStopa ) + "%"

      nPom := nKD3X
      hRec[ "stopa_21" ] := FormNum2( nPom, 16, cPictureStopa ) + "%"

      nPom := nKD1X + nKD2X + nKD3X
      hRec[ "stopa_22" ] := FormNum2( nPom, 16, cPictureStopa ) + "%"

      nDopr1X := round2( nBrutoOsnova * nKD1X / 100, gZaok2 )
      nDopr2X := round2( nBrutoOsnova * nKD2X / 100, gZaok2 )
      nDopr3X := round2( nBrutoOsnova * nKD3X / 100, gZaok2 )

      nPojDoprIZ := round2( ( nPojBrOsn * nkD1X / 100 ), gZaok2 ) + ;
         round2( ( nPojBrOsn * nkD2X / 100 ), gZaok2 ) + ;
         round2( ( nPojBrOsn * nkD3X / 100 ), gZaok2 )


      nPom := nDopr1X // iznos doprinosa
      hRec[ "iznos_19" ] := FormNum2( nPom, 16, cPictureIznos )

      nPom := nDopr2X
      hRec[ "iznos_20" ] := FormNum2( nPom, 16, cPictureIznos )

      nPom := nDopr3X
      hRec[ "iznos_21" ] := FormNum2( nPom, 16, cPictureIznos )

      nPom := nDopr1X + nDopr2X + nDopr3X // ukupni doprinosi iz plate
      nUkDoprIZ := nPom
      hRec[ "iznos_22" ] := FormNum2( nPom, 16, cPictureIznos )

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

   select_o_ops( radn->idopsrad )
   hRec[ "opcina_2" ] := ops->naz

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
*/

STATIC FUNCTION download_template()

   s_cDirF18Template := ExePath() + "template" + SLASH
   s_cUrl := "https://github.com/hernad/F18_template/releases/download/" + ;
      f18_template_ver() + SLASH + s_cTemplateName

   IF DirChange( s_cDirF18Template ) != 0
      IF ! MakeDir( s_cDirF18Template )
         MsgBeep( "Kreiranje dir: " + s_cDirF18Template + " neuspješno?! STOP" )
         RETURN .F.
      ENDIF
   ENDIF

   IF !File( s_cDirF18Template + s_cTemplateName ) .OR. ;
         ( sha256sum( s_cDirF18Template + s_cTemplateName ) != s_cSHA256sum )

      IF !Empty( download_file( s_cUrl, s_cDirF18Template + s_cTemplateName ) )
         MsgBeep( "Download " + s_cDirF18Template + s_cTemplateName )
      ELSE
         MsgBeep( "Error download:" + s_cDirF18Template + s_cTemplateName )
         RETURN .F.
      ENDIF
   ENDIF

   IF sha256sum( s_cDirF18Template + s_cTemplateName ) != s_cSHA256sum
      MsgBeep( "ERROR sha256sum: " + s_cDirF18Template + s_cTemplateName + "##" + s_cSHA256sum )
      RETURN .F.
   ENDIF

   RETURN .T.
