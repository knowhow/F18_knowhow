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

STATIC __par_len


FUNCTION SpecDPK()

   LOCAL nCol1

   picBHD := FormPicL( "9 " + gPicBHD, 17 )

   cF := cDD := "2"
   // format izvjestaja
   cPG := "D"
   // prikazi grad partnera
   cIdFirma := gFirma
   nIznos := nIznos2 := 0
   cDP := "1"
   qqKonto := qqPartner := Space( 100 )

   O_PARTN

   __par_len := Len( partn->id )

   Box( "skpoi", 10, 70, .F. )
   @ m_x + 1, m_y + 2 SAY "SPECIFIKACIJA PARTNERA NA KONTU"
   IF gNW == "D"
      @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 4, m_y + 2 SAY "Konto  " GET qqKonto PICTURE "@!S50"
   @ m_x + 5, m_y + 2 SAY "Partner" GET qqPartner PICTURE "@!S50"
   @ m_x + 6, m_y + 2 SAY "Duguje/Potrazuje (1/2) ?" GET cDP PICTURE "@!" VALID cDP $ "12"
   @ m_x + 7, m_y + 2 SAY "IZNOS " + ValDomaca() GET nIznos  PICTURE '999999999999.99'
   IF gVar1 <> "1"
      @ m_x + 8, m_y + 2 SAY "IZNOS " + ValPomocna() GET nIznos2 PICTURE '9999999999.99'
   ENDIF
   @ m_x + 9, m_y + 2 SAY "Format izvjestaja A3/A4 (1/2) :" GET cF VALID cF $ "12"
   @ m_x + 10, m_y + 2 SAY "Prikazi grad partnera (D/N) :" GET cPG PICT "@!" VALID cPG $ "DN"
   READ
   IF cF == "2"
      IF gVar1 == "0"
         @ m_x + 10, m_y + 40 SAY AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + " (1/2):" GET cDD VALID cDD $ "12"
         READ
      ELSE
         cDD := "1"
      ENDIF
   ENDIF

   DO WHILE .T.
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "IdKonto", "C" )
      aUsl2 := Parsiraj( qqPartner, "IdPartner", "C" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL;  exit; ENDIF
   ENDDO

   BoxC()

   B := 0

   cIdFirma := Left( cIdFirma, 2 )

   IF cF == "1"
      M := "----- " + Replicate( "-", __par_len ) + " ------------------------------------ ----------------------- ------------------ ----------------- ----------------- ----------------- ----------------- ----------------- ----------------- -----------------"
   ELSEIF cPG == "D"
      M := "---- " + Replicate( "-", __par_len ) + " ------------------------- ---------------- ----------------- ----------------- ----------------- -----------------"
   ELSE
      M := "---- " + Replicate( "-", __par_len ) + " ------------------------- ----------------- ----------------- ----------------- -----------------"
   ENDIF
   O_SUBAN
   SELECT SUBAN
   PRIVATE cFilt1 := "IdFirma=='" + cIdFirma + "'.and." + aUsl1 + ".and." + aUsl2
   SET FILTER to &cFilt1


   GO TOP
   EOF CRET

   nStr := 0
   START PRINT CRET
   DO WHILE !Eof()
      nSD1DEM := nSP1DEM := nSD1BHD := nSP1BHD := 0

      cIdKonto := IdKonto
      IF PRow() <> 0; FF; ZaglDPK(); ENDIF

      nUkDugBHD := nUkPotBHD := nUkDugDEM := nUkPotDEM := 0
      DO WHILE !Eof() .AND. cIdKonto = IdKonto // konto

         cIdPartner := IdPartner

         nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
         DO WHILE  !Eof() .AND. cIdKonto = IdKonto .AND. cIdPartner == IdPartner
            IF D_P = "1"
               nDugBHD += IznosBHD; nDugDEM += IznosDEM
            ELSE
               nPotBHD += IznosBHD; nPotDEM += IznosDEM
            ENDIF
            SKIP
         ENDDO

         nRazl := nDugBHD - nPotBHD
         nRazl2 := nDugDEM - nPotDEM
         IF cDP == "2"
            nRazl := -nRazl; nRazl2 := -nRazl2
         ENDIF

         IF ( nIznos == 0 .OR. ( nRazl > nIznos ) )  .AND. ( nIznos2 == 0 .OR. ( nRazl2 > nIznos2 ) )

            // ako je nRazl=0 uzeti sve partnere
            IF PRow() == 0
               ZaglDPK()
            ENDIF

            IF PRow() > 60 + gPStranica
               FF
               ZaglDPK()
            ENDIF

            @ PRow() + 1, 0 SAY ++B PICTURE '9999'
            @ PRow(), 5 SAY cIdPartner

            SELECT PARTN
            HSEEK cIdPartner

            @ PRow(), PCol() + 1 SAY PadR( naz, 25 )

            IF cF == "1" // a3 format

               @ PRow(), PCol() + 1 SAY PadR( naz2, 25 ) PICT 'XXXXXXXXXXXX'
               @ PRow(), PCol() + 1 SAY PTT
               @ PRow(), PCol() + 1 SAY PadR( Mjesto, 16 ) PICT 'XXXXXXXXXXXXXXXX'

            ELSEIF cPG == "D"

               @ PRow(), PCol() + 1 SAY PadR( Mjesto, 16 ) PICT 'XXXXXXXXXXXXXXXX'
            ENDIF

            nCol1 := PCol()

            IF cF == "1" .OR. cDD = "1"
               @ PRow(), PCol() + 1 SAY nDugBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
            ENDIF
            IF cF == "1" .OR. cDD = "2"
               @ PRow(), PCol() + 1 SAY nDugDEM PICTURE picbhd
               @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picbhd
            ENDIF
            nUkDugBHD += nDugBHD
            nUkDugDEM += nDugDEM
            nUkPotBHD += nPotBHD
            nUkPotDEM += nPotDEM

            nSDBHD := nDugBHD - nPotBHD
            nSDDEM := nDugDEM - nPotDEM

            IF nSDBHD >= 0
               nSPBHD := 0; nSPDEM := 0
            ELSE
               nSPBHD := -nSDBHD; nSPDEM := -nSDDEM
               nSDBHD := nSDDEM := 0
            ENDIF

            IF cF == "1" .OR. cDD = "1"
               @ PRow(), PCol() + 1 SAY nSDBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nSPBHD PICTURE picBHD
            ENDIF
            IF cF == "1" .OR. cDD = "2"
               @ PRow(), PCol() + 1 SAY nSDDEM PICTURE picbhd
               @ PRow(), PCol() + 1 SAY nSPDEM PICTURE picbhd
            ENDIF

            nSD1DEM += nSDDEM; nSP1DEM += nSPDEM
            nSD1BHD += nSDBHD; nSP1BHD += nSPBHD
            SELECT SUBAN

         ENDIF


      ENDDO // konto

      IF PRow() > 60 + gPStranica; FF; ZaglDPK(); ENDIF
      ?  M
      ? "UKUPNO ZA KONTO:"
      @ PRow(), nCol1 SAY ""
      IF cF == "1" .OR. cDD == "1"
         @ PRow(), PCol() + 1      SAY nUkDugBHD PICTURE picBHD
         @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE picBHD
      ENDIF
      IF cF == "1" .OR. cDD == "2"
         @ PRow(), PCol() + 1 SAY nUkDugDEM PICTURE picbhd
         @ PRow(), PCol() + 1 SAY nUkPotDEM PICTURE picbhd
      ENDIF

      nCol2 := PCol()

      IF cF == "1" .OR. cDD = "1"
         @ PRow(), PCol() + 1 SAY nSD1BHD PICTURE picBHD // dug bhd ukupno
         @ PRow(), PCol() + 1 SAY nSP1BHD PICTURE picBHD // pot bhd ukupno
      ENDIF

      IF cF == "1" .OR. cDD = "2"
         @ PRow(), PCol() + 1 SAY nSD1DEM PICTURE picbhd // dug dem ukupno
         @ PRow(), PCol() + 1 SAY nSP1DEM PICTURE picbhd // pot dem ukupno
      ENDIF
      ? M
      @ PRow() + 1, nCol2 SAY ""

      IF cF == "1" .OR. cDD = "1"
         nSaldo := nUkDugBHD - nUkPotBHD
         @ PRow(), PCol() + 1 SAY iif( nSaldo >= 0, nSaldo, 0 ) PICTURE picBHD // dug bhd
         nSaldo := nUkPotBHD - nUkDugBHD
         @ PRow(), PCol() + 1 SAY iif( nSaldo >= 0, nSaldo, 0 ) PICTURE picBHD // pot bhd
      ENDIF

      IF cF == "1" .OR. cDD = "2"
         nSaldo := nUkDugDEM - nUkPotDEM
         @ PRow(), PCol() + 1 SAY iif( nSaldo >= 0, nSaldo, 0 ) PICTURE picbhd // dug dem
         nSaldo := nUkPotDEM - nUkDugDEM
         @ PRow(), PCol() + 1 SAY iif( nSaldo >= 0, nSaldo, 0 ) PICTURE picbhd // pot dem
      ENDIF
      ? M


   ENDDO // eof()

   FF
   ENDPRINT

   closeret

   RETURN




/*! \fn ZaglDPK()
 *  \brief Zaglavlje specifikacije partnera po kontu
 */

FUNCTION ZaglDPK()

   ?
   P_COND
   ?? "FIN.P: SPECIFIKACIJA "
   @ PRow(), PCol() + 2 SAY ""
   IF !Empty( qqPartner )
      ?? " PARTNERA:", Trim( qqpartner ), "  "
   ELSE
      ?? " SVIH PARTNERA  "
   ENDIF
   IF nIznos <> 0
      IF cDP == "1"
         ?? "KOJI DUGUJU PREKO", nIznos, AllTrim( ValDomaca() )
      ELSE
         ?? "KOJI POTRA�UJU PREKO", nIznos, AllTrim( ValDomaca() )
      ENDIF
   ELSEIF nIznos2 <> 0
      IF cDP == "1"
         ?? "KOJI DUGUJU PREKO", nIznos2, AllTrim( ValPomocna() )
      ELSE
         ?? "KOJI POTRA�UJU PREKO", nIznos2, AllTrim( ValPomocna() )
      ENDIF
   ENDIF
   ?? "  NA DAN :", Date()
   IF cF == "1"
      @ PRow(), 200 SAY "Str:" + Str( ++nStr, 3 )
   ELSE
      @ PRow(), 100 SAY "Str:" + Str( ++nStr, 3 )
      IF cDD == "1"
         @ PRow() + 1, 4 SAY "*** OBRA�UN ZA " + ValDomaca() + "****"
      ELSE
         @ PRow() + 1, 4 SAY "*** OBRA�UN ZA " + ValPomocna() + "****"
      ENDIF
   ENDIF
   @ PRow() + 1, 0 SAY " FIRMA:"
   @ PRow(), PCol() + 2 SAY cIdFirma
   SELECT PARTN; HSEEK cIdFirma
   @ PRow(), PCol() + 1 SAY AllTrim( PadR( naz, 25 ) ); @ PRow(), PCol() + 1 SAY naz2

   @ PRow(), PCol() + 2 SAY "KONTO:"; @ PRow(), PCol() + 2 SAY cIdKonto
   IF cF == "1"
      ? "----- " + Replicate( "-", __par_len ) + " ------------------------------------ ----- ----------------- ----------------------------------------------------------------------- -----------------------------------------------------------------------"
      ? "*RED.*" + PadC( "�IFRA", __par_len ) + "*     NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *       K  U  M  U  L  A  T  I  V  N  I       P  R  O  M  E  T           *                 S      A      L      D       O                       *"
      ? "      " + REPL( " ", __par_len ) + "                                                              ----------------------------------------------------------------------- -----------------------------------------------------------------------"
      ? "*BROJ*" + Replicate( " ", __par_len ) + "*                                   * BROJ*                 *   DUGUJE   " + ValDomaca() + "  *  POTRA�UJE " + ValDomaca() + " *   DUGUJE  " + ValPomocna() + "  *   POTRA�. " + ValPomocna() + "  *    DUGUJE " + ValDomaca() + "  *  POTRA�UJE " + ValDomaca() + " *   DUGUJE  " + ValPomocna() + "  *   POTRA�." + ValPomocna() + "  *"
      ? m
   ELSEIF cPG == "D"
      ? "----- " + Replicate( "-", __par_len ) + " ------------------------ ---------------- ----------------------------------- -----------------------------------"
      ? "*RED.*" + PadC( "�IFRA", __par_len ) + "*     NAZIV POSLOVNOG    *     MJESTO     *         KUMULATIVNI  PROMET       *               SALDO              *"
      ? "                                                       ----------------------------------- -----------------------------------"
      ? "*BROJ*" + Replicate( " ", __par_len )  + "*     PARTNERA           *                *    DUGUJE       *   POTRA�UJE     *    DUGUJE       *   POTRA�UJE    *"
      ? m
   ELSE
      ? "----- " + Replicate( "-", __par_len ) + " ------------------------ ----------------------------------- -----------------------------------"
      ? "*RED.*" + PadC( "SIFRA", __par_len ) + "*      NAZIV POSLOVNOG    *         KUMULATIVNI  PROMET       *               SALDO              *"
      ? "      " + REPL( " ", __par_len ) + "                        ----------------------------------- -----------------------------------"
      ? "*BROJ*" + Replicate( " ", __par_len ) + "*      PARTNERA           *    DUGUJE       *   POTRA�UJE     *    DUGUJE       *   POTRA�UJE    *"
      ? m
   ENDIF


   SELECT SUBAN

   RETURN



/*! \fn SpecBrDan()
 *  \brief Otvorene stavke preko odredjenog broja dana
 */

FUNCTION SpecBrDan()

   LOCAL nCol1 := 0

   picBHD := FormPicL( "9 " + gPicBHD, 16 )
   picDEM := FormPicL( "9 " + gPicDEM, 16 )



   cIdFirma := gFirma; nIznosBHD := 0; nDana := 30; cIdKonto := Space( 7 )

   O_KONTO
   O_PARTN
   dDatumOd := CToD( "" )
   dDatum := Date()
   cUkupnoPartner := "D"
   cPojed := "D"
   cD_P := "1"
   __par_len := Len( partn->id )
   qqBrDok := Space( 40 )

   M := "----- " + Replicate( "-", __par_len ) + " ----------------------------------- ------ ---------------- -------- -------- --------- -----------------"
   IF gVar1 == "0"
      M += " ----------------"
   ENDIF


   // Markeri otvorenih stavki
   // D - uzeti u obzir markere
   // N - izvjestaj saldirati bez obzira na markere, sabirajuci prema broju veze
   cMarkeri := "N"
   IF IzFmkIni( "FIN", "Ostav_Markeri", "N", KUMPATH ) == "D"
      cMarkeri := "D"
   ENDIF

   // uzeti u obzir datum valutiranja
   PRIVATE cObzirDatVal := "D"
   IF IzFmkIni( "FIN", "Ostav_DatVal", "D", KUMPATH ) == "N"
      cObzirDatVal := "N"
   ENDIF


   Box( "skpoi", 14, 70, .F. )
   @ m_x + 1, m_y + 2 SAY "OTVORENE STAVKE PREKO/DO ODREDJENOG BROJA DANA"
   IF gNW == "D"
      @ m_x + 3, m_y + 2 SAY "Firma "
      ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   PRIVATE cViseManje := ">"
   @ m_x + 4, m_y + 2 SAY "KONTO  " GET cIdKonto VALID P_KontoFin( @cIdKonto )
   @ m_x + 5, m_y + 2 SAY "Broj dana ?" GET cViseManje VALID cViseManje $ "><"
   @ m_x + 5, Col() + 2 GET nDana PICTURE "9999"

   @ m_x + 6, m_y + 2 SAY "obracun od " GET dDatumOd
   @ m_x + 6, Col() + 2 SAY  "do datuma:" GET dDatum
   @ m_x + 8, m_y + 2 SAY "duguje/potrazuje (1/2):" GET cD_P
   @ m_x + 9, m_y + 2 SAY "Uzeti u obzir datum valutiranja :" GET cObzirDatVal PICT "@!" VALID cObzirDatVal $ "DN" when {|| cObzirDatVal := iif( cViseManje = ">", "D", "N" ), .T. }
   @ m_x + 10, m_y + 2 SAY "Uzeti u obzir markere           :" GET cMarkeri     PICT "@!" VALID cObzirDatVal $ "DN"

   @ m_x + 12, m_y + 2 SAY "prikaz pojedinacnog racuna:" GET cPojed VALID cPojed $ "DN" PICT "@!"
   @ m_x + 13, m_y + 2 SAY "prikaz ukupno za partnera :" GET cUkupnoPartner VALID cUkupnoPartner $ "DN" PICT "@!"
   @ m_x + 14, m_y + 2 SAY "Uslov za broj veze (prazno-svi)" GET qqBrDok PICT "@S20"
   READ
   ESC_BCR

   BoxC()

   B := 0

   cIdFirma := Left( cIdFirma, 2 )

   nStr := 0

   IF IzFMKIni( "FAKT", "VrstePlacanja", "N", SIFPATH ) == "D"
      O_VRSTEP
   ENDIF

   O_SUBAN ; SET ORDER TO TAG "3"
   // "IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)"
   HSEEK cIdFirma + cIdKonto

   EOF CRET

   START PRINT CRET

   cIdKonto := IdKonto

   IF PRow() <> 0
      FF
      ZaglSpBrDana()
   ENDIF

   IF !Empty( qqBrDok )
      aUslBrDok := {}
      aUslBrDok := TOKuNIZ( AllTrim( qqBrDok ), ";" )
   ENDIF


   KDIN := KDEM := 0   // ukupno za konto BHD,DEM
   DO WHILE !Eof() .AND. cIdKonto == IdKonto

      cIdPartner := Idpartner
      nDinP := nDemP := 0
      DO WHILE !Eof() .AND. cIdKonto == IdKonto .AND. idpartner == cidpartner

         dDatDok := CToD( "" )
         cBrdok := field->brdok

         IF !Empty( qqBrDok ) .AND. Len( aUslBrDok ) <> 0
            lFound := .F.
            FOR i := 1 TO Len( aUslBrDok )
               nOdsjeci := Len( aUslBrDok[ i, 1 ] )
               IF Right( AllTrim( cBrdok ), nOdsjeci ) == aUslBrDok[ i, 1 ]
                  lFound := .T.
                  EXIT
               ENDIF
            NEXT
            IF !lFound
               SKIP
               LOOP
            ENDIF
         ENDIF


         nDin := nDEM := 0
         DO WHILE !Eof() .AND. idkonto == cidkonto .AND. idpartner == cidpartner .AND. ;
               brdok == cBrdok

            IF ( cMarkeri == "N" .OR. OtvSt = " " )

               IF  DatDok <= dDatum  .AND. ;// stavke samo do zadanog datuma !!
                  ( Empty( dDatumOd ) .OR. DatDok >= dDatumOd )
                  IF cD_P == "1" // kupci
                     IF d_P == "1"
                        nDin += IznosBHD  ; nDEM += IznosDEM
                     ELSE
                        nDin -= IznosBHD  ; nDEM -= IznosDEM
                     ENDIF
                  ELSE  // dobalja�i
                     IF d_P == "2"
                        nDin += IznosBHD  ; nDEM += IznosDEM
                     ELSE
                        nDin -= IznosBHD  ; nDEM -= IznosDEM
                     ENDIF
                  ENDIF

               ENDIF

               IF ( cD_P == "1" .AND. D_P == "1"  .AND. iznosbhd > 0 ) .OR. ;
                     ( cD_P == "2" .AND. D_P == "2"  .AND. iznosbhd > 0 )
                  // dDatDok:=datdok
                  IF cObzirDatVal == "D"
                     // uzima se u obzir datum valutiranja
                     dDatDok := iif( Empty( DATVAL ), DATDOK, DATVAL )
                  ELSE
                     dDatDok := DatDok
                  ENDIF

               ENDIF

            ENDIF // otvst =" "

            SKIP
         ENDDO

         IF !Empty( dDatDok ) .AND. iif( cViseManje = ">", dDatum - dDatDok > nDana, ( dDatum - dDatDok > 0 .AND. dDatum - dDatDok <= nDana ) ) .AND. ;
               Abs( Round( nDin, 4 ) ) > 0

            KDIN += nDin; KDEM += nDEM
            nDINP += nDin; nDEMP += nDEM
            IF cPojed == "D"

               IF PRow() == 0
                  ZaglSpBrDana()
               ENDIF
               IF PRow() > 60 + gPStranica
                  FF
                  ZaglSpBrDana()
               ENDIF

               @ PRow() + 1, 1 SAY ++B PICTURE '9999'
               @ PRow(), PCol() + 1 SAY cIdPartner
               SELECT PARTN
               HSEEK cIdPartner
               @ PRow(), PCol() + 1 SAY PadR( naz, 25 )
               @ PRow(), PCol() + 1 SAY naz2 PICTURE 'XXXXXXXXXX'
               @ PRow(), PCol() + 1 SAY PTT
               @ PRow(), PCol() + 1 SAY Mjesto

               SELECT SUBAN

               @ PRow(), PCol() + 1 SAY cBrDok
               @ PRow(), PCol() + 1 SAY dDatDok
               @ PRow(), PCol() + 1 SAY k1 + "-" + k2 + "-" + k3iz256( k3 ) + k4
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY nDin PICTURE picBHD
               IF gVar1 = "0"
                  @ PRow(), PCol() + 1 SAY nDEM PICTURE picDEM
               ENDIF
            ENDIF // cpojed=="D"

         ENDIF  // dana

      ENDDO // partner

      IF cUkupnoPartner == "D"  .AND. Abs( Round( nDinP, 4 ) ) > 0

         IF cpojed == "D"
            ? m
         ENDIF

         IF PRow() == 0; ZaglSpBrDana(); ENDIF
         IF PRow() > 60 + gPStranica; FF; ZaglSpBrDana(); ENDIF

         IF cPojed == "N"
            @ PRow() + 1, 1 SAY ++B PICTURE '9999'
         ELSE
            @ PRow() + 1, 1 SAY Space( 4 )
         ENDIF
         @ PRow(), PCol() + 1 SAY cIdPartner
         SELECT PARTN
         HSEEK cIdPartner
         @ PRow(), PCol() + 1 SAY PadR( naz, 25 )
         @ PRow(), PCol() + 1 SAY naz2 PICT 'XXXXXXXXXX'
         @ PRow(), PCol() + 1 SAY PTT
         @ PRow(), PCol() + 1 SAY Mjesto
         SELECT SUBAN

         @ PRow(), PCol() + 1 SAY Space( Len( cBrDok ) )
         @ PRow(), PCol() + 1 SAY Space( 8 )  // dDatDok
         @ PRow(), PCol() + 1 SAY k1 + "-" + k2 + "-" + k3iz256( k3 ) + k4
         nCol1 := PCol() + 1
         @ PRow(), PCol() + 1 SAY nDinP PICTURE picBHD
         IF gVar1 = "0"
            @ PRow(), PCol() + 1 SAY nDEMP PICTURE picDEM
         ENDIF

         IF cpojed == "D"
            ? m
         ENDIF
      ENDIF

   ENDDO  // konto
   IF PRow() > 60 + gPStranica; FF; ZaglSpBrDana(); ENDIF
   ? M
   ? "UKUPNO ZA KONTO:"
   @ PRow(), nCol1    SAY KDIN PICTURE picBHD
   IF gVar1 = "0"
      @ PRow(), PCol() + 1 SAY KDEM PICTURE picDEM
   ENDIF
   ? M


   FF
   ENDPRINT

   closeret

   RETURN



/*! \fn ZaglSpBrDana()
 *  \brief Zaglavlje za otvorene stavke preko odredjenog broja dana
 */

FUNCTION ZaglSpBrDana()

   LOCAL cPom

   ?
   P_COND
   ?? "FIN: SPECIFIKACIJA PARTNERA SA NEPLA�ENIM RA�UNIMA " + iif( cViseManje = ">", "PREKO ", "DO " ) + Str( nDana, 3 ) + " DANA  NA DAN "; ?? dDatum
   IF !Empty( dDatumOd )
      ? "     obuhva�en je period:", dDatumOd, "-", dDatum
   ENDIF

   IF !Empty( qqBrDok )
      ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '" + AllTrim( qqBrDok ) + "'"
   ENDIF

   @ PRow(), 123 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, PadR( partn->naz, 25 ), partn->naz2
   ENDIF

   ? "KONTO:", cIdkonto

   SELECT SUBAN

   ? "----- " + Replicate( "-", __par_len ) + " ----------------------------------- ------ ---------------- -------- -------- -------- "
   ?? Replicate( "-", 17 )
   IF gVar1 == "0" // dvovalutno
      ?? " " + Replicate( "-", 17 )
   ENDIF
   ? "*RED *" + PadC( "PART-", __par_len ) + "*      NAZIV POSLOVNOG PARTNERA      PTT     MJESTO         *  BROJ  * DATUM  * K1-K4  *"
   IF gVar1 == "0"
      ?? PadC( "NEPLA�ENO", 35 )
   ELSE
      ?? PadC( "NEPLA�ENO", 17 )
   ENDIF

   ? " BR. " + PadC( "NER", __par_len ) + "                                                                                         "

   ?? Replicate( "-", 17 )
   IF gVar1 == "0" // dvovalutno
      ?? " " + Replicate( "-", 17 )
   ENDIF

   ? "*    *" + Replicate( " ", __par_len ) + "*                                                           * RA�UNA *" + iif( cObzirDatVal == "D", " VALUTE ", " RA�UNA " ) + "*        *"

   cPom := ""
   IF cD_P = "1"
      cPom += "    DUGUJE "
   ELSE
      cPom += "   POTRA�. "
   ENDIF
   cPom += ValDomaca() + "  * "

   IF gVar1 = "0" // dvovalutno
      IF cD_P = "1"
         cPom += "  DUGUJE "
      ELSE
         cPom += " POTRA�. "
      ENDIF
      cPom += ValPomocna() + "  *"
   ENDIF
   ?? cPom

   ? m

   RETURN

// ---------------------------------------------------
// Specifikacija subanalitickih konta
// ---------------------------------------------------
FUNCTION fin_spec_po_suban_kontima()

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
   PRIVATE cSkVar := "N"
   PRIVATE fK1 := fk2 := fk3 := fk4 := "N"
   PRIVATE cRasclaniti := "N"
   PRIVATE cRascFunkFond := "N"

   cN2Fin := IzFMkIni( 'FIN', 'PartnerNaziv2', 'N' )

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

   qqKonto := qqPartner := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   O_PARAMS

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

   O_PARTN

   __par_len := Len( partn->id )

   cTip := "1"
   Box( "", 20, 65 )
   SET CURSOR ON
   PRIVATE cK1 := cK2 := "9"
   PRIVATE cK3 := cK4 := "99"
   IF IzFMKIni( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
      cK3 := "999"
   ENDIF
   IF gDUFRJ == "D"
      cIdRj := Space( 60 )
   ELSE
      cIdRj := "999999"
   ENDIF
   cFunk := "99999"
   cFond := "9999"
   cNula := "N"
   DO WHILE .T.
      @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA SUBANALITICKIH KONTA"
      IF gDUFRJ == "D"
         cIdFirma := PadR( gFirma + ";", 30 )
         @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma PICT "@!S20"
      ELSE
         IF gNW == "D"
            @ m_x + 3, m_y + 2 SAY "Firma "
            ?? gFirma, "-", gNFirma
         ELSE
            @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| IF( !Empty( cIdFirma ), P_Firma( @cIdFirma ), ), cidfirma := Left( cidfirma, 2 ), .T. }
         ENDIF
      ENDIF
      @ m_x + 4, m_y + 2 SAY "Konto   " GET qqKonto  PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Partner " GET qqPartner PICT "@!S50"
      @ m_x + 6, m_y + 2 SAY "Datum dokumenta od" GET dDatOd
      @ m_x + 6, Col() + 2 SAY "do" GET dDatDo
      IF gVar1 == "0"
         @ m_x + 7, m_y + 2 SAY "Obracun za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + "/" + AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) + " (1/2/3):" GET cTip VALID ctip $ "123"
      ELSE
         cTip := "1"
      ENDIF

      @ m_x + 8, m_y + 2 SAY "Prikaz sintetickih konta (D/N) ?" GET cSK  PICT "@!" VALID csk $ "DN"
      @ m_x + 9, m_y + 2 SAY "Prikaz stavki sa saldom 0 D/N" GET cNula PICT "@!" VALID cNula  $ "DN"
      @ m_x + 10, m_y + 2 SAY "Skracena varijanta (D/N) ?" GET cSkVar PICT "@!" VALID cSkVar $ "DN"
      @ m_x + 11, m_y + 2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"
      @ m_x + 12, m_y + 2 SAY "Uslov za vrstu naloga (prazno-svi) " GET cVN PICT "@!S20"

      cRasclaniti := "N"

      IF gRJ == "D"
         @ m_x + 13, m_y + 2 SAY "Rasclaniti po RJ (D/N) "  GET cRasclaniti PICT "@!" VALID cRasclaniti $ "DN"
         @ m_x + 14, m_y + 2 SAY "Rasclaniti po RJ/FUNK/FOND? (D/N) "  GET cRascFunkFond PICT "@!" VALID cRascFunkFond $ "DN"
      ENDIF

      @ m_x + 15, m_y + 2 SAY "Opcina (prazno-sve):" GET cOpcine

      UpitK1k4( 16 )

      @ m_x + 19, m_y + 2 SAY "Export izvjestaja u dbf (D/N) ?" GET cExpRptDN PICT "@!" VALID cExpRptDN $ "DN"

      READ
      ESC_BCR
      O_PARAMS
      PRIVATE cSection := "S"
      PRIVATE cHistory := " "
      PRIVATE aHistory := {}
      WPar( "qK", qqKonto )
      WPar( "qP", qqPartner )
      WPar( "d1", dDatoD )
      WPar( "d2", dDatDo )
      SELECT params
      USE

      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      aUsl2 := Parsiraj( qqPartner, "IdPartner" )
      IF gDUFRJ == "D"
         aUsl3 := Parsiraj( cIdFirma, "IdFirma" )
         aUsl4 := Parsiraj( cIdRJ, "IdRj" )
      ENDIF
      aBV := Parsiraj( qqBrDok, "UPPER(BRDOK)", "C" )
      aVN := Parsiraj( cVN, "IDVN", "C" )
      IF aBV <> NIL .AND. aVN <> NIL .AND. ausl1 <> NIL .AND. aUsl2 <> NIL .AND. IF( gDUFRJ == "D", aUsl3 <> NIL .AND. aUsl4 <> NIL, .T. )
         EXIT
      ENDIF
   ENDDO
   BoxC()

   lExpRpt := ( cExpRptDN == "D" )

   IF lExpRpt
      aSSFields := get_ss_fields( gRj, __par_len )
      t_exp_create( aSSFields )
   ENDIF

   IF gDUFRJ != "D"
      cIdFirma := Left( cIdFirma, 2 )
   ENDIF

   IF cRasclaniti == "D"
      O_RJ
   ENDIF

   O_PARTN
   O_KONTO
   O_SUBAN

   CistiK1k4()

   SELECT SUBAN
   IF !Empty( cIdFirma ) .AND. gDUFRJ != "D"
      IF cRasclaniti == "D"
         INDEX ON idfirma + idkonto + idpartner + idrj + DToS( datdok ) TO SUBSUB
         SET ORDER TO TAG "SUBSUB"
      ELSEIF cRascFunkFond == "D"
         INDEX ON idfirma + idkonto + idpartner + idrj + funk + fond + DToS( datdok ) TO SUBSUB
         SET ORDER TO TAG "SUBSUB"

      ELSE
         // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr
         SET ORDER TO TAG "1"
      ENDIF
   ELSE
      IF cRasclaniti == "D"
         INDEX ON idkonto + idpartner + idrj + DToS( datdok ) TO SUBSUB
         SET ORDER TO TAG "SUBSUB"
      ELSEIF cRascFunkFond == "D"
         INDEX ON idkonto + idpartner + idrj + funk + fond + DToS( datdok ) TO SUBSUB
         SET ORDER TO TAG "SUBSUB"
      ELSE
         cIdFirma := ""
         INDEX ON IdKonto + IdPartner + DToS( DatDok ) + BrNal + RBr TO SVESUB
         SET ORDER TO TAG "SVESUB"
      ENDIF
   ENDIF

   IF gDUFRJ == "D"
      cFilter := aUsl3
   ELSE
      cFilter := "IdFirma=" + dbf_quote( cidfirma )
   ENDIF

   IF !Empty( cVN )
      cFilter += ( ".and. " + aVN )
   ENDIF

   IF !Empty( qqBrDok )
      cFilter += ( ".and." + aBV )
   ENDIF

   IF aUsl1 <> ".t."
      cFilter += ( ".and." + aUsl1 )
   ENDIF

   IF aUsl2 <> ".t."
      cFilter += ( ".and." + aUsl2 )
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

   IF gRj == "D" .AND. Len( cIdrj ) <> 0
      IF gDUFRJ == "D"
         cFilter += ( ".and." + aUsl4 )
      ELSE
         cFilter += ( ".and. idrj='" + cidrj + "'" )
      ENDIF
   ENDIF

   IF gTroskovi == "D" .AND. Len( cFunk ) <> 0
      cFilter += ( ".and. Funk='" + cFunk + "'" )
   ENDIF

   IF gTroskovi == "D" .AND. Len( cFond ) <> 0
      cFilter += ( ".and. Fond='" + cFond + "'" )
   ENDIF

   SET FILTER to &cFilter

   GO TOP
   EOF CRET

   Pic := PicBhd

   START PRINT CRET

   IF cSkVar == "D"
      nDOpis := 25
      IF __par_len > 6
         // nDOpis += 2
      ENDIF
      nDIznos := 12
      pic := Right( picbhd, nDIznos )
   ELSE
      nDOpis := 50
      IF __par_len > 6
         // nDOpis += 2
      ENDIF
      nDIznos := 20
   ENDIF

   IF cTip == "3"
      m := "------- " + Replicate( "-", __par_len ) + " " + REPL( "-", nDOpis ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos )
   ELSE
      m := "------- " + Replicate( "-", __par_len ) + " " + REPL( "-", nDOpis ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos )
   ENDIF

   nStr := 0

   nud := 0
   nup := 0      // DIN
   nud2 := 0
   nup2 := 0    // DEM
   DO WHILE !Eof()

      cSin := Left( idkonto, 3 )
      nKd := 0
      nKp := 0
      nKd2 := 0
      nKp2 := 0

      DO WHILE !Eof() .AND.  cSin == Left( idkonto, 3 )

         nTArea := Select()

         cIdKonto := IdKonto
         cIdPartner := IdPartner

         IF !Empty( cOpcine )
            SELECT partn
            SEEK cIdPartner
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
         IF PRow() == 0
            zagl6( cSkVar )
         ENDIF
         IF cRascFunkFond == "D"
            aRasclan := {}
            nDugujeBHD := 0
            nPotrazujeBHD := 0
         ENDIF
         DO WHILE !Eof() .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner .AND. RasclanRJ()
            IF cRascFunkFond == "D"
               cGetFunkFond := idrj + funk + fond
               cGetIdRj := idrj
               cGetFunk := funk
               cGetFond := fond
            ENDIF
            // racuna duguje/potrazuje
            IF d_P == "1"
               nD += iznosbhd
               nD2 += iznosdem
               IF cRascFunkFond == "D"
                  nDugujeBHD := iznosbhd
               ENDIF
            ELSE
               nP += iznosbhd
               nP2 += iznosdem
               IF cRascFunkFond == "D"
                  nPotrazujeBHD := iznosbhd
               ENDIF
            ENDIF

            SKIP 1

            IF cRascFunkFond == "D" .AND. cGetFunkFond <> idrj + funk + fond
               AAdd( aRasclan, { cGetIdRj, cGetFunk, cGetFond, nDugujeBHD, nPotrazujeBHD } )
               nDugujeBHD := 0
               nPotrazujeBHD := 0
            ENDIF
         ENDDO
         IF PRow() > 60 + gPStranica
            FF
            zagl6( cSkVar )
         ENDIF
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
               SELECT PARTN
               HSEEK cIdPartner
               SELECT SUBAN
               IF gVSubOp == "D"
                  SELECT KONTO
                  HSEEK cIdKonto
                  SELECT SUBAN
                  cPom := AllTrim( KONTO->naz ) + " (" + AllTrim( AllTrim( PARTN->naz ) + PN2() ) + ")"
                  ?? PadR( cPom, nDOpis - DifIdP( cidpartner ) )
                  IF Len( cPom ) > nDOpis - DifIdP( cidpartner )
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
               SELECT KONTO
               HSEEK cIdKonto
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
               IF gRj == "D" .AND. cRasclaniti == "D"

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

               fill_ss_tbl( cIdKonto, cIdPartner, IF( Empty( cIdPartner ), konto->naz, AllTrim( partn->naz ) ), nD, nP, nD - nP, cRj_id, cRj_naz )
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
      IF PRow() > 60 + gPStranica
         FF
         zagl6( cSkVar )
      ENDIF
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

   IF PRow() > 60 + gPStranica
      FF
      zagl6( cSkVar )
   ENDIF

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
   FF
   ENDPRINT

   IF lExpRpt
      tbl_export()
   ENDIF

   closeret

   RETURN





/*! \fn PartVanProm()
 *  \brief Partneri van prometa
 */

FUNCTION PartVanProm()

   LOCAL   dDatOd := CToD ( "" ), dDatDo := Date ()
   PRIVATE picBHD := FormPicL( gPicBHD, 16 )
   PRIVATE picDEM := FormPicL( gPicDEM, 12 )
   PRIVATE cIdKonto := Space ( 7 ), cIdFirma := Space ( Len ( gFirma ) ), ;
      cKrit := Space ( 60 ), aUsl

   O_KONTO
   O_PARTN
   O_SUBAN
   __par_len := Len( partn->id )
   //
   Box (, 11, 60 )
   @ m_x, m_y + 15 SAY "PREGLED PARTNERA BEZ PROMETA"
   IF gNW == "D"
      cIdFirma := gFirma
      @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 4, m_y + 2 SAY " Konto (prazno-svi)" GET cIdKonto ;
      VALID Empty ( cIdKonto ) .OR. P_KontoFin ( @cIdKonto )
   @ m_x + 6, m_y + 2 SAY "Kriterij za telefon" GET cKrit PICT "@S30@!";
      VALID {|| aUsl := Parsiraj ( cKrit, "Telefon" ), ;
      iif ( aUsl == NIL, .F., .T. ) }
   @ m_x + 8, m_y + 2 SAY "         Pocevsi od" GET dDatOd ;
      VALID dDatOd <= dDatDo
   @ m_x + 10, m_y + 2 SAY "       Zakljucno sa" GET dDatDo ;
      VALID dDatOd <= dDatDo
   READ
   ESC_BCR
   BoxC()

   START PRINT CRET

   INI
   ?
   F10CPI
   ?? Space ( 5 ) + "Firma:", gNFirma
   ? PadC ( "PARTNERI BEZ PROMETA", 80 )
   ? PadC ( "na dan " + DToC ( Date() ) + ".", 80 )
   ?
   ? Space ( 5 ) + "    Konto:", ;
      iif ( Empty ( cIdKonto ), "SVI", cIdKonto + Ocitaj ( F_KONTO, cIdKonto, "Naz" ) )
   ? Space ( 5 ) + " Kriterij:", cKrit
   ? Space ( 5 ) + "Za period:", IF ( Empty ( dDatOd ), "", DToC ( dDatOd ) + " " ) + ;
      "do", DToC ( dDatDo )
   ?
   ? Space ( 5 ) + PadR( "Sifra", __par_len ), PadR( "NAZIV", 25 ), ;
      PadR ( "MJESTO", Len ( PARTN->Mjesto ) ), PadR ( "ADRESA", Len ( PARTN->Adresa ) )
   ? Space ( 5 ) + REPL( "-", __par_len ), REPL ( "-", 25 ), ;
      REPL ( "-", Len ( PARTN->Mjesto ) ), REPL ( "-", Len ( PARTN->Adresa ) )

   nBrPartn := 0
   SELECT SUBAN
   SET ORDER TO TAG "2"

   SELECT PARTN
   IF !Empty ( aUsl )
      SET FILTER to &aUsl
   ENDIF
   GO TOP
   WHILE ! Eof()
      fNema := .T.
      SELECT SUBAN
      SEEK cIdFirma + PARTN->Id
      WHILE ! Eof() .AND. SUBAN->( IdFirma + IdPartner ) == ( cIdFirma + PARTN->Id )
         IF ( Empty ( cIdKonto ) .OR. SUBAN->IdKonto == cIdKonto ) .AND. ;
               dDatOd <= DatDok .AND. DatDok <= dDatDo
            fNema := .F.
            EXIT
         ENDIF
         SKIP
      END
      IF fNema
         ? Space ( 5 ) + PARTN->Id, PadR( PARTN->Naz, 25 ), PARTN->Mjesto, PARTN->Adresa
         nBrPartn ++
      ENDIF
      SELECT PARTN
      SKIP
   END
   ? Space ( 5 ) + REPL( "-", __par_len ), REPL ( "-", 25 ), ;
      REPL ( "-", Len ( PARTN->Mjesto ) ), REPL ( "-", Len ( PARTN->Adresa ) )
   ?
   ? Space ( 5 ) + "Ukupno izlistano", AllTrim ( Str ( nBrPartn ) ), ;
      "partnera bez prometa"
   EJECT
   ENDPRINT
   CLOSERET

   RETURN





/*! \fn SpecPoDosp(lKartica)
 *  \brief Otvorene stavke grupisano po brojevima veze
 *  \param lKartica
 */

FUNCTION SpecPoDosp( lKartica )

   LOCAL nCol1 := 72
   LOCAL cSvi := "N"
   LOCAL lPrikSldNula := .F.
   LOCAL lExpRpt := .F.
   LOCAL cExpRpt := "N"
   LOCAL aExpFld
   LOCAL cStart
   LOCAL cP_naz := ""
   PRIVATE cIdPartner

   IF lKartica == NIL
      lKartica := .F.
   ENDIF

   IF lKartica
      cPoRN := "D"
   ELSE
      cPoRN := "N"
   ENDIF

   cDokument := Space( 8 )

   picBHD := FormPicL( gPicBHD, 14 )
   picDEM := FormPicL( gPicDEM, 10 )

   IF gVar1 == "0"
      m := "----------- ------------- -------------- -------------- ---------- ---------- ---------- -------------------------"
   ELSE
      m := "----------- ------------- -------------- -------------- -------------------------"
   ENDIF

   m := "-------- -------- " + m

   nStr := 0
   fVeci := .F.
   cPrelomljeno := "N"

   O_SUBAN
   O_PARTN
   O_KONTO

   __par_len := Len( partn->id )

   cIdFirma := gFirma
   cIdkonto := Space( 7 )
   cIdPartner := PadR( "", __par_len )
   dNaDan := Date()
   cOpcine := Space( 20 )
   cValuta := "1"
   cPrikNule := "N"

   cSaRokom := "N"
   nDoDana1 :=  8
   nDoDana2 := 15
   nDoDana3 := 30
   nDoDana4 := 60

   PICPIC := PadR( fetch_metric( "fin_spec_po_dosp_picture", NIL, "99999999.99" ), 15 )

   Box(, 18, 60 )

   IF gNW == "D"
      @ m_x + 1, m_y + 2 SAY "Firma "
      ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma ;
         VALID {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF

   @ m_x + 2, m_y + 2 SAY "Konto:               " GET cIdkonto   PICT "@!"  VALID P_kontoFin( @cIdkonto )
   IF cPoRN == "D"
      @ m_x + 3, m_y + 2 SAY "Partner (prazno svi):" GET cIdpartner PICT "@!"  VALID Empty( cIdpartner )  .OR. ( "." $ cidpartner ) .OR. ( ">" $ cidpartner ) .OR. P_Firma( @cIdPartner )
   ENDIF
   // @ m_x+ 5,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"
   @ m_x + 6, m_y + 2 SAY "Izvjestaj se pravi na dan:" GET dNaDan
   @ m_x + 7, m_y + 2 SAY "Prikazati rocne intervale (D/N) ?" GET cSaRokom VALID cSaRokom $ "DN" PICT "@!"
   @ m_x + 8, m_y + 2 SAY "Interval 1: do (dana)" GET nDoDana1 WHEN cSaRokom == "D" PICT "999"
   @ m_x + 9, m_y + 2 SAY "Interval 2: do (dana)" GET nDoDana2 WHEN cSaRokom == "D" PICT "999"
   @ m_x + 10, m_y + 2 SAY "Interval 3: do (dana)" GET nDoDana3 WHEN cSaRokom == "D" PICT "999"
   @ m_x + 11, m_y + 2 SAY "Interval 4: do (dana)" GET nDoDana4 WHEN cSaRokom == "D" PICT "999"
   @ m_x + 13, m_y + 2 SAY "Prikaz iznosa (format)" GET PICPIC PICT "@!"
   @ m_x + 14, m_y + 2 SAY "Uslov po opcini (prazno - nista)" GET cOpcine
   @ m_x + 15, m_y + 2 SAY "Prikaz stavki kojima je saldo 0 (D/N)?" GET cPrikNule VALID cPrikNule $ "DN" PICT "@!"

   IF cPoRN == "N"
      @ m_x + 16, m_y + 2 SAY "Prikaz izvjestaja u (1)KM (2)EURO" GET cValuta VALID cValuta $ "12"
   ENDIF
   @ m_x + 18, m_y + 2 SAY "Export izvjestaja u DBF ?" GET cExpRpt VALID cExpRpt $ "DN" PICT "@!"
   READ
   ESC_BCR
   Boxc()

   PICPIC := AllTrim( PICPIC )
   set_metric( "fin_spec_po_dosp_picture", NIL, PICPIC )

   lExpRpt := ( cExpRpt == "D" )

   IF cPrikNule == "D"
      lPrikSldNula := .T.
   ENDIF

   IF "." $ cIdPartner
      cIdPartner := StrTran( cIdPartner, ".", "" )
      cIdPartner := Trim( cIdPartner )
   ENDIF
   IF ">" $ cIdPartner
      cIdPartner := StrTran( cIdPartner, ">", "" )
      cIdPartner := Trim( cIdPartner )
      fVeci := .T.
   ENDIF
   IF Empty( cIdpartner )
      cIdPartner := ""
   ENDIF

   cSvi := cIdpartner

   IF lExpRpt == .T.
      aExpFld := get_ost_fields( cSaRokom, __par_len )
      t_exp_create( aExpFld )
   ENDIF

   SELECT ( F_TRFP2 )
   IF !Used()
      O_TRFP2
   ENDIF

   HSEEK "99 " + Left( cIdKonto, 1 )
   DO WHILE !Eof() .AND. IDVD == "99" .AND. Trim( idkonto ) != Left( cIdKonto, Len( Trim( idkonto ) ) )
      SKIP 1
   ENDDO

   IF idvd == "99" .AND. Trim( idkonto ) == Left( cIdKonto, Len( Trim( idkonto ) ) )
      cDugPot := D_P
   ELSE
      cDugPot := "1"
      Box(, 3, 60 )
      @ m_x + 2, m_y + 2 SAY "Konto " + cIdKonto + " duguje / potrazuje (1/2)" GET cdugpot  VALID cdugpot $ "12" PICT "9"
      READ
      Boxc()
   ENDIF

   fin_create_pom_table( nil, __par_len )
   // kreiraj pomocnu bazu

   O_TRFP2
   O_SUBAN
   O_PARTN
   O_KONTO

   IF cPoRN == "D"
      gaZagFix := { 5, 3 }
   ELSE
      IF cSaRokom == "N"
         gaZagFix := { 4, 4 }
      ELSE
         gaZagFix := { 4, 5 }
      ENDIF
   ENDIF

   START PRINT CRET

   nUkDugBHD := 0
   nUkPotBHD := 0

   SELECT suban
   SET ORDER TO TAG "3"

   IF cSvi == "D"
      SEEK cIdFirma + cIdKonto
   ELSE
      SEEK cIdFirma + cIdKonto + cIdPartner
   ENDIF

   DO WHILE !Eof() .AND. idfirma == cIdfirma .AND. cIdKonto == IdKonto

      cIdPartner := idpartner
      nUDug2 := 0
      nUPot2 := 0
      nUDug := 0
      nUPot := 0

      fPrviprolaz := .T.

      DO WHILE !Eof() .AND. idfirma == cIdfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner

         cBrDok := BrDok
         cOtvSt := otvst
         nDug2 := nPot2 := 0
         nDug := nPot := 0
         aFaktura := { CToD( "" ), CToD( "" ), CToD( "" ) }

         DO WHILE !Eof() .AND. idfirma == cIdfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner .AND. brdok == cBrDok

            IF D_P == "1"
               nDug += IznosBHD
               nDug2 += IznosDEM
            ELSE
               nPot += IznosBHD
               nPot2 += IznosDEM
            ENDIF

            IF D_P == cDugPot
               aFaktura[ 1 ] := DATDOK
               aFaktura[ 2 ] := DATVAL
            ENDIF

            IF aFaktura[ 3 ] < DatDok  // datum zadnje promjene
               aFaktura[ 3 ] := DatDok
            ENDIF

            SKIP 1
         ENDDO

         IF Round( ndug - npot, 2 ) == 0
            // nista
         ELSE
            fPrviProlaz := .F.
            IF cPrelomljeno == "D"
               IF ( ndug - npot ) > 0
                  nDug := nDug - nPot
                  nPot := 0
               ELSE
                  nPot := nPot - nDug
                  nDug := 0
               ENDIF
               IF ( ndug2 - npot2 ) > 0
                  nDug2 := nDug2 - nPot2
                  nPot2 := 0
               ELSE
                  nPot2 := nPot2 - nDug2
                  nDug2 := 0
               ENDIF
            ENDIF
            SELECT POM
            APPEND BLANK
            Scatter()
            _idpartner := cIdPartner
            _datdok    := aFaktura[ 1 ]
            _datval    := aFaktura[ 2 ]
            _datzpr    := aFaktura[ 3 ]
            _brdok     := cBrDok
            _dug       := nDug
            _pot       := nPot
            _dug2      := nDug2
            _pot2      := nPot2
            _otvst     := IF( IF( Empty( _datval ), _datdok > dNaDan, _datval > dNaDan ), " ", "1" )
            Gather()
            SELECT SUBAN
         ENDIF
      ENDDO // partner

      IF PRow() > 58 + gPStranica
         FF
         ZSpecPoDosp( nil, nil, PICPIC )
      ENDIF

      IF ( !fveci .AND. idpartner = cSvi ) .OR. fVeci

      ELSE
         EXIT
      ENDIF
   ENDDO

   SELECT POM
   IF cSaRokom == "D"
      INDEX ON IDPARTNER + OTVST + Rocnost() + DToS( DATDOK ) + DToS( iif( Empty( DATVAL ), DATDOK, DATVAL ) ) + BRDOK TAG "2"
   ELSE
      INDEX ON IDPARTNER + OTVST + DToS( DATDOK ) + DToS( iif( Empty( DATVAL ), DATDOK, DATVAL ) ) + BRDOK TAG "2"
   ENDIF
   SET ORDER TO TAG "2"
   GO TOP

   nTUDug := nTUPot := nTUDug2 := nTUPot2 := 0
   nTUkUVD := nTUkUVP := nTUkUVD2 := nTUkUVP2 := 0
   nTUkVVD := nTUkVVP := nTUkVVD2 := nTUkVVP2 := 0

   IF cSaRokom == "D"
      // D,TD    P,TP   D2,TD2  P2,TP2
      anInterUV := { { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 1
         { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 2
      { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 3
         { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 4
      { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } } }        // preko intervala 4

      // D,TD    P,TP   D2,TD2  P2,TP2
      anInterVV := { { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 1
         { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 2
      { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 3
         { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }, ;        // do - interval 4
      { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } } }        // preko intervala 4
   ENDIF

   cLastIdPartner := ""
   IF cPoRN == "N"
      fPrviProlaz := .T.
   ENDIF

   DO WHILE !Eof()

      IF cPoRN == "D"
         fPrviProlaz := .T.
      ENDIF

      cIdPartner := IDPARTNER

      // provjeri saldo partnera
      IF !lPrikSldNula .AND. saldo_nula( cIdPartner )
         SKIP
         LOOP
      ENDIF

      // provjeri opcine
      IF !Empty( cOpcine )
         SELECT partn
         SEEK cIdPartner
         IF At( partn->idops, cOpcine ) <> 0
            SELECT pom
            SKIP
            LOOP
         ENDIF
         SELECT pom
      ENDIF

      nUDug := nUPot := nUDug2 := nUPot2 := 0
      nUkUVD := nUkUVP := nUkUVD2 := nUkUVP2 := 0
      nUkVVD := nUkVVP := nUkVVD2 := nUkVVP2 := 0

      cFaza := otvst

      IF cSaRokom == "D"
         FOR i := 1 TO Len( anInterUV )
            FOR j := 1 TO Len( anInterUV[ i ] )
               anInterUV[ i, j, 1 ] := 0
               anInterVV[ i, j, 1 ] := 0
            NEXT
         NEXT
         nFaza := RRocnost()
      ENDIF

      IF PRow() > 52 + gPStranica
         FF
         ZSpecPoDosp( .T., nil, PICPIC )
         fPrviProlaz := .F.
      ENDIF

      IF fPrviProlaz
         ZSpecPoDosp( nil, nil, PICPIC )
         fPrviProlaz := .F.
      ENDIF

      SELECT pom

      DO WHILE !Eof() .AND. cIdPartner == IdPartner

         IF cPoRn == "D"
            ? datdok, datval, PadR( brdok, 10 )
            nCol1 := PCol() + 1
            ?? " "
            ?? Transform( dug, picbhd ), Transform( pot, picbhd ), Transform( dug - pot, picbhd )
            IF gVar1 == "0"
               ?? " " + Transform( dug2, picdem ), Transform( pot2, picdem ), Transform( dug2 - pot2, picdem )
            ENDIF
         ELSEIF cLastIdPartner != cIdPartner .OR. Len( cLastIdPartner ) < 1
            Pljuc( cIdPartner )
            cP_naz := PadR( Ocitaj( F_PARTN, cIdPartner, "naz" ), 25 )
            PPljuc( cP_naz )
            cLastIdPartner := cIdPartner
         ENDIF

         IF otvst == " "
            IF cPoRn == "D"
               ?? "   U VALUTI" + IF( cSaRokom == "D", IspisRocnosti(), "" )
            ENDIF
            nUkUVD  += Dug
            nUkUVP  += Pot
            nUkUVD2 += Dug2
            nUkUVP2 += Pot2
            IF cSaRokom == "D"
               anInterUV[ nFaza, 1, 1 ] += dug
               anInterUV[ nFaza, 2, 1 ] += pot
               anInterUV[ nFaza, 3, 1 ] += dug2
               anInterUV[ nFaza, 4, 1 ] += pot2
            ENDIF
         ELSE
            IF cPoRn == "D"
               ?? " VAN VALUTE" + IF( cSaRokom == "D", IspisRocnosti(), "" )
            ENDIF
            nUkVVD  += Dug
            nUkVVP  += Pot
            nUkVVD2 += Dug2
            nUkVVP2 += Pot2
            IF cSaRokom == "D"
               anInterVV[ nFaza, 1, 1 ] += dug
               anInterVV[ nFaza, 2, 1 ] += pot
               anInterVV[ nFaza, 3, 1 ] += dug2
               anInterVV[ nFaza, 4, 1 ] += pot2
            ENDIF
         ENDIF
         nUDug += Dug
         nUPot += Pot
         nUDug2 += Dug2
         nUPot2 += Pot2

         SKIP 1
         // znaci da treba
         IF cFaza != otvst .OR. Eof() .OR. cIdPartner != idpartner // <-� prikazati
            IF cPoRn == "D"
               ? m
            ENDIF                           // � subtotal
            IF cFaza == " "
               IF cSaRokom == "D"
                  SKIP -1
                  IF cPoRn == "D"
                     ? "UK.U VALUTI" + IspisRocnosti() + ":"
                     @ PRow(), nCol1 SAY anInterUV[ nFaza, 1, 1 ] PICTURE picBHD
                     @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 2, 1 ] PICTURE picBHD
                     @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 1, 1 ] -anInterUV[ nFaza, 2, 1 ] PICTURE picBHD

                     IF gVar1 == "0"
                        @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 3, 1 ] PICTURE picdem
                        @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 4, 1 ] PICTURE picdem
                        @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 3, 1 ] -anInterUV[ nFaza, 4, 1 ] PICTURE picdem
                     ENDIF
                  ENDIF
                  anInterUV[ nFaza, 1, 2 ] += anInterUV[ nFaza, 1, 1 ]
                  anInterUV[ nFaza, 2, 2 ] += anInterUV[ nFaza, 2, 1 ]
                  anInterUV[ nFaza, 3, 2 ] += anInterUV[ nFaza, 3, 1 ]
                  anInterUV[ nFaza, 4, 2 ] += anInterUV[ nFaza, 4, 1 ]
                  IF cPoRn == "D"
                     ? m
                  ENDIF
                  SKIP 1
               ENDIF
               IF cPoRn == "D"
                  ? "UKUPNO U VALUTI:"
                  @ PRow(), nCol1 SAY nUkUVD PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY nUkUVP PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY nUkUVD - nUkUVP PICTURE picBHD
                  IF gVar1 == "0"
                     @ PRow(), PCol() + 1 SAY nUkUVD2 PICTURE picdem
                     @ PRow(), PCol() + 1 SAY nUkUVP2 PICTURE picdem
                     @ PRow(), PCol() + 1 SAY nUkUVD2 - nUkUVP2 PICTURE picdem
                  ENDIF
               ENDIF
               nTUkUVD  += nUkUVD
               nTUkUVP  += nUkUVP
               nTUkUVD2 += nUkUVD2
               nTUkUVP2 += nUkUVP2
            ELSE
               IF cSaRokom == "D"
                  SKIP -1
                  IF cPoRn == "D"
                     ? "UK.VAN VALUTE" + IspisRocnosti() + ":"
                     @ PRow(), nCol1 SAY anInterVV[ nFaza, 1, 1 ] PICTURE picBHD
                     @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 2, 1 ] PICTURE picBHD
                     @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 1, 1 ] -anInterVV[ nFaza, 2, 1 ] PICTURE picBHD
                     IF gVar1 == "0"
                        @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 3, 1 ] PICTURE picdem
                        @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 4, 1 ] PICTURE picdem
                        @ PRow(), PCol() + 1 SAY 44 PICTURE picdem
                        @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 3, 1 ] -anInterVV[ nFaza, 4, 1 ] PICTURE picdem
                     ENDIF
                  ENDIF
                  anInterVV[ nFaza, 1, 2 ] += anInterVV[ nFaza, 1, 1 ]
                  anInterVV[ nFaza, 2, 2 ] += anInterVV[ nFaza, 2, 1 ]
                  anInterVV[ nFaza, 3, 2 ] += anInterVV[ nFaza, 3, 1 ]
                  anInterVV[ nFaza, 4, 2 ] += anInterVV[ nFaza, 4, 1 ]
                  IF cPoRn == "D"
                     ? m
                  ENDIF
                  SKIP 1
               ENDIF
               IF cPoRn == "D"
                  ? "UKUPNO VAN VALUTE:"
                  @ PRow(), nCol1 SAY nUkVVD PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY nUkVVP PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY nUkVVD - nUkVVP PICTURE picBHD
                  IF gVar1 == "0"
                     @ PRow(), PCol() + 1 SAY nUkVVD2 PICTURE picdem
                     @ PRow(), PCol() + 1 SAY nUkVVP2 PICTURE picdem
                     @ PRow(), PCol() + 1 SAY nUkVVD2 - nUkVVP2 PICTURE picdem
                  ENDIF
               ENDIF
               nTUkVVD  += nUkVVD
               nTUkVVP  += nUkVVP
               nTUkVVD2 += nUkVVD2
               nTUkVVP2 += nUkVVP2
            ENDIF
            IF cPoRn == "D"
               ? m
            ENDIF
            cFaza := otvst
            IF cSaRokom == "D"
               nFaza := RRocnost()
            ENDIF
         ELSEIF cSaRokom == "D" .AND. nFaza != RRocnost()
            SKIP -1
            IF cPoRn == "D"
               ? m
            ENDIF
            IF cFaza == " "
               IF cPoRn == "D"
                  ? "UK.U VALUTI" + IspisRocnosti() + ":"
                  @ PRow(), nCol1 SAY anInterUV[ nFaza, 1, 1 ] PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 2, 1 ] PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 1, 1 ] -anInterUV[ nFaza, 2, 1 ] PICTURE picBHD
                  IF gVar1 == "0"
                     @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 3, 1 ] PICTURE picdem
                     @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 4, 1 ] PICTURE picdem
                     @ PRow(), PCol() + 1 SAY anInterUV[ nFaza, 3, 1 ] -anInterUV[ nFaza, 4, 1 ] PICTURE picdem
                  ENDIF
               ENDIF
               anInterUV[ nFaza, 1, 2 ] += anInterUV[ nFaza, 1, 1 ]
               anInterUV[ nFaza, 2, 2 ] += anInterUV[ nFaza, 2, 1 ]
               anInterUV[ nFaza, 3, 2 ] += anInterUV[ nFaza, 3, 1 ]
               anInterUV[ nFaza, 4, 2 ] += anInterUV[ nFaza, 4, 1 ]
            ELSE
               IF cPoRn == "D"
                  ? "UK.VAN VALUTE" + IspisRocnosti() + ":"
                  @ PRow(), nCol1 SAY anInterVV[ nFaza, 1, 1 ] PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 2, 1 ] PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 1, 1 ] -anInterVV[ nFaza, 2, 1 ] PICTURE picBHD
                  IF gVar1 == "0"
                     @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 3, 1 ] PICTURE picdem
                     @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 4, 1 ] PICTURE picdem
                     @ PRow(), PCol() + 1 SAY anInterVV[ nFaza, 3, 1 ] -anInterVV[ nFaza, 4, 1 ] PICTURE picdem
                  ENDIF
               ENDIF
               anInterVV[ nFaza, 1, 2 ] += anInterVV[ nFaza, 1, 1 ]
               anInterVV[ nFaza, 2, 2 ] += anInterVV[ nFaza, 2, 1 ]
               anInterVV[ nFaza, 3, 2 ] += anInterVV[ nFaza, 3, 1 ]
               anInterVV[ nFaza, 4, 2 ] += anInterVV[ nFaza, 4, 1 ]
            ENDIF
            IF cPoRn == "D"
               ? m
            ENDIF
            SKIP 1
            nFaza := RRocnost()
         ENDIF

      ENDDO

      IF PRow() > 58 + gPStranica
         FF
         ZSpecPoDosp( .T., nil, PICPIC )
      ENDIF

      SELECT POM
      IF !fPrviProlaz  // bilo je stavki
         IF cPoRn == "D"
            ? M
            ? "UKUPNO:"
            @ PRow(), nCol1 SAY nUDug PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nUPot PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nUDug - nUPot PICTURE picBHD
            IF gVar1 == "0"
               @ PRow(), PCol() + 1 SAY nUDug2 PICTURE picdem
               @ PRow(), PCol() + 1 SAY nUPot2 PICTURE picdem
               @ PRow(), PCol() + 1 SAY nUDug2 - nUPot2 PICTURE picdem
            ENDIF
            ? m
         ELSE
            IF cSaRokom == "D"
               FOR i := 1 TO Len( anInterUV )
                  IF ( cValuta == "1" )
                     PPljuc( Transform( anInterUV[ i, 1, 1 ] -anInterUV[ i, 2, 1 ], PICPIC ) )
                  ELSE
                     PPljuc( Transform( anInterUV[ i, 3, 1 ] -anInterUV[ i, 4, 1 ], PICPIC ) )
                  ENDIF
               NEXT

               IF ( cValuta == "1" )
                  PPljuc( Transform( nUkUVD - nUkUVP, PICPIC ) )
               ELSE
                  PPljuc( Transform( nUkUVD2 - nUkUVP2, PICPIC ) )
               ENDIF

               FOR i := 1 TO Len( anInterVV )
                  IF ( cValuta == "1" )
                     PPljuc( Transform( anInterVV[ i, 1, 1 ] -anInterVV[ i, 2, 1 ], PICPIC ) )
                  ELSE
                     PPljuc( Transform( anInterVV[ i, 3, 1 ] -anInterVV[ i, 4, 1 ], PICPIC ) )
                  ENDIF
               NEXT
               IF ( cValuta == "1" )
                  PPljuc( Transform( nUkVVD - nUkVVP, PICPIC ) )
                  PPljuc( Transform( nUDug - nUPot, PICPIC ) )
               ELSE
                  PPljuc( Transform( nUkVVD2 - nUkVVP2, PICPIC ) )
                  PPljuc( Transform( nUDug2 - nUPot2, PICPIC ) )
               ENDIF

               IF lExpRpt == .T.
                  IF cValuta == "1"
                     fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD - nUkUVP, nUkVVD - nUkVVP, nUDug - nUPot, anInterUV[ 1, 1, 1 ] - anInterUV[ 1, 2, 1 ], anInterUV[ 2, 1, 1 ] - anInterUV[ 2, 2, 1 ], anInterUV[ 3, 1, 1 ] - anInterUV[ 3, 2, 1 ], anInterUV[ 4, 1, 1 ] - anInterUV[ 4, 2, 1 ], anInterUV[ 5, 1, 1 ] - anInterUV[ 5, 2, 1 ], anInterVV[ 1, 1, 1 ] - anInterVV[ 1, 2, 1 ], anInterVV[ 2, 1, 1 ] - anInterVV[ 2, 2, 1 ], anInterVV[ 3, 1, 1 ] - anInterVV[ 3, 2, 1 ], anInterVV[ 4, 1, 1 ] - anInterVV[ 4, 2, 1 ], anInterVV[ 5, 1, 1 ] - anInterVV[ 5, 2, 1 ] )
                  ELSE
                     fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD2 - nUkUVP2, nUkVVD2 - nUkVVP2, nUDug2 - nUPot2, anInterUV[ 1, 3, 1 ] - anInterUV[ 1, 4, 1 ], anInterUV[ 2, 3, 1 ] - anInterUV[ 2, 4, 1 ], anInterUV[ 3, 3, 1 ] - anInterUV[ 3, 4, 1 ], anInterUV[ 4, 3, 1 ] - anInterUV[ 4, 4, 1 ], anInterUV[ 5, 3, 1 ] - anInterUV[ 5, 4, 1 ], anInterVV[ 1, 3, 1 ] - anInterVV[ 1, 4, 1 ], anInterVV[ 2, 3, 1 ] - anInterVV[ 2, 4, 1 ], anInterVV[ 3, 3, 1 ] - anInterVV[ 3, 4, 1 ], anInterVV[ 4, 3, 1 ] - anInterVV[ 4, 4, 1 ], anInterVV[ 5, 3, 1 ] - anInterVV[ 5, 4, 1 ] )
                  ENDIF
               ENDIF
            ELSE
               IF ( cValuta == "1" )
                  PPljuc( Transform( nUkUVD - nUkUVP, PICPIC ) )
                  PPljuc( Transform( nUkVVD - nUkVVP, PICPIC ) )
                  PPljuc( Transform( nUDug - nUPot, PICPIC ) )
               ELSE
                  PPljuc( Transform( nUkUVD2 - nUkUVP2, PICPIC ) )
                  PPljuc( Transform( nUkVVD2 - nUkVVP2, PICPIC ) )
                  PPljuc( Transform( nUDug2 - nUPot2, PICPIC ) )
               ENDIF

               IF lExpRpt == .T.
                  IF cValuta == "1"
                     fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD - nUkUVP, nUkVVD - nUkVVP, nUDug - nUPot )

                  ELSE
                     fill_ost_tbl( cSaRokom, cIdPartner, cP_naz, nUkUVD2 - nUkUVP2, nUkVVD2 - nUkVVP2, nUDug2 - nUPot2 )

                  ENDIF
               ENDIF


            ENDIF
         ENDIF
      ENDIF

      IF cPoRn == "D"
         ?
         ?
         ?
      ENDIF

      nTUDug += nUDug
      nTUDug2 += nUDug2
      nTUPot += nUPot
      nTUPot2 += nUPot2
   ENDDO

   IF cPoRn == "D" .AND. Len( cSvi ) < Len( idpartner ) .AND. ;
         ( Round( nTUDug, 2 ) != 0 .OR. Round( nTUPot, 2 ) != 0 .OR. ;
         Round( nTUkUVD, 2 ) != 0 .OR. Round( nTUkUVP, 2 ) != 0 .OR. ;
         Round( nTUkVVD, 2 ) != 0 .OR. Round( nTUkVVP, 2 ) != 0 )

      // prikazimo total
      FF
      ZSpecPoDosp( .T., .T., PICPIC )
      ? m2 := StrTran( M, "-", "=" )
      IF cSaRokom == "D"
         FOR i := 1 TO Len( anInterUV )
            ? "PARTN.U VAL." + IspisRoc2( i ) + ":"
            @ PRow(), nCol1 SAY anInterUV[ i, 1, 2 ] PICTURE picBHD
            @ PRow(), PCol() + 1 SAY anInterUV[ i, 2, 2 ] PICTURE picBHD
            @ PRow(), PCol() + 1 SAY anInterUV[ i, 1, 2 ] -anInterUV[ i, 2, 2 ] PICTURE picBHD
            IF gVar1 == "0"
               @ PRow(), PCol() + 1 SAY anInterUV[ i, 3, 2 ] PICTURE picdem
               @ PRow(), PCol() + 1 SAY anInterUV[ i, 4, 2 ] PICTURE picdem
               @ PRow(), PCol() + 1 SAY anInterUV[ i, 3, 2 ] -anInterUV[ i, 4, 2 ] PICTURE picdem
            ENDIF
         NEXT
         ? m
      ENDIF
      ? "PARTNERI UKUPNO U VALUTI  :"
      @ PRow(), nCol1 SAY nTUkUVD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nTUkUVP PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nTUkUVD - nTUkUVP PICTURE picBHD
      IF gVar1 == "0"
         @ PRow(), PCol() + 1 SAY nTUkUVD2 PICTURE picdem
         @ PRow(), PCol() + 1 SAY nTUkUVP2 PICTURE picdem
         @ PRow(), PCol() + 1 SAY nTUkUVD2 - nTUkUVP2 PICTURE picdem
      ENDIF
      ? m2
      IF cSaRokom == "D"
         FOR i := 1 TO Len( anInterVV )
            ? "PARTN.VAN VAL." + IspisRoc2( i ) + ":"
            @ PRow(), nCol1 SAY anInterVV[ i, 1, 2 ] PICTURE picBHD
            @ PRow(), PCol() + 1 SAY anInterVV[ i, 2, 2 ] PICTURE picBHD
            @ PRow(), PCol() + 1 SAY anInterVV[ i, 1, 2 ] -anInterVV[ i, 2, 2 ] PICTURE picBHD
            IF gVar1 == "0"
               @ PRow(), PCol() + 1 SAY anInterVV[ i, 3, 2 ] PICTURE picdem
               @ PRow(), PCol() + 1 SAY anInterVV[ i, 4, 2 ] PICTURE picdem
               @ PRow(), PCol() + 1 SAY anInterVV[ i, 3, 2 ] -anInterVV[ i, 4, 2 ] PICTURE picdem
            ENDIF
         NEXT
         ? m
      ENDIF

      ? "PARTNERI UKUPNO VAN VALUTE:"
      @ PRow(), nCol1 SAY nTUkVVD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nTUkVVP PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nTUkVVD - nTUkVVP PICTURE picBHD
      IF gVar1 == "0"
         @ PRow(), PCol() + 1 SAY nTUkVVD2 PICTURE picdem
         @ PRow(), PCol() + 1 SAY nTUkVVP2 PICTURE picdem
         @ PRow(), PCol() + 1 SAY nTUkVVD2 - nTUkVVP2 PICTURE picdem
      ENDIF
      ? m2
      ? "PARTNERI UKUPNO           :"
      @ PRow(), nCol1 SAY nTUDug PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nTUPot PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nTUDug - nTUPot PICTURE picBHD
      IF gVar1 == "0"
         @ PRow(), PCol() + 1 SAY nTUDug2 PICTURE picdem
         @ PRow(), PCol() + 1 SAY nTUPot2 PICTURE picdem
         @ PRow(), PCol() + 1 SAY nTUDug2 - nTUPot2 PICTURE picdem
      ENDIF
      ? m2

   ENDIF // total

   IF cPoRn == "N"

      cTmpL := ""

      // uzmi liniju
      _get_line1( @cTmpL, cSaRokom, PICPIC )

      ? cTmpL

      Pljuc( PadR( "UKUPNO", Len( POM->IDPARTNER + PadR( PARTN->naz, 25 ) ) + 1 ) )

      _get_line2( @cTmpL, cSaRokom, PICPIC )

      IF cSaRokom == "D"
         FOR i := 1 TO Len( anInterUV )
            IF ( cValuta == "1" )
               PPljuc( Transform( anInterUV[ i, 1, 2 ] -anInterUV[ i, 2, 2 ], PICPIC ) )
            ELSE
               PPljuc( Transform( anInterUV[ i, 3, 2 ] -anInterUV[ i, 4, 2 ], PICPIC ) )
            ENDIF
         NEXT
         IF ( cValuta == "1" )
            PPljuc( Transform( nTUkUVD - nTUkUVP, PICPIC ) )
         ELSE
            PPljuc( Transform( nTUkUVD2 - nTUkUVP2, PICPIC ) )
         ENDIF

         FOR i := 1 TO Len( anInterVV )
            IF ( cValuta == "1" )
               PPljuc( Transform( anInterVV[ i, 1, 2 ] -anInterVV[ i, 2, 2 ], PICPIC ) )
            ELSE
               PPljuc( Transform( anInterVV[ i, 3, 2 ] -anInterVV[ i, 4, 2 ], PICPIC ) )
            ENDIF
         NEXT

         IF ( cValuta == "1" )
            PPljuc( Transform( nTUkVVD - nTUkVVP, PICPIC ) )
            PPljuc( Transform( nTUDug - nTUPot, PICPIC ) )
         ELSE
            PPljuc( Transform( nTUkVVD2 - nTUkVVP2, PICPIC ) )
            PPljuc( Transform( nTUDug2 - nTUPot2, PICPIC ) )
         ENDIF

         IF lExpRpt == .T.

            IF cValuta == "1"
               fill_ost_tbl( cSaRokom, "UKUPNO", "", nTUkUVD - nTUkUVP, nTUkVVD - nTUkVVP, nTUDug - nTUPot, anInterUV[ 1, 1, 2 ] - anInterUV[ 1, 2, 2 ], anInterUV[ 2, 1, 2 ] - anInterUV[ 2, 2, 2 ], anInterUV[ 3, 1, 2 ] - anInterUV[ 3, 2, 2 ], anInterUV[ 4, 1, 2 ] - anInterUV[ 4, 2, 2 ], anInterUV[ 5, 1, 2 ] - anInterUV[ 5, 2, 2 ], anInterVV[ 1, 1, 2 ] - anInterVV[ 1, 2, 2 ], anInterVV[ 2, 1, 2 ] - anInterVV[ 2, 2, 2 ], anInterVV[ 3, 1, 2 ] - anInterVV[ 3, 2, 2 ], anInterVV[ 4, 1, 2 ] - anInterVV[ 4, 2, 2 ], anInterVV[ 5, 1, 2 ] - anInterVV[ 5, 2, 2 ] )
            ELSE
               fill_ost_tbl( cSaRokom, "UKUPNO", "", nTUkUVD2 - nTUkUVP2, nTUkVVD2 - nTUkVVP2, nTUDug2 - nTUPot2, anInterUV[ 1, 3, 2 ] - anInterUV[ 1, 4, 2 ], anInterUV[ 2, 3, 2 ] - anInterUV[ 2, 4, 2 ], anInterUV[ 3, 3, 2 ] - anInterUV[ 3, 4, 2 ], anInterUV[ 4, 3, 2 ] - anInterUV[ 4, 4, 2 ], anInterUV[ 5, 3, 2 ] - anInterUV[ 5, 4, 2 ], anInterVV[ 1, 3, 2 ] - anInterVV[ 1, 4, 2 ], anInterVV[ 2, 3, 2 ] - anInterVV[ 2, 4, 2 ], anInterVV[ 3, 3, 2 ] - anInterVV[ 3, 4, 2 ], anInterVV[ 4, 3, 2 ] - anInterVV[ 4, 4, 2 ], anInterVV[ 5, 3, 2 ] - anInterVV[ 5, 4, 2 ] )
            ENDIF

         ENDIF

      ELSE
         IF ( cValuta == "1" )
            PPljuc( Transform( nTUkUVD - nTUkUVP, PICPIC ) )
            PPljuc( Transform( nTUkVVD - nTUkVVP, PICPIC ) )
            PPljuc( Transform( nTUDug - nTUPot, PICPIC ) )
         ELSE
            PPljuc( Transform( nTUkUVD2 - nTUkUVP2, PICPIC ) )
            PPljuc( Transform( nTUkVVD2 - nTUkVVP2, PICPIC ) )
            PPljuc( Transform( nTUDug2 - nTUPot2, PICPIC ) )
         ENDIF

         IF lExpRpt == .T.

            IF cValuta == "1"
               fill_ost_tbl( cSaRokom, "UKUPNO", "", nTUkUVD - nTUkUVP, nTUkVVD - nTUkVVP, nTUDug - nTUPot )
            ELSE
               fill_ost_tbl( cSaRokom, "UKUPNO", "", nTUkUVD2 - nTUkUVP2, nTUkVVD2 - nTUkVVP2, nTUDug2 - nTUPot2 )
            ENDIF

         ENDIF

      ENDIF

      ? cTmpL

   ENDIF

   FF

   ENDPRINT

   IF lExpRpt == .T.
      tbl_export()
   ENDIF

   SELECT ( F_POM )
   USE

   CLOSERET

   RETURN


