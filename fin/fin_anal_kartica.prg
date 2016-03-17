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


FUNCTION fin_anal_kartica()

   LOCAL nCOpis := 0, cOpis := ""

   cIdFirma := gFirma
   qqKonto := ""
   cBrza := "D"
   cPTD := "N"
   IF gVar1 == "0"
      M := "------- -------- ---- -------- ---------------- ----------------- ----------------- ------------- ------------- -------------"
   ELSE
      M := "------- -------- ---- -------- ---------------- ----------------- ------------------"
   ENDIF

   O_PARTN
   O_KONTO

   dDatOd := dDAtDo := CToD( "" )
   cPredh := "2"

   O_PARAMS
   PRIVATE cSection := "3", cHistory := " ", aHistory := {}
   Params1()
   RPar( "c1", @cIdFirma ); RPar( "c2", @qqKonto ); RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )
   RPar( "c3", @cBrza )
   RPar( "c4", @cPredh )
   RPar( "c8", @cPTD )
   IF gNW == "D";cIdFirma := gFirma; ENDIF

   Box( "", 9, 65, .F. )
   DO WHILE .T.
      SET CURSOR ON
      @ m_x + 1, m_y + 2 SAY "ANALITICKA KARTICA"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Brza kartica (D/N/S)" GET cBrza PICT "@!" VALID cBrza $ "DNS"
      @ m_x + 4, m_y + 2 SAY "BEZ/SA prethodnim prometom (1/2):" GET cPredh VALID cPredh $ "12"
      read; ESC_BCR
      IF cBrza == "D"
         qqKonto := PadR( qqKonto, 7 )
         @ m_x + 6, m_y + 2 SAY "Konto: " GET qqKonto VALID P_Konto( @qqKonto )
      ELSE
         qqKonto := PadR( qqKonto, 60 )
         @ m_x + 6, m_y + 2 SAY "Konto: " GET qqKonto PICTURE "@S50"
      ENDIF
      IF gNW == "N"
         @ m_x + 7, m_y + 2 SAY "Prikaz tipa dokumenta (D/N)" GET cPTD PICT "@!" VALID cPTD $ "DN"
      ENDIF
      @ m_x + 8, m_y + 2 SAY "Datum od:" GET dDatOd
      @ m_x + 8, Col() + 2 SAY "do:" GET dDatDo
      cIdRJ := ""
      IF gRJ == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 9, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
      read; ESC_BCR

      IF cBrza == "N" .OR. cBrza == "S"
         qqKonto := Trim( qqKonto )
         aUsl1 := Parsiraj( qqKonto, "IdKonto", "C" )
         IF aUsl1 <> NIL; exit; ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO
   BoxC()

   IF cIdRj == "999999"; cidrj := ""; ENDIF
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cidrj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   IF Params2()
      WPar( "c1", PadR( cIdFirma, 2 ) ); WPar( "c2", @qqKonto ); WPar( "d1", @dDatOd ); WPar( "d2", @dDatdo )
      WPar( "c3", cBrza )
      WPar( "c4", cPredh )
      WPar( "c8", cPTD )
   ENDIF
   SELECT params; USE

   IF gNW == "N" .AND. cPTD == "D"
      m := Stuff( m, 30, 0, " -- ------------- ---------- --------------------" )
      O_SUBAN; SET ORDER TO TAG 4
      O_TDOK
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      otvori_sint_anal_kroz_temp( .F., "IDRJ='" + cIdRJ + "'" )
   ELSE
      O_ANAL
   ENDIF
   O_KONTO

   SELECT ANAL

   IF cBrza == "S"
      SET ORDER TO TAG "3"
   ENDIF

   cFilt1 := ".t." + IF( cBrza == "D", "", ".and." + aUsl1 ) + ;
      IF( Empty( dDatOd ) .OR. cPredh == "2", "", ".and.DATNAL>=" + dbf_quote( dDatOd ) ) + ;
      IF( Empty( dDatDo ), "", ".and.DATNAL<=" + dbf_quote( dDatDo ) )

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   IF cBrza == "D"
      HSEEK cIdFirma + qqKonto
   ELSE
      HSEEK cIdFirma
   ENDIF

   EOF CRET

   nStr := 0

   IF cBrza == "S"; m := "------- " + m; ENDIF

   START PRINT CRET

   IF nStr == 0; AnalKZagl(); ENDIF

   nSviD := nSviP := nSviD2 := nSviP2 := 0
   DO WHILE !Eof() .AND. IdFirma = cIdFirma

      IF cBrza == "D"
         IF qqKonto <> IdKonto; exit; ENDIF
      ENDIF

      nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
      cIdkonto := IdKonto

      IF PRow() > 55 + dodatni_redovi_po_stranici(); FF; AnalKZagl(); ENDIF
      ? m
      SELECT KONTO; HSEEK cIdKonto; SELECT anal
      IF cBrza == "S"
         ? "KONTA : ", qqKonto
      ELSE
         ? "KONTO   ", cIdKonto, AllTrim( konto->naz )
      ENDIF
      ? m

      nDugBHD := nPotBHD := DugDEM := nPotDEM := 0
      fPProm := .T.
      DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. ( cIdKonto == IdKonto .OR. cBrza == "S" )
         // ********* prethodni promet *********************************
         IF cPredh == "2"
            IF dDatOd > datnal .AND. fPProm == .T.
               nDugBHD += DugBHD; nPotBHD += PotBHD
               nDugDEM += DugDEM; nPotDEM += PotDEM
               skip; LOOP
            ELSE
               IF fPProm
                  ? "Prethodno stanje"
                  @ PRow(), IF( gNW == "N" .AND. cPTD == "D", 31 + 49, 31 ) SAY nDugBHD     PICTURE PicBHD
                  @ PRow(), PCol() + 2  SAY nPotBHD     PICTURE PicBHD
                  @ PRow(), PCol() + 2  SAY nDugBHD - nPotBHD PICTURE PicBHD
                  IF gVar1 == "0"
                     @ PRow(), PCol() + 2  SAY nDugDEM     PICTURE PicDEM
                     @ PRow(), PCol() + 2  SAY nPotDEM     PICTURE PicDEM
                     @ PRow(), PCol() + 2  SAY nDugDEM - nPotDEM PICTURE PicDEM
                  ENDIF
               ENDIF
               fPProm := .F.
            ENDIF
         ENDIF

         IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; AnalKZagl();ENDIF
         IF cBrza == "S"
            @ PRow() + 1, 3 SAY IdKonto
            @ PRow(), 11 SAY IdVN
            @ PRow(), 16 SAY BrNal
            @ PRow(), 25 SAY RBr
            @ PRow(), 31 SAY DatNal
         ELSE
            @ PRow() + 1, 3 SAY IdVN
            @ PRow(), 8 SAY BrNal
            @ PRow(), 17 SAY RBr
            @ PRow(), 22 SAY DatNal
         ENDIF
         IF gNW == "N" .AND. cPTD == "D"
            lPom := .F.
            SELECT SUBAN; GO TOP
            SEEK ANAL->( idfirma + idvn + brnal )
            DO WHILE !Eof() .AND. ANAL->( idfirma + idvn + brnal ) == idfirma + idvn + brnal
               IF ANAL->idkonto == idkonto; lPom := .T. ; EXIT; ENDIF
               SKIP 1
            ENDDO
            IF lPom
               SELECT TDOK; HSEEK SUBAN->idtipdok
            ENDIF
            SELECT ANAL
            @ PRow(), 31 + IF( cBrza == "S", 8, 0 ) SAY IF( lPom, SUBAN->idtipdok, "??"      )
            @ PRow(), PCol() + 1 SAY IF( lPom, TDOK->naz, Space( 13 ) )
            @ PRow(), PCol() + 1 SAY IF( lPom, SUBAN->brdok, Space( 10 ) )
            nCOpis := PCol() + 1
            @ PRow(), PCol() + 1 SAY IF( lPom, PadR( cOpis := AllTrim( SUBAN->opis ), 20 ), Space( 20 ) )
         ENDIF
         @ PRow(), IF( gNW == "N" .AND. cPTD == "D", 30 + 49, 31 ) + IF( cBrza == "S", 8, 0 ) SAY DugBHD PICTURE PicBHD
         @ PRow(), PCol() + 2 SAY PotBHD PICTURE picBHD
         nDugBHD += DugBHD; nPotBHD += PotBHD
         @ PRow(), PCol() + 2 SAY nDugBHD - nPotBHD PICTURE PicBHD
         IF gVar1 == "0"
            @ PRow(), PCol() + 2 SAY DugDEM PICTURE PicDEM
            @ PRow(), PCol() + 2 SAY PotDEM PICTURE picDEM
            nDugDEM += DugDEM; nPotDEM += PotDEM
            @ PRow(), PCol() + 2 SAY nDugDEM - nPotDEM PICTURE PicDEM
         ENDIF
         OstatakOpisa( cOpis, nCOpis, {|| IF( PRow() > 61 + dodatni_redovi_po_stranici(), Eval( {|| gPFF(), AnalKZagl() } ), ) } )
         SKIP
      ENDDO    // konto

      IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; AnalKZagl(); ENDIF
      ? M
      IF cBrza == "S"
         ? "UKUPNO ZA KONTA:" + qqKonto
      ELSE
         ? "UKUPNO ZA KONTO:" + cIdKonto
      ENDIF
      @ PRow(), IF( gNW == "N" .AND. cPTD == "D", 30 + 49, 31 ) + IF( cBrza == "S", 8, 0 ) SAY nDugBHD  PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nPotBHD           PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nDugBHD - nPotBHD   PICTURE PicBHD

      IF gVar1 == "0"
         @ PRow(), PCol() + 2  SAY nDugDEM           PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nPotDEM           PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nDugDEM - nPotDEM   PICTURE PicDEM
      ENDIF
      ? M

      nSviD += nDugBHD; nSviP += nPotBHD
      nSviD2 += nDugDEM; nSviP2 += nPotDEM

      IF gnRazRed == 99
         FF; AnalKZagl()
      ELSE
         i := 0
         DO WHILE PRow() <= 55 + dodatni_redovi_po_stranici() .AND. gnRazRed > i
            ?; ++i
         ENDDO
      ENDIF

   ENDDO // eof()

   IF cBrza == "N"
      IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; AnalKZagl(); ENDIF
      ? M
      ? "UKUPNO ZA SVA KONTA:"
      @ PRow(), IF( gNW == "N" .AND. cPTD == "D", 30 + 49, 31 ) SAY nSviD  PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nSviP             PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nSviD - nSviP       PICTURE PicBHD

      IF gVar1 == "0"
         @ PRow(), PCol() + 2  SAY nSviD2            PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nSviP2            PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nSviD2 - nSviP2     PICTURE PicDEM
      ENDIF
      ? m
   ENDIF

   FF

   ENDPRINT

   closeret

   RETURN




