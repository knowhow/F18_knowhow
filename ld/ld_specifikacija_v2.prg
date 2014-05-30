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



#include "ld.ch"


FUNCTION zadnji_dan_mjeseca( nMonth )

   LOCAL nDay := 0

   DO CASE
   CASE nMonth = 1
      nDay := 31
   CASE nMonth = 2
      nDay := 28
   CASE nMonth = 3
      nDay := 31
   CASE nMonth = 4
      nDay := 30
   CASE nMonth = 5
      nDay := 31
   CASE nMonth = 6
      nDay := 30
   CASE nMonth = 7
      nDay := 31
   CASE nMonth = 8
      nDay := 31
   CASE nMonth = 9
      nDay := 30
   CASE nMonth = 10
      nDay := 31
   CASE nMonth = 11
      nDay := 30
   CASE nMonth = 12
      nDay := 31
   ENDCASE

   RETURN nDay



FUNCTION prvi_dan_mjeseca( nMonth )

   LOCAL nDay := 1

   RETURN nDay



// ----------------------------------------------
// da li je radnik u republ.srpskoj
// gleda polje region "REG" iz opcina
// " " ili "1" = federacija
// "2" = rs
// ----------------------------------------------
FUNCTION radnik_iz_rs( cOpsst, cOpsrad )

   LOCAL lRet := .F.
   LOCAL nTArea := Select()

   O_OPS
   SELECT ops
   hseek cOpsst
   IF ops->reg == "2"
      lRet := .T.
   ENDIF
   SELECT ( nTArea )

   RETURN lRet