// -----------------------------------------------------
// vraca liniju za report varijanta 1
// -----------------------------------------------------
STATIC FUNCTION _get_line1( cTmpL, cSaRokom, cPicForm )

   LOCAL cStart := "�"
   LOCAL cMidd := "�"
   LOCAL cLine := "�"
   LOCAL cEnd := "�"
   LOCAL cFill := "�"
   LOCAL nFor := 3

   IF cSaRokom == "D"
      nFor := 13
   ENDIF

   cTmpL := cStart
   cTmpL += Replicate( cFill, __par_len )
   cTmpL += cMidd
   cTmpL += Replicate( cFill, 25 )

   FOR i := 1 TO nFor
      cTmpL += cLine
      cTmpL += Replicate( cFill, Len( cPicForm ) )
   NEXT

   cTmpL += cEnd

   RETURN

// ------------------------------------------------------
// vraca liniju varijantu 2
// ------------------------------------------------------
STATIC FUNCTION _get_line2( cTmpL, cSaRokom, cPicForm )

   LOCAL cStart := "�"
   LOCAL cLine := "�"
   LOCAL cEnd := "�"
   LOCAL cFill := "�"
   LOCAL nFor := 3

   IF cSaRokom == "D"
      nFor := 13
   ENDIF

   cTmpL := cStart
   cTmpL += Replicate( cFill, __par_len )
   cTmpL += cLine
   cTmpL += Replicate( cFill, 25 )

   FOR i := 1 TO nFor
      cTmpL += cLine
      cTmpL += Replicate( cFill, Len( cPicForm ) )
   NEXT

   cTmpL += cEnd

   RETURN



