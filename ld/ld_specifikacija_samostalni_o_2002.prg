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
   PRIVATE aSpec := {}
   PRIVATE cFNTZ := "D"
   PRIVATE gPici := "9,999,999,999,999,999" + IIF( gZaok > 0, PadR( ".", gZaok + 1, "9" ), "" )
   PRIVATE gPici2 := "9,999,999,999,999,999" + IIF( gZaok2 > 0, PadR( ".", gZaok2 + 1, "9" ), "" )
   PRIVATE gPici3 := "999,999,999,999.99"

   FOR i := 1 TO nGrupaPoslova + 1
      AAdd( aSpec, { 0, 0, 0, 0 } )
      // br.bodova, br.radnika, minuli rad, uneto
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
   nDanOd := prvi_dan_mjeseca( gMjesec )
   nMjesecOd := gMjesec
   nGodinaOd := gGodina
   // posljednji dan mjeseca
   nDanDo := zadnji_dan_mjeseca( gMjesec )
   nMjesecDo := gMjesec
   nGodinaDo := gGodina

   // varijable izvjestaja
   nMjesec := gMjesec
   nGodina := gGodina
   cObracun := gObracun

   cDopr1 := "1X"
   cDopr2 := "2X"
   cDopr3 := "  "
   cFirmNaz := Space( 35 )
   cFirmAdresa := Space( 35 )
   cFirmOpc := Space( 35 )
   cFirmVD := Space( 50 )
   cRadn := Space( _LR_ )


