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


#include "f18.ch"

STATIC PICD
STATIC REP1_LEN := 158 


FUNCTION fin_bb_grupe_b( params )

   LOCAL nPom
   LOCAL cIdFirma := params[ "idfirma" ]
   LOCAL dDatOd := params[ "datum_od" ]
   LOCAL dDatDo := params[ "datum_do" ]
   LOCAL qqKonto := params[ "konto" ]
   LOCAL cIdRj := params[ "id_rj" ]
   LOCAL lNule := params[ "saldo_nula" ]
   LOCAL lPodKlas := params[ "podklase" ]
   LOCAL cFormat := params["format"]
   LOCAL cKlKonto, cSinKonto, cIdKonto, cIdPartner
   LOCAL cFilter, aUsl1, nStr := 0
   LOCAL b, b1, b2
   LOCAL nValuta := params[ "valuta" ]
   LOCAL nBBK := 1
   LOCAL aNaziv, nColNaz
   PRIVATE M6, M7, M8, M9, M10
 
   PICD := FormPicL( gPicBHD, 15 )

   IF gRJ == "D" .AND. ( "." $ cIdRj )
      cIdRj := Trim( StrTran( cIdRj, ".", "" ) )
   ENDIF

   M1 := "------ ----------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
   M2 := "*REDNI*   GRUPA   *        POČETNO STANJE         *         TEKUĆI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
   M3 := "          KONTA    ------------------------------- ------------------------------- ------------------------------- -------------------------------"
   M4 := "*BROJ *           *    DUGUJE     *   POTRAŽUJE   *    DUGUJE     *   POTRAŽUJE   *    DUGUJE     *   POTRAŽUJE   *    DUGUJE     *   POTRAŽUJE  *"
   M5 := "------ ----------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"

   fin_bb_txt_header()

   O_PARTN
   O_KONTO
   O_BBKLAS

   SELECT BBKLAS
   my_dbf_zap()

   IF gRJ == "D" .AND. Len( cIdRJ ) <> 0
      otvori_sint_anal_kroz_temp( .T., "IDRJ='" + cIdRJ + "'" )
   ELSE
      O_SINT
   ENDIF

   cFilter := ""

   IF !( Empty( qqkonto ) )
      aUsl1 := Parsiraj( qqKonto, "idkonto" )
      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         cFilter := aUsl1 + ".and. DATNAL>=" + dbf_quote( dDatOd ) + " .and. DATNAL<=" + dbf_quote( dDatDo )
      ELSE
         cFilter := aUsl1
      ENDIF
   ELSEIF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilter := "DATNAL>=" + dbf_quote( dDatOd ) + " .and. DATNAL<=" + dbf_quote( dDatDo )
   ENDIF

   IF Len( cIdFirma ) < 2
      SELECT SINT
      Box(, 2, 30 )
      nSlog := 0
      nUkupno := RECCOUNT2()
      cFilt := IF( Empty( cFilter ), "IDFIRMA=" + dbf_quote( cIdFirma ), cFilter + ".and.IDFIRMA=" + dbf_quote( cIdFirma ) )
      cSort1 := "IdKonto+dtos(DatNal)"
      INDEX ON &cSort1 TO "SINTMP" FOR &cFilt Eval( fin_tek_rec_2() ) EVERY 1
      GO TOP
      BoxC()
   ELSE
      IF !Empty( cFilter )
         SET FILTER TO &cFilter
      ENDIF
      HSEEK cIdFirma
   ENDIF

   EOF CRET

   nStr := 0

   start_print_close_ret()

   B := 1
   D1S := D2S := D3S := D4S := P1S := P2S := P3S := P4S := 0
   D4PS := P4PS := D4TP := P4TP := D4KP := P4KP := D4S := P4S := 0

   nCol1 := 50

   DO WHILE !Eof() .AND. IdFirma = cIdFirma

      IF PRow() == 0
         zagl_bb_grupe( params, @nStr )
      ENDIF

      cKlKonto := Left( IdKonto, 1 )

      D3PS := P3PS := D3TP := P3TP := D3KP := P3KP := D3S := P3S := 0

      DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cKlKonto == Left( IdKonto, 1 )

         cIdKonto := Left( IdKonto, 2 )

         D1PS := P1PS := D1TP := P1TP := D1KP := P1KP := D1S := P1S := 0

         DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == Left( IdKonto, 2 )

            IF nValuta == 1
               Dug := DugBHD * nBBK
               Pot := PotBHD * nBBK
            ELSE 
               Dug := DUGDEM
               Pot := POTDEM
            ENDIF

            D1KP += Dug
            P1KP += Pot

            IF IdVN = "00"
               D1PS += Dug
               P1PS += Pot
            ELSE
               D1TP += Dug
               P1TP += Pot
            ENDIF
            SKIP
         ENDDO 

         IF PRow() > 63 + dodatni_redovi_po_stranici()
             FF
             zagl_bb_grupe( params, @nStr )
         ENDIF

         @ PRow() + 1, 1 SAY B PICTURE '9999'
         ?? "."
         @ PRow(), 10 SAY PadC( cIdKonto, 8 )
         nCol1 := PCol() + 1
         @ PRow(), PCol() + 1 SAY D1PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY D1TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D1KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1KP PICTURE PicD

         D1S := D1KP - P1KP

         IF D1S >= 0
            P1S := 0
            D3S += D1S
            D4S += D1S
         ELSE
            P1S := -D1S
            D1S := 0
            P3S += P1S
            P4S += P1S
         ENDIF

         @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1S PICTURE PicD

         SELECT SINT

         D3PS += D1PS
         P3PS += P1PS
         D3TP += D1TP
         P3TP += P1TP
         D3KP += D1KP
         P3KP += P1KP

         ++B

      ENDDO

      SELECT BBKLAS
      APPEND BLANK
      RREPLACE IdKlasa WITH cKlKonto, ;
         PocDug  WITH D3PS, ;
         PocPot  WITH P3PS, ;
         TekPDug WITH D3TP, ;
         TekPPot WITH P3TP, ;
         KumPDug WITH D3KP, ;
         KumPPot WITH P3KP, ;
         SalPDug WITH D3S, ;
         SalPPot WITH P3S

      SELECT SINT

      IF lPodKlas
         ?U M5
         ? "UKUPNO KLASA " + cklkonto
         @ PRow(), nCol1    SAY D3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3S PICTURE PicD
         ?U M5
      ENDIF

      D4PS += D3PS
      P4PS += P3PS
      D4TP += D3TP
      P4TP += P3TP
      D4KP += D3KP
      P4KP += P3KP

   ENDDO

   IF PRow() > 58 + dodatni_redovi_po_stranici()
      FF 
      zagl_bb_grupe( params, @nStr )
   ENDIF

   ?U M5
   ? "UKUPNO:"
   @ PRow(), nCol1    SAY D4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4TP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4TP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4S PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4S PICTURE PicD
   ?U M5

   nPom := d4ps - p4ps

   @ PRow() + 1, nCol1   SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD

   nPom := d4tp - p4tp
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD

   nPom := d4kp - p4kp
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD

   nPom := d4s - p4s
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD
   ? M5

   FF

   ?? "REKAPITULACIJA PO KLASAMA NA DAN: "
   ?? Date()
   ?U  M6
   ?U  M7
   ?U  M8
   ?U  M9
   ?U  M10

   SELECT BBKLAS
   GO TOP

   nPocDug := nPocPot := nTekPDug := nTekPPot := nKumPDug := nKumPPot := nSalPDug := nSalPPot := 0

   DO WHILE !Eof()
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

   ?U M10
   ? "UKUPNO:"
   @ PRow(), 10       SAY  nPocDug    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nPocPot    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPPot   PICTURE PicD
   ?U M10

   FF
   end_print()

   my_close_all_dbf()

   RETURN



