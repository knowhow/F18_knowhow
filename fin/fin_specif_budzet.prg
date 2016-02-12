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



FUNCTION IzvrsBudz()

   LOCAL cLM := Space ( 5 )
   LOCAL fKraj
   LOCAL n
   PRIVATE picBHD := FormPicL( gPicBHD, 15 )
   PRIVATE picDEM := FormPicL( gPicDEM, 12 )
   PRIVATE cIdKonto
   PRIVATE cIdFirma := Space( Len( gFirma ) )
   PRIVATE cIdRj := Space( 50 )
   PRIVATE cFunk := Space( 60 )
   PRIVATE dDatOd := CToD( "" )
   PRIVATE dDatDo := Date()
   PRIVATE aUslK
   PRIVATE aUslRj
   PRIVATE aUslFunk
   PRIVATE cSpecKonta
   PRIVATE nProc := 0
   PRIVATE cBuIz := "N"
   PRIVATE cPeriod := PadR( "JANUAR - ", 40 )

   PRIVATE nKorRed1 := Val( IzFmkIni( "FinBudzet", "KorRed1", "0", KUMPATH ) )
   PRIVATE nKorRed2 := Val( IzFmkIni( "FinBudzet", "KorRed2", "0", KUMPATH ) )
   PRIVATE nKorRed3 := Val( IzFmkIni( "FinBudzet", "KorRed3", "0", KUMPATH ) )
   PRIVATE nKorRed4 := Val( IzFmkIni( "FinBudzet", "KorRed4", "0", KUMPATH ) )

   cIdKonto := PadR( "6;", 60 )
   cSpecKonta := PadR( "", 60 )

   cI1 := "D"
   cI2 := "D"
   cI3 := "D"
   cI4 := "D"

   cSTKI1 := "N"
   cProv := "D"

   PRIVATE cBRZaZ := PadR( IzFMKIni( 'BUDZET', 'BrRedZaZagl', '0', KUMPATH ), 2 )

   IF gBuIz == "D"
      O_BUIZ
   ENDIF
   O_PARTN

   DO WHILE .T.

      Box (, 22, 75 )  // 19
      @ m_x, m_y + 15 SAY "IZVRSENJE BUDZETA / PREGLED RASHODA"

      // procenat ucesca perioda u godisnjem planu
      IF gNW == "D"
         cIdFirma := gFirma
         @ m_x + 1, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF

      @ m_x + 3, m_y + 2 SAY "         Konta (prazno-sva)" GET cIdKonto PICT "@S30@!" VALID {|| aUslK := Parsiraj ( cIdKonto, "IdKonto" ), iif ( aUslK == NIL, .F., .T. ) }
      @ m_x + 4, m_y + 2 SAY " Razdjel/glava (prazno-svi)" GET cIdRj PICT "@S30@!" VALID {|| aUslRj := Parsiraj ( cIdRj, "IdRj" ), iif ( aUslRj == NIL, .F., .T. ) }
      @ m_x + 5, m_y + 2 SAY "Funkc. klasif  (prazno-sve)" GET cFunk PICT "@S30@!" VALID {|| aUslFunk := Parsiraj ( cFunk, "Funk", "C" ), iif ( aUslFunk == NIL, .F., .T. ) }
      @ m_x + 6, m_y + 2 SAY "                 Pocevsi od" GET dDatOd VALID dDatOd <= dDatDo
      @ m_x + 7, m_y + 2 SAY "               Zakljucno sa" GET dDatDo VALID dDatOd <= dDatDo
      @ m_x + 10, m_y + 2 SAY "Procenat u odnosu god. plan" GET nProc PICT "999.99"

      @ m_x + 13, m_y + 2 SAY "          Obuhvaceni period" GET cPeriod PICT "@!"
      @ m_x + 14, m_y + 2 SAY "Izvjestaj 1" GET cI1 PICT "@!" VALID ci1 $ "DN"
      @ Row(), Col() + 2 SAY "2:" GET cI2 PICT "@!" VALID ci2 $ "DN"
      @ Row(), Col() + 2 SAY "3:" GET cI3 PICT "@!" VALID ci3 $ "DN"
      @ Row(), Col() + 2 SAY "4:" GET cI4 PICT "@!" VALID ci4 $ "DN"
      @ m_x + 16, m_y + 2 SAY "Subtotali po analitici za izvjestaj 1 ? (D/N)" GET cSTKI1 PICT "@!" VALID cSTKI1 $ "DN"
      @ m_x + 18, m_Y + 2 SAY "Provjeriti stavke koje nisu definisane u budzetu" GET cProv PICT "@!" VALID cprov $ "DN"

      IF gBuIz == "D"
         cBuIz := "D"
         @ m_x + 19, m_Y + 2 SAY "U izvjestaju koristiti korekciju za sortiranje konta? (D/N)" GET cBuIz PICT "@!" VALID cBuIz $ "DN"
      ENDIF

      @ m_x + 20, m_Y + 2 SAY "Broj redova za zaglavlje na izvjest. (0 - nista): " GET cBRZaZ
      READ
      ESC_BCR
      BoxC()

      UzmiIzIni( KUMPATH + 'fmk.ini', 'BUDZET', 'BrRedZaZagl', cBRZaZ, 'WRITE' )

      IF ( aUslK == NIL .OR. aUslRJ == NIL .OR. aUslFunk == NIL )
         LOOP
      ELSE
         EXIT
      ENDIF

   ENDDO

   O_BUDZET
   SET ORDER TO TAG "2"

   O_KONTO
   O_RJ
   O_FUNK
   O_SUBAN

   SELECT SUBAN
   cFilter := ""
   IF aUslK <> ".t."
      cFilter += aUslK
   ENDIF
   IF aUslRj <> ".t."
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + aUslRj  // cidrj
   ENDIF
   IF aUslFunk <> ".t."
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + aUslFunk
   ENDIF
   IF !Empty ( dDatOd )
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + "DatDok>=" + dbf_quote( dDatOd )
   ENDIF
   IF !Empty ( dDatDo )
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + "DatDok<=" + dbf_quote( dDatDo )
   ENDIF

   IF !Empty ( cFilter )
      SET FILTER to &cFilter
   ENDIF

   SELECT budzet
   PRIVATE cFiltB := ""
   IF aUslK <> ".t."
      cFiltB += IF ( !Empty ( cFiltB ), ".and.", "" ) + aUslK
   ENDIF
   IF aUslRj <> ".t."
      cFiltB += IF ( !Empty ( cFiltB ), ".and.", "" ) + aUslRj
   ENDIF
   IF aUslFunk <> ".t."
      cFiltB += IF ( !Empty ( cFiltB ), ".and.", "" ) + aUslFunk
   ENDIF
   SET FILTER to &cFiltB

   START PRINT CRET
   P_INI
   ?
   F10CPI

   SELECT budzet
   IF cBuIz == "D"
      INDEX ON idrj + BuIz( idkonto ) TO IZBUD
      SET ORDER TO TAG "IZBUD"
   ELSE
      SET ORDER TO TAG "1"  // "1","IdRj+Idkonto"
   ENDIF

   SELECT suban
   IF cBuIz == "D"
      INDEX ON idFirma + BuIz( IdKonto ) + DToS( DatDok ) + idpartner TO IZSUB
      SET ORDER TO TAG "IZSUB"
   ELSE
      SET ORDER TO TAG "5"
   ENDIF

   nTotal := 0
   nVanBudzeta := 0
   nVanB2 := 0

   SEEK cidfirma

   DO WHILE !Eof() .AND. idfirma == cidfirma
      IF d_p == "1"
         nTotal += iznosbhd
      ELSE
         nTotal -= iznosbhd
      ENDIF
      SELECT budzet
      SEEK suban->idrj
      IF !Found()
         IF cprov == "D"
            MsgBeep( " RJ:" + suban->idrj + "## <ESC> suti" )
            IF LastKey() == K_ESC
               cProv := "N"
            ENDIF
         ENDIF
         SELECT suban
         IF d_p == "1"
            nVanBudzeta += iznosbhd
         ELSE
            nVanBudzeta -= iznosbhd
         ENDIF
      ELSE // rj postoji
         SELECT budzet
         SEEK suban->( idrj + idkonto )
         IF !Found() // potrazi one koje se nece pojaviti u izvjestaju 4
            SKIP -1 // idi na predh stavku budzeta
            IF idrj <> suban->idrj
               IF cProv == "D"
                  MsgBeep( "Nema u planu:" + suban->idrj + "/" + suban->idkonto + "## <ESC> suti" )
                  IF LastKey() == K_ESC
                     cProv := "N"
                  ENDIF
               ENDIF
               SELECT suban
               IF d_p == "1"
                  nVanB2 += iznosbhd
               ELSE
                  nVanB2 -= iznosbhd
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      SELECT suban
      SKIP 1
   ENDDO


   IF cI1 == "D"
      SELECT suban
      IF cBuIz == "D"
         INDEX ON idFirma + BuIz( IdKonto ) + DToS( DatDok ) + idpartner TO IZSUB
         SET ORDER TO TAG "IZSUB"
      ELSE
         SET ORDER TO TAG "5"
      ENDIF

      // izvjestaj 1
      GO TOP
      INI
      F10CPI
      B_ON

      Razmak( Val( cBRZaZ ) )

      ?? PadC ( "P R E G L E D   R A S H O D A", 80 )
      ? PadC ( "PO SKUPINAMA TROSKOVA", 80 )
      ? PadC ( "ZA PERIOD " + AllTrim ( cPeriod ), 80 )
      B_OFF
      ?

      P_COND
      cLM := Space ( 10 )
      th1 := cLM + "                                                                                                                   Ucesce"
      th2 := cLM + "Ekonom.                                                   Plan za                          Izvrsenje     Procenat  u ukup."
      th3 := cLM + " kod    Skupina troskova                               tekucu godinu    Plan za period     za period     izvrsenja trosk."
      th4 := cLM + "                                                         (KM)               (KM)            (KM)          (%)      (%)"
      m := cLM + "------- --------------------------------------------- ---------------- ---------------- ---------------- --------- -------"

      fPrvaStr := .T.
      nPageNo := 2
      IB_Zagl1()
      nSlob := nKorRed1 + 46 -Val( cBrZaZ )
      nTot1 := nTot2 := nTot3 := 0

      SELECT BUDZET
      IF cBuIz == "D"
         INDEX ON BuIz( idkonto ) TO IZBUD2
         SET ORDER TO TAG "IZBUD2"
      ELSE
         SET ORDER TO TAG "2"    // "2", "Idkonto"
      ENDIF

      aSTKI1 := { 0, 0, 0, "" }

      GO TOP
      DO WHILE !Eof()
         cSk := Left ( Idkonto, 2 )
         nTotSk := 0
         nTotPlSk := 0
         DO WHILE !Eof() .AND. Left( Idkonto, 2 ) = cSk
            cKto := BuIz( IdKonto )
            cKtoStvarni := IdKonto
            IF nSlob = 0
               IB_Zagl1()
            ENDIF

            // Izracunaj plan za tekucu godinu

            nPlan := 0
            DO WHILE !Eof() .AND. BuIz( Idkonto ) == cKto
               nPlan += ( Iznos + RebIznos )
               SKIP 1
            ENDDO

            cBudzetNext := BuIz( idkonto ) // sljedeca stavka u budzetu
            IF Eof()
               cBudzetNext := "XXX"
            ENDIF

            nTotPlSk += nPlan
            nPlanPer := nPlan * nProc / 100
            SELECT suban
            SEEK cidfirma + cKtoStvarni
            fUBudzetu := .T.

            DO WHILE fUbudzetu .OR. !Eof() .AND. cidfirma == idfirma .AND. BuIz( idkonto ) >= cKto .AND. BuIz( idkonto ) < cBudzetNext

               nTotEK := 0
               cSKonto := BuIz( idkonto )
               cSKontoStvarni := idkonto

               IF Empty( aSTKI1[ 4 ] )
                  aSTKI1[ 4 ] := iif( fUBudzetu, cKtoStvarni, cSKontoStvarni )
               ENDIF

               DO WHILE !Eof() .AND. cidfirma == idfirma .AND. BuIz( IdKonto ) == iif( fUBudzetu, cKto, cSKonto )
                  IF d_p == "1"
                     nTotEK += IznosBHD
                  ELSE
                     nTotEK -= IznosBHD
                  ENDIF
                  SKIP 1
               ENDDO

               IF nSlob = 0
                  IB_Zagl1()
               ENDIF

               ? cLM
               SELECT konto
               HSEEK iif( fUBudzetu, cKtoStvarni, cSKontoStvarni )
               SELECT suban
               ?? iif( fUBudzetu, cKtoStvarni, cSKontoStvarni ), PadR ( Konto->Naz, 46 )
               ?? Transform( nPlan,    "9,999,999,999.99" ), Transform( nPlanPer, "9,999,999,999.99" ), Transform( nTotEK,   "9,999,999,999.99" )
               IF nPlanPer > 0
                  ?? " " + Transform( nTotEK * 100 / nPlanPer, "99,999.99" )
               ELSE
                  ?? Space ( 1 + 9 )
               ENDIF
               IF nTotal > 0
                  ?? " ", Str ( nTotEK * 100 / nTotal, 6, 2 )
               ENDIF

               IF cSTKI1 == "D"
                  aSTKI1[ 1 ] += nPlan
                  aSTKI1[ 2 ] += nPlanPer
                  aSTKI1[ 3 ] += nTotEk
                  // ispitati (MS)
                  IF Eof() .OR. SubStr( idkonto, 6, 2 ) == "0 " .OR. Left( aSTKI1[ 4 ], 5 ) <> Left( idkonto, 5 )
                     ? cLM
                     ?? aSTKI1[ 4 ], PadR ( "UKUPNO", 46, "_" )
                     ?? Transform( aSTKI1[ 1 ], "9,999,999,999.99" ), Transform( aSTKI1[ 2 ], "9,999,999,999.99" ), Transform( aSTKI1[ 3 ], "9,999,999,999.99" )
                     IF aSTKI1[ 2 ] > 0
                        ?? " " + Transform( aSTKI1[ 3 ] * 100 / aSTKI1[ 2 ], "99,999.99" )
                     ELSE
                        ?? Space ( 1 + 9 )
                     ENDIF
                     IF nTotal > 0
                        ?? " ", Str ( aSTKI1[ 3 ] * 100 / nTotal, 6, 2 )
                     ENDIF
                     aSTKI1[ 1 ] := 0
                     aSTKI1[ 2 ] := 0
                     aSTKI1[ 3 ] := 0
                     aSTKI1[ 4 ] := ""
                     nSlob--
                  ENDIF
               ENDIF

               fUBudzetu := .F.
               nSlob --
               nTotSk += nTotEK
               nPlan := 0
               nPlanPer := 0

            ENDDO // suban
            SELECT budzet
         ENDDO  // cSK

         IF nSlob < 3
            IB_Zagl1 ()
         ENDIF

         ? m
         nPlanPer := nTotPlSk * nProc / 100
         ?
         B_ON
         ?? cLM, Space ( 6 ), PadL ( "   UKUPNO SKUPINA TROSKOVA " + cSk + ": ", 45 ), Transform( nTotPlSk, "9,999,999,999.99" ), Transform( nPlanPer, "9,999,999,999.99" ), Transform( nTotSk,   "9,999,999,999.99" )
         IF nPlanPer > 0
            ?? " " + Transform( nTotSk * 100 / nPlanPer, "99,999.99" )
         ELSE
            ?? Space( 10 )
         ENDIF
         IF nTotal > 0
            ?? " ", Str ( nTotSk * 100 / nTotal, 5, 2 )
         ENDIF
         nTot1 += nTotPlSk
         nTot2 += nPlanPer
         nTot3 += nTotSk

         B_OFF
         ? m
         nSlob -= 3
      ENDDO // eof

      ?
      B_ON
      ?? cLM, Space ( 6 ), PadL ( " UKUPNI TROSKOVI PO SKUPINAMA: ", 45 ), Transform( nTot1, "9,999,999,999.99" ), Transform( nTot2, "9,999,999,999.99" ), Transform( nTot3, "9,999,999,999.99" )
      IF nTot2 > 0
         ?? " " + Transform( nTot3 * 100 / nTot2, "99,999.99" )
      ELSE
         ?? Space ( 10 )
      ENDIF
      IF nTotal > 0
         ?? " ", Str ( nTot3 * 100 / nTotal, 5, 2 )
      ENDIF
      B_OFF
      ? m

      cLM := Space ( 5 )

      IF !"D" $ ci2 + ci3 + ci4
         ?
         ?
         ?
         ?
         ? Space( 80 ) + "Ministar: _________________________________"
      ENDIF

      FF

   ENDIF // kraj izvjestaja 1


   IF ci2 == "D"
      // izvjestaj 2

      // struktura tro�kova po vrstama

      F10CPI
      B_ON

      // if !"D" $ ci1   //mjesto za zaglavlje
      Razmak( Val( cBRZaZ ) )
      // endif

      ?? PadC ( "STRUKTURA TROSKOVA PO VRSTAMA", 80 )
      ? PadC ( "ZA PERIOD " + AllTrim ( cPeriod ), 80 )
      ?
      B_OFF
      th1 := cLM + " " + "Vrsta  " + " " + PadR ( "Naziv vrste troska", Len ( KONTO->Naz ) ) + " " + PadC ( "Iznos (" + AllTrim ( ValDomaca() ) + ")", 16 )

      m := cLM + " " + REPL ( "-", 7 ) + " " + REPL ( "-", Len( KONTO->Naz ) ) + " " + REPL ( "-", 16 )

      F12CPI
      fPrvaStr := .T.
      nPageNo := 2
      IB_Zagl2 ()

      nSlob := nKorRed2 + 50 -Val( cBrZaZ )
      nTotTr := 0

      SELECT suban
      IF cBuIz == "D"
         INDEX ON idFirma + BuIz( IdKonto ) + DToS( DatDok ) + idpartner TO IZSUB
         SET ORDER TO TAG "IZSUB"
      ELSE
         SET ORDER TO TAG "5"
      ENDIF

      SEEK cidfirma
      DO WHILE !Eof() .AND. idfirma == cidfirma
         _IdKonto := BuIz( IdKonto )
         _IdKontoStvarni := IdKonto
         IF nSlob == 0
            FF
            IB_Zagl2 ()
            nSlob := nKorRed2 + 50 -Val( cBrZaZ )
         ENDIF
         SELECT KONTO
         HSEEK _IdKontoStvarni
         SELECT suban
         ? cLM, _IdKontoStvarni, KONTO->Naz

         nTotKonto := 0
         DO WHILE !Eof() .AND. idfirma == cidfirma .AND. BuIz( IdKonto ) == _IdKonto
            IF d_p == "1"
               nTotKonto += IznosBHD
            ELSE
               nTotKonto -= IznosBHD
            ENDIF
            SKIP 1
         ENDDO
         ?? " " + Transform( nTotKonto, "9,999,999,999.99" )
         nSlob --
         nTotTr += nTotKonto
      ENDDO

      ? m
      ?
      B_ON
      ?? cLM, PadL( "UKUPNI TROSKOVI PO VRSTAMA: ", 7 + Len( KONTO->naz ) + 1 )
      ?? " " + Transform( nTotTr, "9,999,999,999.99" )
      B_OFF
      ? m

      IF !"D" $ ci3 + ci4
         ?
         ?
         ?
         ?
         ? Space( 80 ) + "Ministar: _________________________________"
      ENDIF

      FF

   ENDIF // izvjestaj 2


   IF ci3 == "D" .OR. cI4 == "D"
      SELECT suban
      MsgO( "Kreiram pomocni index ..." )
      SET FILTER TO
      INDEX ON idfirma + idrj + BuIz( idkonto ) TO subrj  for &cFilter// privremeni index
      SET ORDER TO TAG "SUBRJ"
      MsgC()
   ENDIF

   IF ci3 == "D"
      // izvjestaj 3

      // rashodi po potr. jedinicama

      F10CPI
      B_ON

      // if !"D" $ ci1 + ci2   //mjesto za zaglavlje
      Razmak( Val( cBRZaZ ) )
      // endif

      ?? PadC ( "RASHODI PO BUDZETSKIM KORISNICIMA", 80 )
      ? PadC ( "ZA PERIOD " + AllTrim ( cPeriod ), 80 )
      ?
      ? PadC ( "UKUPNI RASHODI PO POTROSACKIM JEDINICAMA", 80 )
      ?
      B_OFF

      cLM := Space ( 12 )
      th1 := cLM + "                                                       Plan za                          Izvrsenje      Procenat"
      th2 := cLM + "Razdjel Glava  NAZIV BUDZETSKOG KORISNIKA           tekucu godinu     Plan za period    za period      izvrsenja"
      th3 := cLM + "                                                          (KM)             (KM)             (KM)          (%)"
      m := cLM + "------- ------ ------------------------------------ ---------------- ---------------- ---------------- ---------"

      P_COND
      fPrvaStr := .T.
      nPageNo := 2
      IB_Zagl3()
      nSlob := nKorRed3 + 49 -Val( cBrZaZ )
      nTot1 := nTot2 := nTot3 := 0

      SELECT BUDZET
      IF cBuIz == "D"
         INDEX ON idrj + BuIz( idkonto ) TO IZBUD
         SET ORDER TO TAG "IZBUD"
      ELSE
         SET ORDER TO TAG "1"
      ENDIF
      // "1","IdRj+Idkonto",KUMPATH+"BUDZET"

      GO TOP
      DO WHILE !Eof()
         cRazd := Left ( IdRj, 2 )
         nTotRazd := 0
         nTotPlan := 0
         fPrvi := .T.
         DO WHILE !Eof() .AND. IdRj = cRazd
            cIdRj := IdRj

            IF fPrvi
               IF nSlob = 0
                  FF
                  IB_Zagl3 ()
                  nSlob := nKorRed3 + 49 -Val( cBrZaZ )
               ENDIF
               ? cLM
               B_ON
               SELECT RJ
               HSEEK PadR ( cRazd, Len ( RJ->Id ) )
               cRazdNaz := RJ->Naz
               ?? PadR ( cRazd, 7 ), Space ( 6 ), cRazdNaz
               B_OFF
               nSlob --
               fPrvi := .F.
               SELECT budzet
            ENDIF

            IF nSlob == 0
               FF
               IB_Zagl3 ()
               nSlob := nKorRed3 + 49 -Val( cBrZaZ )
               ? cLM
               B_ON
               ?? PadR ( cRazd, 7 ), Space ( 6 ), cRazdNaz, "(nastavak)"
               B_OFF
               nSlob --
            ENDIF
            ? cLM + Space ( 8 )  // 7+1
            SELECT RJ
            HSEEK cIdRj
            SELECT budzet
            ?? cIdRj, RJ->Naz, " "

            nPlan := 0
            DO WHILE !Eof() .AND. IdRj == cIdRj
               nPlan += ( Iznos + RebIznos )
               SKIP 1
            ENDDO
            nTotPlan += nPlan

            SELECT suban
            SEEK cidfirma + cidrj
            nIzvr := 0

            DO WHILE !Eof() .AND. idfirma == cidfirma .AND. IdRj == cIdRj
               IF d_p == "1"
                  nIzvr += IznosBHD
               ELSE
                  nIzvr -= IznosBHD
               ENDIF
               SKIP 1
            ENDDO

            SELECT budzet
            nTotRazd += nIzvr

            nPlanProc := nPlan * nProc / 100
            ?? Transform ( nPlan, "9,999,999,999.99" ), Transform ( nPlanProc, "9,999,999,999.99" ), Transform ( nIzvr, "9,999,999,999.99" )
            IF nPlanProc > 0
               ?? " " + Transform ( nIzvr * 100 / nPlanProc, "99,999.99" )
            ENDIF
            nSlob --
         ENDDO  // cRazd
         IF nSlob < 2
            FF
            IB_Zagl3 ()
            nSlob := nKorRed3 + 49 -Val( cBrZaZ )
            ? cLM
            B_ON
            ?? PadR ( cRazd, 7 ), Space ( 6 ), cRazdNaz, "(nastavak)"
            B_OFF
            nSlob --
         ENDIF
         ?
         B_ON
         nPlanProc := nTotPlan * nProc / 100
         ?? cLM, Space ( 7 ), Space ( 6 ), PadL ( "UKUPNO RAZDJEL " + cRazd + ":", Len ( RJ->Naz ) ), Transform ( nTotPlan, "9,999,999,999.99" ), Transform ( nPlanProc, "9,999,999,999.99" ), Transform ( nTotRazd, "9,999,999,999.99" )
         IF nPlanProc > 0
            ?? " " + Transform ( nTotRazd * 100 / nPlanProc, "99,999.99" )
         ENDIF
         B_OFF
         nTot1 += nTotPlan
         nTot2 += nPlanProc
         nTot3 += nTotRazd
         ? m
         nSlob -= 2
      ENDDO  // eof

      ?
      B_ON
      IF nVanBudzeta <> 0
         ?? cLM, Space ( 7 ), Space ( 6 ), PadL ( "STAVKE VAN PLANA BUDZETA:", Len ( RJ->Naz ) ), Transform ( 0, "9,999,999,999.99" ), Transform ( 0, "9,999,999,999.99" ), Transform ( nVanBudzeta, "9,999,999,999.99" )
         ?
      ENDIF
      ?? cLM, Space ( 7 ), Space ( 6 ), PadL ( "UKUPNO RASHODI PO JEDINICAMA:", Len ( RJ->Naz ) ), Transform ( nTot1, "9,999,999,999.99" ), Transform ( nTot2, "9,999,999,999.99" ), Transform ( nTot3 + nVanBudzeta, "9,999,999,999.99" )
      IF nTot2 > 0
         ?? " " + Transform ( ( nTot3 + nVanBudzeta ) * 100 / nTot2, "99,999.99" )
      ENDIF
      B_OFF
      ? m

      IF !"D" $ ci4
         ?
         ?
         ?
         ?
         ? Space( 80 ) + "Ministar: _________________________________"
      ENDIF


      // detaljni izvjestaj

      FF

   ENDIF // izvjestaj 3


   IF ci4 == "D"
      // izvjestaj 4
      F10CPI
      B_ON

      // if !"D" $ ci1 + ci2 + ci3   //mjesto za zaglavlje
      Razmak( Val( cBRZaZ ) )
      // endif

      ?? PadC ( "RASHODI PO BUDZETSKIM KORISNICIMA", 80 )
      ? PadC ( "ZA PERIOD " + AllTrim ( cPeriod ), 80 )
      ?
      ? PadC ( "RASHODI PO POTROSACKIM JEDINICAMA, SKUPINAMA I VRSTAMA TROSKOVA", 80 )
      ?
      B_OFF
      cLM := Space ( 5 )
      th1 := cLM + "                                                                    Plan za                          Izvrsenje     Procenat"
      th2 := cLM + "                                                                 tekucu godinu    Plan za period     za period     izvrsenja"
      th3 := cLM + "NAZIV BUDZETSKOG KORISNIKA, SKUPINA I VRSTA TROSKOVA                 (KM)             (KM)             (KM)           (%)"
      m := cLM + "--------------------------------------------------------------- ---------------- ---------------- ---------------- ---------"
      SELECT BUDZET
      IF cBuIz == "D"
         INDEX ON idrj + BuIz( idkonto ) TO IZBUD
         SET ORDER TO TAG "IZBUD"
      ELSE
         SET ORDER TO TAG "1"
      ENDIF
      // "1","IdRj+Idkonto",KUMPATH+"BUDZET"

      P_COND
      fPrvaStr := .T.
      nPageNo := 2
      IB_Zagl4()
      nSlob := nKorRed4 + 49 -Val( cBrZaZ )
      nTot1 := nTot2 := nTot3 := 0

      SELECT budzet
      GO TOP
      cRazdjel := ""
      nTotIRa := 0
      nTotPlanRa := 0
      nURazdjelu := 1

      DO WHILE !Eof()

         cIdRj := IdRj
         SELECT RJ
         HSEEK cIdRj
         SELECT budzet

         IF nSlob == 0
            IB_Zagl4 ()
         ENDIF
         ?
         B_ON
         ?? cLM + cIdRj, RJ->Naz
         B_OFF
         nSlob --
         cRazdjel := Left( cidrj, 2 )
         nTotPlanRj := 0
         nTotIRJ := 0
         DO WHILE !Eof() .AND. idrj == cidrj
            cKto := BuIz( idkonto )
            cKtoStvarni := idkonto
            nPlan := 0
            DO WHILE !Eof() .AND. idrj == cidrj .AND. BuIz( Idkonto ) == cKto
               nPlan += BUDZET->( Iznos + RebIznos )
               SKIP 1
            ENDDO
            IF idrj == cidrj
               cBudzetNext := BuIz( idkonto ) // sljedeca stavka u budzetu
            ELSE
               cBudzetNext := "XXXXX"
            ENDIF
            IF Eof()
               cBudzetNext := "XXXXX"
            ENDIF

            SELECT konto
            HSEEK cKtoStvarni
            IF nSlob == 0
               IB_Zagl4()
               ?
               B_ON
               ?? cLM + cIdRj, RJ->Naz, "(nastavak)"
               B_OFF
               nSlob --
            ENDIF

            ?
            B_ON
            ?? cLM + Space ( 6 ), cKtoStvarni, konto->Naz
            B_OFF
            nSlob --

            fUBudzetu := .T.
            SELECT suban
            SEEK cidfirma + cidrj + cKtoStvarni
            nTotek2 := 0

            DO WHILE fUbudzetu .OR. !Eof() .AND. idfirma == cidfirma .AND. idrj == cIdrj .AND. BuIz( idkonto ) >= cKto .AND. BuIz( idkonto ) < cBudzetNext
               cSkonto := BuIz( IdKonto )
               cSkontoStvarni := IdKonto
               SELECT konto
               SEEK  cSKontoStvarni
               SELECT suban
               nTotEk := 0
               DO WHILE !Eof() .AND. cidfirma == idfirma .AND. idrj == cidrj .AND. BuIz( IdKonto ) == iif( fUBudzetu, cKto, cSKonto )
                  IF d_p == "1"
                     nTotEK += IznosBHD
                  ELSE
                     nTotEK -= IznosBHD
                  ENDIF
                  SKIP 1
               ENDDO
               IF nTotEk <> 0
                  ? cLM + Space ( 6 ), cSkontoStvarni, Left ( KONTO->Naz, 49 )
                  ?? Space ( 16 ), Space ( 16 ), Transform( nTotEk, "9,999,999,999.99" )
               ENDIF
               nTotEK2 += nTotEk
               nSlob --
               IF nSlob <= 0
                  IB_Zagl4()
                  ?
                  B_ON
                  ?? cLM + cIdRj, RJ->Naz, "(nastavak)"
                  B_OFF
                  nSlob --
               ENDIF

               fubudzetu := .F.
            ENDDO // fubudzetu

            SELECT budzet
            ?
            nPlanProc := nPlan * nProc / 100
            B_ON
            ?? cLM + PadL ( "UKUPNO SKUPINA TROSKOVA " + AllTrim ( cKtoStvarni ), 13 + Len ( KONTO->Naz ) -7 ), Transform( nPlan, "9,999,999,999.99" ), Transform( nPlanProc, "9,999,999,999.99" ), Transform( nTotEK2, "9,999,999,999.99" )
            IF nPlanProc > 0
               ?? " " + Transform( nTotEk2 * 100 / nPlanProc, "99,999.99" )
            ENDIF
            B_OFF
            nSlob --

            nTotPlanRj += nPlan
            nTotIRJ += nTotEK2

            IF nSlob < 3
               IB_Zagl4 ()
               ?
               B_ON
               ?? cLM + cIdRj, RJ->Naz, "(nastavak)"
               B_OFF
               nSlob --
            ENDIF
         ENDDO // cidrj
         nPlanProc := nTotPlanRj * nProc / 100
         ? m
         ?
         B_ON
         ?? cLM + PadL ( "UKUPNO BUDZETSKI KORISNIK " + AllTrim ( cIdRj ), 13 + Len ( KONTO->Naz ) -7 ), Transform( nTotPlanRj, "9,999,999,999.99" ), Transform( nPlanProc, "9,999,999,999.99" ), Transform( nTotIRJ, "9,999,999,999.99" )
         IF nPlanProc > 0
            ?? " " + Transform( nTotIRJ * 100 / nPlanProc, "99,999.99" )
         ENDIF

         nTotIRa += nTotIRj
         nTotPlanRa += nTotPlanRj

         IF Left( idrj, 2 ) <> cRazdjel
            IF nURazdjelu > 1
               ?
               nPlanProcRa := nTotPlanRa * nProc / 100
               ?? cLM + PadL ( "UKUPNO RAZDJEL " + cRazdjel, 13 + Len ( KONTO->Naz ) -7 ), Transform( nTotPlanRa, "9,999,999,999.99" ), Transform( nPlanProcRa, "9,999,999,999.99" ), Transform( nTotIRa, "9,999,999,999.99" )
               IF nPlanProcRa > 0
                  ?? " " + Transform( nTotIRa * 100 / nPlanProcRa, "99,999.99" )
               ENDIF
            ENDIF
            nTotIRa := 0
            nTotPlanRa := 0
            nURazdjelu := 1
         ELSE
            nURazdjelu++
         ENDIF

         B_OFF
         nTot1 += nTotPlanRj
         nTot2 += nPlanProc
         nTot3 += nTotIRJ
         ? m
         nSlob -= 3

      ENDDO  // eof()

      ? m
      ?
      B_ON

      IF nVanBudzeta <> 0
         ?? cLM + PadL ( "STAVKE VAN PLANA BUDZETA:", 13 + Len ( KONTO->Naz ) -7 ), Transform( 0, "9,999,999,999.99" ), Transform( 0, "9,999,999,999.99" ), Transform( nVanBudzeta + nVanB2, "9,999,999,999.99" )
         ?
      ENDIF

      ?? cLM + PadL ( "UKUPNO SVI BUDZETSKI KORISNICI:", 13 + Len ( KONTO->Naz ) -7 ), Transform( nTot1, "9,999,999,999.99" ), Transform( nTot2, "9,999,999,999.99" ), Transform( nTot3 + nVanBudzeta + nVanB2, "9,999,999,999.99" )
      IF nTot2 > 0
         ?? " " + Transform( ( nTot3 + nVanBudzeta + nVanB2 ) * 100 / nTot2, "99,999.99" )
      ENDIF
      B_OFF
      ? m

      ?
      ?
      ?
      ?
      ? Space( 80 ) + "Ministar: _________________________________"

      FF

      // izvjestaj 4
   ENDIF


   ENDPRINT
   CLOSERET

   RETURN



