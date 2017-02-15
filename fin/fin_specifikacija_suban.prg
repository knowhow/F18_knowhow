 /*
  * This file is part of the bring.out FMK, a free and open source
  * accounting software suite,
  * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
  * It is licensed to you under the Common Public Attribution License
  * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
  * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
  * root directory of this source code archive.
  * By using this software, you agree to be bound by its terms.
  */

#include "f18.ch"

MEMVAR gPicBHD, picBHD, qqKonto, qqPartner, qqBrDok
// MEMVAR gDUFRJ
MEMVAR cIdFirma, cIdRj, dDatOd, dDatDo, cFunk, cFond, cNula
MEMVAR cSkVar, cRasclaniti, cRascFunkFond, cN2Fin
MEMVAR cFilter
MEMVAR fK1, fK2, fK3, fK4, cK1, cK2, cSection, cHistory, aHistory

FIELD idkonto, idpartner, idrj

FUNCTION fin_specifikacija_suban()

   LOCAL cSK := "N"
   LOCAL cLDrugi := ""
   LOCAL cPom := ""
   LOCAL nCOpis := 0
   LOCAL cLTreci := ""
   LOCAL cIzr1
   LOCAL cIzr2
   LOCAL cExpRptDN := "N"
   LOCAL cOpcine := Space( 20 )
   LOCAL cVN := Space( 20 )
   LOCAL bZagl :=  {|| zagl_fin_specif( cSkVar ) }
   LOCAL oPDF, xPrintOpt
   LOCAL cSqlWhere

   LOCAL nC
   PRIVATE cSkVar := "N"
   PRIVATE fK1 := fk2 := fk3 := fk4 := "N"
   PRIVATE cRasclaniti := "N"
   PRIVATE cRascFunkFond := "N"
   PRIVATE cN2Fin := "N" // cN2Fin := my_get_from_ini( 'FIN', 'PartnerNaziv2', 'N' )

   nC := 50

   o_params()
   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "k1", @fk1 )
   RPar( "k2", @fk2 )
   RPar( "k3", @fk3 )
   RPar( "k4", @fk4 )
   SELECT params
   USE

   cIdFirma := self_organizacija_id()
   picBHD := FormPicL( "9 " + gPicBHD, 20 )

   qqKonto := qqPartner := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   o_params()

   PRIVATE cSection := "S"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "qK", @qqKonto )
   RPar( "qP", @qqPartner )
   RPar( "d1", @dDatoD )
   RPar( "d2", @dDatDo )

   qqkonto := PadR( qqKonto, 100 )
   qqPartner := PadR( qqPartner, 100 )
   qqBrDok := Space( 40 )

   SELECT params
   USE

   // o_partner()

   cTip := "1"
   Box( "", 20, 65 )
   SET CURSOR ON
   PRIVATE cK1 := cK2 := "9"
   PRIVATE cK3 := cK4 := "99"



   cIdRj := "999999"

   cFunk := "99999"
   cFond := "9999"
   cNula := "N"
   DO WHILE .T.
      @ form_x_koord() + 1, form_y_koord() + 6 SAY8 "SPECIFIKACIJA SUBANALITIČKIH KONTA"

      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Firma "
      ?? self_organizacija_id(), "-", self_organizacija_naziv()

      @ form_x_koord() + 4, form_y_koord() + 2 SAY "Konto   " GET qqKonto  PICT "@!S50"
      @ form_x_koord() + 5, form_y_koord() + 2 SAY "Partner " GET qqPartner PICT "@!S50"
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Datum dokumenta od" GET dDatOd
      @ form_x_koord() + 6, Col() + 2 SAY "do" GET dDatDo
      IF fin_dvovalutno()
         @ form_x_koord() + 7, form_y_koord() + 2 SAY "Obracun za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + "/" + AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) + " (1/2/3):" GET cTip VALID ctip $ "123"
      ELSE
         cTip := "1"
      ENDIF

      @ form_x_koord() + 8, form_y_koord() + 2 SAY8 "Prikaz sintetičkih konta (D/N) ?" GET cSK  PICT "@!" VALID csk $ "DN"
      @ form_x_koord() + 9, form_y_koord() + 2 SAY "Prikaz stavki sa saldom 0 D/N" GET cNula PICT "@!" VALID cNula  $ "DN"
      @ form_x_koord() + 10, form_y_koord() + 2 SAY "Skracena varijanta (D/N) ?" GET cSkVar PICT "@!" VALID cSkVar $ "DN"
      @ form_x_koord() + 11, form_y_koord() + 2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"
      @ form_x_koord() + 12, form_y_koord() + 2 SAY "Uslov za vrstu naloga (prazno-svi) " GET cVN PICT "@!S20"

      cRasclaniti := "N"

      IF gFinRj == "D"
         @ form_x_koord() + 13, form_y_koord() + 2 SAY "Rasclaniti po RJ (D/N) "  GET cRasclaniti PICT "@!" VALID cRasclaniti $ "DN"
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Rasclaniti po RJ/FUNK/FOND? (D/N) "  GET cRascFunkFond PICT "@!" VALID cRascFunkFond $ "DN"
      ENDIF

      @ form_x_koord() + 15, form_y_koord() + 2 SAY8 "Općina (prazno-sve):" GET cOpcine

      UpitK1k4( 16 )

      @ form_x_koord() + 19, form_y_koord() + 2 SAY "Export izvjestaja u dbf (D/N) ?" GET cExpRptDN PICT "@!" VALID cExpRptDN $ "DN"

      READ
      ESC_BCR
      o_params()
      PRIVATE cSection := "S"
      PRIVATE cHistory := " "
      PRIVATE aHistory := {}
      WPar( "qK", qqKonto )
      WPar( "qP", qqPartner )
      WPar( "d1", dDatoD )
      WPar( "d2", dDatDo )
      SELECT params
      USE

      cSqlWhere := parsiraj_sql( "idkonto", qqKonto )
      cSqlWhere += " AND " + parsiraj_sql( "idpartner", Trim( qqPartner ) )

      aBV := Parsiraj( qqBrDok, "UPPER(BRDOK)", "C" )
      aVN := Parsiraj( cVN, "IDVN", "C" )
      IF aBV <> NIL .AND. aVN <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   lExpRpt := ( cExpRptDN == "D" )

   IF lExpRpt
      aSSFields := get_ss_fields( gFinRj, FIELD_PARTNER_ID_LENGTH )
      create_dbf_r_export( aSSFields )
   ENDIF


   cIdFirma := Left( cIdFirma, 2 )


   // IF cRasclaniti == "D"
   // o_rj()
   // ENDIF

   // o_partner()
   o_konto()
   MsgO( "Preuzimanje podataka sa SQL servera ..." )
   find_suban_za_period( cIdFirma, dDatOd, dDatDo, "idfirma,idkonto,idpartner,brdok", cSqlWhere )
   Msgc()

   CistiK1k4()

   SELECT SUBAN

   IF cRasclaniti == "D"
      INDEX ON idfirma + idkonto + idpartner + idrj + DToS( datdok ) TO SUBSUB
      SET ORDER TO TAG "SUBSUB"
   ELSEIF cRascFunkFond == "D"
      INDEX ON idfirma + idkonto + idpartner + idrj + funk + fond + DToS( datdok ) TO SUBSUB
      SET ORDER TO TAG "SUBSUB"

   ELSE
      SET ORDER TO TAG "1" // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr
   ENDIF


   cFilter := "IdFirma=" + dbf_quote( cidfirma )


   IF !Empty( cVN )
      cFilter += ( ".and. " + aVN )
   ENDIF

   IF !Empty( qqBrDok )
      cFilter += ( ".and." + aBV )
   ENDIF


   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilter += ( ".and. DATDOK>=" + dbf_quote( dDatOd ) + ".and. DATDOK<=" + dbf_quote( dDatDo ) )
   ENDIF

   IF fk1 == "D" .AND. Len( ck1 ) <> 0
      cFilter += ( ".and. k1='" + ck1 + "'" )
   ENDIF

   IF fk2 == "D" .AND. Len( ck2 ) <> 0
      cFilter += ( ".and. k2='" + ck2 + "'" )
   ENDIF

   IF fk3 == "D" .AND. Len( ck3 ) <> 0
      cFilter += ( ".and. k3='" + ck3 + "'" )
   ENDIF

   IF fk4 == "D" .AND. Len( ck4 ) <> 0
      cFilter += ( ".and. k4='" + ck4 + "'" )
   ENDIF

   IF gFinRj == "D" .AND. Len( cIdrj ) <> 0

      cFilter += ( ".and. idrj='" + cIdRj + "'" )

   ENDIF

   IF gTroskovi == "D" .AND. Len( cFunk ) <> 0
      cFilter += ( ".and. Funk='" + cFunk + "'" )
   ENDIF

   IF gTroskovi == "D" .AND. Len( cFond ) <> 0
      cFilter += ( ".and. Fond='" + cFond + "'" )
   ENDIF

   SET FILTER TO &cFilter

   GO TOP
   EOF CRET

   Pic := PicBhd

   IF !is_legacy_ptxt()
      oPDF := PDFClass():New()
      xPrintOpt := hb_Hash()
      xPrintOpt[ "tip" ] := "PDF"
      xPrintOpt[ "layout" ] := "portrait"
      xPrintOpt[ "font_size" ] := 7
      xPrintOpt[ "opdf" ] := oPDF
      xPrintOpt[ "left_space" ] := 0
   ENDIF

   IF !start_print( xPrintOpt )
      RETURN .F.
   ENDIF

   IF cSkVar == "D"
      nDOpis := 25
      nDIznos := 12
      pic := Right( picbhd, nDIznos )
   ELSE
      nDOpis := 50
      nDIznos := 20
   ENDIF

   IF cTip == "3"
      m := "------- " + Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " " + REPL( "-", nDOpis ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos )
   ELSE
      m := "------- " + Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " " + REPL( "-", nDOpis ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos )
   ENDIF

   nStr := 0

   nUd := 0
   nUp := 0      // DIN
   nUd2 := 0
   nUp2 := 0    // DEM

   Eval( bZagl )

   DO WHILE !Eof()

      cSin := Left( field->idkonto, 3 )
      nKd := 0
      nKp := 0
      nKd2 := 0
      nKp2 := 0

      DO WHILE !Eof() .AND.  cSin == Left( fiel->idkonto, 3 )

         nTArea := Select()

         cIdKonto := IdKonto
         cIdPartner := field->idPartner

         IF !Empty( cOpcine )
            select_o_partner( cIdPartner )
            IF AllTrim( field->idops ) $ cOpcine
               // to je taj partner...
            ELSE
               // posto nije to taj preskoci...
               SELECT ( nTArea )
               SKIP
               LOOP
            ENDIF
         ENDIF

         SELECT ( nTArea )

         nD := 0
         nP := 0
         nD2 := 0
         nP2 := 0

         IF cRasclaniti == "D"
            cRasclan := idrj
         ELSE
            cRasclan := ""
         ENDIF
         check_nova_strana( bZagl, oPDF )

         IF cRascFunkFond == "D"
            aRasclan := {}
            nDugujeBHD := 0
            nPotrazujeBHD := 0
         ENDIF
         DO WHILE !Eof() .AND. cIdKonto == IdKonto .AND. field->IdPartner == cIdPartner .AND. RasclanRJ()
            IF cRascFunkFond == "D"
               cGetFunkFond := idrj + funk + fond
               cGetIdRj := idrj
               cGetFunk := funk
               cGetFond := fond
            ENDIF
            // racuna duguje/potrazuje
            IF d_P == "1"
               nD += field->iznosbhd
               nD2 += iznosdem
               IF cRascFunkFond == "D"
                  nDugujeBHD := field->iznosbhd
               ENDIF
            ELSE
               nP += field->iznosbhd
               nP2 += iznosdem
               IF cRascFunkFond == "D"
                  nPotrazujeBHD := field->iznosbhd
               ENDIF
            ENDIF

            SKIP 1

            IF cRascFunkFond == "D" .AND. cGetFunkFond <> idrj + funk + fond
               AAdd( aRasclan, { cGetIdRj, cGetFunk, cGetFond, nDugujeBHD, nPotrazujeBHD } )
               nDugujeBHD := 0
               nPotrazujeBHD := 0
            ENDIF
         ENDDO
         check_nova_strana( bZagl, oPDF )
         IF cNula == "D" .OR. Round( nd - np, 3 ) <> 0 .AND. cTip $ "13" .OR. Round( nd2 - np2, 3 ) <> 0 .AND. cTip $ "23"
            ? cIdKonto, IdPartner( cIdPartner ), ""
            IF cRasclaniti == "D"
               SELECT RJ
               SEEK Left( cRasclan, Len( SUBAN->idrj ) )
               SELECT SUBAN
               IF !Empty( Left( cRasclan, Len( SUBAN->idrj ) ) )
                  cLTreci := "RJ:" + Left( cRasclan, Len( SUBAN->idrj ) ) + "-" + Trim( RJ->naz )
               ENDIF

            ENDIF
            nCOpis := PCol()
            // ispis partnera
            IF !Empty( cIdPartner )
               select_o_partner( cIdPartner )
               SELECT SUBAN
               IF gVSubOp == "D"
                  select_o_konto( cIdKonto )
                  SELECT SUBAN
                  cPom := AllTrim( KONTO->naz ) + " (" + AllTrim( AllTrim( PARTN->naz ) + PN2() ) + ")"
                  ?? PadR( cPom, nDOpis - DifIdP( cIdpartner ) )
                  IF Len( cPom ) > nDOpis - DifIdP( cIdpartner )
                     cLDrugi := SubStr( cPom, nDOpis + 1 )
                  ENDIF
               ELSE
                  cPom := AllTrim( PARTN->naz ) + PN2()
                  IF !Empty( partn->mjesto )
                     IF Right( Trim( Upper( partn->naz ) ), Len( Trim( partn->mjesto ) ) ) != Trim( Upper( partn->mjesto ) )
                        cPom := Trim( AllTrim( partn->naz ) + PN2() ) + " " + Trim( partn->mjesto )
                        aTxt := Sjecistr( cPom, nDOpis )
                        cPom := aTxt[ 1 ]
                        IF Len( aTxt ) > 1
                           cLDrugi := aTxt[ 2 ]
                        ENDIF
                     ENDIF
                  ENDIF
                  ?? PadR( cPom, nDOpis )
               ENDIF
            ELSE
               select_o_konto( cIdKonto )
               SELECT SUBAN
               ?? PadR( KONTO->naz, nDOpis )
            ENDIF
            nC := PCol() + 1
            // ispis duguje/potrazuje/saldo
            IF cTip == "1"
               @ PRow(), PCol() + 1 SAY nD PICT pic
               @ PRow(), PCol() + 1 SAY nP PICT pic
               @ PRow(), PCol() + 1 SAY nD - nP PICT pic
            ELSEIF cTip == "2"
               @ PRow(), PCol() + 1 SAY nD2 PICT pic
               @ PRow(), PCol() + 1 SAY nP2 PICT pic
               @ PRow(), PCol() + 1 SAY nD2 - nP2 PICT pic
            ELSE
               @ PRow(), PCol() + 1 SAY nD - nP PICT pic
               @ PRow(), PCol() + 1 SAY nD2 - nP2 PICT pic
            ENDIF

            IF lExpRpt
               IF gFinRj == "D" .AND. cRasclaniti == "D"

                  cRj_id := cRasclan

                  IF !Empty( cRj_id )
                     cRj_naz := rj->naz
                  ELSE
                     cRj_naz := ""
                  ENDIF

               ELSE
                  cRj_id := nil
                  cRj_naz := nil
               ENDIF

               fill_ss_tbl( cIdKonto, cIdPartner, iif( Empty( cIdPartner ), konto->naz, AllTrim( partn->naz ) ), nD, nP, nD - nP, cRj_id, cRj_naz )
            ENDIF

            nKd += nD
            nKp += nP  // ukupno  za klasu
            nKd2 += nD2
            nKp2 += nP2  // ukupno  za klasu
         ENDIF // cnula
         IF Len( cLDrugi ) > 0
            @ PRow() + 1, nCOpis SAY cLDrugi
            cLDrugi := ""
         ENDIF
         IF Len( cLTreci ) > 0
            @ PRow() + 1, nCOpis SAY cLTreci
            cLTreci := ""
         ENDIF

         IF cRascFunkFond == "D" .AND. Len( aRasclan ) > 0
            @ PRow() + 1, nCOpis SAY Replicate( "-", 113 )
            FOR i := 1 TO Len( aRasclan )
               @ PRow() + 1, nCOpis SAY "RJ: " + aRasclan[ i, 1 ] + ", FUNK: " + aRasclan[ i, 2 ] + ", FOND: " + aRasclan[ i, 3 ] + ": "
               @ PRow(), PCol() + 15 SAY aRasclan[ i, 4 ] PICT pic
               @ PRow(), PCol() + 1 SAY aRasclan[ i, 5 ] PICT pic
               @ PRow(), PCol() + 1 SAY aRasclan[ i, 4 ] - aRasclan[ i, 5 ] PICT pic
            NEXT
            @ PRow() + 1, nCOpis SAY Replicate( "-", 113 )
         ENDIF

      ENDDO  // sintetika
      check_nova_strana( bZagl, oPDF )
      IF cSK == "D"
         ? m
         ?  "SINT.K.", cSin, ":"
         IF cTip == "1"
            @ PRow(), nC SAY nKd PICT pic
            @ PRow(), PCol() + 1 SAY nKp PICT pic
            @ PRow(), PCol() + 1 SAY nKd - nKp PICT pic
         ELSEIF cTip == "2"
            @ PRow(), nC SAY nKd2 PICT pic
            @ PRow(), PCol() + 1 SAY nKp2 PICT pic
            @ PRow(), PCol() + 1 SAY nKd2 - nKp2 PICT pic
         ELSE
            @ PRow(), nC SAY nKd - nKP PICT pic
            @ PRow(), PCol() + 1 SAY nKd2 - nKP2 PICT pic
         ENDIF
         ? m
      ENDIF
      nUd += nKd
      nUp += nKp   // ukupno za sve
      nUd2 += nKd2
      nUp2 += nKp2   // ukupno za sve
   ENDDO

   check_nova_strana( bZagl, oPDF )


   ? m
   ? " UKUPNO:"
   IF cTip == "1"
      @ PRow(), nC       SAY nUd PICT pic
      @ PRow(), PCol() + 1 SAY nUp PICT pic
      @ PRow(), PCol() + 1 SAY nUd - nUp PICT pic
   ELSEIF cTip == "2"
      @ PRow(), nC       SAY nUd2 PICT pic
      @ PRow(), PCol() + 1 SAY nUp2 PICT pic
      @ PRow(), PCol() + 1 SAY nUd2 - nUp2 PICT pic
   ELSE
      @ PRow(), nC       SAY nUd - nUP PICT pic
      @ PRow(), PCol() + 1 SAY nUd2 - nUP2 PICT pic
   ENDIF

   IF lExpRpt
      fill_ss_tbl( "UKUPNO", "", "", nUD, nUP, nUD - nUP )
   ENDIF

   ? m
   IF is_legacy_ptxt()
      FF
   ENDIF
   end_print( xPrintOpt )

   IF lExpRpt
      open_r_export_table()
   ENDIF

   closeret





