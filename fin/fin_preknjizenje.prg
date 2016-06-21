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

// ----------------------------------------------------------
// preknjizenje konta
// ----------------------------------------------------------
FUNCTION prefin_unos_naloga()

   LOCAL fK1 := "N"
   LOCAL fk2 := "N"
   LOCAL fk3 := "N"
   LOCAL fk4 := "N"
   LOCAL cSK := "N"

   nC := 50

   O_PARAMS

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "k1", @fk1 )
   RPar( "k2", @fk2 )
   RPar( "k3", @fk3 )
   RPar( "k4", @fk4 )

   SELECT params
   USE

   cIdFirma := gFirma
   picBHD := FormPicL( "9 " + gPicBHD, 20 )

   O_PARTN

   dDatOd := CToD( "" )
   dDatDo := CToD( "" )

   qqKonto := Space( 100 )
   qqPartner := Space( 100 )
   IF gRJ == "D"
      qqIdRj := Space( 100 )
   ENDIF

   cTip := "1"

   Box( "", 14, 65 )
   SET CURSOR ON

   cK1 := "9"
   cK2 := "9"
   cK3 := "99"
   cK4 := "99"
   cNula := "N"
   cPreknjizi := "P"
   cStrana := "D"
   cIDVN := "88"
   cBrNal := "00000001"
   dDatDok := Date()
   cRascl := "D"
   PRIVATE lRJRascl := .F.


   DO WHILE .T.
      @ m_x + 1, m_y + 6 SAY "PREKNJIZENJE SUBANALITICKIH KONTA"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Konto   " GET qqKonto  PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Partner " GET qqPartner PICT "@!S50"
      IF gRJ == "D"
         @ m_x + 5, m_y + 2 SAY "Rad.jed." GET qqIdRj PICT "@!S50"
         @ m_x + 6, m_y + 2 SAY "Rasclaniti po RJ" GET cRascl PICT "@!" VALID cRascl $ "DN"
      ENDIF
      @ m_x + 7, m_y + 2 SAY "Datum dokumenta od" GET dDatOd
      @ m_x + 7, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 8, m_y + 2 SAY "Protustav/Storno/Saldo (P/S/T) " GET cPreknjizi VALID cPreknjizi $ "PST" PICT "@!"
      READ

      IF cPreknjizi == "T"
         @ m_x + 9, m_y + 38 SAY "Duguje/Potrazuje (D/P)" GET cStrana VALID cStrana $ "DP" PICT "@!"
      ENDIF

      @ m_x + 10, m_y + 2 SAY "Sifra naloga koji se generise" GET cIDVN
      @ m_x + 10, Col() + 2 SAY "Broj" GET cBrNal
      @ m_x + 10, Col() + 2 SAY "datum" GET dDatDok
      IF fk1 == "D"
         @ m_x + 11, m_y + 2 SAY "K1 (9 svi) :" GET cK1
      ENDIF
      IF fk2 == "D"
         @ m_x + 12, m_y + 2 SAY "K2 (9 svi) :" GET cK2
      ENDIF
      IF fk3 == "D"
         @ m_x + 13, m_y + 2 SAY "K3 (" + cK3 + " svi):" GET cK3
      ENDIF
      IF fk4 == "D"
         @ m_x + 14, m_y + 2 SAY "K4 (99 svi):" GET cK4
      ENDIF

      READ
      ESC_BCR

      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      aUsl2 := Parsiraj( qqPartner, "IdPartner" )

      IF gRJ == "D"
         IF cRascl == "D"
            lRJRascl := .T.
         ENDIF
      ENDIF

      IF gRJ == "D"
         aUsl3 := Parsiraj( qqIdRj, "IdRj" )
      ENDIF

      IF aUsl1 <> NIL .AND. aUsl2 <> NIL
         EXIT
      ENDIF

      IF gRJ == "D" .AND. aUsl3 <> NIL
         EXIT
      ENDIF

   ENDDO
   BoxC()

   cIdFirma := Left( cIdFirma, 2 )

   O_FIN_PRIPR
   O_KONTO
   o_suban()

   IF cK1 == "9"
      cK1 := ""
   ENDIF
   IF cK2 == "9"
      cK2 := ""
   ENDIF
   IF cK3 == REPL( "9", Len( ck3 ) )
      cK3 := ""
   ELSE
      cK3 := K3U256( cK3 )
   ENDIF
   IF cK4 == "99"
      cK4 := ""
   ENDIF

   SELECT SUBAN

   IF ( gRj == "D" .AND. lRjRascl )
      SET ORDER TO TAG "9" // idfirma+idkonto+idrj+idpartner+...
   ELSE
      SET ORDER TO TAG "1"
   ENDIF

   cFilt1 := "IDFIRMA=" + dbf_quote( cIdFirma ) + ".and." + aUsl1 + ".and." + aUsl2 + IF( gRJ == "D", ".and." + aUsl3, "" ) + ;
      IF( Empty( dDatOd ), "", ".and.DATDOK>=" + dbf_quote( dDatOd ) ) + ;
      IF( Empty( dDatDo ), "", ".and.DATDOK<=" + dbf_quote( dDatDo ) ) + ;
      IF( fk1 == "N", "", ".and.k1=" + dbf_quote( ck1 ) ) + ;
      IF( fk2 == "N", "", ".and.k2=" + dbf_quote( ck2 ) ) + ;
      IF( fk3 == "N", "", ".and.k3=ck3" ) + ;
      IF( fk4 == "N", "", ".and.k4=" + dbf_quote( ck4 ) )

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   GO TOP
   EOF CRET

   Pic := PicBhd

   IF cTip == "3"
      m := "------  ------ ------------------------------------------------- --------------------- --------------------"
   ELSE
      m := "------  ------ ------------------------------------------------- --------------------- -------------------- --------------------"
   ENDIF

   nStr := 0
   nUd := 0
   nUp := 0      // DIN
   nUd2 := 0
   nUp2 := 0    // DEM
   nRbr := 0

   SELECT fin_pripr
   GO BOTTOM
   nRbr := Val( rbr )
   SELECT suban

   DO WHILE !Eof()
      cSin := Left( idkonto, 3 )
      nKd := 0
      nKp := 0
      nKd2 := 0
      nKp2 := 0
      DO WHILE !Eof() .AND.  cSin == Left( idkonto, 3 )
         cIdKonto := IdKonto
         cIdPartner := IdPartner
         IF gRj == "D"
            cIdRj := idRj
         ENDIF
         nD := 0
         nP := 0
         nD2 := 0
         nP2 := 0

         IF ( gRj == "D" .AND. lRjRascl )
            bCond := {|| cIdKonto == IdKonto .AND. IdRj == cIdRj .AND. IdPartner == cIdPartner }
         ELSE
            bCond := {|| cIdKonto == IdKonto .AND. IdPartner == cIdPartner }
         ENDIF

         DO WHILE !Eof() .AND. Eval( bCond )
            IF d_P == "1"
               nD += iznosbhd
               nD2 += iznosdem
            ELSE
               nP += iznosbhd
               nP2 += iznosdem
            ENDIF
            SKIP
         ENDDO    // partner

         SELECT fin_pripr

         // dodata opcija za preknjizenje saldo T
         IF cPreknjizi == "T"
            IF Round( nD - nP, 2 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE d_p WITH iif( cStrana == "D", "1", "2" ), iznosbhd with ( nD - nP ), iznosdem with ( nD2 - nP2 )
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
         ENDIF

         IF cPreknjizi == "P"
            IF Round( nD - nP, 2 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE  d_p WITH iif( nD - nP > 0, "2", "1" ), iznosbhd WITH Abs( nD - nP ), iznosdem WITH Abs( nD2 - nP2 )
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
         ENDIF

         IF cPreknjizi == "S"
            IF Round( nD, 3 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE  d_p WITH "1", iznosbhd WITH -nd, iznosdem WITH -nd2
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
            IF Round( nP, 3 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE  d_p WITH "2", iznosbhd WITH -nP, iznosdem WITH -nP2
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
         ENDIF
         SELECT suban
         nKd += nD
         nKp += nP  // ukupno  za klasu
         nKd2 += nD2
         nKp2 += nP2  // ukupno  za klasu
      ENDDO  // sintetika
      nUd += nKd
      nUp += nKp   // ukupno za sve
      nUd2 += nKd2
      nUp2 += nKp2   // ukupno za sve
   ENDDO // eof

   my_close_all_dbf()
   RETURN