// --------------------------------------------------------
// provjeri da li je saldo partnera 0, vraca .t. ili .f.
// --------------------------------------------------------
FUNCTION saldo_nula( cIdPartn )

   LOCAL nPRecNo
   LOCAL nLRecNo
   LOCAL nDug := 0
   LOCAL nPot := 0

   nPRecNo := RecNo()

   DO WHILE !Eof() .AND. idpartner == cIdPartn
      nDug += dug
      nPot += pot
      SKIP
   ENDDO

   SKIP -1

   nLRecNo := RecNo()

   IF ( Round( nDug, 2 ) - Round( nPot, 2 ) == 0 )
      GO ( nLRecNo )
      RETURN .T.
   ENDIF

   GO ( nPRecNo )

   RETURN .F.


/*! \fn ZSpecPoDosp(fStrana,lSvi)
 *  \brief Zaglavlje izvjestaja specifikacije po dospjecu
 *  \param fStrana
 *  \param lSvi
 */

FUNCTION ZSpecPoDosp( fStrana, lSvi, PICPIC )

   LOCAL nII
   LOCAL cTmp

   ?

   IF cSaRokom == "D" .AND. ( ( Len( AllTrim( PICPIC ) ) * 13 ) + 46 ) > 170
      ?? "#%LANDS#"
   ENDIF

   IF cPoRn == "D"
      IF gVar1 == "0"
         P_COND2
      ELSE
         P_COND
      ENDIF
   ELSE
      IF cSaRokom == "D"
         P_COND2
      ELSE
         P_10CPI
      ENDIF
   ENDIF

   IF lSvi == NIL
      lSvi := .F.
   ENDIF

   IF fStrana == NIL
      fStrana := .F.
   ENDIF

   IF nStr = 0
      fStrana := .T.
   ENDIF

   IF cPoRn == "D"
      ?? "FIN.P:  SPECIFIKACIJA OTVORENIH STAVKI PO DOSPIJECU NA DAN "; ?? dNaDan
      IF fStrana
         @ PRow(), 110 SAY "Str:" + Str( ++nStr, 3 )
      ENDIF

      SELECT PARTN
      HSEEK cIdFirma

      ? "FIRMA:", cIdFirma, "-", gNFirma

      SELECT KONTO
      HSEEK cIdKonto

      ? "KONTO  :", cIdKonto, naz

      IF lSvi
         ? "PARTNER: SVI"
      ELSE
         SELECT PARTN
         HSEEK cIdPartner
         ? "PARTNER:", cIdPartner, Trim( PadR( naz, 25 ) ), " ", Trim( naz2 ), " ", Trim( mjesto )
      ENDIF

      ? m
      ?

      ?? "Dat.dok.*Dat.val.* "

      IF gVar1 == "0"
         ?? "  BrDok   *   dug " + ValDomaca() + "  *   pot " + ValDomaca() + "   *  saldo  " + ValDomaca() + " * dug " + ValPomocna() + " * pot " + ValPomocna() + " *saldo " + ValPomocna() + "*      U/VAN VALUTE      *"
      ELSE
         ?? "  BrDok   *   dug " + ValDomaca() + "  *   pot " + ValDomaca() + "   *  saldo  " + ValDomaca() + " *      U/VAN VALUTE      *"
      ENDIF

      ? m

   ELSE
      ?? "FIN.P:  SPECIFIKACIJA OTVORENIH STAVKI PO DOSPIJECU NA DAN "; ?? dNaDan
      SELECT PARTN
      HSEEK cIdFirma
      ? "FIRMA:", cIdFirma, "-", gNFirma
      SELECT KONTO
      HSEEK cIdKonto

      ? "KONTO  :", cIdKonto, naz

      IF cSaRokom == "D"

         // prvi red
         cTmp := "�"
         cTmp += Replicate( "�", __par_len )
         cTmp += "�"
         cTmp += Replicate( "�", 25 )
         cTmp += "�"
         cTmp += Replicate( "�", ( Len( PICPIC ) * 5 ) + 4 )
         cTmp += "�"
         cTmp += Replicate( "�", Len( PICPIC ) )
         cTmp += "�"
         cTmp += Replicate( "�", ( Len( PICPIC ) * 5 ) + 4 )
         cTmp += "�"
         cTmp += Replicate( "�", Len( PICPIC ) )
         cTmp += "�"
         cTmp += Replicate( "�", Len( PICPIC ) )
         cTmp += "�"

         ? cTmp

         // drugi red
         cTmp := "�"
         cTmp += Replicate( " ", __par_len )
         cTmp += "�"
         cTmp += Replicate( " ", 25 )
         cTmp += "�"
         cTmp += _f_text( "U      V  A  L  U  T  I", ( Len( PICPIC ) * 5 ) + 4 )

         cTmp += "�"
         cTmp += Replicate( " ", Len( PICPIC ) )

         cTmp += "�"
         cTmp += _f_text( "V  A  N      V  A  L  U  T  E", ( Len( PICPIC ) * 5 ) + 4 )
         cTmp += "�"
         cTmp += Replicate( " ", Len( PICPIC ) )
         cTmp += "�"
         cTmp += Replicate( " ", Len( PICPIC ) )
         cTmp += "�"

         ? cTmp


         // treci red
         cTmp := "�"
         cTmp += PadC( "SIFRA", __par_len )
         cTmp += "�"
         cTmp += _f_text( "NAZIV  PARTNERA", 25 )
         cTmp += "�"

         FOR nII := 1 TO 5
            cTmp += Replicate( "�", Len( PICPIC ) )

            IF nII == 5
               cTmp += "�"
            ELSE
               cTmp += "�"
            ENDIF

         NEXT

         cTmp += _f_text( " ", Len( PICPIC ) )
         cTmp += "�"

         FOR nII := 1 TO 5
            cTmp += Replicate( "�", Len( PICPIC ) )

            IF nII == 5
               cTmp += "�"
            ELSE
               cTmp += "�"
            ENDIF
         NEXT

         cTmp += _f_text( " ", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "UKUPNO", Len( PICPIC ) )
         cTmp += "�"

         ? cTmp

         cTmp := "�"
         cTmp += PadC( "PARTN.", __par_len )
         cTmp += "�"
         cTmp += _f_text( " ", 25 )

         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana1, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana2, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana3, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana4, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "PR." + Str( nDoDana4, 2 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "UKUPNO", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana1, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana2, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana3, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "DO" + Str( nDoDana4, 3 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "PR." + Str( nDoDana4, 2 ) + " D.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "UKUPNO", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( " ", Len( PICPIC ) )
         cTmp += "�"

         ? cTmp

         cTmp := "�"
         cTmp += Replicate( "�", __par_len )
         cTmp += "�"
         cTmp += Replicate( "�", 25 )

         FOR nII := 1 TO 13
            cTmp += "�"
            cTmp += Replicate( "�", Len( PICPIC ) )
         NEXT

         cTmp += "�"

         ? cTmp

      ELSE

         // 1 red
         cTmp := "�"
         cTmp += Replicate( "�", __par_len )
         cTmp += "�"
         cTmp += Replicate( "�", 25 )

         FOR nII := 1 TO 3
            cTmp += "�"
            cTmp += Replicate( "�", Len( PICPIC ) )
         NEXT

         cTmp += "�"

         ? cTmp


         // 2 red

         cTmp := "�"
         cTmp += PadC( "SIFRA", __par_len )
         cTmp += "�"
         cTmp += _f_text( " ", 25 )
         cTmp += "�"
         cTmp += _f_text( "UKUPNO", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "UKUPNO", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( " ", Len( PICPIC ) )
         cTmp += "�"

         ? cTmp

         // 3 red

         cTmp := "�"
         cTmp += PadC( "PARTN.", __par_len )
         cTmp += "�"
         cTmp += _f_text( "NAZIV PARTNERA", 25 )
         cTmp += "�"
         cTmp += _f_text( "U VALUTI", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "VAN VAL.", Len( PICPIC ) )
         cTmp += "�"
         cTmp += _f_text( "UKUPNO", Len( PICPIC ) )
         cTmp += "�"

         ? cTmp

         // 4 red
         cTmp := "�"
         cTmp += REPL( "�", __par_len )
         cTmp += "�"
         cTmp += Replicate( "�", 25 )

         FOR nII := 1 TO 3
            cTmp += "�"
            cTmp += Replicate( "�", Len( PICPIC ) )
         NEXT

         cTmp += "�"

         ? cTmp
      ENDIF
   ENDIF

   RETURN


// ---------------------------------------------
// formatiraj tekst ... na nLen
// ---------------------------------------------
STATIC FUNCTION _f_text( cTxt, nLen )
   RETURN PadC( cTxt, nLen )




/*! \fn getmjesto(cMjesto)
 *  \brief
 *  \param cMjesto
 */

FUNCTION getmjesto( cMjesto )

   LOCAL fRet
   LOCAL nSel := Select()

   SELECT partn
   SEEK ( nsel )->idpartner
   fRet := .F.
   IF mjesto = cMjesto
      fRet := .T.
   ENDIF
   SELECT ( nSel )

   RETURN fRet




/*! \fn P_VKSG(cId,dx,dy)
 *  \brief
 *  \param cId
 *  \param dx
 *  \param dy
 */

FUNCTION P_VKSG( cId, dx, dy )

   PRIVATE ImeKol, Kol

   ImeKol := { { "Konto", {|| id    },     "id"       }, ;
      { "Godina", {|| godina },     "godina"   }, ;
      { "St.konto", {|| ids   },     "ids"      };
      }
   Kol := { 1, 2, 3 }

   RETURN PostojiSifra( F_VKSG, 1, 10, 60, "Veze konta sa prethodnim godinama", @cId, dx, dy )




/*! \fn FFor1()
 *  \brief Funkcija koju koristi StampaTabele()
 */

STATIC FUNCTION FFor1()

   cIdP := IDPARTNER

   ukPartner := 0
   FOR i := 1 TO Len( aGod )
      cPom7777 := "ukGOD" + aGod[ i, 1 ]
      &cPom7777 := 0
   NEXT
   cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) -1, 4 )
   &cPom7777 := 0
   cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) -2, 4 )
   &cPom7777 := 0

   DO WHILE !Eof() .AND. IDPARTNER == cIdP
      FOR i := 1 TO Len( aGod )
         cPom7777 := "ukGOD" + aGod[ i, 1 ]
         cPom7778 := SubStr( cPom7777, 3 )
         &cPom7777 += &cPom7778
         ukPartner += &cPom7778
      NEXT
      cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) -1, 4 )
      cPom7778 := SubStr( cPom7777, 3 )
      &cPom7777 += &cPom7778
      ukPartner += &cPom7778
      cPom7777 := "ukGOD" + Str( Val( aGod[ i - 1, 1 ] ) -2, 4 )
      cPom7778 := SubStr( cPom7777, 3 )
      &cPom7777 += &cPom7778
      ukPartner += &cPom7778
      SKIP 1
   ENDDO
   SKIP -1

   RETURN .T.


