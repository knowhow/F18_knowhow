/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fin.ch"

FUNCTION fin_bb_analitika_b( params )

   PRIVATE A1, D4PS, P4PS, D4TP, P4TP, D4KP, P4KP, D4S, P4S

   cIdFirma := gFirma

   O_KONTO
   O_PARTN

   qqKonto := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   PRIVATE cFormat := "2", cPodKlas := "N"
   Box( "", 8, 60 )
   SET CURSOR ON
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "ANALITICKI BRUTO BILANS"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Konto " GET qqKonto PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Od datuma :" GET dDatOD
      @ m_x + 4, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 6, m_y + 2 SAY "Format izvjestaja A3/A4 (1/2)" GET cFormat
      @ m_x + 7, m_y + 2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas $ "DN" PICT "@!"
      cIdRJ := ""
      IF gRJ == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 8, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      IF aUsl1 <> NIL; exit; ENDIF
   ENDDO
   BoxC()

   cidfirma := Trim( cidfirma )

   IF cIdRj == "999999"; cidrj := ""; ENDIF
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cidrj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   IF cFormat == "1"
      M1 := "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M2 := "*REDNI*   KONTO   *                NAZIV ANALITICKOG KONTA                  *        PO¬ETNO STANJE         *         TEKUI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
      M3 := "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M4 := "*BROJ *           *                                                         *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE  *"
      M5 := "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   ELSE
      M1 := "------ ----------- ---------------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M2 := "*REDNI*   KONTO   *         NAZIV ANALITICKOG KONTA        *        PO¬ETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
      M3 := "                                                            ------------------------------- ------------------------------- -------------------------------"
      M4 := "*BROJ *           *                                        *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE  *"
      M5 := "------ ----------- ---------------------------------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   ENDIF

   O_BBKLAS
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      SintFilt( .F., "IDRJ='" + cIdRJ + "'" )
   ELSE
      O_ANAL
   ENDIF

   SELECT BBKLAS; ZAP

   SELECT ANAL

   cFilter := ""

   IF !( Empty( qqkonto ) )
      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         cFilter += ( iif( Empty( cFilter ), "", ".and." ) + ;
            aUsl1 + ".and. DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo ) )
      ELSE
         cFilter += ( iif( Empty( cFilter ), "", ".and." ) + aUsl1 )
      ENDIF
   ELSEIF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilter += ( iif( Empty( cFilter ), "", ".and." ) + ;
         "DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo ) )
   ENDIF

   IF Len( cIdFirma ) < 2
      SELECT ANAL
      Box(, 2, 30 )
      nSlog := 0; nUkupno := RECCOUNT2()
      cFilt := IF( Empty( cFilter ), "IDFIRMA=" + cm2str( cIdFirma ), cFilter + ".and.IDFIRMA=" + cm2str( cIdFirma ) )
      cSort1 := "IdKonto+dtos(DatNal)"
      INDEX ON &cSort1 TO "ANATMP" FOR &cFilt Eval( fin_tek_rec_2() ) EVERY 1
      GO TOP
      BoxC()
   ELSE
      SET FILTER TO &cFilter
      HSEEK cIdFirma
   ENDIF

   EOF CRET

   nStr := 0

   BBMnoziSaK()

   START PRINT CRET

   B := 0

   D1S := D2S := D3S := D4S := P1S := P2S := P3S := P4S := 0

   D4PS := P4PS := D4TP := P4TP := D4KP := P4KP := D4S := P4S := 0

   nCol1 := 50

   DO WHILE !Eof() .AND. IdFirma = cIdFirma

      IF PRow() == 0; BrBil_21(); ENDIF

      cKlKonto := Left( IdKonto, 1 )
      D3PS := P3PS := D3TP := P3TP := D3KP := P3KP := D3S := P3S := 0
      DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cKlKonto == Left( IdKonto, 1 ) // kl konto

         cSinKonto := Left( idkonto, 3 )
         D2PS := P2PS := D2TP := P2TP := D2KP := P2KP := D2S := P2S := 0
         DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cSinKonto == Left( idkonto, 3 ) // sin konto

            cIdKonto := IdKonto

            D1PS := P1PS := D1TP := P1TP := D1KP := P1KP := D1S := P1S := 0
            DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == IdKonto // konto
               IF cTip == ValDomaca(); Dug := DugBHD * nBBK; Pot := PotBHD * nBBK; else; Dug := DUGDEM; Pot := POTDEM; ENDIF
               D1KP = D1KP + Dug
               P1KP = P1KP + Pot
               IF IdVN = "00"
                  D1PS += Dug; P1PS += Pot
               ELSE
                  D1TP += Dug; P1TP += Pot
               ENDIF
               SKIP
            ENDDO   // konto

            @ PRow() + 1, 1 SAY ++B PICTURE '9999';?? "."
            @ PRow(), 10 SAY cIdKonto

            SELECT KONTO
            HSEEK cIdKonto
            IF cFormat == "1"
               @ PRow(), 19 SAY naz
            ELSE
               @ PRow(), 19 SAY PadR( naz, 40 )
            ENDIF
            SELECT ANAL

            nCol1 := PCol() + 1
            @ PRow(), PCol() + 1 SAY D1PS PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1PS PICTURE PicD
            IF cFormat == "1"
               @ PRow(), PCol() + 1 SAY D1TP PICTURE PicD
               @ PRow(), PCol() + 1 SAY P1TP PICTURE PicD
            ENDIF
            @ PRow(), PCol() + 1 SAY D1KP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1KP PICTURE PicD

            D1S = D1KP - P1KP
            IF D1S >= 0
               P1S := 0
               D2S += D1S; D3S += D1S; D4S += D1S
            ELSE
               P1S := -D1S; D1S := 0
               P1S := P1KP - D1KP
               P2S += P1S
               P3S += P1S; P4S += P1S
            ENDIF
            @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1S PICTURE PicD

            D2PS = D2PS + D1PS
            P2PS = P2PS + P1PS
            D2TP = D2TP + D1TP
            P2TP = P2TP + P1TP
            D2KP = D2KP + D1KP
            P2KP = P2KP + P1KP
            IF PRow() > 65 + gpStranica; FF;BrBil_21(); ENDIF

         ENDDO  // sinteticki konto
         IF PRow() > 61 + gpStranica; FF; BrBil_21(); ENDIF

         ? M5
         @ PRow() + 1, 10 SAY cSinKonto
         @ PRow(), nCol1    SAY D2PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2PS PICTURE PicD
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY D2TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P2TP PICTURE PicD
         ENDIF
         @ PRow(), PCol() + 1 SAY D2KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D2S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2S PICTURE PicD
         ? M5

         D3PS = D3PS + D2PS; P3PS = P3PS + P2PS
         D3TP = D3TP + D2TP; P3TP = P3TP + P2TP
         D3KP = D3KP + D2KP; P3KP = P3KP + P2KP

      ENDDO  // klasa konto

      SELECT BBKLAS
      APPEND BLANK
      REPLACE IdKlasa WITH cKlKonto, ;
         PocDug  WITH D3PS, ;
         PocPot  WITH P3PS, ;
         TekPDug WITH D3TP, ;
         TekPPot WITH P3TP, ;
         KumPDug WITH D3KP, ;
         KumPPot WITH P3KP, ;
         SalPDug WITH D3S, ;
         SalPPot WITH P3S

      SELECT ANAL

      IF cPodKlas == "D"
         ? M5
         ? "UKUPNO KLASA " + cklkonto
         @ PRow(), nCol1    SAY D3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3PS PICTURE PicD
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY D3TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P3TP PICTURE PicD
         ENDIF
         @ PRow(), PCol() + 1 SAY D3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3S PICTURE PicD
         ? M5
      ENDIF
      D4PS += D3PS; P4PS += P3PS; D4TP += D3TP; P4TP += P3TP; D4KP += D3KP; P4KP += P3KP

   ENDDO

   IF PRow() > 61 + gpStranica; FF ; BrBil_21(); ENDIF
   ? M5
   ? "UKUPNO:"
   @ PRow(), nCol1    SAY D4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4PS PICTURE PicD
   IF cFormat == "1"
      @ PRow(), PCol() + 1 SAY D4TP PICTURE PicD
      @ PRow(), PCol() + 1 SAY P4TP PICTURE PicD
   ENDIF
   @ PRow(), PCol() + 1 SAY D4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4S PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4S PICTURE PicD
   ? M5

   IF PRow() > 55 + gpStranica; FF; else; ?;?; ENDIF

   ?? "REKAPITULACIJA PO KLASAMA NA DAN: ";?? Date()
   ?  M6
   ?  M7
   ?  M8
   ?  M9
   ?  M10

   SELECT BBKLAS; GO TOP


   nPocDug := nPocPot := nTekPDug := nTekPPot := nKumPDug := nKumPPot := nSalPDug := nSalPPot := 0

   DO WHILE !Eof()
      @ PRow() + 1, 4   SAY IdKlasa
      @ PRow(), 10       SAY PocDug               PICTURE PicD
      @ PRow(), PCol() + 1 SAY PocPot               PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPPot              PICTURE PicD

      nPocDug   += PocDug
      nPocPot   += PocPot
      nTekPDug  += TekPDug
      nTekPPot  += TekPPot
      nKumPDug  += KumPDug
      nKumPPot  += KumPPot
      nSalPDug  += SalPDug
      nSalPPot  += SalPPot
      SKIP
   ENDDO

   ? M10
   ? "UKUPNO:"
   @ PRow(), 10       SAY  nPocDug    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nPocPot    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPPot   PICTURE PicD
   ? M10

   FF

   END PRINT

   closeret

   RETURN


/*! \fn BrBil_21()
 *  \brief Zaglavlje analitickog bruto bilansa
 */

FUNCTION BrBil_21()

   ?
   P_COND2
   ?? "FIN: ANALITI¬KI BRUTO BILANS U VALUTI '" + Trim( cBBV ) + "'"
   IF !( Empty( dDatod ) .AND. Empty( dDatDo ) )
      ?? " ZA PERIOD OD", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()
   @ PRow(), IF( cFormat == "1", 220, 142 ) SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN
      HSEEK  cIdFirma
      ? "Firma:", cIdFirma, partn->naz, partn->naz2
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT ANAL

   ? M1
   ? M2
   ? M3
   ? M4
   ? M5

   RETURN
