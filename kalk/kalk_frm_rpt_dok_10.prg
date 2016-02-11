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

FUNCTION StKalk10_2()

   LOCAL nCol1 := nCol2 := 0, npom := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

   // iznosi troskova i marzi koji se izracunavaju u KTroskovi()

   nStr := 0
   cIdPartner := IdPartner; cBrFaktP := BrFaktP; dDatFaktP := DatFaktP

   cIdKonto := IdKonto; cIdKonto2 := IdKonto2

   P_COND2
   ?? "KALK: KALKULACIJA BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), browse_tdok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   SELECT PARTN; HSEEK cIdPartner

   ?  "DOBAVLJAC:", cIdPartner, "-", naz, Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP

   SELECT KONTO; HSEEK cIdKonto
   ?  "MAGACINSKI KONTO zaduzuje :", cIdKonto, "-", naz

   m := "--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

   ? m
   ? "*R * ROBA     *  FCJ     * NOR.KALO * KASA-    * " + c10T1 + " * " + c10T2 + " * " + c10T3 + " * " + c10T4 + " * " + c10T5 + " *   NC     *" + iif( gVarVP == "1", " MARZA.   ", " RUC+PRUC " ) + "*  VPC    *"
   ? "*BR* TARIFA   *  KOLICINA* PRE.KALO * SKONTO   *          *          *          *          *          *          *          *         *"
   ? "*  *          *   sum    *   sum    *  sum     *   sum    *   sum    *    sum   *   sum    *   sum    *   sum    *   sum    *  sum    *"

   ? m
   nTot := nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTotA := 0
   nTotB := nTotP := nTotM := 0

   SELECT kalk_pripr

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

      vise_kalk_dok_u_pripremi( cIdd )
      RptSeekRT()
      KTroskovi()

      DokNovaStrana( 125, @nStr, 2 )

      IF gKalo == "1"
         SKol := Kolicina - GKolicina - GKolicin2
      ELSE
         SKol := Kolicina
      ENDIF

      nTot +=  ( nU := Round( FCj * Kolicina, gZaokr ) )
      IF gKalo == "1"
         nTot1 += ( nU1 := Round( FCj2 * ( GKolicina + GKolicin2 ), gZaokr ) )
      ELSE
         // stanex
         nTot1 += ( nU1 := Round( NC * ( GKolicina + GKolicin2 ), gZaokr ) )
      ENDIF
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
         nTotB += Round( nU9 * tarifa->vpp / 100,gZaokr ) // porez na razliku u cijeni
      ELSE
         PRIVATE cistaMar := Round( nU9 / ( 1 + tarifa->vpp / 100 ),gZaokr )
         nTotB += Round( cistaMar * tarifa->vpp / 100, gZaokr )  // porez na razliku u cijeni
      ENDIF
      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), 4 SAY  ""; ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"
      IF roba->( FieldPos( "KATBR" ) ) <> 0
         ?? " KATBR:", roba->katbr
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

      SKIP
   ENDDO

   DokNovaStrana( 125, @nStr, 5 )
   ? m

   @ PRow() + 1, 0        SAY "Ukupno:"
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

   IF g10Porez == "D" .OR. gVarVP == "2"
      ? m
      IF gVarVP == "1"
         ? "Ukalkulisani porez na ruc (PRUC):"
         @ PRow(), PCol() + 1 SAY nTotB PICT picdem
         @ PRow(), PCol() + 15 SAY "RUC - PRUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTot9, picdem ) )
         @ PRow(), PCol() + 1 SAY "-"
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTotB, picdem ) )
         @ PRow(), PCol() + 1 SAY "="
         @ PRow(), PCol() + 1 SAY nTot9 - nTotB PICT picdem
      ELSE
         ? "RUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTot9 - nTotB, picdem ) ); ?? ","
         @ PRow(), PCol() + 15 SAY "PRUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTotB, picdem ) ); ?? ","
         @ PRow(), PCol() + 15 SAY "RUC + PRUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTot9, picdem ) )
      ENDIF
   ENDIF
   ? m

   RETURN
// }