FUNCTION ld_specifikacija_plate()

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
   LOCAL cMatBr
   LOCAL _proizv_ini
   LOCAL _a_benef := {}
   LOCAL _omjer_zdravstvo, _omjer_nezap
   LOCAL nDopr1X
   LOCAL nDopr2X 
   LOCAL nDopr3X
   LOCAL nDopr5X
   LOCAL nDopr6X 
   LOCAL nDopr7X
   LOCAL nPojDoprI
   LOCAL nObrCount := 0

   PRIVATE aSpec := {}
   PRIVATE cFNTZ := "D"
   PRIVATE gPici := "9,999,999,999,999,999" + iif( gZaok > 0, PadR( ".", gZaok + 1, "9" ), "" )
   PRIVATE gPici2 := "9,999,999,999,999,999" + iif( gZaok2 > 0, PadR( ".", gZaok2 + 1, "9" ), "" )
   PRIVATE gPici3 := "999,999,999,999.99"

   _proizv_ini := my_home() + "proizvj.ini"

   FOR i := 1 TO nGrupaPoslova + 1
      // br.bodova, br.radnika, minuli rad, uneto
      AAdd( aSpec, { 0, 0, 0, 0 } )
   NEXT

   cIdRJ := "  "
   qqIDRJ := ""
   qqOpSt := ""

   nPorOlaksice := 0
   nBrutoOsnova := 0
   nMBrutoOsnova := 0
   nBrutoDobra := 0
   nBrutoOsBenef := 0
   nPojBrOsn := 0
   nPojBrBenef := 0
   nOstaleObaveze := 0
   nBolPreko := 0
   nPorezOstali := 0
   nObustave := 0
   nOstOb1 := 0
   nOstOb2 := 0
   nOstOb3 := 0
   nOstOb4 := 0
   nPorOsnovica := 0
   uNaRuke := 0

   nDanOd := prvi_dan_mjeseca( gMjesec )
   nMjesecOd := gMjesec
   nGodinaOd := gGodina
   nDanDo := zadnji_dan_mjeseca( gMjesec )
   nMjesecDo := gMjesec
   nGodinaDo := gGodina

   nMjesec := gMjesec
   nGodina := gGodina

   cObracun := gObracun
   cMRad := "17"
   cPorOl := "  "
   cBolPr := "  "

   ccOO1 := Space( 20 )
   ccOO2 := Space( 20 )
   ccOO3 := Space( 20 )
   ccOO4 := Space( 20 )
   cnOO1 := Space( 20 )
   cnOO2 := Space( 20 )
   cnOO3 := Space( 20 )
   cnOO4 := Space( 20 )

   cMatBr := PadR( "--", 13 )
   cDopr1 := "10"
   cDopr2 := "11"
   cDopr3 := "12"
   cDopr5 := "20"
   cDopr6 := "21"
   cDopr7 := "22"
   cDDoprPio := Space( 100 )
   cDDoprZdr := Space( 100 )
   cPrimDobra := Space( 100 )
   cDoprOO := ""
   cPorOO := ""
   cFirmNaz := Space( 35 )
   cFirmAdresa := Space( 35 )
   cFirmOpc := Space( 35 )
   cFirmVD := Space( 50 )
   cIsplata := "A"

   OSpecif()

   IF ( FieldPos( "DNE" ) <> 0 )
      GO TOP
      DO WHILE !Eof()
         AAdd( aOps, { id, dne, 0 } ) // sifra opstine, dopr.koje nema, neto
         SKIP 1
      ENDDO
      lPDNE := .T.
   ELSE
      lPDNE := .F.
   ENDIF

   cFirmNaz := fetch_metric( "org_naziv", nil, cFirmNaz )
   cFirmNaz := PadR( cFirmNaz, 35 )

   cFirmAdresa := fetch_metric( "ld_firma_adresa", nil, cFirmAdresa )
   cFirmAdresa := PadR( cFirmAdresa, 35 )

   cFirmOpc := fetch_metric( "ld_firma_opcina", nil, cFirmOpc )
   cFirmOpc := PadR( cFirmOpc, 35 )

   cFirmVD := fetch_metric( "ld_firma_vrsta_djelatnosti", nil, cFirmVD )
   cFirmVD := PadR( cFirmVD, 50 )

   cMRad := fetch_metric( "ld_specifikacija_minuli_rad", nil, cMRad )
   cPrimDobra := fetch_metric( "ld_specifikacija_primanja_dobra", nil, cPrimDobra )
   cDopr1 := fetch_metric( "ld_specifikacija_doprinos_1", nil, cDopr1 )
   cDopr2 := fetch_metric( "ld_specifikacija_doprinos_2", nil, cDopr2 )
   cDopr3 := fetch_metric( "ld_specifikacija_doprinos_3", nil, cDopr3 )
   cDopr5 := fetch_metric( "ld_specifikacija_doprinos_5", nil, cDopr5 )
   cDopr6 := fetch_metric( "ld_specifikacija_doprinos_6", nil, cDopr6 )
   cDopr7 := fetch_metric( "ld_specifikacija_doprinos_7", nil, cDopr7 )
   cDDoprPio := fetch_metric( "ld_specifikacija_doprinos_pio", nil, cDDoprPio )
   cDDoprZdr := fetch_metric( "ld_specifikacija_doprinos_zdr", nil, cDDoprZdr )
   cc001 := fetch_metric( "ld_specifikacija_c1", nil, ccOO1 )
   cc002 := fetch_metric( "ld_specifikacija_c2", nil, ccOO2 )
   cc003 := fetch_metric( "ld_specifikacija_c3", nil, ccOO3 )
   cc004 := fetch_metric( "ld_specifikacija_c4", nil, ccOO4 )
   cn001 := fetch_metric( "ld_specifikacija_n1", nil, cnOO1 )
   cn002 := fetch_metric( "ld_specifikacija_n2", nil, cnOO2 )
   cn003 := fetch_metric( "ld_specifikacija_n3", nil, cnOO3 )
   cn004 := fetch_metric( "ld_specifikacija_n4", nil, cnOO4 )
   qqIdRj := fetch_metric( "ld_specifikacija_rj", nil, qqIdRJ )
   qqOpSt := fetch_metric( "ld_specifikacija_opcine", nil, qqOpSt )
   qqIdRj := PadR( qqIdRj, 80 )
   qqOpSt := PadR( qqOpSt, 80 )

   _omjer_zdravstvo := fetch_metric( "ld_specifikacija_omjer_dopr_zdr", NIL, 10.2 )
   _omjer_nezap := fetch_metric( "ld_specifikacija_omjer_dopr_nezap", NIL, 30 )

   cIsplata := fetch_metric( "ld_specifikacija_vrsta_isplate", nil, cIsplata )

   cMatBr := fetch_metric( "ld_specifikacija_maticni_broj", nil, cMatBr )
   cMatBR := PadR( cMatBr, 13 )

   dDatIspl := Date()

   DO WHILE .T.
      Box(, 22 + IF( gVarSpec == "1", 0, 1 ), 75 )

      @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): " ;
         GET qqIdRJ PICT "@!S15"
      @ m_x + 1, Col() + 1 SAY "Djelatnost" GET cRTipRada ;
         VALID val_tiprada( cRTipRada ) PICT "@!"
      @ m_x + 1, Col() + 1 SAY "Spec.za RS" GET cRepSr ;
         VALID cRepSr $ "DN" PICT "@!"

      @ m_x + 2, m_y + 2 SAY "Opstina stanov.(prazno-sve): " ;
         GET qqOpSt PICT "@!S20"

      IF lViseObr
         @ m_x + 2, Col() + 1 SAY "Obr.:" GET cObracun ;
            WHEN HelpObr( .T., cObracun ) ;
            VALID ValObr( .T., cObracun )
      ENDIF

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


      @ m_x + 9, m_y + 2 SAY "Prim.u usl.ili dobrima (npr: 12;14;)" ;
         GET cPrimDobra  PICT "@!S20"

      @ m_x + 10, m_y + 2 SAY "Dopr.pio (iz)" GET cDopr1
      @ m_x + 10, Col() + 2 SAY "Dopr.pio (na)" GET cDopr5
      @ m_x + 11, m_y + 2 SAY "Dopr.zdr (iz)" GET cDopr2
      @ m_x + 11, Col() + 2 SAY "Dopr.zdr (na)" GET cDopr6
      @ m_x + 11, Col() + 1 SAY "Omjer dopr.zdr (%):" GET _omjer_zdravstvo PICT "999.99999"
      @ m_x + 12, m_y + 2 SAY "Dopr.nez (iz)" GET cDopr3
      @ m_x + 12, Col() + 2 SAY "Dopr.nez (na)" GET cDopr7
      @ m_x + 12, Col() + 1 SAY "Omjer dopr.nez (%):" GET _omjer_nezap PICT "999.99999"

      @ m_x + 13, m_y + 2 SAY "Dod.dopr.pio" GET cDDoprPio PICT "@S35"
      @ m_x + 14, m_y + 2 SAY "Dod.dopr.zdr" GET cDDoprZdr PICT "@S35"

      @ m_x + 15, m_y + 2 SAY "Ost.obaveze: NAZIV                  USLOV"
      @ m_x + 16, m_y + 2 SAY " 1." GET ccOO1
      @ m_x + 16, m_y + 30 GET cnOO1
      @ m_x + 17, m_y + 2 SAY " 2." GET ccOO2
      @ m_x + 17, m_y + 30 GET cnOO2
      @ m_x + 18, m_y + 2 SAY " 3." GET ccOO3
      @ m_x + 18, m_y + 30 GET cnOO3
      @ m_x + 19, m_y + 2 SAY " 4." GET ccOO4
      @ m_x + 19, m_y + 30 GET cnOO4

      @ m_x + 21, m_y + 2 SAY "Isplata: 'A' doprinosi+porez, 'B' samo doprinosi, 'C' samo porez" GET cIsplata VALID cIsplata $ "ABC" PICT "@!"

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
   set_metric( "ld_specifikacija_minuli_rad", nil, cMRad )
   set_metric( "ld_specifikacija_primanja_dobra", nil, cPrimDobra )
   set_metric( "ld_specifikacija_doprinos_1", nil, cDopr1 )
   set_metric( "ld_specifikacija_doprinos_2", nil, cDopr2 )
   set_metric( "ld_specifikacija_doprinos_3", nil, cDopr3 )
   set_metric( "ld_specifikacija_doprinos_5", nil, cDopr5 )
   set_metric( "ld_specifikacija_doprinos_6", nil, cDopr6 )
   set_metric( "ld_specifikacija_doprinos_7", nil, cDopr7 )
   set_metric( "ld_specifikacija_doprinos_pio", nil, cDDoprPio )
   set_metric( "ld_specifikacija_doprinos_zdr", nil, cDDoprZdr )
   set_metric( "ld_specifikacija_c1", nil, ccOO1 )
   set_metric( "ld_specifikacija_c2", nil, ccOO2 )
   set_metric( "ld_specifikacija_c3", nil, ccOO3 )
   set_metric( "ld_specifikacija_c4", nil, ccOO4 )
   set_metric( "ld_specifikacija_n1", nil, cnOO1 )
   set_metric( "ld_specifikacija_n2", nil, cnOO2 )
   set_metric( "ld_specifikacija_n3", nil, cnOO3 )
   set_metric( "ld_specifikacija_n4", nil, cnOO4 )
   set_metric( "ld_specifikacija_vrsta_isplate", nil, cIsplata )
   set_metric( "ld_specifikacija_omjer_dopr_zdr", NIL, _omjer_zdravstvo )
   set_metric( "ld_specifikacija_omjer_dopr_nezap", NIL, _omjer_nezap )

   qqIdRj := Trim( qqIdRj )
   qqOpSt := Trim( qqOpSt )

   set_metric( "ld_specifikacija_rj", nil, qqIdRJ )
   set_metric( "ld_specifikacija_opcine", nil, qqOpSt )

   set_metric( "ld_specifikacija_maticni_broj", nil, cMatBr )

   PoDoIzSez( nGodina, nMjesec )

   cIniName := _proizv_ini

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

   cDoprOO1 := Izrezi( "D->", 2, @cnOO1 )
   cDoprOO2 := Izrezi( "D->", 2, @cnOO2 )
   cDoprOO3 := Izrezi( "D->", 2, @cnOO3 )
   cDoprOO4 := Izrezi( "D->", 2, @cnOO4 )

   // dodatni doprinos pio
   cDodDoprP := Izrezi( "D->", 2, @cDDoprPio )
   // dodatni doprinos zdr
   cDodDoprZ := Izrezi( "D->", 2, @cDDoprZdr )

   ParObr( nMjesec, nGodina, cObracun, Left( qqIdRJ, 2 ) )

   SELECT LD
   SET ORDER TO TAG ( TagVO( "2" ) )

   PRIVATE cFilt := ".t."

   IF !Empty( qqIdRJ )
      cFilt += ( ".and." + aUslRJ )
   ENDIF

   IF !Empty( cObracun )
      cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
   ENDIF

   SET FILTER TO &cFilt

   GO TOP
   HSEEK Str( nGodina, 4 ) + Str( nMjesec, 2 )

   IF !Found()
      MsgBeep( "Obracun za ovaj mjesec ne postoji !" )
      my_close_all_dbf()
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

   DO WHILE Str( nGodina, 4 ) + Str( nMjesec, 2 ) == Str( godina, 4 ) + Str( mjesec, 2 )

      SELECT RADN
      HSEEK LD->idradn
      cRTR := g_tip_rada( ld->idradn, ld->idrj )
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

      IF ! ( RADN->( &aUslOpSt ) )
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
         IF Len( aPom ) < 1 .OR. ( nPom := AScan( aPom, {| x| x[ 1 ] == LD->brbod } ) ) == 0
            AAdd( aPom, { LD->brbod, 1, nP77, LD->uneto } )
         ELSE
            IF ! ( lViseObr .AND. Empty( cObracun ) .AND. LD->obr $ "23456789" )
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
      nPojBrOsn := bruto_osn( nNetoOsn, cRTR, nKoefLO, nRSpr_koef )

      // pojedinacni bruto - dobra ili usluge
      nPojBrDobra := 0
      IF nPrDobra > 0
         nPojBrDobra := bruto_osn( nPrDobra, cRTR, nKoefLO, nRSpr_koef )
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
      IF UBenefOsnovu()

         cFFTmp := gBFForm
         gBFForm := StrTran( gBFForm, "_", "" )

         nPojBrBenef := bruto_osn( nNetoOsn - IF( !Empty( gBFForm ), &gBFForm, 0 ), cRTR, nKoefLO, nRSpr_koef )

         nBrutoOsBenef += nPojBrBenef

         _benef_st := BenefStepen()
         add_to_a_benef( @_a_benef, AllTrim( radn->k3 ), _benef_st, nPojBrBenef )

         gBFForm := cFFtmp

      ENDIF

      nPom := nMBrutoOsnova

      nkDopZX := 0
      nkDopPX := 0

      UzmiIzIni( cIniName, 'Varijable', 'U017', FormNum2( nPom, 16, gPici2 ), 'WRITE' )

      SELECT DOPR
      GO TOP

      DO WHILE !Eof()

         IF DOPR->poopst == "1" .AND. lPDNE
            nBOO := 0
            FOR i := 1 TO Len( aOps )
               IF ! ( DOPR->id $ aOps[ i, 2 ] )
                  nBOO += aOps[ i, 3 ]
               ENDIF
            NEXT
            nBOO := bruto_osn( nBOO, cRTR, nKoefLO )
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
      SELECT POR
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
         nOps := AScan( aOps, {| x| x[ 1 ] == RADN->idopsst } )
         IF nOps > 0
            aOps[ nOps, 3 ] += Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 )
         ELSE
            AAdd( aOps, { RADN->idopsst, "", Max( ld->uneto, PAROBR->prosld * gPDLimit / 100 ) } )
         ENDIF
      ENDIF
      
      ++ nObrCount

      SKIP 1

   ENDDO

   IF nObrCount == 0
      MsgBeep( "Štampa specifikacije nije moguća, nema obračuna !" )
      RETURN .T.
   ENDIF

   nPorNaPlatu := round2( nPorNaPlatu, gZaok2 )

   // obustave iz place
   UzmiIzIni( cIniName, 'Varijable', 'O18I', FormNum2( -nObustave, 16, gPici2 ), 'WRITE' )

   // Ostale obaveze = OstaleObaveze.1

   ASort( aPom, , , {| x, y| x[ 1 ] > y[ 1 ] } )
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
   UzmiIzIni( cIniName, 'Varijable', 'U016', Str( nURadnika, 0 ),'WRITE' )
   // ukupno neto
   UzmiIzIni( cIniName, 'Varijable', 'U018', FormNum2( nUNETO, 16, gPici2 ), 'WRITE' )
   UzmiIzIni( cIniName, 'Varijable', 'D13N', " ", 'WRITE' )

   SELECT POR
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

   IF IzFmkIni( 'LD', 'BolPreko42IzbaciIz19', 'N', KUMPATH ) == 'D'
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
   nPom := nPom2 * ( _omjer_zdravstvo / 100 )
   nD21a := nPom
   UzmiIzIni( cIniName, 'Varijable', 'D21a', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   // nezaposlenost iz + nezaposlenost na placu
   nPom := nDopr3x + nDopr7x
   nPom2 := nPom
   UzmiIzIni( cIniName, 'Varijable', 'D22', FormNum2( _ispl_d( nPom, cIsplata ), 16, gPici2 ), 'WRITE' )

   // nezaposlenost za RS
   nPom := nPom2 * ( _omjer_nezap / 100 )
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
      cSpecRtm := cSpecRtm + cRTipRada

      // stampaj specifikaciju
      f18_rtm_print( AllTrim( cSpecRtm ), "DUMMY", "1" )

   ENDIF

   RETURN .T.


// ---------------------------------------------
// isplata doprinosa, kontrola iznosa
// ---------------------------------------------
FUNCTION _ispl_d( nIzn, cIspl )

   IF cIspl $ "AB"
      RETURN nIzn
   ELSE
      RETURN 0
   ENDIF

   RETURN

// ---------------------------------------------
// isplata poreza, kontrola iznosa
// ---------------------------------------------
FUNCTION _ispl_p( nIzn, cIspl )

   IF cIspl $ "AC"
      RETURN nIzn
   ELSE
      RETURN 0
   ENDIF

   RETURN
