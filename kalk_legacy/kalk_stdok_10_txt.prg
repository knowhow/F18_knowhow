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

MEMVAR m
MEMVAR PicDEM, PicKOL, PicPROC

FUNCTION kalk_stampa_dok_10_txt()

   LOCAL nCol1 := 0
   LOCAL nCol2 := 0
   LOCAL nPom := 0
   LOCAL nTot, nTot1, nTot2, nTot3, nTot4, nTot5, nTot6, nTot7, nTot8, nTot9, nTotA, nTotB, nTotP, nTotM

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

   nStr := 0
   cIdPartner := field->IdPartner
   cBrFaktP := field->BrFaktP
   dDatFaktP := field->DatFaktP
   cIdKonto := field->IdKonto
   cIdKonto2 := field->IdKonto2

   P_COND2

   ?? "KALKULACIJA BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), P_TipDok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok

   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   SELECT PARTN
   HSEEK cIdPartner

   ?U  "DOBAVLJAČ:", cIdPartner, "-", PadR( field->naz, 25 ), Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP

   SELECT kalk_pripr

   SELECT KONTO
   HSEEK cIdKonto

   ?U  "MAGACINSKI KONTO zadužuje :", cIdKonto, "-", field->naz

   m := "--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

   IF ( gMpcPomoc == "D" )
      m += " ---------- ----------"
   ENDIF

   ? m

   IF gMpcPomoc == "D"
      // prikazi mpc
      ? "*R * ROBA     *  FCJ     * NOR.KALO * KASA-    * " + c10T1 + " * " + c10T2 + " * " + c10T3 + " * " + c10T4 + " * " + c10T5 + " *   NC     *  MARZA   * PROD.CIJ.*   PDV%   * PROD.CIJ.*"
      ? "*BR* TARIFA   *  KOLICINA* PRE.KALO * SKONTO   *          *          *          *          *          *          *          * BEZ.PDV  *   PDV    * SA PDV   *"

      ? "*  *          *   sum    *   sum    *  sum     *   sum    *   sum    *    sum   *   sum    *   sum    *   sum    *   sum    *   sum    *   sum    *    sum   *"
   ELSE
      // prikazi samo do neto cijene - bez pdv-a
      ? "*R * ROBA     *  FCJ     * NOR.KALO * KASA-    * " + c10T1 + " * " + c10T2 + " * " + c10T3 + " * " + c10T4 + " * " + c10T5 + " *   NC     *  MARZA   * PROD.CIJ.*"
      ? "*BR* TARIFA   *  KOLICINA* PRE.KALO * SKONTO   *          *          *          *          *          *          *          * BEZ.PDV  *"

      ? "*  *          *   sum    *   sum    *  sum     *   sum    *   sum    *    sum   *   sum    *   sum    *   sum    *   sum    *   sum    *"

   ENDIF

   ? m

   nTot := nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTotA := 0
   nTotB := nTotP := nTotM := 0

   SELECT kalk_pripr

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD
      vise_kalk_dok_u_pripremi( cIdd )
      kalk_pozicioniraj_roba_tarifa_by_kalk_fields()
      kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()
      print_nova_strana( 125, @nStr, 2 )
      IF gKalo == "1"
         SKol := field->Kolicina - field->GKolicina - field->GKolicin2
      ELSE
         SKol := field->Kolicina
      ENDIF

      nPDVStopa := tarifa->opp
      nPDV := MPCsaPP / ( 1 + ( tarifa->opp / 100 ) ) * ( tarifa->opp / 100 )

      nTot +=  ( nU := Round( FCj * Kolicina, gZaokr ) )
      nTot1 += ( nU1 := Round( FCj2 * ( GKolicina + GKolicin2 ), gZaokr ) )

      nTot2 += ( nU2 := Round( -Rabat / 100 * FCJ * Kolicina, gZaokr ) )
      nTot3 += ( nU3 := Round( nPrevoz * SKol, gZaokr ) )
      nTot4 += ( nU4 := Round( nBankTr * SKol, gZaokr ) )
      nTot5 += ( nU5 := Round( nSpedTr * SKol, gZaokr ) )
      nTot6 += ( nU6 := Round( nCarDaz * SKol, gZaokr ) )
      nTot7 += ( nU7 := Round( nZavTr * SKol, gZaokr ) )
      nTot8 += ( nU8 := Round( NC *    ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
      nTot9 += ( nU9 := Round( nMarza * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
      nTotA += ( nUA := Round( VPC   * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )

      IF gVarVP == "1"
         nTotB += Round( nU9 * tarifa->vpp / 100, gZaokr ) // porez na razliku u cijeni
      ELSE
         PRIVATE cistaMar := Round( nU9 / ( 1 + tarifa->vpp / 100 ), gZaokr )
         nTotB += Round( cistaMar * tarifa->vpp / 100, gZaokr )  // porez na razliku u cijeni
      ENDIF
      // total porez
      nTotP += ( nUP := nPDV * kolicina )
      // total mpcsapp
      nTotM += ( nUM := MPCsaPP * kolicina )

      // 1. PRVI RED
      @ PRow() + 1, 0 SAY rbr PICTURE "999"
      @ PRow(), 4 SAY ""

      ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"

/*
      IF roba->( FieldPos( "KATBR" ) ) <> 0
  --       ?? " KATBR:", roba->katbr
      ENDIF
*/

      IF roba_barkod_pri_unosu() .AND. !Empty( roba->barkod )
         ?? ", BK: " + roba->barkod
      ENDIF

      @ PRow() + 1, 4 SAY IdRoba
      nCol1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY FCJ                   PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY GKolicina             PICTURE PicKol
      @ PRow(), PCol() + 1 SAY -Rabat                PICTURE PicProc
      @ PRow(), PCol() + 1 SAY nPrevoz / FCJ2 * 100      PICTURE PicProc
      @ PRow(), PCol() + 1 SAY nBankTr / FCJ2 * 100      PICTURE PicProc
      @ PRow(), PCol() + 1 SAY nSpedTr / FCJ2 * 100      PICTURE PicProc
      @ PRow(), PCol() + 1 SAY nCarDaz / FCJ2 * 100      PICTURE PicProc
      @ PRow(), PCol() + 1 SAY nZavTr / FCJ2 * 100       PICTURE PicProc
      @ PRow(), PCol() + 1 SAY NC                    PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nMarza / NC * 100         PICTURE PicProc
      @ PRow(), PCol() + 1 SAY VPC                   PICTURE PicCDEM

      IF gMpcPomoc == "D"
         @ PRow(), PCol() + 1 SAY nPDVStopa         PICTURE PicProc
         @ PRow(), PCol() + 1 SAY MPCsaPP           PICTURE PicCDEM
      ENDIF

      // 2. DRUGI RED
      @ PRow() + 1, 4 SAY IdTarifa
      @ PRow(), nCol1    SAY Kolicina             PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY GKolicin2            PICTURE PicKol
      @ PRow(), PCol() + 1 SAY -Rabat / 100 * FCJ       PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nPrevoz              PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nBankTr              PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nSpedTr              PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nCarDaz              PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nZavTr               PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY 0                    PICTURE PicDEM
      @ PRow(), PCol() + 1 SAY nMarza               PICTURE PicCDEM
      IF gMpcPomoc == "D"
         @ PRow(), PCol() + 1 SAY 0          PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nPDV           PICTURE PicCDEM
      ENDIF

      // 3. TRECI RED
      @ PRow() + 1, nCol1   SAY nU          PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU1         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU2         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU3         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU4         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU5         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU6         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU7         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU8         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU9         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nUA         PICTURE         PICDEM
      IF gMpcPomoc == "D"
         @ PRow(), PCol() + 1  SAY nUP         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nUM         PICTURE         PICDEM
      ENDIF

      SKIP
   ENDDO

   print_nova_strana( 125, @nStr, 5 )
   ? m

   @ PRow() + 1, 0 SAY "Ukupno:"
   @ PRow(), nCol1     SAY nTot          PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot1         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot2         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot3         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot4         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot5         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot6         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot7         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot8         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot9         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTotA         PICTURE         PICDEM

   IF ( gMpcPomoc == "D" )
      @ PRow(), PCol() + 1  SAY nTotP         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTotM         PICTURE         PICDEM
   ENDIF

   ? m
   ?U "Magacin se zadužuje po nabavnoj vrijednosti " + AllTrim( Transform( nTot8, picdem ) )

   ? m

   RETURN .T.
