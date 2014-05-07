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


STATIC __par_len




FUNCTION fin_bb_subanalitika_b( params )

   cIdFirma := gFirma

   O_KONTO
   O_PARTN

   __par_len := Len( partn->id )

   qqKonto := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   PRIVATE cFormat := "2"
   PRIVATE cPodKlas := "N"
   PRIVATE cNule := "D"
   PRIVATE cExpRptDN := "N"
   PRIVATE cBBSkrDN := "N"
   PRIVATE cPrikaz := "1"

   Box( "sanb", 13, 60 )
   SET CURSOR ON

   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "SUBANALITICKI BRUTO BILANS"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Konto " GET qqKonto    PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Od datuma :" GET dDatOD
      @ m_x + 4, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 6, m_y + 2 SAY "Format izvjestaja A3/A4/A4L (1/2/3)" GET cFormat
      @ m_x + 7, m_y + 2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas $ "DN" PICT "@!"
      @ m_x + 8, m_y + 2 SAY "Prikaz stavki sa saldom 0 D/N " GET cNule VALID cnule $ "DN" PICT "@!"
      cIdRJ := ""
      IF gRJ == "D"
         cIdRJ := "999999"
         @ m_x + 9, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
 	
      @ m_x + 10, m_y + 2 SAY "Export izvjestaja u dbf (D/N)? " GET cExpRptDN VALID cExpRptDN $ "DN" PICT "@!"
      @ m_x + 11, m_y + 2 SAY "Export skraceni bruto bilans (D/N)? " GET cBBSkrDN VALID cBBSkrDN $ "DN" PICT "@!"
	
      @ m_x + 12, m_y + 2 SAY "Prikaz suban (1) / suban+anal (2) / anal (3)" GET cPrikaz VALID cPrikaz $ "123" PICT "@!"
	
      READ
      ESC_BCR
 	
      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      IF aUsl1 <> NIL
         EXIT
      ENDIF
   ENDDO

   BoxC()

   cIdFirma := Trim( cIdFirma )

   IF cIdRj == "999999"
      cIdRj := ""
   ENDIF

   IF gRJ == "D" .AND. "." $ cIdRj
      cIdRj := Trim( StrTran( cIdRj, ".", "" ) )
   ENDIF

   IF cFormat $ "1#3"
      PRIVATE REP1_LEN := 236
      th1 := "---- ------- -------- --------------------------------------------------- -------------- ----------------- --------------------------------- ------------------------------- ------------------------------- -------------------------------"
      th2 := "*R. * KONTO *PARTNER *     NAZIV KONTA ILI PARTNERA                      *    MJESTO    *      ADRESA     *        PO¬ETNO STANJE           *         TEKUI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
      th3 := "                                                                                                           --------------------------------- ------------------------------- ------------------------------- -------------------------------"
      th4 := "*BR.*       *        *                                                   *              *                 *    DUGUJE       *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *     DUGUJE    *   POTRA¦UJE  *"
      th5 := "---- ------- -------- --------------------------------------------------- -------------- ----------------- ----------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   ELSE
      PRIVATE REP1_LEN := 158
      th1 := "---- ------- -------- -------------------------------------- --------------------------------- ------------------------------- -------------------------------"
      th2 := "*R. * KONTO *PARTNER *    NAZIV KONTA ILI PARTNERA          *        PO¬ETNO STANJE           *       KUMULATIVNI PROMET      *            SALDO             *"
      th3 := "                                                             --------------------------------- ------------------------------- -------------------------------"
      th4 := "*BR.*       *        *                                      *    DUGUJE       *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *     DUGUJE    *   POTRA¦UJE  *"
      th5 := "---- ------- -------- -------------------------------------- ----------------- --------------- --------------- --------------- --------------- ---------------"
   ENDIF

   PRIVATE lExpRpt := ( cExpRptDN == "D" )
   PRIVATE lBBSkraceni := ( cBBSkrDN == "D" )

   IF lExpRpt
      aExpFields := get_sbb_fields( lBBSkraceni, __par_len )
      t_exp_create( aExpFields )
      cLaunch := exp_report()
   ENDIF

   O_KONTO
   O_PARTN
   O_SUBAN
   O_KONTO
   O_BBKLAS

   SELECT BBKLAS
   ZAPP()

   PRIVATE cFilter := ""

   SELECT SUBAN

   IF gRj == "D" .AND. Len( cIdrj ) <> 0
      cFilter += iif( Empty( cFilter ), "", ".and." ) + "idrj=" + cm2str( cidrj )
   ENDIF

   IF aUsl1 <> ".t."
      cFilter += iif( Empty( cFilter ), "", ".and." ) + aUsl1
   ENDIF
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilter += iif( Empty( cFilter ), "", ".and." ) + "DATDOK>=CTOD('" + DToC( dDatOd ) + "') .and. DATDOK<=CTOD('" + DToC( dDatDo ) + "')"
   ENDIF

   IF !Empty( cFilter ) .AND. Len( cIdFirma ) == 2
      SET FILTER to &cFilter
   ENDIF

   IF Len( cIdFirma ) < 2
      SELECT SUBAN
      Box(, 2, 30 )
      nSlog := 0; nUkupno := RECCOUNT2()
      cFilt := IF( Empty( cFilter ), "IDFIRMA=" + cm2str( cIdFirma ), cFilter + ".and.IDFIRMA=" + cm2str( cIdFirma ) )
      cSort1 := "IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr"
      INDEX ON &cSort1 TO "SUBTMP" FOR &cFilt Eval( fin_tek_rec_2() ) EVERY 1
      GO TOP
      BoxC()
   ELSE
      HSEEK cIdFirma
   ENDIF

   EOF CRET

   nStr := 0

   BBMnoziSaK()

   START PRINT CRET


   B := B1 := B2 := 0  // brojaci

   SELECT SUBAN

   D1S := D2S := D3S := D4S := 0
   P1S := P2S := P3S := P4S := 0

   D4PS := P4PS := D4TP := P4TP := D4KP := P4KP := 0
   nCol1 := 50
   DO WHILE !Eof() .AND. IdFirma = cIdFirma   // idfirma

      IF PRow() == 0
         ZaglSan( cFormat )
      ENDIF

      // PS - pocetno stanje
      // TP - tekuci promet
      // KP - kumulativni promet
      // S - saldo

      D3PS := P3PS := D3TP := P3TP := D3KP := P3KP := D3S := P3S := 0
      cKlKonto := Left( IdKonto, 1 )

      DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cKlKonto == Left( IdKonto, 1 )

         cSinKonto := Left( IdKonto, 3 )
         D2PS := P2PS := D2TP := P2TP := D2KP := P2KP := D2S := P2S := 0

         DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cSinKonto == Left( IdKonto, 3 )

            cIdKonto := IdKonto
            D1PS := P1PS := D1TP := P1TP := D1KP := P1KP := D1S := P1S := 0
            DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == IdKonto
	
               cIdPartner := IdPartner
               D0PS := P0PS := D0TP := P0TP := D0KP := P0KP := D0S := P0S := 0

               DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner
	
                  IF cTip == ValDomaca()
                     IF D_P = "1"
                        D0KP += IznosBHD * nBBK
                     ELSE
                        P0KP += IznosBHD * nBBK
                     ENDIF
                  ELSE
                     IF D_P = "1"
                        D0KP += IznosDEM
                     ELSE
                        P0KP += IznosDEM
                     ENDIF
                  ENDIF

                  IF cTip == ValDomaca()
                     IF IdVN = "00"
                        IF D_P == "1"; D0PS += IznosBHD * nBBK; ELSE; P0PS += IznosBHD * nBBK; ENDIF
                     ELSE
                        IF D_P == "1"; D0TP += IznosBHD * nBBK; ELSE; P0TP += IznosBHD * nBBK; ENDIF
                     ENDIF
                  ELSE

                     IF IdVN = "00"
                        IF D_P == "1"; D0PS += IznosDEM; ELSE; P0PS += IznosDEM; ENDIF
                     ELSE
                        IF D_P == "1"; D0TP += IznosDEM; ELSE; P0TP += IznosDEM; ENDIF
                     ENDIF
                  ENDIF

                  SKIP
               ENDDO

               IF PRow() > 61 + gpStranica
                  FF
                  ZaglSan( cFormat )
               ENDIF

               IF ( cNule == "N" .AND. Round( D0KP - P0KP, 2 ) == 0 )
                  // ne prikazuj
               ELSE

                  @ PRow() + 1, 0 SAY  ++B  PICTURE '9999'    // ; ?? "."
                  @ PRow(), PCol() + 1 SAY cIdKonto
                  @ PRow(), PCol() + 1 SAY cIdPartner       // IdPartner(cIdPartner)
                  SELECT PARTN
                  HSEEK cIdPartner

                  IF cFormat == "2"
                     @ PRow(), PCol() + 1 SAY PadR( naz, 48 -Len ( cidpartner ) )   // difidp
                  ELSE
                     @ PRow(), PCol() + 1 SAY PadR( naz, 20 )
                     @ PRow(), PCol() + 1 SAY PadR( naz2, 20 )
                     @ PRow(), PCol() + 1 SAY Mjesto
                     @ PRow(), PCol() + 1 SAY Adresa PICTURE 'XXXXXXXXXXXXXXXXX'
                  ENDIF
                  SELECT SUBAN
                  nCol1 := PCol() + 1
                  @ PRow(), PCol() + 1 SAY D0PS PICTURE PicD
                  @ PRow(), PCol() + 1 SAY P0PS PICTURE PicD
                  IF cFormat == "1"
                     @ PRow(), PCol() + 1 SAY D0TP PICTURE PicD
                     @ PRow(), PCol() + 1 SAY P0TP PICTURE PicD
                  ENDIF
                  @ PRow(), PCol() + 1 SAY D0KP PICTURE PicD
                  @ PRow(), PCol() + 1 SAY P0KP PICTURE PicD
                  D0S := D0KP - P0KP
                  IF D0S >= 0
                     P0S := 0
                  ELSE
                     P0S := -D0S
                     D0S := 0
                  ENDIF
                  @ PRow(), PCol() + 1 SAY D0S PICTURE PicD
                  @ PRow(), PCol() + 1 SAY P0S PICTURE PicD
	
                  D1PS += D0PS;P1PS += P0PS;D1TP += D0TP;P1TP += P0TP;D1KP += D0KP;P1KP += P0KP

                  IF lExpRpt .AND. !Empty( cIdPartner ) .AND. cPrikaz $ "12"
                     IF lBBSkraceni
                        fill_ssbb_tbl( cIdKonto, cIdPartner, partn->naz, D0KP, P0KP, D0KP - P0KP )
                     ELSE
                        fill_sbb_tbl( cIdKonto, cIdPartner, partn->naz, D0PS, P0PS, D0KP, P0KP, D0S, P0S )
                     ENDIF
                  ENDIF
               ENDIF
	
            ENDDO // konto

            IF PRow() > 59 + gpStranica
               FF
               ZaglSan( cFormat )
            ENDIF

            @ PRow() + 1, 2 SAY Replicate( "-", REP1_LEN - 2 )
            @ PRow() + 1, 2 SAY ++B1 PICTURE '9999'      // ; ?? "."
            @ PRow(), PCol() + 1 SAY cIdKonto
            SELECT KONTO
            HSEEK cIdKonto
            IF cFormat == "1"
               @ PRow(), PCol() + 1 SAY naz
            ELSE
               @ PRow(), PCol() + 1 SAY Left ( naz, 47 )  // 40
            ENDIF
            SELECT SUBAN

            @ PRow(), nCol1     SAY D1PS PICTURE PicD
            @ PRow(), PCol() + 1  SAY P1PS PICTURE PicD
            IF cFormat == "1"
               @ PRow(), PCol() + 1  SAY D1TP PICTURE PicD
               @ PRow(), PCol() + 1  SAY P1TP PICTURE PicD
            ENDIF
            @ PRow(), PCol() + 1  SAY D1KP PICTURE PicD
            @ PRow(), PCol() + 1  SAY P1KP PICTURE PicD
	
            D1S := D1KP - P1KP

            IF D1S >= 0
               P1S := 0
               D2S += D1S;D3S += D1S;D4S += D1S
            ELSE
               P1S := -D1S; D1S := 0
               P2S += P1S;P3S += P1S;P4S += P1S
            ENDIF

            @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1S PICTURE PicD
            @ PRow() + 1, 2 SAY Replicate( "-", REP1_LEN - 2 )
	
            SELECT SUBAN
            D2PS += D1PS;P2PS += P1PS;D2TP += D1TP;P2TP += P1TP;D2KP += D1KP;P2KP += P1KP

            IF lExpRpt .AND. ( ( cPrikaz == "1" .AND. Empty( cIdPartner ) ) .OR. cPrikaz $ "23" )
               IF lBBSkraceni
                  fill_ssbb_tbl( cIdKonto, "", konto->naz, D1KP, P1KP, D1KP - P1KP )
               ELSE
                  fill_sbb_tbl( cIdKonto, "", konto->naz, D1PS, P1PS, D1KP, P1KP, D1S, P1S )
               ENDIF
            ENDIF

         ENDDO  // sin konto

         IF PRow() > 61 + gpStranica
            FF
            ZaglSan( cFormat )
         ENDIF

         @ PRow() + 1, 4 SAY Replicate( "=", REP1_LEN - 4 )
         @ PRow() + 1, 4 SAY ++B2 PICTURE '9999';?? "."
         @ PRow(), PCol() + 1 SAY cSinKonto
         SELECT KONTO; hseek cSinKonto
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY Left( naz, 50 )
         ELSE
            @ PRow(), PCol() + 1 SAY Left( naz, 44 )       // 45
         ENDIF
         SELECT SUBAN
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
         @ PRow() + 1, 4 SAY Replicate( "=", REP1_LEN - 4 )

         SELECT SUBAN

         D3PS += D2PS;P3PS += P2PS;D3TP += D2TP;P3TP += P2TP;D3KP += D2KP;P3KP += P2KP

         IF lExpRpt
            IF lBBSkraceni
               fill_ssbb_tbl( cSinKonto, "", konto->naz, D2KP, P2KP, D2KP - P2KP )
            ELSE
               fill_sbb_tbl( cSinKonto, "", konto->naz, D2PS, P2PS, D2KP, P2KP, D2S, P2S )
            ENDIF
         ENDIF
	
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
      SELECT SUBAN

      IF cPodKlas == "D"
         ? th5
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
         ? th5
      ENDIF

      D4PS += D3PS;P4PS += P3PS;D4TP += D3TP;P4TP += P3TP;D4KP += D3KP;P4KP += P3KP

      IF lExpRpt
         IF lBBSkraceni
            fill_ssbb_tbl( cKlKonto, "", konto->naz, D3KP, P3KP, D3KP - P3KP )
         ELSE
            fill_sbb_tbl( cKlKonto, "", konto->naz, D3PS, P3PS, D3KP, P3KP, D3S, P3S )
         ENDIF
      ENDIF
	
   ENDDO

   IF PRow() > 59 + gpStranica
      FF
      ZaglSan( cFormat )
   ENDIF

   ? th5
   @ PRow() + 1, 6 SAY "UKUPNO:"
   @ PRow(), nCol1 SAY D4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4PS PICTURE PicD
   IF cFormat == "1"
      @ PRow(), PCol() + 1 SAY D4TP PICTURE PicD
      @ PRow(), PCol() + 1 SAY P4TP PICTURE PicD
   ENDIF
   @ PRow(), PCol() + 1 SAY D4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4S PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4S PICTURE PicD
   ? th5

   IF lExpRpt
      IF lBBSkraceni
         fill_ssbb_tbl( "UKUPNO", "", "", D4KP, P4KP, D4KP - P4KP )
      ELSE
         fill_sbb_tbl( "UKUPNO", "", "", D4PS, P4PS, D4KP, P4KP, D4S, P4S )
      ENDIF
   ENDIF

   IF PRow() > 55 + gpStranica; FF; ELSE; ?;?; ENDIF

   ?? "REKAPITULACIJA PO KLASAMA NA DAN:"; @ PRow(), PCol() + 2 SAY Date()
   ? M6
   ? M7
   ? M8
   ? M9
   ? M10

   SELECT BBKLAS
   GO TOP
   nPocDug := nPocPot := nTekPDug := nTekPPot := nKumPDug := nKumPPot := nSalPDug := nSalPPot := 0

   DO WHILE !Eof()
      IF PRow() > 63 + gpStranica; FF; ENDIF
      @ PRow() + 1, 4      SAY IdKlasa
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

   IF PRow() > 59 + gpStranica; FF; ENDIF
   ? M10
   ? "UKUPNO:"
   @ PRow(), 10 SAY  nPocDug    PICTURE PicD
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

   IF lExpRpt
      tbl_export( cLaunch )
   ENDIF

   RETURN




