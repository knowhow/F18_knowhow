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


FUNCTION fin_sint_kartica()

   cIdFirma := gFirma
   qqKonto := ""
   dDatOd := fetch_metric( "fin_kart_datum_od", my_user(), CToD( "" ) )
   dDatDo := fetch_metric( "fin_kart_datum_do", my_user(), CToD( "" ) )
   cBrza := "D"

   IF fin_dvovalutno()
      M := "------- -------- ---- -------- ---------------- ----------------- ----------------- ------------- ------------- -------------"
   ELSE
      M := "------- -------- ---- -------- ---------------- ----------------- ------------------"
   ENDIF

   cPredh := "2"

   O_PARTN
   O_PARAMS

   PRIVATE cSection := "1"; cHistory := " ";aHistory := {}

   Params1()

   RPar( "c1", @cIdFirma )
   RPar( "c2", @qqKonto )
   RPar( "c3", @cBrza )
   RPar( "c4", @cPredh )

   IF gNW == "D"; cIdFirma := gFirma; ENDIF

   Box( "", 9, 75 )
   DO WHILE .T.
      SET CURSOR ON
      @ m_x + 1, m_y + 2 SAY "KARTICA (SINTETICKI KONTO)"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Brza kartica (D/N)               " GET cBrza PICT "@!" VALID cBrza $ "DN"
      @ m_x + 4, m_y + 2 SAY "BEZ/SA prethodnim prometom (1/2):" GET cPredh VALID cPredh $ "12"
      read; ESC_BCR
      IF cBrza == "D"
         qqKonto := PadR( qqKonto, 3 )
         @ m_x + 6, m_y + 2 SAY "Konto: " GET qqKonto
      ELSE
         qqKonto := PadR( qqKonto, 60 )
         @ m_x + 6, m_y + 2 SAY "Konto: " GET qqKonto PICTURE "@S50"
      ENDIF
      @ m_x + 8, m_y + 2 SAY "Datum od:" GET dDatOd
      @ m_x + 8, Col() + 2 SAY "do:" GET dDatDo
      cIdRJ := ""
      IF gRJ == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 9, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
      read; ESC_BCR

      IF cBrza == "N"
         aUsl1 := Parsiraj( qqKonto, "IdKonto", "C" )
         IF aUsl1 <> NIL; exit; ENDIF
      ELSE
         EXIT
      ENDIF

   ENDDO

   IF Params2()
      WPar( "c1", @cIdFirma );WPar( "c2", @qqKonto );WPar( "d1", @dDatOD ); WPar( "d2", @dDatDo )
      WPAr( "c3", @cBrza )
      WPar( "c4", cPredh )
   ENDIF
   SELECT params; USE

   BoxC()

   IF cIdRj == "999999"; cidrj := ""; ENDIF
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cidrj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   MsgO( "Preuzimanje podataka sa SQL servera ..." )

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      otvori_sint_anal_kroz_temp( .T., "IDRJ='" + cIdRJ + "'" )
   ELSE
      IF cBrza == "D"
         find_sint_by_konto_za_period( cIdFirma, qqKonto, dDatOd, dDatDo )
      ELSE

         find_sint_by_konto_za_period( cIdFirma, NIL, dDatOd, dDatDo )
      ENDIF
   ENDIF
   O_KONTO

   SELECT SINT

   cFilt1 := ".t." + IF( cBrza == "D", "", ".and." + aUsl1 ) + ;
      IF( Empty( dDatOd ) .OR. cPredh == "2", "", ".and.DATNAL>=" + dbf_quote( dDatOd ) ) + ;
      IF( Empty( dDatDo ), "", ".and.DATNAL<=" + dbf_quote( dDatDo ) )

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   GO TOP
   MsgC()

   EOF RET

   nStr := 0

   start_print()

   IF nStr == 0; SinkZagl();ENDIF
   nSviD := nSviP := nSviD2 := nSviP2 := 0
   DO WHILE !Eof() .AND. idfirma == cIdFirma

      IF cBrza == "D"
         IF qqKonto <> IdKonto; exit; ENDIF
      ENDIF

      cIdkonto := IdKonto
      nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0

      IF PRow() > 55 + dodatni_redovi_po_stranici(); FF; SinKZagl(); ENDIF

      ? m
      SELECT KONTO; HSEEK cIdKonto
      ? "KONTO   ", cIdKonto, AllTrim( konto->naz )

      SELECT SINT
      ? m
      nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
      fPProm := .T.
      DO WHILE !Eof() .AND. idfirma == cIdFirma .AND. cIdKonto == IdKonto

         // ********* prethodni promet *********************************
         IF cPredh == "2"
            IF dDatOd > datnal .AND. fPProm == .T.
               nDugBHD += DugBHD; nPotBHD += PotBHD
               nDugDEM += DugDEM; nPotDEM += PotDEM
               skip; LOOP
            ELSE
               IF fPProm
                  ? "Prethodno stanje"
                  @ PRow(), 31             SAY nDugBHD     PICTURE PicBHD
                  @ PRow(), PCol() + 2  SAY nPotBHD     PICTURE PicBHD
                  @ PRow(), PCol() + 2  SAY nDugBHD - nPotBHD PICTURE PicBHD
                  IF fin_dvovalutno()
                     @ PRow(), PCol() + 2  SAY nDugDEM     PICTURE PicDEM
                     @ PRow(), PCol() + 2  SAY nPotDEM     PICTURE PicDEM
                     @ PRow(), PCol() + 2  SAY nDugDEM - nPotDEM PICTURE PicDEM
                  ENDIF
               ENDIF
               fPProm := .F.
            ENDIF
         ENDIF

         IF PRow() > 60 + dodatni_redovi_po_stranici()
            FF
            SinKZagl()
         ENDIF

         ? IdVN
         @ PRow(), 8 SAY BrNal
         @ PRow(), 17 SAY RBr
         @ PRow(), 22 SAY DatNal
         @ PRow(), 31 SAY DugBHD PICTURE PicBHD
         @ PRow(), PCol() + 2 SAY PotBHD PICTURE picBHD
         nDugBHD += DugBHD; nPotBHD += PotBHD
         nDugDEM += DugDEM; nPotDEM += PotDEM
         @ PRow(), PCol() + 2 SAY nDugBHD - nPotBHD PICTURE PicBHD
         IF fin_dvovalutno()
            @ PRow(), PCol() + 2 SAY DugDEM PICTURE PicDEM
            @ PRow(), PCol() + 2 SAY PotDEM PICTURE picDEM
            @ PRow(), PCol() + 2 SAY nDugDEM - nPotDEM PICTURE PicDEM
         ENDIF
         SKIP

      ENDDO

      IF PRow() > 60 + dodatni_redovi_po_stranici()
         FF
         SinKZagl()
      ENDIF

      ? m
      ? "UKUPNO ZA:" + cIdKonto
      @ PRow(), 31             SAY nDugBHD     PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nPotBHD     PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nDugBHD - nPotBHD PICTURE PicBHD
      IF fin_dvovalutno()
         @ PRow(), PCol() + 2  SAY nDugDEM     PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nPotDEM     PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nDugDEM - nPotDEM PICTURE PicDEM
      ENDIF

      ? M
      nSviD += nDugBHD; nSviP += nPotBHD
      nSviD2 += nDugDEM; nSviP2 += nPotDEM

      check_nova_strana( {|| SinKZagl() } )


   ENDDO

   IF cBrza == "N"
      IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; SinKZagl(); ENDIF
      ? M
      ? "UKUPNO ZA SVA KONTA:"
      @ PRow(), 31             SAY nSviD           PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nSviP           PICTURE PicBHD
      @ PRow(), PCol() + 2  SAY nSviD - nSviP     PICTURE PicBHD
      IF fin_dvovalutno()
         @ PRow(), PCol() + 2  SAY nSviD2          PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nSviP2          PICTURE PicDEM
         @ PRow(), PCol() + 2  SAY nSviD2 - nSviP2   PICTURE PicDEM
      ENDIF
      ? M
   ENDIF

   FF
   end_print()

   closeret

   RETURN .T.