/*! \fn IB_Zagl1()
 *  \brief Zaglavlje izvrsenje budzeta 1
 */

FUNCTION IB_Zagl1()

   IF fPrvaStr
      fPrvaStr := .F.
   ELSE
      FF
      Razmak( Val( cBRZaZ ) )
      ?
      ? Space ( 9 ), "Pregled rashoda po vrstama i skupinama troskova", Space ( 60 ), "Strana", Str ( nPageNo++, 3 )
      ?
   ENDIF
   ? m
   ? th1
   ? th2
   ? th3
   ? th4
   ? m
   nSlob := nKorRed1 + 46 -Val( cBrZaZ )

   RETURN



/*! \fn IB_Zagl2()
 *  \brief Zaglavlje izvjestaja izvrsenje budzeta 2
 */

FUNCTION IB_Zagl2()

   IF fPrvaStr
      fPrvaStr := .F.
   ELSE
      Razmak( Val( cBRZaZ ) )
      ? Space ( 5 ), "Struktura troskova po vrstama", Space ( 41 ), "Strana", Str ( nPageNo++, 3 )
      ?
   ENDIF
   ? m
   ? th1
   ? m

   RETURN



/*! \fn IB_Zagl3()
 *  \brief Zaglavlje izvjestaja izvrsenje budzeta varijanta 3
 */