/*! \fn ZaglSan()
 *  \brief Zaglavlje strane subanalitickog bruto bilansa
 */

FUNCTION ZaglSan( cFormat )

   IF cFormat == nil
      cFormat := "2"
   ENDIF

   ?

   IF cFormat $ "1#3"
      ? "#%LANDS#"
   ENDIF

   P_COND2

   ?? "FIN: SUBANALITI¬KI BRUTO BILANS U VALUTI '" + Trim( cBBV ) + "'"
   IF !( Empty( dDatod ) .AND. Empty( dDatDo ) )
      ?? " ZA PERIOD OD", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()
   @ PRow(), REP1_LEN - 15 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      ? "Firma:"
      @ PRow(), PCol() + 2 SAY cIdFirma
      SELECT PARTN
      HSEEK cIdFirma
      @ PRow(), PCol() + 2 SAY Naz; @ PRow(), PCol() + 2 SAY Naz2
   ENDIF

   IF gRJ == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   ? th1
   ? th2
   ? th3
   ? th4
   ? th5

   SELECT SUBAN

   RETURN



STATIC FUNCTION fill_ssbb_tbl( cKonto, cIdPart, cNaziv, ;
      nFDug, nFPot, nFSaldo )

   LOCAL nArr

   nArr := Select()

   O_R_EXP
   APPEND BLANK
   REPLACE field->konto WITH cKonto
   REPLACE field->idpart WITH cIdPart
   REPLACE field->naziv WITH cNaziv
   REPLACE field->duguje WITH nFDug
   REPLACE field->potrazuje WITH nFPot
   REPLACE field->saldo WITH nFSaldo

   SELECT ( nArr )

   RETURN