/* getmjesto(cMjesto)
 *
 *   param: cMjesto
 */

FUNCTION getmjesto( cMjesto )

   LOCAL fRet
   LOCAL nSel := Select()

   select_o_partner( ( nSel )->idpartner )
   fRet := .F.
   IF mjesto = cMjesto
      fRet := .T.
   ENDIF
   SELECT ( nSel )

   RETURN fRet



/*  Funkcija koju koristi print_lista_2()
 */

STATIC FUNCTION FFor1()

   cIdP := IDPARTNER

   ukPartner := 0
   FOR i := 1 TO Len( aGod )
      cPom7777 := "ukGOD" + aGod[ i, 1 ]
      &cPom7777 := 0
   NEXT
   cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) - 1, 4 )
   &cPom7777 := 0
   cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) - 2, 4 )
   &cPom7777 := 0

   DO WHILE !Eof() .AND. IDPARTNER == cIdP
      FOR i := 1 TO Len( aGod )
         cPom7777 := "ukGOD" + aGod[ i, 1 ]
         cPom7778 := SubStr( cPom7777, 3 )
         &cPom7777 += &cPom7778
         ukPartner += &cPom7778
      NEXT
      cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) - 1, 4 )
      cPom7778 := SubStr( cPom7777, 3 )
      &cPom7777 += &cPom7778
      ukPartner += &cPom7778
      cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) - 2, 4 )
      cPom7778 := SubStr( cPom7777, 3 )
      &cPom7777 += &cPom7778
      ukPartner += &cPom7778
      SKIP 1
   ENDDO
   SKIP -1

   RETURN .T.