FUNCTION IB_Zagl3()

   IF fPrvaStr
      fPrvaStr := .F.
   ELSE
      Razmak( Val( cBRZaZ ) )
      ? Space ( 11 ), "Ukupni rashodi po potrosackim jedinicama", Space ( 61 ), "Strana", Str ( nPageNo++, 3 )
      ?
   ENDIF
   ? m
   ? th1
   ? th2
   ? th3
   ? m

   RETURN



/*! \fn IB_Zagl4()
 *  \brief Zaglavlje izvjestaja izvrsenje budzeta varijanta 4
 */

FUNCTION IB_Zagl4()

   IF fPrvaStr
      fPrvaStr := .F.
   ELSE
      FF
      Razmak( Val( cBRZaZ ) )
      ? Space ( 5 ), "Rashodi po potrosackim jedinicama, skupinama i vrstama troskova",  Space ( 48 ), "Strana", Str ( nPageNo++, 3 )
      ?
   ENDIF
   ? m
   ? th1
   ? th2
   ? th3
   ? m
   nSlob := nKorRed4 + 49 -Val( cBrZaZ )

   RETURN



/*! \fn Prihodi()
 *  \brief Prihodi
 */

FUNCTION Prihodi()

   LOCAL fKraj
   LOCAL n
   PRIVATE picBHD := FormPicL( gPicBHD, 15 )
   PRIVATE picDEM := FormPicL( gPicDEM, 12 )
   PRIVATE cIdKonto
   PRIVATE cIdFirma := Space( Len( gFirma ) )
   PRIVATE cIdRj := Space( 50 )
   PRIVATE cFunk := Space( 60 )
   PRIVATE dDatOd := CToD( "" )
   PRIVATE dDatDo := Date()
   PRIVATE aUslK
   PRIVATE aUslRj
   PRIVATE aUslFunk
   PRIVATE cSpecKonta
   PRIVATE nProc := 0

   // private cPeriod := PADR ("JANUAR - ", 40)

   cIdKonto := PadR ( "7;", 60 )
   cSpecKonta := PadR ( "", 60 )

   PRIVATE cPeriod := PadR ( "JANUAR - ", 40 )


   cProv := "D"

   O_PARTN

   DO WHILE .T.

      Box (, 22, 70 )  // 19
      @ m_x, m_y + 15 SAY "PREGLED PRIHODA"

      // procenat ucesca perioda u godisnjem planu

      IF gNW == "D"
         cIdFirma := gFirma
         @ m_x + 1, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "         Konta (prazno-sva)" GET cIdKonto PICT "@S30@!" VALID {|| aUslK := Parsiraj ( cIdKonto, "IdKonto", "C" ), iif ( aUslK == NIL, .F., .T. ) }
      @ m_x + 4, m_y + 2 SAY " Razdjel/glava (prazno-svi)" GET cIdRj PICT "@S30@!" VALID {|| aUslRj := Parsiraj ( cIdRj, "IdRj" ), iif ( aUslRj == NIL, .F., .T. ) }
      @ m_x + 5, m_y + 2 SAY "Funkc. klasif  (prazno-sve)" GET cFunk PICT "@S30@!" VALID {|| aUslFunk := Parsiraj ( cFunk, "Funk", "C" ), iif ( aUslFunk == NIL, .F., .T. ) }
      @ m_x + 6, m_y + 2 SAY "                 Pocevsi od" GET dDatOd VALID dDatOd <= dDatDo
      @ m_x + 7, m_y + 2 SAY "               Zakljucno sa" GET dDatDo VALID dDatOd <= dDatDo
      @ m_x + 12, m_y + 2 SAY "Procenat u odnosu god. plan" GET nProc PICT "999.99"
      @ m_x + 18, m_y + 2 SAY "          Obuhvaceni period" GET cPeriod PICT "@!"

      @ m_x + 22, m_Y + 2 SAY "Provjeriti stavke koje nisu definisane u budzetu" GET cProv PICT "@!" VALID cprov $ "DN"
      READ
      ESC_BCR
      BoxC()

      IF ( aUslK == NIL .OR. aUslRJ == NIL .OR. aUslFunk == NIL )
         LOOP
      ELSE
         EXIT
      ENDIF

   ENDDO

   O_BUDZET
   O_KONTO
   O_SUBAN


   SELECT SUBAN
   cFilter := ""
   IF aUslK <> ".t."
      cFilter += aUslK
   ENDIF
   IF aUslRj <> ".t."
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + aUslRj  // cidrj
   ENDIF
   IF aUslFunk <> ".t."
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + aUslFunk
   ENDIF
   IF !Empty ( dDatOd )
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + "DatDok>=" + dbf_quote( dDatOd )
   ENDIF
   IF !Empty ( dDatDo )
      cFilter += IF ( !Empty ( cFilter ), ".and.", "" ) + "DatDok<=" + dbf_quote( dDatDo )
   ENDIF

   IF !Empty ( cFilter )
      SET FILTER to &cFilter
   ENDIF

   SELECT SUBAN
   SET ORDER TO TAG "1"
   // "1","IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr",KUMPATH+"SUBAN") //subanaliti
   GO TOP

   SELECT budzet
   PRIVATE cFiltB := ""
   IF aUslK <> ".t."
      cFiltB += IF ( !Empty ( cFiltB ), ".and.", "" ) + aUslK
   ENDIF
   IF aUslRj <> ".t."
      cFiltB += IF ( !Empty ( cFiltB ), ".and.", "" ) + aUslRj
   ENDIF
   IF aUslFunk <> ".t."
      cFiltB += IF ( !Empty ( cFiltB ), ".and.", "" ) + aUslFunk
   ENDIF
   SET FILTER to &cFiltB
   SET ORDER TO TAG "2" // IDKONTO

   EOF CRET

   START PRINT CRET

   SELECT BUDZET
   SET ORDER TO TAG "1"
   SELECT suban
   SET ORDER TO TAG "5"
   GO TOP
   nTotal := 0
   nVanBudzeta := 0
   nVanB2 := 0
   SEEK cidfirma
   // cLast:=IDKONTO

   DO WHILE !Eof() .AND. idfirma == cidfirma
      IF d_p == "2"
         nTotal += iznosbhd
      ELSE
         nTotal -= iznosbhd
      ENDIF
      SKIP 1
   ENDDO

   nTotal := nTotal - nVanBudzeta - nVanB2

   SELECT BUDZET
   SET ORDER TO TAG "2"
   SELECT SUBAN
   SET ORDER TO TAG "1"
   GO TOP

   INI
   ?
   F10CPI

   // ispis izvjestaja

   F10CPI
   B_ON
   ?? PadC ( "P R E G L E D   P R I H O D A", 80 )
   ? PadC ( "ZA PERIOD " + AllTrim ( cPeriod ), 80 )
   ?
   ? PadC ( "STRUKTURA PRIHODA PO VRSTAMA", 80 )
   B_OFF
   ?

   cLM := Space ( 10 )

   th1 := cLM + "                                                                                                                      Ucesce "
   th2 := cLM + "                                                          Plan za                          Izvrsenje      Procenat    u ukup."
   th3 := cLM + "Sifra i naziv ekonomske kategorije prihoda             tekucu godinu    Plan za period     za period      izvrsenja   prihod."
   th4 := cLM + "                                                            (KM)             (KM)             (KM)           (%)        (%)  "
   m := cLM + "----------------------------------------------------- ---------------- ---------------- ---------------- ------------ -------"
   m1 := StrTran ( m, "-", "*" )

   P_COND
   fPrvaStr := .T.
   nPageNo := 2
   PR_Zagl()

   SELECT KONTO

   SELECT BUDZET
   GO TOP

   cIdRj := Space ( Len ( BUDZET->IdRj ) ) // zbog BUDZET-a - prihodi ne idu po RJ
   nLen1 := 53
   nLen2 := Len ( konto->Naz ) -5 -1

   nTotPlan := 0
   nTotPr := 0
   nL1 := nL2 := nPlanL1 := nPlanL2 := 0
   fneman3 := .F.

   DO WHILE !Eof()

      IF PRow() > 63 + gPStranica
         PR_Zagl()
      ENDIF


      cLev1 := idkonto
      fLev1 := .T.
      SELECT konto
      HSEEK clev1
      SELECT budzet
      ? cLM
      B_ON
      ?? cLev1, ( cLev1Naz := konto->naz )
      B_OFF

      IF fond = "N1"
         SKIP 1
      ENDIF

      nPlanL1 := 0
      nL1 := 0
      DO WHILE !Eof() .AND. fLev1

         cLev2 := idkonto
         fLev2 := .T.
         SELECT konto
         HSEEK clev2
         SELECT budzet
         ? cLM
         B_ON
         ?? cLev2, ( cLev2Naz := konto->naz )
         B_OFF
         IF fond = "N2" .AND. !fneman3
            SKIP
         ENDIF
         IF fond = "N2"
            IF !fneman3
               SKIP -1
            ENDIF
            fneman3 := .T.   // ponovo se desava n2, NEMA N3
         ELSE
            fneman3 := .F.
         ENDIF
         nPlanL2 := 0
         nL2 := 0
         DO WHILE !Eof() .AND. fLev2
            cKto := IdKonto
            IF PRow() > 62 + gPStranica
               FF
               Pr_Zagl()
            ENDIF

            // Izracunaj plan za tekucu godinu

            nPlan := 0
            DO WHILE !Eof() .AND. Idkonto == cKto
               nPlan += ( Iznos + RebIznos )
               SKIP 1
            ENDDO

            nPlanL2 += nPlan
            cBudzetNext := idkonto // sljedeca stavka u budzetu
            IF Eof()
               cBudzetNext := "XXX"
            ENDIF

            nPlanPer := nPlan * nProc / 100
            SELECT suban   // IDI NA SUBANALITIKU .........................
            SEEK cidfirma + ckto
            fUBudzetu := .T.
            DO WHILE fUbudzetu .OR. !Eof() .AND. cidfirma == idfirma .AND. idkonto >= cKto .AND. idkonto < cBudzetNext

               nTotEK := 0
               cSKonto := idkonto
               DO WHILE !Eof() .AND. cidfirma == idfirma .AND. IdKonto == iif( fUBudzetu, cKto, cSKonto )
                  IF d_p == "2"
                     nTotEK += IznosBHD
                  ELSE
                     nTotEK -= IznosBHD
                  ENDIF
                  SKIP 1
               ENDDO

               ? cLM
               SELECT konto
               HSEEK iif( fUBudzetu, cKto, cSKonto )
               SELECT suban
               ?? Space( 8 )
               ?? iif( fUBudzetu, cKto, cSKonto ), PadR ( Konto->Naz, 38 )
               ?? Transform( nPlan,    "9,999,999,999.99" ), Transform( nPlanPer, "9,999,999,999.99" ), Transform( nTotEK,   "9,999,999,999.99" )
               IF nPlanPer > 0
                  ?? " " + Transform( nTotEK * 100 / nPlanPer, "99,999.99" )
               ELSE
                  ?? Space ( 1 + 9 )
               ENDIF
               IF nTotal > 0
                  ?? "   ", Str ( nTotEK * 100 / nTotal, 6, 2 )
               ENDIF
               fUBudzetu := .F.
               nL2 += nTotEK
               nPlan := 0
               nPlanPer := 0

            ENDDO // suban
            SELECT budzet
            IF fond = "N2" .OR. fond = "N1"
               fLev2 := .F.  // prekini level 2
            ENDIF

         ENDDO // fLev2 prekid

         IF PRow() > 62 + gPStranica
            PR_Zagl()
            ? cLM
            B_ON
            ?? cLev2, cLev2Naz, "(nastavak)"
            B_OFF
         ENDIF

         IF PRow() > 60 + gPStranica
            PR_Zagl()
         ELSE
            ? m
         ENDIF

         ? cLM
         B_ON
         nPom := nPlanL2 * nProc / 100
         ?? PadL ( "UKUPNO " + cLev2 + " " + cLev2Naz, nLen1 ), Transform( nPlanL2, "9,999,999,999.99" ), Transform( nPom, "9,999,999,999.99" ), Transform( nL2, "9,999,999,999.99" )
         IF nPom > 0
            ?? " " + Transform( nL2 * 100 / nPom, "99,999.99" )
         ENDIF
         IF nTotal > 0
            ?? "   ", Str ( nL2 * 100 / nTotal, 6, 2 )
         ENDIF
         B_OFF
         ? m

         IF fond = "N1"
            flev1 := .F.
         ENDIF

         nPlanL1 += nPlanL2
         nL1 += nL2

      ENDDO // fLEv1 prekid

      IF PRow() > 63 + gPStranica
         PR_Zagl()
         ? cLM
         B_ON
         ?? cLev1, cLev1Naz, "(nastavak)"
         B_OFF
      ENDIF

      IF PRow() > 60 + gPStranica
         PR_Zagl()
      ELSE
         ? m1
      ENDIF

      ? cLM
      B_ON

      nPom := nPlanL1 * nProc / 100
      ?? PadL ( "UKUPNO " + cLev1 + " " + cLev1Naz, nLen1 ), Transform( nPlanL1, "9,999,999,999.99" ), Transform( nPom, "9,999,999,999.99" ), Transform( nL1, "9,999,999,999.99" )
      IF nPom > 0
         ?? " " + Transform( nL1 * 100 / nPom, "99,999.99" )
      ENDIF
      IF nTotal > 0
         ?? "   ", Str ( nL1 * 100 / nTotal, 6, 2 )
      ENDIF
      B_OFF
      ? m1
      nTotPlan += nPlanL1
      // nTotPr+=nL2
      nTotPr += nL1

   ENDDO

   IF PRow() > 60 + gPStranica
      PR_Zagl()
   ELSE
      ? m1
   ENDIF

   nPom := nTotPlan * nProc / 100
   ? cLM
   B_ON
   ?? PadL ( "U  K  U  P  N  O   P R I H O D I", nLen1 ), Transform( nTotPlan, "9,999,999,999.99" ), Transform( nPom, "9,999,999,999.99" ), Transform( nTotPR, "9,999,999,999.99" )

   IF nPom > 0
      ?? " " + Transform( nTotPR * 100 / nPom, "99,999.99" )
   ENDIF
   IF nTotal > 0
      ?? "   ", Str ( nTotPR * 100 / nTotal, 6, 2 )
   ENDIF
   B_OFF
   ? m1
   FF
   ENDPRINT

   RETURN