STATIC FUNCTION fill_sbb_tbl( cKonto, cIdPart, cNaziv, ;
      nPsDug, nPsPot, nKumDug, nKumPot, ;
      nSldDug, nSldPot )

   LOCAL nArr

   nArr := Select()

   O_R_EXP
   APPEND BLANK
   REPLACE field->konto WITH cKonto
   REPLACE field->idpart WITH cIdPart
   REPLACE field->naziv WITH cNaziv
   REPLACE field->psdug WITH nPsDug
   REPLACE field->pspot WITH nPsPot
   REPLACE field->kumdug WITH nKumDug
   REPLACE field->kumpot WITH nKumPot
   REPLACE field->slddug WITH nSldDug
   REPLACE field->sldpot WITH nSldPot

   SELECT ( nArr )

   RETURN



STATIC FUNCTION get_sbb_fields( lBBSkraceni, nPartLen )

   IF nPartLen == nil
      nPartLen := 6
   ENDIF

   aFields := {}
   AAdd( aFields, { "konto", "C", 7, 0 } )
   AAdd( aFields, { "idpart", "C", nPartLen, 0 } )
   AAdd( aFields, { "naziv", "C", 40, 0 } )

   IF lBBSkraceni
      AAdd( aFields, { "duguje", "N", 15, 2 } )
      AAdd( aFields, { "potrazuje", "N", 15, 2 } )
      AAdd( aFields, { "saldo", "N", 15, 2 } )
   ELSE
      AAdd( aFields, { "psdug", "N", 15, 2 } )
      AAdd( aFields, { "pspot", "N", 15, 2 } )
      AAdd( aFields, { "kumdug", "N", 15, 2 } )
      AAdd( aFields, { "kumpot", "N", 15, 2 } )
      AAdd( aFields, { "slddug", "N", 15, 2 } )
      AAdd( aFields, { "sldpot", "N", 15, 2 } )
   ENDIF

   RETURN aFields



FUNCTION fin_bb_txt_header()

   M6 := "--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   M7 := "*        *          PO¬ETNO STANJE       *         TEKUI PROMET         *        KUMULATIVNI PROMET     *            SALDO             *"
   M8 := "  KLASA   ------------------------------- ------------------------------- ------------------------------- -------------------------------"
   M9 := "*        *    DUGUJE     *   POTRA¦UJE   *     DUGUJE    *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *     DUGUJE    *    POTRA¦UJE *"
   M10 := "--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"

   RETURN
