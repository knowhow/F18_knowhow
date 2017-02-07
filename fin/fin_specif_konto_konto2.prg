#include "f18.ch"

/* SpecKK2
 *     Specifikacija konto/konto2 partner
 *   param: lOtvSt


FUNCTION SpecKK2( lOtvSt )

   LOCAL fK1 := fk2 := fk3 := fk4 := "N", nC1 := 35

   cIdFirma := self_organizacija_id()

   PRIVATE picBHD := FormPicL( "9 " + gPicBHD, 16 )
   PRIVATE picDEM := FormPicL( "9 " + gPicDEM, 14 ), cPG := "D"
   PRIVATE lOtvoreneStavke := lOtvSt

   o_konto()
--   o_partner()


   cDinDem := "1"
   dDatOd := dDatDo := CToD( "" )
   cKumul := cPredh := "1"
   PRIVATE qqKonto := qqKonto2 := qqPartner := ""

   IF gNW == "D";cIdFirma := self_organizacija_id(); ENDIF
   cK1 := cK2 := "9"; cK3 := cK4 := "99"

   IF my_get_from_ini( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
      ck3 := "999"
   ENDIF

   cNula := "D"

   qqPartner := PadR( qqPartner, 60 )
   Box( "", 17, 65 )
   SET CURSOR ON
   @ form_x_koord() + 1, form_y_koord() + 2 SAY "SPECIFIKACIJA SUBANALITIKE KONTO/KONTO2"
   READ
   DO WHILE .T.

      IF gNW == "D"
         @ form_x_koord() + 3, form_y_koord() + 2 SAY "Firma "; ?? self_organizacija_id(), "-", self_organizacija_naziv()
      ELSE
         @ form_x_koord() + 3, form_y_koord() + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF

      qqKonto := PadR( qqKonto, 7 )
      qqKonto2 := PadR( qqKonto2, 7 )
      @ form_x_koord() + 5, form_y_koord() + 2 SAY "Konto   " GET qqKonto  VALID P_KontoFin( @qqKonto )
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Konto 2 " GET qqKonto2  VALID P_KontoFin( @qqKonto2 ) .AND. qqKonto2 > qqkonto
      @ form_x_koord() + 7, form_y_koord() + 2 SAY "Partner " GET qqPartner PICT "@!S50"
      @ form_x_koord() + 8, form_y_koord() + 2 SAY "Datum dokumenta od:" GET dDatod
      @ form_x_koord() + 8, Col() + 2 SAY "do" GET dDatDo   VALID dDatOd <= dDatDo
      @ form_x_koord() + 9, form_y_koord() + 2 SAY "Prikazi mjesto partnera (D/N)" GET cPG PICT "@!" VALID cPG $ "DN"
      IF fin_dvovalutno()
         @ form_x_koord() + 10, form_y_koord() + 2 SAY "Prikaz " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + " (1/2)" GET cDinDem PICT "@!" VALID cDinDem $ "12"
      ENDIF
      @ form_x_koord() + 11, form_y_koord() + 2 SAY "Prikaz stavki sa saldom 0 D/N/2/4" GET cNula PICT "@!" VALID cNula  $ "DN24"

      IF fk1 == "D"; @ form_x_koord() + 14, form_y_koord() + 2 SAY "K1 (9 svi) :" GET cK1; ENDIF
      IF fk2 == "D"; @ form_x_koord() + 15, form_y_koord() + 2 SAY "K2 (9 svi) :" GET cK2; ENDIF
      IF fk3 == "D"; @ form_x_koord() + 16, form_y_koord() + 2 SAY "K3 (" + ck3 + " svi):" GET cK3; ENDIF
      IF fk4 == "D"; @ form_x_koord() + 17, form_y_koord() + 2 SAY "K4 (99 svi):" GET cK4; ENDIF

      read; ESC_BCR

      aUsl1 := Parsiraj( qqPartner, "IdPartner", "C" )

      IF aUsl1 <> NIL; exit; ENDIF // ako je NIL - sintaksna greska

   ENDDO

   BoxC()

   IF cPG == "N"
      PRIVATE m := Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " ------------------------- ---------------- ---------------- ----------------"
   ELSE
      PRIVATE m := Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " ------------------------- ---------------- ---------------- ---------------- ----------------"
   ENDIF

   o_suban()

   cIdRj := "999999"  // samo da program ne ispada u f-ji CistiK1K4()
   cFunk := "99999"
   cFond := "9999"
   CistiK1K4()

   SELECT SUBAN
   // 2: "IdFirma+IdPartner+IdKonto"
   SET ORDER TO TAG "2"

   cFilt1 := ".t."

   IF  fk1 == "N" .AND. fk2 == "N" .AND. fk3 == "N" .AND. fk4 == "N"

      IF Empty( dDatOd ) .AND. Empty( dDatDo )
         IF Len( aUsl1 ) == 0
            cFilt1 := ".t."
         ELSE
            cFilt1 := aUsl1
         ENDIF
      ELSE
         cFilt1 := "DATDOK>=" + dbf_quote( dDatOd ) + ".and.DATDOK<=" + dbf_quote( dDatDo ) + ".and." + aUsl1
      ENDIF

   ELSE  // odigraj sa ck4
      IF Empty( dDatOd ) .AND. Empty( dDatDo )
         cFilt1 := aUsl1 + ".and.k1=" + dbf_quote( ck1 ) + ".and.k2=" + dbf_quote( ck2 ) + ;
            ".and.k3=ck3.and.k4=" + dbf_quote( ck4 )
      ELSE
         cFilt1 := "DATDOK>=" + dbf_quote( dDatOd ) + ".and.DATDOK<=" + dbf_quote( dDatDo ) + ".and." + ;
            aUsl1 + ".and.k1=" + dbf_quote( ck1 ) + ".and.k2=" + dbf_quote( ck2 ) + ;
            ".and.k3=ck3.and.k4=" + dbf_quote( ck4 )
      ENDIF
   ENDIF

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   -- HSEEK cidfirma

   EOF CRET

   nStr := 0

   IF !start_print()
      RETURN .F.
   ENDIF



   IF nStr == 0; Zagl7(); ENDIF


   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
   DO WHILE !Eof() .AND. IdFirma == cIdFirma



      cIdPartner := IdPartner

      nDBHD := nPBHD := nDDEM := nPDEM := 0
      SEEK cidfirma + cidpartner + qqkonto
      IF !Found()
         SEEK cidfirma + cidpartner + qqkonto2
         IF !Found()
            SEEK cidfirma + cidpartner + "!"
         ENDIF
      ENDIF

      DO WHILE !Eof() .AND. IdFirma == cIdFirma .AND. cIdpartner == idpartner
         IF idkonto == qqkonto
            IF D_P == "1"
               nDBHD += iznosbhd
               nDDEM += iznosdem
            ELSE
               nDBHD -= iznosbhd
               nDDEM -= iznosdem
            ENDIF
         ELSEIF idkonto == qqkonto2
            IF D_P == "1"
               nPBHD -= iznosbhd
               nPDEM -= iznosdem
            ELSE
               nPBHD += iznosbhd
               nPDEM += iznosdem
            ENDIF
         ENDIF
         SKIP
      ENDDO

      fuslov := .F.
      IF  cNula == "D"
         IF ( ndbhd <> 0 .OR. npbhd <> 0 )
            fuslov := .T.
         ENDIF
      ELSEIF cnula == "N"
         IF Round( nDBHD - nPBHD, 3 ) <> 0
            fuslov := .T.
         ENDIF
      ELSEIF cnula == "2"
         IF Round( nDBHD - nPBHD, 3 ) <> 0   .AND.  Round( ndbhd, 3 ) <> 0  .AND. Round( npbhd, 3 ) <> 0
            fuslov := .T.
            // i saldo 1 i saldo2 su zivi ,   i ukupan saldo <>0
         ENDIF

      ELSEIF cnula == "4"
         IF Round( ndbhd, 3 ) <> 0  .AND. Round( npbhd, 3 ) <> 0
            fuslov := .T.
            // bitno je sa su saldo 1 i saldo2 su zivi
         ENDIF
      ENDIF

      IF fUslov
         IF PRow() > 56 + dodatni_redovi_po_stranici()
            FF
            Zagl7()
         ENDIF

         @ PRow() + 1, 0 SAY cidpartner

      --   SELECT partn
      --   HSEEK cIdPartner
         SELECT suban

         @ PRow(), PCol() + 1 SAY PadR( partn->naz, 25 )

         IF cPG == "D"
            @ PRow(), PCol() + 1 SAY PARTN->Mjesto
         ENDIF

         nC1 := PCol() + 1

         IF cDinDem == "1"
            @ PRow(), PCol() + 1 SAY nDBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nPBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nDBHD - nPBHD PICTURE picBHD
            nDugBHD += nDBHD
            nPotBHD += nPBHD
         ELSEIF cDinDem == "2"   // devize
            @ PRow(), PCol() + 1 SAY nDDEM PICTURE picbhd
            @ PRow(), PCol() + 1 SAY nPDEM PICTURE picbhd
            @ PRow(), PCol() + 1 SAY nDDEM - nPDEM PICTURE picbhd
            nDugDEM += nDDEM
            nPotDEM += nPDEM
         ENDIF
      ENDIF


   ENDDO
   ? M
   ? "UKUPNO:"

   IF cDinDem == "1"
      @ PRow(), nC1      SAY nDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
   ELSEIF cDinDem == "2"
      @ PRow(), nC1      SAY nDugDEM PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picbhd
   ENDIF
   ? m

   FF
   end_print()
   closeret

   RETURN



STATIC FUNCTION Zagl7()

   ?
   P_COND
   ?? "FIN: SPECIFIKACIJA SUBANALITIKE ", qqkonto, "-", qqkonto2, " ZA "
   IF cDinDem == "1"
      ?? ValDomaca()
   ELSEIF cDinDem == "2"
      ?? ValPomocna()
   ENDIF
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "  ZA DOKUMENTE U PERIODU ", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", self_organizacija_id(), self_organizacija_naziv()
   ELSE
    --  SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, PadR( partn->naz, 25 ), partn->naz2
   ENDIF

   SELECT SUBAN

   ? m
   IF cPG = "D"
      ? PadR( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + " PARTNER                       MJESTO           saldo1         saldo2           saldo"
   ELSE
      ? PadR( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + "  PARTNER                       saldo1           saldo2           saldo"
   ENDIF
   ? m

   RETURN


 */