/*! \fn StKalk10_3()
 *  \brief Stampa kalkulacije 10 - magacin po vp, DEFAULT VARIJANTA
 */

FUNCTION StKalk10_3( lBezNC )

   // {
   LOCAL nCol1 := nCol2 := 0, npom := 0

   IF lBezNC == NIL
      lBezNC := .F.
   ENDIF

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
   // iznosi troskova i marzi koji se izracunavaju u KTroskovi()


   nStr := 0
   cIdPartner := IdPartner; cBrFaktP := BrFaktP; dDatFaktP := DatFaktP

   cIdKonto := IdKonto; cIdKonto2 := IdKonto2

   P_10CPI
   IF cidvd == "10" .OR. cidvd == "70"
      ?? "ULAZ U MAGACIN - OD DOBAVLJACA"
   ENDIF
   P_COND
   ? "KALK: KALKULACIJA BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, " ,Datum:", DatDok
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   SELECT PARTN; HSEEK cIdPartner
   ?
   ?  "DOBAVLJAC:", cIdPartner, "-", naz, Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP
   ?
   SELECT KONCIJ; SEEK Trim( cIdKonto ); lNC := .T.
   IF naz <> "N1"; lNc := .F. ; ENDIF
   SELECT KONTO; HSEEK cIdKonto
   ?  "MAGACINSKI KONTO zaduzuje :", cIdKonto, "-", naz


   IF !Empty( kalk_pripr->Idzaduz2 )
      ?? " Rad.nalog:", kalk_pripr->Idzaduz2
   ENDIF

   IF lBezNC

      m := "--- ---------- ----------" + iif( lNC, "", " ---------- ----------" )
      IF gmpcpomoc == "D" .OR. ( IsPDV() .AND. gPDVMagNab == "D" )
         m += " ----------"
      ENDIF
      ? m
      ?U "*R * ROBA     * KOLIČINA " + iif( lNC, "", "*   PPP    *    VPC  *" )
      IF gmpcpomoc == "D" .OR. ( IsPDV() .AND. gPDVMagNab == "D" )
         ?? "    MPC   *"
      ENDIF
      ? "*BR* TARIFA   *          " + iif( lNC, "", "*          *         *" )
      IF gmpcpomoc == "D" .OR. ( IsPDV() .AND. gPDVMagNab == "D" )
         ?? "          *"
      ENDIF

      ? "*  *          *          " + iif( lNC, "", "*          *         *" )
      IF gmpcpomoc == "D" .OR. ( IsPDV() .AND. gPDVMagNab == "D" )
         ?? "          *"
      ENDIF

   ELSE

      m := "--- ---------- ---------- ---------- ---------- ---------- ---------- ----------" + IF( lNC, "", " ---------- ---------- ----------" )
      IF gmpcpomoc == "D"
         m += " ----------"
      ENDIF
      ? m
      ? "*R * ROBA     *  FCJ     * KOLICINA * RABAT    * FCJ-RAB  * TROSKOVI *    NC    *" + IF( lNC, "", iif( gVarVP == "1", " MARZA.   ", " RUC+PRUC " ) + "*   PPP    *    VPC  *" )
      IF gmpcpomoc == "D" .OR. ( IsPDV() .AND. gPDVMagNab == "D" )
         ?? "    MPC   *"
      ENDIF
      ? "*BR* TARIFA   *          *          * DOBAVLJ. *          *          *          *" + IF( lNC, "", "          *          *         *" )
      IF gmpcpomoc == "D"  .OR. ( IsPDV() .AND. gPDVMagNab == "D" )
         ?? "          *"
      ENDIF

      ? "*  *          *  FV      *          *          * FV-RABAT *          *          *" + IF( lNC, "", "          *          *         *" )
      IF gmpcpomoc == "D"  .OR. ( IsPDV() .AND. gPDVMagNab == "D" )
         ?? "          *"
      ENDIF

   ENDIF

   ? m
   nTot := nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTotA := 0
   nTotB := 0
   nTotP := nTotQ := 0
   nTotM := 0  // maloprodajna
   SELECT kalk_pripr

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2


   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

      vise_kalk_dok_u_pripremi( cIdd )
      RptSeekRT()
      KTroskovi()

      DokNovaStrana( 125, @nStr, 2 )

      IF gKalo == "1"
         SKol := Kolicina - GKolicina - GKolicin2
      ELSE
         SKol := Kolicina
      ENDIF

      nTot +=  ( nU := Round( FCj * Kolicina, gZaokr ) )
      IF gKalo == "1"
         nTot1 += ( nU1 := Round( FCj2 * ( GKolicina + GKolicin2 ), gZaokr ) )
      ELSE
         nTot1 += ( nU1 := Round( NC * ( GKolicina + GKolicin2 ), gZaokr ) )
      ENDIF
      nTot2 += ( nU2 := Round( -Rabat / 100 * FCJ * Kolicina, gZaokr ) )

      nTot3 += ( nU3 := Round( nPrevoz * SKol, gZaokr ) )
      nTot4 += ( nU4 := Round( nBankTr * SKol, gZaokr ) )
      nTot5 += ( nU5 := Round( nSpedTr * SKol, gZaokr ) )
      nTot6 += ( nU6 := Round( nCarDaz * SKol, gZaokr ) )
      nTot7 += ( nU7 := Round( nZavTr * SKol, gZaokr ) )

      // stanex
      nTot8 += ( nU8 := nU + nU2 + nU3 + nU4 + nU5 + nU6 + nU7 )

      IF !( roba->tip $ "VKX" )
         nUP := 0
      ELSE
         IF roba->tip = "X"
            nTotP += ( nUP := Round( mpcsapp / ( 1 + tarifa->opp / 100 ) * tarifa->opp / 100 * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
         ELSE
            nTotP += ( nUP := Round( vpc / ( 1 + tarifa->opp / 100 ) * tarifa->opp / 100 * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
         ENDIF
      ENDIF


      nTotA += ( nUA := Round( VPC   * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )

      // stanex   marza
      nTot9 += ( nU9 := Round( nUA - nUp - nU8, gZaokr ) )

      IF gVarVP == "1"
         nTotB += Round( nU9 * tarifa->vpp / 100, gZaokr )  // porez na razliku u cijeni
      ELSE
         PRIVATE cistaMar := Round( nU9 / ( 1 + tarifa->vpp / 100 ),gZaokr )
         nTotB += Round( cistaMar * tarifa->vpp / 100,gZaokr ) // porez na razliku u cijeni
      ENDIF

      IF gMpcPomoc == "D"
         nTotM += ( nUM := Round ( roba->mpc * kolicina, gZaokr ) )
      ENDIF

      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), 4 SAY  ""; ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"
      IF roba->( FieldPos( "KATBR" ) ) <> 0
         ?? " KATBR:", roba->katbr
      ENDIF
      @ PRow() + 1, 4 SAY IdRoba
      nCol1 := PCol() + 1
      IF !lBezNC
         @ PRow(), PCol() + 1 SAY FCJ                   PICTURE PicCDEM
      ENDIF
      @ PRow(), PCol() + 1 SAY Kolicina              PICTURE pickol
      IF !lBezNC
         @ PRow(), PCol() + 1 SAY -Rabat                PICTURE PicProc
         @ PRow(), PCol() + 1 SAY fcj * ( 1 -Rabat / 100 )     PICT piccdem
         @ PRow(), PCol() + 1 SAY ( nprevoz + nbanktr + nspedtr + ncardaz + nZavTr ) / FCJ2 * 100       PICTURE PicProc

         @ PRow(), PCol() + 1 SAY NC                    PICTURE PicCDEM
      ENDIF

      IF !lNC
         IF !lBezNC
            @ PRow(), PCol() + 1 SAY nMarza / NC * 100         PICTURE PicProc
         ENDIF
         IF roba->tip $ "VKX"
            @ PRow(), PCol() + 1 SAY tarifa->opp             PICTURE Picproc
         ELSE
            @ PRow(), PCol() + 1 SAY 0                        PICTURE Picproc
         ENDIF
         @ PRow(), PCol() + 1 SAY VPC                   PICTURE PicCDEM
      ENDIF

      IF gMpcPomoc == "D"
         @ PRow(), PCol() + 1  SAY roba->mpc       PICTURE         PICCDEM
      ENDIF

      @ PRow() + 1, 4 SAY IdTarifa
      @ PRow(), nCol1    SAY  Space( Len( PicProc ) )
      IF !lBezNC
         @ PRow(), PCol() + 1 SAY  Space( Len( PicProc ) )
         @ PRow(), PCol() + 1 SAY -Rabat / 100 * FCJ       PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY  Space( Len( PicProc ) )
         @ PRow(), PCol() + 1 SAY ( nprevoz + nbanktr + nspedtr + ncardaz + nZavTr )  PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY  Space( Len( PicProc ) )
      ENDIF

      IF !lNC
         IF !lBezNC
            @ PRow(), PCol() + 1 SAY nMarza               PICTURE PicCDEM
         ENDIF
         @ PRow(), PCol() + 1 SAY nUP / kolicina         PICTURE PicCDEM
      ENDIF

      IF lBezNC
         @ PRow() + 1, nCol1   SAY Space( Len( PicProc ) )
         IF !lNC
            @ PRow(), PCol() + 1  SAY nUP         PICTURE         PICDEM
            @ PRow(), PCol() + 1  SAY nUA         PICTURE         PICDEM
         ENDIF
      ELSE
         @ PRow() + 1, nCol1   SAY nU          PICTURE         PICDEM
         @ PRow(), PCol() + 1 SAY Space( Len( PicProc ) )
         @ PRow(), PCol() + 1  SAY nU2         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU + nU2     PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nu3 + nu4 + nu5 + nu6 + nu7    PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU8         PICTURE         PICDEM

         IF !lNC
            @ PRow(), PCol() + 1  SAY nU9         PICTURE         PICDEM
            @ PRow(), PCol() + 1  SAY nUP         PICTURE         PICDEM
            @ PRow(), PCol() + 1  SAY nUA         PICTURE         PICDEM
         ENDIF
      ENDIF

      IF gMpcPomoc == "D"
         @ PRow(), PCol() + 1  SAY nUM         PICTURE         PICDEM
      ENDIF

      SKIP
   ENDDO


   DokNovaStrana( 125, @nStr, 5 )
   ? m
   @ PRow() + 1, 0        SAY "Ukupno:"

   // stanex   nabavna cijena
   nTot8 := nTot + nTot2 + nTot3 + nTot4 + nTot5 + nTot6 + nTot7
   nTot9 := nTotA - nTot8 - nTotP   // utvrdi razliku izmedju nc i prodajne cijene

   IF lBezNC
      @ PRow(), nCol1     SAY Space( Len( PicProc ) )
      IF !lNC
         @ PRow(), PCol() + 1  SAY nTotP         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nTotA         PICTURE         PICDEM
      ENDIF
   ELSE
      @ PRow(), nCol1     SAY nTot          PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY Space( Len( PicProc ) )
      @ PRow(), PCol() + 1  SAY nTot2         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY ntot + nTot2         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY ntot3 + ntot4 + ntot5 + ntot6 + ntot7  PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot8         PICTURE         PICDEM

      IF !lNC
         @ PRow(), PCol() + 1  SAY nTot9         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nTotP         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nTotA         PICTURE         PICDEM
      ENDIF
   ENDIF

   IF gMpcPomoc == "D"
      @ PRow(), PCol() + 1  SAY nTotM         PICTURE         PICDEM
   ENDIF

   IF !lBezNC .AND. ( g10Porez == "D" .OR. gVarVP == "2" )
      ? m
      IF gVarVP == "1"
         ? "Ukalkulisani porez na ruc (PRUC):"
         @ PRow(), PCol() + 1 SAY nTotB PICT picdem
         @ PRow(), PCol() + 8 SAY "RUC - PRUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTot9, picdem ) )
         @ PRow(), PCol() + 1 SAY "-"
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTotB, picdem ) )
         @ PRow(), PCol() + 1 SAY "="
         @ PRow(), PCol() + 1 SAY nTot9 - nTotB PICT picdem
      ELSE
         ? "RUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTot9 - nTotB, picdem ) ); ?? ","
         @ PRow(), PCol() + 8 SAY "PRUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTotB, picdem ) ); ?? ","
         @ PRow(), PCol() + 8 SAY "RUC + PRUC ="
         @ PRow(), PCol() + 1 SAY AllTrim( Transform( nTot9, picdem ) )
      ENDIF
   ENDIF

   IF !lBezNC .AND. Round( ntot3 + ntot4 + ntot5 + ntot6 + ntot7, 2 ) <> 0
      DokNovaStrana( 125, @nStr, 10 )
      ?
      ?  m
      ?  "Troskovi (analiticki):"
      IF ntot3 <> 0
         ?  c10T1, ":"
         @ PRow(), 30 SAY  ntot3 PICT picdem
      ENDIF
      IF ntot4 <> 0
         ?  c10T2, ":"
         @ PRow(), 30 SAY  ntot4 PICT picdem
      ENDIF
      IF ntot5 <> 0
         ?  c10T3, ":"
         @ PRow(), 30 SAY  ntot5 PICT picdem
      ENDIF
      IF ntot6 <> 0
         ?  c10T4, ":"
         @ PRow(), 30 SAY  ntot6 PICT picdem
      ENDIF
      IF ntot7 <> 0
         ?  c10T5, ":"
         @ PRow(), 30 SAY  ntot7 PICT picdem
      ENDIF
      ? m
      ? "Ukupno troskova:"
      @ PRow(), 30 SAY  nTot3 + nTot4 + nTot5 + nTot6 + nTot7 PICT picdem
      ? m
   ENDIF

   RETURN .T.




/*! \fn StKalk10_4()
 *  \brief Stampa kalkulacije 10 - varijanta 3, za papir formata A3
 */

FUNCTION StKalk10_4()


   LOCAL nCol1 := nCol2 := 0, npom := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
   // iznosi troskova i marzi koji se izracunavaju u KTroskovi()

   nStr := 0
   cIdPartner := IdPartner; cBrFaktP := BrFaktP; dDatFaktP := DatFaktP

   cIdKonto := IdKonto; cIdKonto2 := IdKonto2

   P_COND2
   ?? Space( 180 ) + "Str." + Str( ++nStr, 3 )     // 220-40
   ? PadC( "PRIJEMNI LIST - KALKULACIJA BR." + cIdFirma + "-" + cIdVD + "-" + cBrDok + "     Datum:" + DToC( DatDok ), 242 )
   ? PadC( Replicate( "-", 64 ), 242 )
   SELECT PARTN; HSEEK cIdPartner
   ?
   ? Space( 104 ) + "DOBAVLJAC: " + cIdPartner + "-" + naz
   ? Space( 104 ) + "Racun broj: " + cBrFaktP + " od " + DToC( dDatFaktP )
   ?
   SELECT KONTO; HSEEK cIdKonto
   ?  "KONTO zaduzuje :", cIdKonto, "-", naz


   m := "--- ---------- ----------------------------------- ---" + " ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -----------"

   ? m

   ?U "*R.* Sifra    *                                   *Jed*" + "         F A K T U R A          *      R A B A T      *  CARINSKI TROSKOVI  *  OSTALI. ZAV. TROSK.*      M A R Z A      *POREZ NA PROM.PROIZV.*  IZNOS   * VELEPROD.*"
   ?U "*br* artikla  *     N A Z I V    A R T I K L A    *mj.*" + "--------------------------------*---------------------*---------------------*---------------------*---------------------*---------------------*  VELE-   *  CIJENA  *"
   ?U "*  *          *                                   *   *" + " Količina *  Cijena  *   Iznos  *    %     *   Iznos  *    %     *   Iznos  *    %     *   Iznos  *    %     *   Iznos  *    %     *   Iznos  * PRODAJE  *          *"

   ? m
   nTot := nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTotA := 0
   nTotB := 0
   nTotP := nTotQ := 0
   SELECT kalk_pripr

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

      vise_kalk_dok_u_pripremi( cIdd )
      RptSeekRT()
      KTroskovi()
      DokNovaStrana( 230, @nStr, 2 )


      IF gKalo == "1"
         SKol := Kolicina - GKolicina - GKolicin2
      ELSE
         SKol := Kolicina
      ENDIF

      nTot +=  ( nU := Round( FCj * Kolicina, gZaokr ) )
      IF gKalo == "1"
         nTot1 += ( nU1 := Round( FCj2 * ( GKolicina + GKolicin2 ), gZaokr ) )
      ELSE
         nTot1 += ( nU1 := Round( NC * ( GKolicina + GKolicin2 ), gZaokr ) )
      ENDIF
      nTot2 += ( nU2 := Round( -Rabat / 100 * FCJ * Kolicina, gZaokr ) )

      nTot3 += ( nU3 := Round( nPrevoz * SKol, gZaokr ) )
      nTot4 += ( nU4 := Round( nBankTr * SKol, gZaokr ) )
      nTot5 += ( nU5 := Round( nSpedTr * SKol, gZaokr ) )
      nTot6 += ( nU6 := Round( nCarDaz * SKol, gZaokr ) )
      nTot7 += ( nU7 := Round( nZavTr * SKol, gZaokr ) )

      nTot8 += ( nU8 := Round( NC *    ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
      nTot9 += ( nU9 := Round( nMarza * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
      IF !( roba->tip $ "VKX" )
         nUP := 0
      ELSE
         IF roba->tip = "X"
            nTotP += ( nUP := Round( mpcsapp / ( 1 + tarifa->opp / 100 ) * tarifa->opp / 100 * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
         ELSE
            nTotP += ( nUP := Round( vpc / ( 1 + tarifa->opp / 100 ) * tarifa->opp / 100 * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
         ENDIF
      ENDIF
      nTotA += ( nUA := Round( VPC * ( Kolicina - Gkolicina - GKolicin2 ), gZaokr ) )
      IF gVarVP == "1"
         nTotB += Round( nU9 * tarifa->vpp / 100,gZaokr ) // porez na razliku u cijeni
      ELSE
         PRIVATE cistaMar := Round( nU9 / ( 1 + tarifa->vpp / 100 ), gZaokr )
         nTotB += Round( cistaMar * tarifa->vpp / 100, gZaokr )  // porez na razliku u cijeni
      ENDIF

      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      ?? " " + IdRoba + " " + PadR( ROBA->naz, 35 ) + " " + ROBA->jmj
      IF roba->( FieldPos( "KATBR" ) ) <> 0
         ?? " KATBR:", roba->katbr
      ENDIF

      ?? " " + Transform( Kolicina, pickol ) + " " + Transform( FCJ, PicCDEM )
      ?? " " + Transform( nU, PICDEM ) + " " + Transform( rabat, PicProc )
      ?? " " + Transform( nU2, PICDEM ) + " " + Transform( 100 * nU6 / nU, PicProc )
      ?? " " + Transform( nU6, PICDEM ) + " " + Transform( 100 * ( nU3 + nU4 + nU5 + nU7 ) / nU, PicProc )
      ?? " " + Transform( ( nU3 + nU4 + nU5 + nU7 ), PICDEM ) + " " + Transform( 100 * nMarza / NC, PicProc )
      ?? " " + Transform( nU9, PICDEM )

      ?? " " + Transform( if( !( roba->tip $ "VKX" ), 0, tarifa->opp ), PicProc ) + " " + Transform( nUP, PICDEM )
      ?? " " + Transform( nUA, PICDEM ) + " " + Transform( VPC, PicCDEM )
      SKIP
   ENDDO

   DokNovaStrana( 230, @nStr, 3 )
   ? m
   ? "UKUPNO:" + Space( 70 ) + Transform( nTot, PICDEM )
   ?? Space( 12 ) + Transform( nTot2, PICDEM ) + Space( 12 ) + Transform( nTot6, PICDEM )
   ?? Space( 12 ) + Transform( ( nTot3 + nTot4 + nTot5 + nTot7 ), PICDEM ) + Space( 12 ) + Transform( nTot9, PICDEM )
   ?? Space( 12 ) + Transform( nTotP, PICDEM )
   ?? " " + Transform( nTotA, PICDEM )
   ? m
   ?

   RETURN .T.
