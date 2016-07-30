/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


FUNCTION StKalk41()

   LOCAL nCol0 := nCol1 := nCol2 := 0
   LOCAL nPom := 0

   IF IsPDV()
      StKalk41PDV()
      RETURN
   ENDIF

   PRIVATE nMarza, nMarza2, nPRUC, aPorezi
   nMarza := nMarza2 := nPRUC := 0
   aPorezi := {}


   nStr := 0
   cIdPartner := IdPartner; cBrFaktP := BrFaktP; dDatFaktP := DatFaktP

   cIdKonto := IdKonto; cIdKonto2 := IdKonto2

   P_10CPI
   Naslov4x()

   SELECT kalk_pripr

   m := "--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
   IF cidvd <> '47'
      m += " ---------- ---------- ---------- ----------"
      IF lPrikPRUC
         m += " ----------"
      ENDIF
   ENDIF

   ? m

   IF cIdVd = '47'
      ? "*R * ROBA     * Kolicina *    MPC   *   PPP %  *   PPU%   *   PP%    *  MPC     *"
      ? "*BR*          *          *          *   PPU    *   PPU    *   PP     *  SA Por  *"
      ? "*  *          *          *    sum   *    sum   *   sum    *          *   sum    *"
   ELSE
      IF lPrikPRUC
         ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  * POREZ NA *    MPC   *   PPP %  *   PPU%   *   PP%    *MPC sa por*          *  MPC     *"
         ? "*BR*          *          *   U MP   *         *  MARZU   *          *   PPP    *   PPU    *   PP     * -Popust  *  Popust  *  SA Por  *"
         ? "*  *          *          *   sum    *         *    sum   *    sum   *    sum   *   sum    *          *   sum    *   sum    *   sum    *"
      ELSE
         ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  *    MPC   *   PPP %  *   PPU%   *   PP%    *MPC sa por*          *  MPC     *"
         ? "*BR*          *          *   U MP   *         *          *   PPP    *   PPU    *   PP     * -Popust  *  Popust  *  SA Por  *"
         ? "*  *          *          *   sum    *         *    sum   *    sum   *   sum    *          *   sum    *   sum    *   sum    *"
      ENDIF
   ENDIF

   ? m

   nTot1 := nTot1b := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := 0
   nTot4a := 0


   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2


   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD


      // formiraj varijable _....
      Scatter()
      RptSeekRT()

      // izracunaj nMarza2
      Marza2R()
      KTroskovi()

      Tarifa( pkonto, idRoba, @aPorezi )
      aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcSaPP, field->nc )
      nPor1 := aIPor[ 1 ]
      nPor2 := aIPor[ 2 ]
      nPor3 := aIPor[ 3 ]
      nPRUC := nPor2
      // nMarza2:=nMarza2-nPRUC // ?!

      VTPorezi()

      print_nova_strana( 125, @nStr, 2 )

      nTot3 +=  ( nU3 := IF( ROBA->tip = "U", 0, NC ) * kolicina )
      nTot4 +=  ( nU4 := nMarza2 * Kolicina )
      nTot4a +=  ( nU4a := nPRUC * Kolicina )
      nTot5 +=  ( nU5 := MPC * Kolicina )

      nTot6 +=  ( nU6 := ( nPor1 + nPor2 + nPor3 ) * Kolicina )
      nTot7 +=  ( nU7 := MPcSaPP * Kolicina )

      nTot8 +=  ( nU8 := ( MPcSaPP - RabatV ) * Kolicina )
      nTot9 +=  ( nU9 := RabatV * Kolicina )

      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), 4 SAY  ""
      ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"
      @ PRow() + 1, 4 SAY IdRoba
      @ PRow(), PCol() + 1 SAY Kolicina PICTURE PicKol

      nCol0 := PCol()

      @ PRow(), nCol0 SAY ""
      IF IDVD <> '47'
         IF ROBA->tip = "U"
            @ PRow(), PCol() + 1 SAY 0                   PICTURE PicCDEM
         ELSE
            @ PRow(), PCol() + 1 SAY NC                   PICTURE PicCDEM
         ENDIF
         @ PRow(), PCol() + 1 SAY nMarza2              PICTURE PicCDEM
         IF lPrikPRUC
            @ PRow(), PCol() + 1 SAY nPRUC             PICTURE PicCDEM
         ENDIF
      ENDIF
      @ PRow(), PCol() + 1 SAY MPC                  PICTURE PicCDEM
      nCol1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY aPorezi[ POR_PPP ]      PICTURE PicProc
      @ PRow(), PCol() + 1 SAY PrPPUMP()             PICTURE PicProc
      @ PRow(), PCol() + 1 SAY aPorezi[ POR_PP ]     PICTURE PicProc
      IF IDVD <> "47"
         @ PRow(), PCol() + 1 SAY MPCSAPP - RabatV       PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY RabatV               PICTURE PicCDEM
      ENDIF
      @ PRow(), PCol() + 1 SAY MPCSAPP              PICTURE PicCDEM

      @ PRow() + 1, 4 SAY idTarifa
      @ PRow(), nCol0 SAY ""
      IF cIDVD <> '47'
         IF ROBA->tip = "U"
            @ PRow(), PCol() + 1  SAY  0                PICTURE picdem
         ELSE
            @ PRow(), PCol() + 1  SAY  nc * kolicina      PICTURE picdem
         ENDIF
         @ PRow(), PCol() + 1  SAY  nmarza2 * kolicina      PICTURE picdem
         IF lPrikPRUC
            @ PRow(), PCol() + 1 SAY nPRUC * kolicina       PICTURE PicDEM
         ENDIF
      ENDIF
      @ PRow(), PCol() + 1 SAY  mpc * kolicina      PICTURE picdem

      @ PRow(), nCol1    SAY  nPor1 * kolicina    PICTURE piccdem
      @ PRow(), PCol() + 1 SAY  nPor2 * kolicina    PICTURE piccdem
      @ PRow(), PCol() + 1 SAY  nPor3 * kolicina   PICTURE PiccDEM
      IF IDVD <> "47"
         @ PRow(), PCol() + 1 SAY  ( mpcsapp - RabatV ) * kolicina   PICTURE picdem
         @ PRow(), PCol() + 1 SAY  RabatV * kolicina   PICTURE picdem
      ENDIF
      @ PRow(), PCol() + 1 SAY  mpcsapp * kolicina   PICTURE picdem

      SKIP 1

   ENDDO


   print_nova_strana( 125, @nStr, 3 )
   ? m
   @ PRow() + 1, 0        SAY "Ukupno:"

   @ PRow(), nCol0  SAY  ""
   IF cIDVD <> '47'
      @ PRow(), PCol() + 1      SAY  nTot3        PICTURE       PicDEM
      @ PRow(), PCol() + 1   SAY  nTot4        PICTURE       PicDEM
      IF lPrikPRUC
         @ PRow(), PCol() + 1   SAY  nTot4a        PICTURE       PicDEM
      ENDIF
   ENDIF
   @ PRow(), PCol() + 1   SAY  nTot5        PICTURE       PicDEM
   @ PRow(), PCol() + 1   SAY  Space( Len( picproc ) )
   @ PRow(), PCol() + 1   SAY  Space( Len( picproc ) )
   @ PRow(), PCol() + 1   SAY  nTot6        PICTURE        PicDEM
   IF cIDVD <> "47"
      @ PRow(), PCol() + 1   SAY  nTot8        PICTURE        PicDEM
      @ PRow(), PCol() + 1   SAY  nTot9        PICTURE        PicDEM
   ENDIF
   @ PRow(), PCol() + 1   SAY  nTot7        PICTURE        PicDEM
   ? m

   // Rekapitulacija tarifa

   print_nova_strana( 125, @nStr, 10 )
   nRec := RecNo()

   RekTar41( cIdFirma, cIdVd, cBrDok, @nStr )

   SET ORDER TO TAG "1"
   GO nRec

   RETURN
