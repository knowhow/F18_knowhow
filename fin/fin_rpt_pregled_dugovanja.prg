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

// ------------------------------------------------------
// specifikacija dugovanja partnera po r.intervalima
// ------------------------------------------------------
FUNCTION SpecDugPartnera()

   LOCAL nCol1 := 72
   LOCAL cSvi := "N"
   LOCAL _partner := fetch_metric( "fin_spec_po_dobav_partner", NIL, Space( 6 ) )
   PRIVATE cIdPartner

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
   cSaRokom := "D"
   cValuta := "1"

   nDoDana1 :=  8
   nDoDana2 := 15
   nDoDana3 := 30
   nDoDana4 := 60

   PICPIC := "9999999999.99"

   Box(, 13, 60 )
   IF gNW == "D"
      @ m_x + 1, m_y + 2 SAY "Firma "
      ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF

   @ m_x + 2, m_y + 2 SAY "Konto:               " GET cIdkonto   PICT "@!"  VALID P_konto( @cIdkonto )
   @ m_x + 3, m_y + 2 SAY "Izvjestaj se pravi na dan:" GET dNaDan
   @ m_x + 4, m_y + 2 SAY "Interval 1: do (dana)" GET nDoDana1 PICT "999"
   @ m_x + 5, m_y + 2 SAY "Interval 2: do (dana)" GET nDoDana2 PICT "999"
   @ m_x + 6, m_y + 2 SAY "Interval 3: do (dana)" GET nDoDana3 PICT "999"
   @ m_x + 7, m_y + 2 SAY "Interval 4: do (dana)" GET nDoDana4 PICT "999"
   @ m_x + 10, m_y + 2 SAY "Prikaz iznosa (format)" GET PICPIC PICT "@!"
   @ m_x + 11, m_y + 2 SAY "Uslov po opcini (prazno - nista)" GET cOpcine
   @ m_x + 12, m_y + 2 SAY "Partner (prazno-svi):" GET _partner VALID Empty( _partner ) .OR. P_Firma( @_partner )
   @ m_x + 13, m_y + 2 SAY "Izvjestaj za (1)KM (2)EURO" GET cValuta VALID cValuta $ "12"

   READ
   ESC_BCR
   BoxC()

   set_metric( "fin_spec_po_dobav_partner", NIL, _partner )

   IF Empty( cIdPartner )
      cIdPartner := ""
   ENDIF

   cSvi := cIdPartner

   // odredjivanje prirode zadanog konta (dug. ili pot.)
   // --------------------------------------------------
   SELECT ( F_TRFP2 )
   IF !Used()
      O_TRFP2
   ENDIF
   HSEEK "99 " + Left( cIdKonto, 1 )
   DO WHILE !Eof() .AND. IDVD == "99" .AND. Trim( idkonto ) != Left( cIdKonto, Len( Trim( idkonto ) ) )
      SKIP 1
   ENDDO
   IF IDVD == "99" .AND. Trim( idkonto ) == Left( cIdKonto, Len( Trim( idkonto ) ) )
      cDugPot := D_P
   ELSE
      cDugPot := "1"
      Box(, 3, 60 )
      @ m_x + 2, m_y + 2 SAY "Konto " + cIdKonto + " duguje / potrazuje (1/2)" GET cdugpot  VALID cdugpot $ "12" PICT "9"
      READ
      Boxc()
   ENDIF

   fin_create_pom_table(, __par_len )  // kreiraj pomocnu bazu

   gaZagFix := { 4, 5 }

   START PRINT RET

   nUkDugBHD := 0
   nUkPotBHD := 0

   SELECT suban
   SET ORDER TO TAG "3"

   SEEK cIdFirma + cIdKonto + cIdPartner

   DO WHILE !Eof() .AND. idfirma == cIdfirma .AND. cIdKonto == IdKonto

      cIdPartner := idpartner
      nUDug2 := 0
      nUPot2 := 0
      nUDug := 0
      nUPot := 0

      fPrviProlaz := .T.

      DO WHILE !Eof() .AND. idfirma == cIdfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner


         cBrDok := BrDok
         cOtvSt := otvst
         nDug2 := 0
         nPot2 := 0
         nDug := 0
         nPot := 0

         aFaktura := { CToD( "" ), CToD( "" ), CToD( "" ) }

         DO WHILE !Eof() .AND. idfirma == cIdfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner .AND. brdok == cBrDok

            IF !Empty( _partner )
               IF _partner <> idpartner
                  SKIP
                  LOOP
               ENDIF
            ENDIF

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

         IF Round( nDug - nPot, 2 ) == 0
            // nista
         ELSE
            fPrviProlaz := .F.
            IF cPrelomljeno == "D"
               IF ( nDug - nPot ) > 0
                  nDug := nDug - nPot
                  nPot := 0
               ELSE
                  nPot := nPot - nDug
                  nDug := 0
               ENDIF
               IF ( nDug2 - nPot2 ) > 0
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

      IF PRow() > 58 + dodatni_redovi_po_stranici()
         FF
         ZaglDuznici()
      ENDIF

      IF ( !fVeci .AND. idpartner = cSvi ) .OR. fVeci
      ELSE
         EXIT
      ENDIF

   ENDDO

   SELECT POM
   INDEX ON IDPARTNER + OTVST + Rocnost() + DToS( DATDOK ) + DToS( iif( Empty( DATVAL ), DATDOK, DATVAL ) ) + BRDOK TAG "2"
   SET ORDER TO TAG "2"
   GO TOP

   nTUDug := nTUPot := nTUDug2 := nTUPot2 := 0
   nTUkUVD := nTUkUVP := nTUkUVD2 := nTUkUVP2 := 0
   nTUkVVD := nTUkVVP := nTUkVVD2 := nTUkVVP2 := 0

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

   cLastIdPartner := ""
   fPrviProlaz := .T.

   DO WHILE !Eof()

      cIdPartner := idpartner

      // a sada provjeri opcine
      // nadji partnera
      IF !Empty( cOpcine )
         SELECT partn
         HSEEK cIdPartner
         IF At( AllTrim( partn->idops ), cOpcine ) == 0
            SELECT pom
            SKIP
            LOOP
         ENDIF
         SELECT pom
      ENDIF

      nUDug := nUPot := nUDug2 := nUPot2 := 0
      nUkUVD := nUkUVP := nUkUVD2 := nUkUVP2 := 0
      nUkVVD := nUkVVP := nUkVVD2 := nUkVVP2 := 0

      FOR i := 1 TO Len( anInterVV )
         FOR j := 1 TO Len( anInterVV[ i ] )
            anInterVV[ i, j, 1 ] := 0
         NEXT
      NEXT

      cFaza := otvst
      nFaza := RRocnost()

      DO WHILE !Eof() .AND. cIdPartner == IdPartner

         IF fPrviProlaz
            ZaglDuznici()
            fPrviProlaz := .F.
         ENDIF

         SELECT pom

         IF cLastIdPartner != cIdPartner .OR. Len( cLastIdPartner ) < 1
            Pljuc( cIdPartner )
            PPljuc( PadR( Ocitaj( F_PARTN, cIdPartner, "naz" ), 25 ) )
            cLastIdPartner := cIdPartner
         ENDIF

         IF otvst <> " "
            nUkVVD  += Dug
            nUkVVP  += Pot
            nUkVVD2 += Dug2
            nUkVVP2 += Pot2
            anInterVV[ nFaza, 1, 1 ] += dug
            anInterVV[ nFaza, 2, 1 ] += pot
            anInterVV[ nFaza, 3, 1 ] += dug2
            anInterVV[ nFaza, 4, 1 ] += pot2
         ENDIF

         nUDug += Dug
         nUPot += Pot
         nUDug2 += Dug2
         nUPot2 += Pot2

         SKIP 1

         // znaci da treba
         IF cFaza != otvst .OR. Eof() .OR. cIdPartner != idpartner

            IF cFaza <> " "
               anInterVV[ nFaza, 1, 2 ] += anInterVV[ nFaza, 1, 1 ]
               anInterVV[ nFaza, 2, 2 ] += anInterVV[ nFaza, 2, 1 ]
               anInterVV[ nFaza, 3, 2 ] += anInterVV[ nFaza, 3, 1 ]
               anInterVV[ nFaza, 4, 2 ] += anInterVV[ nFaza, 4, 1 ]
               nTUkVVD  += nUkVVD
               nTUkVVP  += nUkVVP
               nTUkVVD2 += nUkVVD2
               nTUkVVP2 += nUkVVP2
            ENDIF

         ELSEIF nFaza != RRocnost()

            IF cFaza <> " "
               anInterVV[ nFaza, 1, 2 ] += anInterVV[ nFaza, 1, 1 ]
               anInterVV[ nFaza, 2, 2 ] += anInterVV[ nFaza, 2, 1 ]
               anInterVV[ nFaza, 3, 2 ] += anInterVV[ nFaza, 3, 1 ]
               anInterVV[ nFaza, 4, 2 ] += anInterVV[ nFaza, 4, 1 ]
            ENDIF

         ENDIF

         cFaza := otvst
         nFaza := RRocnost()

      ENDDO

      SELECT POM

      IF !fPrviProlaz  // bilo je stavki
         nIznosRok := 0
         nSaldo := nUDug - nUPot
         nSldDem := nUDug2 - nUPot2
         FOR i := 1 TO Len( anInterVV )
            IF ( cValuta == "1" )
               nIznosRok += anInterVV[ i, 1, 1 ] - anInterVV[ i, 2, 1 ]
               nIznosStavke := nSaldo - nIznosRok
               PPljuc( Transform( nIznosStavke, PICPIC ) )
            ELSE
               nIznosRok += anInterVV[ i, 3, 1 ] - anInterVV[ i, 4, 1 ]
               nIznosStavke := nSldDem - nIznosRok
               PPljuc( Transform( nIznosStavke, PICPIC ) )

            ENDIF
         NEXT
         IF ( cValuta == "1" )
            PPljuc( Transform( nUkVVD - nUkVVP, PICPIC ) )
            PPljuc( Transform( nSaldo, PICPIC ) )
         ELSE
            PPljuc( Transform( nUkVVD2 - nUkVVP2, PICPIC ) )
            PPljuc( Transform( nSldDem, PICPIC ) )
         ENDIF

         IF PRow() > 52 + dodatni_redovi_po_stranici()
            FF
            ZaglDuznici()
            fPrviProlaz := .F.
         ENDIF

      ENDIF

      nTUDug += nUDug
      nTUDug2 += nUDug2
      nTUPot += nUPot
      nTUPot2 += nUPot2

      IF PRow() > 58 + dodatni_redovi_po_stranici()
         FF
         ZaglDuznici( .T. )
      ENDIF

   ENDDO

   ? "�" + REPL( "�", __par_len ) + "���������������������������������������������������������������������������������������������������������������������������Ĵ"

   Pljuc( PadR( "UKUPNO", Len( POM->IDPARTNER + PadR( PARTN->naz, 25 ) ) + 1 ) )

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

   ? "�" + REPL( "�", __par_len ) + "�����������������������������������������������������������������������������������������������������������������������������"

   FF
   ENDPRINT

   SELECT ( F_POM )
   USE

   CLOSERET

   RETURN





