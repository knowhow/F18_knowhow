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


FUNCTION StKalk95_PDV()

   LOCAL cKto1
   LOCAL cKto2
   LOCAL cIdZaduz2
   LOCAL cPom
   LOCAL nCol1 := 0
   LOCAL nCol2 := 0
   LOCAL nPom := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   P_COND2

   ?? "KALK: KALKULACIJA BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), P_TipDok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok

   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   ?
   IF cidvd == "16"  // doprema robe
      ? "PRIJEM U MAGACIN (INTERNI DOKUMENT)"
   ELSEIF cidvd == "96"
      ? "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
   ELSEIF cidvd == "97"
      ? "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
   ELSEIF cidvd == "95"
      ? "OTPIS MAGACIN"
   ENDIF
   ?

   SELECT kalk_pripr

   IF cIdVd $ "95#96#97"
      cPom := "Razduzuje:"
      cKto1 := cIdKonto2
      cKto2 := cIdKonto
   ELSE
      cPom := "Zaduzuje:"
      cKto1 := cIdKonto
      cKto2 := cIdKonto2
   ENDIF

   SELECT konto
   HSEEK cKto1


   ?
   ? PadL( cPom, 14 ), cKto1 + "- " + PadR( konto->naz, 20 )

   IF !Empty( cKto2 )

      IF cIdVd $ "95#96#97"
         cPom := "Zaduzuje:"
      ELSE
         cPom := "Razduzuje:"
      ENDIF

      SELECT konto
      HSEEK cKto2
      ? PadL( cPom, 14 ), cKto2 + "- " + PadR( konto->naz, 20 )
   ENDIF
   ?

   SELECT kalk_pripr

   m := "--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
   ? m
   ? "*R * ROBA     * KOLICINA *   NC     *  MARZA   * PROD.CIJ.*   PDV%   * PROD.CIJ.*"
   ? "*BR* TARIFA   *          *          *          * BEZ.PDV  *   PDV    * SA PDV   *"
   ? "*  * KONTO    *   sum    *   sum    *   sum    *   sum    *   sum    *    sum   *"
   ? m

   nTot := 0
   nTot1 := 0
   nTot2 := 0
   nTot3 := 0
   nTot4 := 0
   nTot5 := 0
   nTot6 := 0
   nTot7 := 0
   nTot8 := 0
   nTot9 := 0
   nTotA := 0
   nTotB := nTotP := nTotM := 0

   SELECT kalk_pripr

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD
      vise_kalk_dok_u_pripremi( cIdd )
      RptSeekRT()
      KTroskovi()
      print_nova_strana( 125, @nStr, 2 )
      IF gKalo == "1"
         SKol := Kolicina - GKolicina - GKolicin2
      ELSE
         SKol := Kolicina
      ENDIF

      nPDVStopa := tarifa->opp
      nPDV := MPCsaPP * ( tarifa->opp / 100 )

      nTot1 += ( nU1 := Round( NC * ( GKolicina + GKolicin2 ), gZaokr ) )
      nTot8 += ( nU8 := Round( NC *    ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
      nTot9 += ( nU9 := Round( nMarza * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
      nTotA += ( nUA := Round( VPC   * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )

      // total porez
      nTotP += ( nUP := nPDV * kolicina )

      // total mpcsapp
      nTotM += ( nUM := MPCsaPP * kolicina )

      // 1. PRVI RED
      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), 4 SAY  ""
      ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"

      @ PRow() + 1, 4 SAY IdRoba
      nCol1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY Kolicina             PICTURE PicKol
      @ PRow(), PCol() + 1 SAY NC                    PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nMarza / NC * 100         PICTURE PicProc
      @ PRow(), PCol() + 1 SAY VPC                   PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nPDVStopa         PICTURE PicProc
      @ PRow(), PCol() + 1 SAY MPCsaPP           PICTURE PicCDEM

      // 2. DRUGI RED
      @ PRow() + 1, 4 SAY IdTarifa
      @ PRow(), PCol() + 27 SAY nMarza               PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY 0       PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nPDV       PICTURE PicCDEM

      // 3. TRECI RED
      @ PRow() + 1, 4 SAY idkonto
      @ PRow() + 1, nCol1   SAY nU1         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU8         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU9         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nUA         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nUP         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nUM         PICTURE         PICDEM

      SKIP
   ENDDO

   print_nova_strana( 125, @nStr, 5 )
   ? m

   @ PRow() + 1, 0 SAY "Ukupno:"
   @ PRow(), nCol1     SAY nTot1         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot8         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot9         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTotA         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTotP         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTotM         PICTURE         PICDEM

   ? m
   IF cIdVD == "16"
      ?U "Magacin se zadužuje po nabavnoj vrijednosti " + AllTrim( Transform( nTot8, picdem ) )
   ELSE
      ?U "Magacin se razdužuje po nabavnoj vrijednosti " + AllTrim( Transform( nTot8, picdem ) )
   ENDIF
   ? m

   RETURN .T.