/*! fn FSvaki1()
 */

STATIC FUNCTION FSvaki1()

   ++nRbr
   cNPartnera := PadR( Ocitaj( F_PARTN, IDPARTNER, "naz" ), 25 )

   RETURN



/* fn Zagl6
 *  brief Zaglavlje specifikacije
 *  param cSkVar
 */

STATIC FUNCTION Zagl6( cSkVar )

/*

?
B_ON
P_COND

?? "FIN: SPECIFIKACIJA SUBANALITICKIH KONTA  ZA "

if cTip=="1"
  ?? ValDomaca()
elseif cTip=="2"
  ?? ValPomocna()
else
  ?? ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())
endif

if !(empty(dDatOd) .and. empty(dDatDo))
  ?? "  ZA DOKUMENTE U PERIODU ",dDatOd,"-",dDatDo
endif

?? " NA DAN: "; ?? DATE()
IF !EMPTY(qqBrDok)
  ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '"+TRIM(qqBrDok)+"'"
ENDIF


@ prow(),125 SAY "Str:"+str(++nStr,3)
B_OFF

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 IF EMPTY(cIdFirma)
  ? "Firma:",gNFirma,"(SVE RJ)"
 ELSE
  SELECT PARTN; HSEEK cIdFirma
  ? "Firma:",cidfirma,PADR(partn->naz, 25),partn->naz2
 ENDIF
endif

?
PrikK1k4()

select SUBAN

IF cSkVar=="D"
  F12CPI
  ? m
ELSE
  P_COND
  ? m
ENDIF
if cTip $ "12"
  IF cSkVar!="D"
    ? "KONTO  " + PADC("PARTN.", __par_len) + "  NAZIV KONTA / PARTNERA                                          duguje            potrazuje                saldo"
  ELSE
    ? "KONTO  " + PADC("PARTN", __par_len) + "  " +  PADR("NAZIV KONTA / PARTNERA",nDOpis)+" "+PADC("duguje",nDIznos)+" "+PADC("potrazuje",nDIznos)+" "+PADC("saldo",nDIznos)
  ENDIF
else
  IF cSkVar!="D"
    ? "KONTO  " + PADC("PARTN.", __par_len) + "  NAZIV KONTA / PARTNERA                                       saldo "+ValDomaca()+"           saldo "+ALLTRIM(ValPomocna())
  ELSE
    ? "KONTO  " + PADC("PARTN.", __par_len) + "  "+PADR("NAZIV KONTA / PARTNERA",nDOpis)+" "+PADC("saldo "+ValDomaca(),nDIznos)+" "+PADC("saldo "+ALLTRIM(ValPomocna()),nDIznos)
  ENDIF
endif
? m

*/
   RETURN .T.
