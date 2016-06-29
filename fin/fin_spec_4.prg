#include "f18.ch"

/* SpecOstPop()
 *     Specifikacija otvorenih stavki po kontima za partnera
 */
FUNCTION SpecOstPop()

   //
   LOCAL nCol1 := nCol2 := 0

   M := "----- ------- ----------------------------- ----------------- ---------------- ------------ ------------ ---------------- ------------"

   cIdFirma := gFirma
   qqPartner := qqKonto := Space( 70 )
   picBHD := FormPicL( "9 " + gPicBHD, 13 )
   picDEM := FormPicL( "9 " + gPicDEM, 10 )

   O_PARTN


   Box( "SSK", 6, 60, .F. )

   DO WHILE .T.
      @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA KONTA ZA ODREDJENE PARTNERE"
      IF gNW == "D"
         @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 5, m_y + 2 SAY "Partner:" GET qqPartner PICT "@!S50"
      @ m_x + 6, m_y + 2 SAY "Konta  :" GET  qqKonto PICT "@!S50"
      READ; ESC_BCR
      aUsl := parsiraj( qqPartner, "idpartner" )
      aUsl2 := parsiraj( qqKonto, "idkonto" )
      IF aUsl <> NIL; exit; ENDIF
   ENDDO

   BoxC()

   nDugBHD := nPotBHD := nUkDugBHD := nUkPotBHD := 0
   nDugDEM := nPotDEM := nUKDugDEM := nUkPotDEM := 0

   O_KONTO
   o_suban()

   SELECT SUBAN; SET ORDER TO TAG "2"  // idfirma+idpartner+idkonto
   cIdFirma := Left( cIdFirma, 2 )

   cFilt1 := aUsl + ".and." + aUsl2

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF !( cFilt1 == ".t." )
      SET FILTER to &cFilt1
   ENDIF

   HSEEK cIdFirma
   EOF CRET

   IF !start_print()
      RETURN .F.
   ENDIF


   B := 0
   DO WHILE cIdFirma == IdFirma .AND. !Eof()

      cIdKonto := IdKonto
      cIdPartner := IdPartner
      B := 0
      nUkDugBHD := nUkPotBHD := 0
      nUKDugDEM := nUkPotDEM := 0
      DO WHILE cIdFirma == IdFirma .AND. !Eof() .AND. cIdPartner = IdPartner
         cIdKonto := IdKonto
         IF PRow() == 0; ZglSpOstP(); ENDIF
         nDugBHD := nPotBHD := 0
         nDugDEM := nPotDEM := 0
         DO WHILE cIdFirma == IdFirma .AND.  !Eof() .AND. cIdPartner == IdPartner .AND. cIdKonto == IdKonto
            IF D_P = "1"
               nDugBHD += IznosBHD; nUkDugBHD += IznosBHD
               nDugDEM += IznosDEM; nUkDugDEM += IznosDEM
            ELSE
               nPotBHD += IznosBHD; nUkPotBHD += IznosBHD
               nPotDEM += IznosDEM; nUkPotDEM += IznosDEM
            ENDIF
            SKIP
         ENDDO
         ? m
         @ PRow() + 1, 1 SAY ++B PICTURE '9999'
         @ PRow(), 6 SAY cIdKonto
         SELECT KONTO; HSEEK cIdKonto
         aRez := SjeciStr( naz, 30 )
         nCol2 := PCol() + 1
         @ PRow(), PCol() + 1 SAY PadR( aRez[ 1 ], 30 )
         nCol1 := PCol() + 1
         @ PRow(), PCol() + 1 SAY nDugBHD PICTURE picBHD
         @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
         @ PRow(), PCol() + 1 SAY nDugDEM PICTURE picDEM
         @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picDEM

         nSaldo := nDugBHD - nPotBHD
         nSaldo2 := nDugDEM - nPotDEM
         @ PRow(), PCol() + 1 SAY nSaldo  PICTURE picBHD
         @ PRow(), PCol() + 1 SAY nSaldo2 PICTURE picDEM

         FOR i := 2 TO Len( aRez )
            @ PRow() + 1, nCol2 SAY aRez[ i ]
         NEXT

         SELECT SUBAN
         nDugBHD := nPotBHD := 0; nDugDEM := nPotDEM := 0

         IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; ENDIF
      ENDDO   // partner

      ? M
      ? "Uk:"
      @ PRow(), PCol() + 1 SAY cIdPartner
      SELECT PARTN; HSEEK cIdPartner
      @ PRow(), PCol() + 1 SAY Left( naz, 28 )
      SELECT SUBAN
      @ PRow(), nCol1    SAY nUkDugBHD PICT picBHD
      @ PRow(), PCol() + 1 SAY nUkPotBHD PICT picBHD
      @ PRow(), PCol() + 1 SAY nUkDugDEM PICT picDEM
      @ PRow(), PCol() + 1 SAY nUkPotDEM PICT picDEM
      @ PRow(), PCol() + 1 SAY nUkDugBHD - nUkPotBHD  PICT picBHD
      @ PRow(), PCol() + 1 SAY nUkDugDEM - nUkPotDEM  PICT picDEM
      ? M

      ?
      ?

   ENDDO

   FF

   end_print()
   CLOSERET

   RETURN



/* ZglSpOstP()
 *     Zaglavlje specifikacije otvorenih stavki partnera po kontima
 */
FUNCTION ZglSpOstP()

   ?
   P_COND
   ?? "FIN: SPECIFIKACIJA OTVORENIH STAVKI PARTNERA :"
   @ PRow(), PCol() + 2 SAY "PO KONTIMA NA DAN :"
   @ PRow(), PCol() + 2 SAY Date()
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )


   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, PadR( partn->naz, 25 ), partn->naz2
   ENDIF

   ? "----- ------- ----------------------------- ------------------------------------------------------------ -----------------------------"
   ? "*RED.* KONTO *       N A Z I V             *     K U M U L A T I V N I    P R O M E T                   *      S A L D O              "
   ? "                                            ------------------------------------------------------------ -----------------------------"
   ? "*BROJ*       *       K O N T A             *  DUGUJE   " + ValDomaca() + "  *  POTRA�UJE " + ValDomaca() + "* DUGUJE " + ValPomocna() + "* POTRA� " + ValPomocna() + "*    " + ValDomaca() + "        *    " + ValPomocna() + "   *"
   ? M

   SELECT SUBAN

   RETURN