STATIC FUNCTION zagl_bb_grupe( params, nStr )

   ?
   P_COND2

   ??U "FIN.P:BRUTO BILANS PO GRUPAMA KONTA U VALUTI '" + IF( params[ "valuta" ] == 1, ValDomaca(), ValPomocna() ) + "'"

   IF !( Empty( params["datum_od"] ) .AND. Empty( params["datum_do"] ) )
      ?? " ZA PERIOD OD", params["datum_od"], "-", params["datum_do"]
   ENDIF

   ?? " NA DAN: "
   ?? Date()
   ?? " (v.B)"

   @ PRow(), REP1_LEN - 15 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      ? "Firma:"
      @ PRow(), PCol() + 2 SAY params["idfirma"]
      SELECT PARTN
      HSEEK params["idfirma"]
      @ PRow(), PCol() + 2 SAY Naz
      @ PRow(), PCol() + 2 SAY Naz2
   ENDIF

   IF !EMPTY( params["konto"] )
      ? "Odabrana konta: " + ALLTRIM( params["konto"] )
   ENDIF

   IF gRJ == "D" .AND. Len( params["id_rj"] ) <> 0
      ? "Radna jedinica ='" + params["id_rj"] + "'"
   ENDIF

   SELECT SINT

   ?U M1
   ?U M2
   ?U M3
   ?U M4
   ?U M5

   RETURN