// ///////////////////

/*! \fn ZaglDuznici(fStrana, lSvi)
 *  \brief Zaglavlje izvjestaja duznika
 *  \param fStrana
 *  \param lSvi
 */

FUNCTION ZaglDuznici( fStrana, lSvi )

   LOCAL nArr

   nArr := Select()
   ?
   P_COND2

   IF lSvi == NIL
      lSvi := .F.
   ENDIF

   IF fStrana == NIL
      fStrana := .F.
   ENDIF

   IF nStr = 0
      fStrana := .T.
   ENDIF

   ?? "FIN.P:  Specifikacija Dugovanja partnera po rocnim intervalima "; ?? dNaDan

   SELECT PARTN
   HSEEK cIdFirma

   ? "FIRMA:", cIdFirma, "-", gNFirma

   SELECT KONTO
   HSEEK cIdKonto

   ? "KONTO  :", cIdKonto, naz
   ? "�" + REPL( "�", __par_len ) + "���������������������������������������������������������������������������������������������������������������������������Ŀ"
   ? "�" + REPL( " ", __par_len ) + "�                         �                     V  A  N      V  A  L  U  T  E                                 �             �"
   ? "�" + PadR( "SIFRA", __par_len ) + "�     NAZIV  PARTNERA     �����������������������������������������������������������������������������������Ĵ  UKUPNO     �"
   ? "�" + PadR( "PARTN.", __par_len ) + "�                         �DO" + Str( nDoDana1, 3 ) + " D.     �DO" + Str( nDoDana2, 3 ) + " D.     �DO" + Str( nDoDana3, 3 ) + " D.     �DO" + Str( nDoDana4, 3 ) + " D.     �PR." + Str( nDoDana4, 2 ) + " D.     � UKUPNO      �             �"
   ? "�" + REPL( "�", __par_len ) + "���������������������������������������������������������������������������������������������������������������������������Ĵ"

   SELECT ( nArr )

   RETURN
