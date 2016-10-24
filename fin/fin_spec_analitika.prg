#include "f18.ch"

/* SpecPoK()
 * Specifikacija po analitickim kontima
 */

FUNCTION SpecPoK()

   LOCAL cSK := "N"
   PRIVATE nC := 66

   cIdFirma := gFirma
   picBHD := FormPicL( "9 " + gPicBHD, 20 )

   O_PARTN

   dDatOd := dDatDo := CToD( "" )

   qqKonto := Space( 100 )

   cTip := "1"
   Box( "", 10, 65 )
   SET CURSOR ON

   cNula := "N"

   DO WHILE .T.
      @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA ANALITICKIH KONTA"
      IF gNW == "D"
         @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 4, m_y + 2 SAY "Konto " GET qqKonto  PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Datum od" GET dDatOd
      @ m_x + 5, Col() + 2 SAY "do" GET dDatDo
      IF fin_dvovalutno()
         @ m_x + 6, m_y + 2 SAY "Obracun za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + " (1/2):" GET cTip VALID ctip $ "12"
      ENDIF
      @ m_x + 7, m_y + 2 SAY "Prikaz sintetickih konta (D/N):" GET cSK PICT "@!" VALID cSK $ "DN"
      @ m_x + 9, m_y + 2 SAY "Prikaz stavki sa saldom 0 D/N" GET cNula PICT "@!" VALID cNula  $ "DN"
      cIdRJ := ""
      IF gFinRj == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 10, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      IF ausl1 <> NIL; exit; ENDIF
   ENDDO

    BoxC()

   IF cIdRj == "999999"; cidrj := ""; ENDIF

   IF gFinRj == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cidrj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   cIdFirma := Left( cIdFirma, 2 )

   O_KONTO
   IF gFinRj == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      otvori_sint_anal_kroz_temp( .F., "IDRJ='" + cIdRJ + "'" )
   ELSE
      o_anal()
   ENDIF

   SELECT ANAL
   SET ORDER TO TAG "1"


   cFilt1 := "IdFirma==" + dbf_quote( cIdFirma )
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilt1 += ( ".and.DatNal>=" + dbf_quote( dDatOd ) + ".and.DatNal<=" + dbf_quote( dDatDo ) )
   ENDIF
   IF aUsl1 <> ".t."
      cFilt1 += ( ".and." + aUsl1 )
   ENDIF


   SET FILTER to &cFilt1

   GO TOP

   EOF CRET

   Pic := PicBhd


   IF !start_print()
      RETURN .F.
   ENDIF

   m := "------ --------------------------------------------------------- --------------------- -------------------- --------------------"
   nStr := 0

   nud := nup := 0
   DO WHILE !Eof()
      cSin := Left( idkonto, 3 )
      nkd := nkp := 0
      DO WHILE !Eof() .AND.  cSin == Left( idkonto, 3 )
         cIdKonto := IdKonto
         nd := np := 0
         IF PRow() == 0; zagl5(); ENDIF
         DO WHILE !Eof() .AND. cIdKonto == IdKonto
            IF cTip == "1"
               nd += dugbhd; np += potbhd
            ELSE
               nd += dugdem; np += potdem
            ENDIF
            SKIP
         ENDDO
         IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; zagl5(); ENDIF

         SELECT KONTO; HSEEK cidkonto; SELECT ANAL

         IF cNula == "D" .OR. Round( nd - np, 3 ) <> 0
            ? cidkonto, KONTO->naz
            nC := PCol() + 1
            @ PRow(), PCol() + 1 SAY nd PICT pic
            @ PRow(), PCol() + 1 SAY np PICT pic
            @ PRow(), PCol() + 1 SAY nd - np PICT pic
            nkd += nd; nkp += np  // ukupno  za klasu
         ENDIF  // cnula

      ENDDO  // sintetika

      IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; zagl5(); ENDIF
      IF cSK == "D" .AND. ( nkd != 0 .OR. nkp != 0 )
         ? m
         ?  "SINT.K.", cSin, ":"
         @ PRow(), nC       SAY nKd PICT pic
         @ PRow(), PCol() + 1 SAY nKp PICT pic
         @ PRow(), PCol() + 1 SAY nKd - nKp PICT pic
         ? m
      ENDIF
      nUd += nKd; nUp += nKp   // ukupno za sve
   ENDDO
   IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; zagl5(); ENDIF
   ? m
   ? " UKUPNO:"
   @ PRow(), nC       SAY nUd PICT pic
   @ PRow(), PCol() + 1 SAY nUp PICT pic
   @ PRow(), PCol() + 1 SAY nUd - nUp PICT pic
   ? m
   FF
   end_print()
   closeret

   RETURN



/* Zagl5()
 *  brief Zaglavlje specifikacije po kontima
 */

STATIC FUNCTION Zagl5()

   ?
   P_COND
   ?? "FIN.P:SPECIFIKACIJA ANALITICKIH KONTA  ZA", AllTrim( iif( cTip == "1", ValDomaca(), ValPomocna() ) )
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "  ZA NALOGE U PERIODU ", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()

   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, PadR( partn->naz, 25 ), partn->naz2
   ENDIF

   IF gFinRj == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT ANAL
   ? m
   ? "KONTO      N A Z I V                                                           duguje            potrazuje                saldo"
   ? m

   RETURN .T.