/*! \fn AnalKZagl()
 *  \brief Zaglavlje analiticke kartice
 */

FUNCTION AnalKZagl()

   ?
   P_COND
   ?? "FIN.P: ANALITICKA KARTICA  NA DAN: "; ?? Date()
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "   ZA PERIOD OD", dDatOd, "DO", dDatDo
   ENDIF
   @ PRow(), 125 SAY "Str." + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, "-", gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cIdFirma, AllTrim( partn->naz ), AllTrim( partn->naz2 )
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT ANAL

   IF gVar1 == "0"
      IF gNW == "N" .AND. cPTD == "D"
         P_COND2
      ENDIF
      ? IF( cBrza == "S", "------- ", "" ) + "------- -------- ---- --------" + IF( gNW == "N" .AND. cPTD == "D", " ------------------------------------------------", "" ) + " ---------------------------------------------------- -----------------------------------------"
      ? IF( cBrza == "S", "*      *", "" ) + "*VRSTA * BROJ   *REDN* DATUM  " + IF( gNW == "N" .AND. cPTD == "D", "*                D O K U M E N T                 ", "" ) + "*             I Z N O S     U     " + ValDomaca() + "               *        I Z N O S     U     " + ValPomocna() + "        *"
      ? IF( cBrza == "S", " KONTO  ", "" ) + "                              " + IF( gNW == "N" .AND. cPTD == "D", " ------------------------------------------------", "" ) + " ---------------------------------------------------- -----------------------------------------"
      ? IF( cBrza == "S", "*      *", "" ) + "*NALOGA*NALOGA  *BROJ*        " + IF( gNW == "N" .AND. cPTD == "D", "*     T I P      * VEZ.BROJ *        OPIS        ", "" ) + "*     DUGUJE     *   POTRAZUJE     *       SALDO     *   DUGUJE   *  POTRAZUJE  *    SALDO    *"
   ELSE
      IF gNW == "N" .AND. cPTD == "D"
         P_COND
      ELSE
         F12CPI
      ENDIF
      ? IF( cBrza == "S", "------- ", "" ) + "------- -------- ---- --------" + IF( gNW == "N" .AND. cPTD == "D", " ------------------------------------------------", "" ) + " -----------------------------------------------------"
      ? IF( cBrza == "S", "*      *", "" ) + "*VRSTA * BROJ   *REDN* DATUM  " + IF( gNW == "N" .AND. cPTD == "D", "*                D O K U M E N T                 ", "" ) + "*             I Z N O S     U     " + ValDomaca() + "               *"
      ? IF( cBrza == "S", " KONTO  ", "" ) + "                              " + IF( gNW == "N" .AND. cPTD == "D", " ------------------------------------------------", "" ) + " -----------------------------------------------------"
      ? IF( cBrza == "S", "*      *", "" ) + "*NALOGA*NALOGA  *BROJ*        " + IF( gNW == "N" .AND. cPTD == "D", "*     T I P      * VEZ.BROJ *        OPIS        ", "" ) + "*     DUGUJE     *   POTRAZUJE     *       SALDO     *"
   ENDIF
   ? M

   RETURN