/* SinKZagl()
 *  Zaglavlje sinteticke kartice
 */

FUNCTION SinKZagl()

   ?
   P_COND
   ??U "FIN.P: SINTETIČKA KARTICA  NA DAN: "; ?? Date()
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "   ZA PERIOD OD", dDatOd, "DO", dDatDo
   ENDIF
   @ PRow(), 125 SAY "Str." + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN
      HSEEK cIdFirma
      ? "Firma:", cidfirma, AllTrim( partn->naz ), AllTrim( partn->naz2 )
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT SINT
   IF fin_jednovalutno()
      F12CPI
   ENDIF
   ?  m
   IF fin_dvovalutno()
      ?  "*VRSTA * BROJ   *REDN* DATUM  *           I  Z  N  O  S     U     " + ValDomaca() + "             *      I  Z  N  O  S     U     " + ValPomocna() + "      *"
      ?  "                               ---------------------------------------------------- -----------------------------------------"
      ?U  "*NALOGA*NALOGA  *BROJ*        *    DUGUJE      *     POTRAŽUJE   *      SALDO      *   DUGUJE    *  POTRAZUJE  *    SALDO   *"
   ELSE
      ?  "*VRSTA * BROJ   *REDN* DATUM  *           I  Z  N  O  S     U     " + ValDomaca() + "             *"
      ?  "                               -----------------------------------------------------"
      ?U  "*NALOGA*NALOGA  *BROJ*        *    DUGUJE      *     POTRAŽUJE   *      SALDO      *"
   ENDIF
   ?  m

   RETURN .T.