/*! \fn PR_Zagl()
 *  \brief Zaglavlje prihoda
 */

FUNCTION PR_Zagl()

   IF fPrvaStr
      fPrvaStr := .F.
   ELSE
      FF
      ? cLM + "Struktura prihoda po vrstama", Space ( 59 ), "Strana", Str ( nPageNo++, 3 )
   ENDIF
   ? m
   ? th1
   ? th2
   ? th3
   ? th4
   ? m

   RETURN




/*! \fn Razmak(nBrRed)
 *  \brief Daje nBrRed praznih redova
 *  \todo Treba prebaciti u /sclib
 *  \param nBrRed  - broj redova
 */

STATIC FUNCTION Razmak( nBrRed )

   PRIVATE i

   FOR i := 1 TO nBrRed
      ?
   NEXT

   RETURN




/*! \fn BuIz(cKonto)
 *  \brief Sortiraj izuzetke u budzetu
 *  \param cKonto
 */

FUNCTION BuIz( cKonto )

   // primjer BUIZ: ID=6138931 , NAZ=6138910030
   // 7 cifri,     10 cifri
   LOCAL nselect
   IF cBuIz == "N"
      RETURN cKonto
   ENDIF

   nSelect := Select()
   SELECT buiz
   SEEK cKonto
   IF Found()
      cKonto := naz
   ENDIF

   SELECT ( nSelect )

   RETURN PadR( cKonto, 10 )