altd()
   YargReport():New( "ld_obr_2002", "xlsx" ):run()


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

      @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): " GET qqIdRJ PICT "@!S15"

      @ m_x + 2, m_y + 2 SAY "Opstina stanov.(prazno-sve): "  GET qqOpSt PICT "@!S20"

      @ m_x + 2, Col() + 1 SAY "Obr.:" GET cObracun   WHEN HelpObr( .T., cObracun ) ;
         VALID ValObr( .T., cObracun )

      @ m_x + 3, m_y + 2 SAY "Period od:" GET nDanOd PICT "99"
      @ m_x + 3, Col() + 1 SAY "/" GET nMjesecOd PICT "99"
      @ m_x + 3, Col() + 1 SAY "/" GET nGodinaOd PICT "9999"
      @ m_x + 3, Col() + 1 SAY "do:" GET nDanDo PICT "99"
      @ m_x + 3, Col() + 1 SAY "/" GET nMjesecDo PICT "99"
      @ m_x + 3, Col() + 1 SAY "/" GET nGodinaDo PICT "9999"

      @ m_x + 4, m_y + 2 SAY " Naziv: " GET cFirmNaz
      @ m_x + 5, m_y + 2 SAY "Adresa: " GET cFirmAdresa
      @ m_x + 6, m_y + 2 SAY "Opcina: " GET cFirmOpc
      @ m_x + 7, m_y + 2 SAY "Vrsta djelatnosti: " GET cFirmVD

      @ m_x + 4, m_y + 52 SAY "ID.broj :" GET cMatBR
      @ m_x + 5, m_y + 52 SAY "Dat.ispl:" GET dDatIspl

      @ m_x + 8, m_y + 2 SAY "Poduzetnik:" GET cRadn  VALID P_RADN( @cRadn )

      @ m_x + 10, m_y + 2 SAY "          Doprinos pio (iz+na):" GET cDopr1
      @ m_x + 11, m_y + 2 SAY "    Doprinos zdravstvo (iz+na):" GET cDopr2
      @ m_x + 12, m_y + 2 SAY "Doprinos nezaposlenost (iz+na):" GET cDopr3

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

   UzmiIzIni( cIniName, 'Varijable', "NAZ", cFirmNaz,'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "ADRESA", cFirmAdresa,'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "OPCINA", cFirmOpc,'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "VRDJ", cFirmVD,'WRITE' )

   UzmiIzIni( cIniName, 'Varijable', "GODOD", Razrijedi( Str( nGodinaOd, 4 ) ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "GODDO", Razrijedi( Str( nGodinaDo, 4 ) ), 'WRITE' )

   UzmiIzIni( cIniName, 'Varijable', "MJOD", Razrijedi( StrTran( Str( nMjesecOd, 2 ), " ", "0" ) ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "MJDO", Razrijedi( StrTran( Str( nMjesecDo, 2 ), " ", "0" ) ), 'WRITE' )

   UzmiIzIni( cIniName, 'Varijable', "DANOD", Razrijedi( StrTran( Str( nDanOd, 2 ), " ", "0" ) ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "DANDO", Razrijedi( StrTran( Str( nDanDo, 2 ), " ", "0" ) ), 'WRITE' )

   UzmiIzIni( cIniName, 'Varijable', "MATBR", Razrijedi( cMatBR ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', "DATISPL", DToC( dDatIspl ), 'WRITE' )

   cObracun := Trim( cObracun )

   ParObr( nMjesec, nGodina, cObracun, Left( qqIdRJ, 2 ) )

   SELECT LD
   SET ORDER TO TAG ( TagVO( "2" ) )

   PRIVATE cFilt := ".t."

   IF !Empty( qqIdRJ )
      cFilt += ( ".and." + aUslRJ )
   ENDIF

   IF !Empty( cObracun )
      cFilt += ( ".and. OBR==" + dbf_quote( cObracun ) )
   ENDIF

   SET FILTER TO &cFilt

   GO TOP
   HSEEK Str( nGodina, 4 ) + Str( nMjesec, 2 )

   nUNeto := 0
   nUNetoOsnova := 0
   nPorNaPlatu := 0
   nKoefLO := 0
   nURadnika := 0
   nULicOdbitak := 0

   DO WHILE Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0) == Str( godina, 4, 0 ) + Str( mjesec, 2, 0 )

      IF field->idradn <> cRadn
         SKIP
         LOOP
      ENDIF

      SELECT RADN
      HSEEK LD->idradn

      cRTR := g_tip_rada( ld->idradn, ld->idrj )

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
      nNetoOsn := Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )
      nUNetoOsnova += nNetoOsn


      // prvo doprinosi i bruto osnova ....
      nPojBrOsn := bruto_osn( nNetoOsn, cRTR, nKoefLO, nRSpr_koef )
      nBrutoOsnova += nPojBrOsn

      // ukupno bruto
      nPom := nBrutoOsnova
      UzmiIzIni( cIniName, 'Varijable', 'U017', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

      SELECT DOPR
      GO TOP

      DO WHILE !Eof()

         IF DOPR->poopst == "1"

            nBOO := 0

            FOR i := 1 TO Len( aOps )
               IF ! ( DOPR->id $ aOps[ i, 2 ] )
                  nBOO += aOps[ i, 3 ]
               ENDIF
            NEXT
            nBOO := bruto_osn( nBOO, cRTR, nKoefLO )
         ELSE
            nBOO := nBrutoOsnova
         ENDIF

         SKIP 1
      ENDDO

      nkD1X := get_dopr( cDopr1, "S" )
      nkD2X := get_dopr( cDopr2, "S" )
      nkD3X := get_dopr( cDopr3, "S" )

      // stope na bruto

      nPom := nKD1X + nKD2X + nKD3X
      UzmiIzIni( cIniName, 'Varijable', 'D11B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD1X
      UzmiIzIni( cIniName, 'Varijable', 'D11_1B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD2X
      UzmiIzIni( cIniName, 'Varijable', 'D11_2B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )
      nPom := nKD3X
      UzmiIzIni( cIniName, 'Varijable', 'D11_3B', FormNum2( nPom, 16, gpici3 ) + "%", 'WRITE' )


      nDopr1X := round2( nBrutoOsnova * nkD1X / 100, gZaok2 )
      nDopr2X := round2( nBrutoOsnova * nkD2X / 100, gZaok2 )
      nDopr3X := round2( nBrutoOsnova * nkD3X / 100, gZaok2 )

      nPojDoprIZ := round2( ( nPojBrOsn * nkD1X / 100 ), gZaok2 ) + ;
         round2( ( nPojBrOsn * nkD2X / 100 ), gZaok2 ) + ;
         round2( ( nPojBrOsn * nkD3X / 100 ), gZaok2 )

      // iznos doprinosa

      nPom := nDopr1X + nDopr2X + nDopr3X

      // ukupni doprinosi iz plate
      nUkDoprIZ := nPom

      UzmiIzIni( cIniName, 'Varijable', 'D11I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
      nPom := nDopr1X
      UzmiIzIni( cIniName, 'Varijable', 'D11_1I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
      nPom := nDopr2X
      UzmiIzIni( cIniName, 'Varijable', 'D11_2I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )
      nPom := nDopr3X
      UzmiIzIni( cIniName, 'Varijable', 'D11_3I', FormNum2( nPom, 16, gPici2 ), 'WRITE' )


      SELECT LD

      nURadnika++

      SKIP 1

   ENDDO

   // podaci o radniku
   // ime poduzetnika
   UzmiIzIni( cIniName, 'Varijable', 'PODNAZ', AllTrim( radn->ime ) + ;
      " " + AllTrim( radn->naz ),'WRITE' )
   // adresa
   UzmiIzIni( cIniName, 'Varijable', 'PODADR', AllTrim( radn->streetname ) + ;
      " " + AllTrim( radn->streetnum ),'WRITE' )
   // matbr
   UzmiIzIni( cIniName, 'Varijable', 'PODMAT', Razrijedi( radn->matbr ),'WRITE' )
   // opcina
   UzmiIzIni( cIniName, 'Varijable', 'PODOPC', ;
      Ocitaj( F_OPS, radn->idopsrad, "naz", .T. ),'WRITE' )

   // ukupno radnika
   UzmiIzIni( cIniName, 'Varijable', 'U016', Str( nURadnika, 0 ),'WRITE' )

   // ukupno neto
   UzmiIzIni( cIniName, 'Varijable', 'U018', FormNum2( nUNETO, 16, gPici2 ), 'WRITE' )

   nPom := nBrutoOsnova
   nUUNR := nPom
   UzmiIzIni( cIniName, 'Varijable', 'UNR', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

   IniRefresh()
   // Odstampaj izvjestaj

   my_close_all_dbf()

   IF LastKey() != K_ESC

      cSpecRtm := "specbs"
      f18_rtm_print( AllTrim( cSpecRtm ), "DUMMY", "1" )

   ENDIF

   RETURN .T.