// }


/*
 * Rekapitulacija tarifa - nova fja
 */
FUNCTION RekTar41( cIdFirma, cIdVd, cBrDok, nStr )

   // {
   LOCAL nTot1
   LOCAL nTot2
   LOCAL nTot3
   LOCAL nTot4
   LOCAL nTot5
   LOCAL nTotP
   LOCAL aPorezi

   SELECT kalk_pripr
   SET ORDER TO TAG "2"
   SEEK cIdfirma + cIdvd + cBrdok

   m := "------ ---------- ---------- ----------  ---------- ---------- ---------- ---------- ---------- ----------"
   ? m
   ? "* Tar *  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *   PP     *  Popust * MPVSAPP *"
   ? m
   nTot1 := 0
   nTot2 := 0
   nTot3 := 0
   nTot4 := 0
   nTot5 := 0
   nTot6 := 0
   nTot7 := 0
   nTot8 := 0
   // popust
   nTotP := 0

   aPorezi := {}
   DO WHILE !Eof() .AND. cIdfirma + cIdvd + cBrDok == idfirma + idvd + brdok
      cIdTarifa := idtarifa
      nU1 := 0
      nU2 := 0
      nU2b := 0
      nU3 := 0
      nU4 := 0
      nU5 := 0
      nUp := 0
      SELECT tarifa
      HSEEK cIdtarifa

      Tarifa( kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi )

      SELECT kalk_pripr
      fVTV := .F.
      DO WHILE !Eof() .AND. cIdfirma + cIdVd + cBrDok == idFirma + idVd + brDok .AND. idTarifa == cIdTarifa

         SELECT roba
         HSEEK kalk_pripr->idroba
         SELECT kalk_pripr
         VtPorezi()

         Tarifa( kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi )

         // mpc bez poreza
         nU1 += kalk_pripr->mpc * kolicina

         aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcSaPP, field->nc )

         // porez na promet
         nU2 += aIPor[ 1 ] * kolicina
         nU3 += aIPor[ 2 ] * kolicina
         nU4 += aIPor[ 3 ] * kolicina

         nU5 += kalk_pripr->MpcSaPP * kolicina
         nUP += rabatv * kolicina

         nTot6 += ( kalk_pripr->mpc - kalk_pripr->nc ) * kolicina

         SKIP
      ENDDO

      nTot1 += nU1
      nTot2 += nU2
      nTot3 += nU3
      nTot4 += nU4
      nTot5 += nU5
      nTotP += nUP

      ? cIdtarifa

      @ PRow(), PCol() + 1   SAY aPorezi[ POR_PPP ] PICT picproc
      @ PRow(), PCol() + 1   SAY PrPPUMP() PICT picproc
      @ PRow(), PCol() + 1   SAY aPorezi[ POR_PP ] PICT picproc

      nCol1 := PCol()
      @ PRow(), nCol1 + 1   SAY nU1 PICT picdem
      @ PRow(), PCol() + 1   SAY nU2 PICT picdem
      @ PRow(), PCol() + 1   SAY nU3 PICT picdem
      @ PRow(), PCol() + 1   SAY nU4 PICT picdem
      @ PRow(), PCol() + 1   SAY nUp PICT picdem
      @ PRow(), PCol() + 1   SAY nU5 PICT picdem
   ENDDO

   print_nova_strana( 125, @nStr, 4 )
   ? m
   ? "UKUPNO"
   @ PRow(), nCol1 + 1    SAY nTot1 PICT picdem
   @ PRow(), PCol() + 1   SAY nTot2 PICT picdem
   @ PRow(), PCol() + 1   SAY nTot3 PICT picdem
   @ PRow(), PCol() + 1   SAY nTot4 PICT picdem
   // popust
   @ PRow(), PCol() + 1   SAY nTotP PICT picdem
   @ PRow(), PCol() + 1   SAY nTot5 PICT picdem
   ? m
   IF cIdVd <> "47"
      ? "RUC:"
      @ PRow(), PCol() + 1 SAY nTot6 PICT picdem
      ? m
   ENDIF

   RETURN .T.