STATIC FUNCTION FSvaki1()

   ++nRbr
   cNPartnera := PadR( Ocitaj( F_PARTN, IDPARTNER, "naz" ), 25 )

   RETURN .T.



/* fn fin_specif_zagl6
 *  brief Zaglavlje specifikacije
 *  param cSkVar
 */

FUNCTION zagl_fin_specif( cSkVar )

   ?
   IF is_legacy_ptxt()

      B_ON
      P_COND
   ENDIF

   ??U "FIN: SPECIFIKACIJA SUBANALITIČKIH KONTA  ZA "

   IF cTip == "1"
      ?? ValDomaca()
   ELSEIF cTip == "2"
      ?? ValPomocna()
   ELSE
      ?? AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() )
   ENDIF

   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "  ZA DOKUMENTE U PERIODU ", dDatOd, "-", dDatDo
   ENDIF

   ?? " NA DAN: "; ?? Date()
   IF !Empty( qqBrDok )
      ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '" + Trim( qqBrDok ) + "'"
   ENDIF

   IF is_legacy_ptxt()
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
      B_OFF
   ENDIF

   IF gNW == "D"
      ? "Firma:", self_organizacija_id(), self_organizacija_naziv()
   ELSE
      IF Empty( cIdFirma )
         ? "Firma:", self_organizacija_naziv(), "(SVE RJ)"
      ELSE
         select_o_partner( cIdFirma )
         ? "Firma:", cIdfirma, PadR( partn->naz, 25 ), partn->naz2
      ENDIF
   ENDIF

   ?
   prikaz_k1_k4_rj()

   SELECT SUBAN

   IF is_legacy_ptxt()
      IF cSkVar == "D"
         F12CPI
      ELSE
         P_COND
      ENDIF
   ENDIF

   ? m

   IF cTip $ "12"
      IF cSkVar != "D"
         ? "KONTO  " + PadC( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + "  NAZIV KONTA / PARTNERA                                          duguje            potrazuje                saldo"
      ELSE
         ? "KONTO  " + PadC( "PARTN", FIELD_PARTNER_ID_LENGTH ) + "  " +  PadR( "NAZIV KONTA / PARTNERA", nDOpis ) + " " + PadC( "duguje", nDIznos ) + " " + PadC( "potrazuje", nDIznos ) + " " + PadC( "saldo", nDIznos )
      ENDIF
   ELSE
      IF cSkVar != "D"
         ? "KONTO  " + PadC( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + "  NAZIV KONTA / PARTNERA                                       saldo " + ValDomaca() + "           saldo " + AllTrim( ValPomocna() )
      ELSE
         ? "KONTO  " + PadC( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + "  " + PadR( "NAZIV KONTA / PARTNERA", nDOpis ) + " " + PadC( "saldo " + ValDomaca(), nDIznos ) + " " + PadC( "saldo " + AllTrim( ValPomocna() ), nDIznos )
      ENDIF
   ENDIF
   ? m

   RETURN .T.




STATIC FUNCTION fill_ss_tbl( cKonto, cPartner, cNaziv, nFDug, nFPot, nFSaldo, cRj, cRjNaz )

   LOCAL nArr

   nArr := Select()

   O_R_EXP
   APPEND BLANK
   REPLACE field->konto WITH cKonto
   REPLACE field->partner WITH cPartner
   REPLACE field->naziv WITH cNaziv
   REPLACE field->duguje WITH nFDug
   REPLACE field->potrazuje WITH nFPot
   REPLACE field->saldo WITH nFSaldo

   IF cRj <> nil
      REPLACE field->rj WITH cRj
      REPLACE field->rjnaziv WITH cRjNaz
   ENDIF

   SELECT ( nArr )

   RETURN .T.


// vraca matricu sa sub.bb poljima
STATIC FUNCTION get_ss_fields( cRj, nPartLen )

   IF cRj == nil
      cRj := "N"
   ENDIF
   IF nPartLen == nil
      nPartLen := 6
   ENDIF

   aFields := {}
   AAdd( aFields, { "konto", "C", 7, 0 } )
   AAdd( aFields, { "partner", "C", nPartLen, 0 } )
   AAdd( aFields, { "naziv", "C", 40, 0 } )

   IF cRj == "D"
      AAdd( aFields, { "rj", "C", 10, 0 } )
      AAdd( aFields, { "rjnaziv", "C", 40, 0 } )
   ENDIF

   AAdd( aFields, { "duguje", "N", 15, 2 } )
   AAdd( aFields, { "potrazuje", "N", 15, 2 } )
   AAdd( aFields, { "saldo", "N", 15, 2 } )

   RETURN aFields