FUNCTION Naslov4x()

   LOCAL cSvediDatFakt

   B_ON

   IF CIDVD == "41"
      ?? "IZLAZ IZ PRODAVNICE - KUPAC"
   ELSEIF CIDVD == "49"
      ?? "IZLAZ IZ PRODAVNICE PO OSTALIM OSNOVAMA"
   ELSEIF cIdVd == "43"
      ?? "IZLAZ IZ PRODAVNICE - KOMISIONA - PARAGON BLOK"
   ELSEIF cIdVd == "47"
      ?? "PREGLED PRODAJE"
   ELSE
      ?? "IZLAZ IZ PRODAVNICE - PARAGON BLOK"
   ENDIF

   B_OFF

   P_COND

   ?

   ?? "KALK BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), P_TipDok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   SELECT PARTN
   HSEEK cIdPartner

   IF cIdVd == "41"
      ?  "KUPAC:", cIdPartner, "-", PadR( naz, 20 ), Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP
   ELSEIF cidvd == "43"
      ?  "DOBAVLJAC KOMIS.ROBE:", cIdPartner, "-", PadR( naz, 20 )
   ENDIF

   SELECT KONTO
   HSEEK cIdKonto
   ?  "Prodavnicki konto razduzuje:", cIdKonto, "-", PadR( naz, 60 )

   RETURN NIL
